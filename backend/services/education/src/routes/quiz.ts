import { Router, Request, Response } from 'express';
import { DatabaseManager } from '../../../shared/src/database/manager';
import { ApiResponse, QuizQuestion, QuizConfig } from '../../../shared/src/types';
import { logger } from '../utils/logger';

const router = Router();
const db = DatabaseManager.getInstance();

// GET /quiz/:contentId - Get quiz questions for content
router.get('/:contentId', async (req: Request, res: Response) => {
  try {
    const { contentId } = req.params;
    const userId = req.headers['x-user-id'] as string;

    // Check if content exists and is quiz type
    const contentQuery = `
      SELECT 
        mc.*,
        em.title as module_title
      FROM module_content mc
      JOIN education_modules em ON mc.module_id = em.id
      WHERE mc.id = $1 AND mc.type = 'quiz' AND em.status = 'published'
    `;

    const contentResult = await db.query(contentQuery, [contentId]);
    
    if (contentResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Quiz content not found',
        timestamp: new Date().toISOString()
      });
    }

    const content = contentResult.rows[0];
    const quizConfig = content.metadata?.quizConfig || {};

    // Get quiz questions
    const questionsQuery = `
      SELECT 
        id,
        type,
        question,
        options,
        explanation,
        points,
        order_index
      FROM quiz_questions
      WHERE content_id = $1
      ORDER BY order_index
    `;

    const questionsResult = await db.query(questionsQuery, [contentId]);
    
    // Get user's previous attempts if any
    let attemptHistory = [];
    if (userId) {
      const attemptsQuery = `
        SELECT 
          attempt_number,
          score,
          max_score,
          passed,
          completed_at
        FROM quiz_attempts
        WHERE user_id = $1 AND content_id = $2
        ORDER BY attempt_number DESC
        LIMIT 5
      `;

      const attemptsResult = await db.query(attemptsQuery, [userId, contentId]);
      attemptHistory = attemptsResult.rows;
    }

    const questions = questionsResult.rows.map((q: any) => ({
      id: q.id,
      type: q.type,
      question: q.question,
      options: q.options || [],
      explanation: q.explanation,
      points: q.points,
      order: q.order_index
    }));

    const response: ApiResponse = {
      success: true,
      data: {
        contentId,
        moduleTitle: content.module_title,
        title: content.title,
        config: {
          passingScore: quizConfig.passingScore || 70,
          timeLimit: quizConfig.timeLimit,
          allowRetry: quizConfig.allowRetry !== false,
          maxAttempts: quizConfig.maxAttempts || 3
        },
        questions,
        maxScore: questions.reduce((sum: number, q: any) => sum + q.points, 0),
        attemptHistory,
        canAttempt: attemptHistory.length < (quizConfig.maxAttempts || 3)
      },
      timestamp: new Date().toISOString()
    };

    res.json(response);
  } catch (error) {
    logger.error('Error fetching quiz:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch quiz',
      timestamp: new Date().toISOString()
    });
  }
});

// POST /quiz/:contentId/questions - Add questions to quiz (admin only)
router.post('/:contentId/questions', async (req: Request, res: Response) => {
  try {
    const { contentId } = req.params;
    const { questions } = req.body;

    if (!Array.isArray(questions) || questions.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'Questions array is required',
        timestamp: new Date().toISOString()
      });
    }

    // Verify content exists and is quiz type
    const contentCheck = await db.query(
      "SELECT id FROM module_content WHERE id = $1 AND type = 'quiz'",
      [contentId]
    );

    if (contentCheck.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Quiz content not found',
        timestamp: new Date().toISOString()
      });
    }

    // Start transaction
    await db.query('BEGIN');

    try {
      // Clear existing questions
      await db.query('DELETE FROM quiz_questions WHERE content_id = $1', [contentId]);

      // Insert new questions
      for (let i = 0; i < questions.length; i++) {
        const question = questions[i];
        
        if (!question.question || !question.type || !question.correctAnswer) {
          throw new Error(`Question ${i + 1}: Missing required fields`);
        }

        await db.query(`
          INSERT INTO quiz_questions (
            content_id, type, question, options, correct_answer, 
            explanation, points, order_index
          )
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        `, [
          contentId,
          question.type,
          question.question,
          JSON.stringify(question.options || []),
          JSON.stringify(question.correctAnswer),
          question.explanation || '',
          question.points || 1,
          i + 1
        ]);
      }

      await db.query('COMMIT');

      res.status(201).json({
        success: true,
        message: `${questions.length} questions added successfully`,
        timestamp: new Date().toISOString()
      });
    } catch (error) {
      await db.query('ROLLBACK');
      throw error;
    }
  } catch (error: any) {
    logger.error('Error adding quiz questions:', error);
    res.status(500).json({
      success: false,
      error: error.message || 'Failed to add quiz questions',
      timestamp: new Date().toISOString()
    });
  }
});

// PUT /quiz/:contentId/config - Update quiz configuration
router.put('/:contentId/config', async (req: Request, res: Response) => {
  try {
    const { contentId } = req.params;
    const { config } = req.body;

    if (!config) {
      return res.status(400).json({
        success: false,
        error: 'Quiz config is required',
        timestamp: new Date().toISOString()
      });
    }

    // Update the metadata with new quiz config
    await db.query(`
      UPDATE module_content 
      SET 
        metadata = COALESCE(metadata, '{}'::jsonb) || jsonb_build_object('quizConfig', $2::jsonb),
        updated_at = NOW()
      WHERE id = $1 AND type = 'quiz'
    `, [contentId, JSON.stringify(config)]);

    res.json({
      success: true,
      message: 'Quiz configuration updated successfully',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    logger.error('Error updating quiz config:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update quiz configuration',
      timestamp: new Date().toISOString()
    });
  }
});

// GET /quiz/:contentId/statistics - Get quiz performance statistics
router.get('/:contentId/statistics', async (req: Request, res: Response) => {
  try {
    const { contentId } = req.params;
    const { period = '30' } = req.query;

    const statsQuery = `
      WITH quiz_stats AS (
        SELECT 
          COUNT(*) as total_attempts,
          COUNT(DISTINCT user_id) as unique_users,
          COUNT(*) FILTER (WHERE passed = true) as passed_attempts,
          AVG(score::decimal / max_score * 100) as average_score,
          AVG(time_spent) as average_time_spent,
          COUNT(*) FILTER (WHERE attempt_number > 1) as retry_attempts
        FROM quiz_attempts
        WHERE content_id = $1
          AND completed_at >= CURRENT_DATE - INTERVAL '${period} days'
      ),
      question_stats AS (
        SELECT 
          qq.question,
          qq.points,
          COUNT(qa.id) as answer_count,
          COUNT(*) FILTER (WHERE qa.is_correct = true) as correct_count,
          (COUNT(*) FILTER (WHERE qa.is_correct = true) * 100.0 / NULLIF(COUNT(qa.id), 0)) as correct_percentage
        FROM quiz_questions qq
        LEFT JOIN quiz_answers qa ON qq.id = qa.question_id
        LEFT JOIN quiz_attempts qat ON qa.attempt_id = qat.id
        WHERE qq.content_id = $1
          AND (qat.completed_at IS NULL OR qat.completed_at >= CURRENT_DATE - INTERVAL '${period} days')
        GROUP BY qq.id, qq.question, qq.points
        ORDER BY correct_percentage ASC
      )
      SELECT 
        qs.*,
        (
          SELECT json_agg(
            json_build_object(
              'question', question,
              'points', points,
              'answerCount', answer_count,
              'correctCount', correct_count,
              'correctPercentage', ROUND(correct_percentage, 2)
            )
          )
          FROM question_stats
        ) as question_performance
      FROM quiz_stats qs
    `;

    const result = await db.query(statsQuery, [contentId]);
    const stats = result.rows[0];

    // Calculate additional metrics
    const passRate = stats.total_attempts > 0 ? 
      (stats.passed_attempts / stats.total_attempts * 100) : 0;
    const retryRate = stats.unique_users > 0 ? 
      (stats.retry_attempts / stats.unique_users * 100) : 0;

    const response: ApiResponse = {
      success: true,
      data: {
        period: parseInt(period as string),
        totalAttempts: parseInt(stats.total_attempts) || 0,
        uniqueUsers: parseInt(stats.unique_users) || 0,
        passedAttempts: parseInt(stats.passed_attempts) || 0,
        passRate: parseFloat(passRate.toFixed(2)),
        averageScore: stats.average_score ? parseFloat(stats.average_score).toFixed(2) : '0.00',
        averageTimeSpent: parseInt(stats.average_time_spent) || 0,
        retryAttempts: parseInt(stats.retry_attempts) || 0,
        retryRate: parseFloat(retryRate.toFixed(2)),
        questionPerformance: stats.question_performance || []
      },
      timestamp: new Date().toISOString()
    };

    res.json(response);
  } catch (error) {
    logger.error('Error fetching quiz statistics:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch quiz statistics',
      timestamp: new Date().toISOString()
    });
  }
});

// DELETE /quiz/:contentId/questions/:questionId - Delete quiz question
router.delete('/:contentId/questions/:questionId', async (req: Request, res: Response) => {
  try {
    const { contentId, questionId } = req.params;

    // Check if question exists and belongs to the content
    const result = await db.query(`
      DELETE FROM quiz_questions 
      WHERE id = $1 AND content_id = $2
      RETURNING id
    `, [questionId, contentId]);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Question not found',
        timestamp: new Date().toISOString()
      });
    }

    // Reorder remaining questions
    await db.query(`
      UPDATE quiz_questions 
      SET order_index = subquery.new_order
      FROM (
        SELECT 
          id,
          ROW_NUMBER() OVER (ORDER BY order_index) as new_order
        FROM quiz_questions 
        WHERE content_id = $1
      ) as subquery
      WHERE quiz_questions.id = subquery.id
    `, [contentId]);

    res.json({
      success: true,
      message: 'Question deleted successfully',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    logger.error('Error deleting quiz question:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete question',
      timestamp: new Date().toISOString()
    });
  }
});

export { router as quizRouter };