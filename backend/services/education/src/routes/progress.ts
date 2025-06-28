import { Router, Request, Response } from 'express';
import { DatabaseManager } from '../../../shared/src/database/manager';
import { ApiResponse } from '../../../shared/src/types';
import { logger } from '../utils/logger';

const router = Router();
const db = DatabaseManager.getInstance();

// GET /progress - Get user's overall educational progress
router.get('/', async (req: Request, res: Response) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    
    if (!userId) {
      return res.status(401).json({
        success: false,
        error: 'User ID required',
        timestamp: new Date().toISOString()
      });
    }

    // Get overall progress statistics
    const progressQuery = `
      WITH module_stats AS (
        SELECT 
          COUNT(*) as total_modules,
          COUNT(*) FILTER (WHERE up.completed = true) as completed_modules,
          COALESCE(AVG(up.progress), 0) as overall_progress,
          COALESCE(SUM(up.time_spent), 0) as total_time_spent,
          COALESCE(SUM(em.xp_reward) FILTER (WHERE up.completed = true), 0) as total_xp_earned
        FROM education_modules em
        LEFT JOIN user_progress up ON em.id = up.module_id AND up.user_id = $1
        WHERE em.status = 'published'
      ),
      tier_progress AS (
        SELECT 
          CASE 
            WHEN completed_modules >= 15 THEN 4
            WHEN completed_modules >= 10 THEN 3
            WHEN completed_modules >= 5 THEN 2
            ELSE 1
          END as current_tier,
          CASE 
            WHEN completed_modules >= 15 THEN 'Kingdom'
            WHEN completed_modules >= 10 THEN 'City'
            WHEN completed_modules >= 5 THEN 'Town'
            ELSE 'Village'
          END as current_tier_name
        FROM module_stats
      ),
      recent_activity AS (
        SELECT 
          em.title as last_module,
          up.last_accessed
        FROM user_progress up
        JOIN education_modules em ON up.module_id = em.id
        WHERE up.user_id = $1
        ORDER BY up.last_accessed DESC
        LIMIT 1
      )
      SELECT 
        ms.*,
        tp.current_tier,
        tp.current_tier_name,
        ra.last_module,
        ra.last_accessed as last_activity
      FROM module_stats ms
      CROSS JOIN tier_progress tp
      LEFT JOIN recent_activity ra ON true
    `;

    const progressResult = await db.query(progressQuery, [userId]);
    const progress = progressResult.rows[0];

    // Get modules by category
    const categoryQuery = `
      SELECT 
        em.category,
        COUNT(*) as total,
        COUNT(*) FILTER (WHERE up.completed = true) as completed,
        COALESCE(AVG(up.progress), 0) as avg_progress
      FROM education_modules em
      LEFT JOIN user_progress up ON em.id = up.module_id AND up.user_id = $1
      WHERE em.status = 'published'
      GROUP BY em.category
      ORDER BY em.category
    `;

    const categoryResult = await db.query(categoryQuery, [userId]);
    const categoryProgress = categoryResult.rows;

    const response: ApiResponse = {
      success: true,
      data: {
        userId,
        overallProgress: parseFloat(progress.overall_progress),
        completedModules: parseInt(progress.completed_modules),
        totalModules: parseInt(progress.total_modules),
        currentTier: progress.current_tier,
        currentTierName: progress.current_tier_name,
        totalTimeSpent: parseInt(progress.total_time_spent),
        totalXpEarned: parseInt(progress.total_xp_earned),
        lastModule: progress.last_module,
        lastActivity: progress.last_activity,
        categoryProgress: categoryProgress.map((cat: any) => ({
          category: cat.category,
          total: parseInt(cat.total),
          completed: parseInt(cat.completed),
          progress: parseFloat(cat.avg_progress)
        })),
        nextTierRequirements: {
          tier: progress.current_tier + 1,
          name: progress.current_tier === 1 ? 'Town' : 
                progress.current_tier === 2 ? 'City' : 
                progress.current_tier === 3 ? 'Kingdom' : 'Master',
          requiredModules: (progress.current_tier + 1) * 5,
          currentModules: parseInt(progress.completed_modules),
          modulesNeeded: Math.max(0, (progress.current_tier + 1) * 5 - parseInt(progress.completed_modules))
        }
      },
      timestamp: new Date().toISOString()
    };

    res.json(response);
  } catch (error) {
    logger.error('Error fetching user progress:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch progress',
      timestamp: new Date().toISOString()
    });
  }
});

// GET /progress/modules - Get detailed module progress
router.get('/modules', async (req: Request, res: Response) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    const { category, tier } = req.query;
    
    let query = `
      SELECT 
        em.id,
        em.title,
        em.description,
        em.category,
        em.tier,
        em.difficulty,
        em.estimated_duration,
        em.xp_reward,
        COALESCE(up.progress, 0) as progress,
        COALESCE(up.completed, false) as completed,
        up.last_accessed,
        up.started_at,
        up.completed_at,
        up.time_spent,
        (
          SELECT COUNT(*)
          FROM quiz_attempts qa
          WHERE qa.user_id = $1 AND qa.module_id = em.id
        ) as quiz_attempts,
        (
          SELECT MAX(score::decimal / max_score * 100)
          FROM quiz_attempts qa
          WHERE qa.user_id = $1 AND qa.module_id = em.id
        ) as best_quiz_score
      FROM education_modules em
      LEFT JOIN user_progress up ON em.id = up.module_id AND up.user_id = $1
      WHERE em.status = 'published'
    `;

    const params = [userId];
    let paramCount = 1;

    if (category) {
      query += ` AND em.category = $${++paramCount}`;
      params.push(category as string);
    }

    if (tier) {
      query += ` AND em.tier = $${++paramCount}`;
      params.push(tier as string);
    }

    query += ` ORDER BY em.tier, em.created_at`;

    const result = await db.query(query, params);
    
    res.json({
      success: true,
      data: result.rows.map((row: any) => ({
        ...row,
        progress: parseFloat(row.progress),
        timeSpent: parseInt(row.time_spent) || 0,
        quizAttempts: parseInt(row.quiz_attempts) || 0,
        bestQuizScore: row.best_quiz_score ? parseFloat(row.best_quiz_score) : null
      })),
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    logger.error('Error fetching module progress:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch module progress',
      timestamp: new Date().toISOString()
    });
  }
});

// POST /progress/content/:contentId - Update content progress
router.post('/content/:contentId', async (req: Request, res: Response) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    const { contentId } = req.params;
    const { completed = false, timeSpent = 0 } = req.body;

    // Update content progress
    await db.query(`
      INSERT INTO content_progress (user_id, content_id, completed, time_spent, last_accessed)
      VALUES ($1, $2, $3, $4, NOW())
      ON CONFLICT (user_id, content_id)
      DO UPDATE SET 
        completed = $3,
        time_spent = content_progress.time_spent + $4,
        last_accessed = NOW()
    `, [userId, contentId, completed, timeSpent]);

    // Update module progress
    const moduleProgressQuery = `
      WITH content_stats AS (
        SELECT 
          mc.module_id,
          COUNT(*) as total_content,
          COUNT(*) FILTER (WHERE cp.completed = true) as completed_content,
          COALESCE(SUM(cp.time_spent), 0) as total_time_spent
        FROM module_content mc
        LEFT JOIN content_progress cp ON mc.id = cp.content_id AND cp.user_id = $1
        WHERE mc.id = $2
        GROUP BY mc.module_id
      )
      UPDATE user_progress 
      SET 
        progress = CASE 
          WHEN cs.total_content > 0 
          THEN (cs.completed_content * 100.0 / cs.total_content)::integer
          ELSE 0
        END,
        completed = (cs.completed_content = cs.total_content AND cs.total_content > 0),
        time_spent = cs.total_time_spent,
        last_accessed = NOW(),
        completed_at = CASE 
          WHEN cs.completed_content = cs.total_content AND cs.total_content > 0 
          THEN NOW()
          ELSE completed_at
        END
      FROM content_stats cs
      WHERE user_progress.user_id = $1 AND user_progress.module_id = cs.module_id
    `;

    await db.query(moduleProgressQuery, [userId, contentId]);

    res.json({
      success: true,
      message: 'Progress updated successfully',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    logger.error('Error updating content progress:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update progress',
      timestamp: new Date().toISOString()
    });
  }
});

// POST /progress/quiz - Submit quiz results
router.post('/quiz', async (req: Request, res: Response) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    const { moduleId, contentId, answers, timeSpent = 0 } = req.body;

    if (!moduleId || !contentId || !answers) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: moduleId, contentId, answers',
        timestamp: new Date().toISOString()
      });
    }

    // Get quiz questions
    const questionsQuery = `
      SELECT id, correct_answer, points
      FROM quiz_questions 
      WHERE content_id = $1
      ORDER BY order_index
    `;
    
    const questionsResult = await db.query(questionsQuery, [contentId]);
    const questions = questionsResult.rows;

    if (questions.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Quiz questions not found',
        timestamp: new Date().toISOString()
      });
    }

    // Calculate score
    let totalScore = 0;
    let maxScore = 0;
    const gradedAnswers = [];

    for (const question of questions) {
      maxScore += question.points;
      const userAnswer = answers[question.id];
      const correctAnswer = question.correct_answer;
      
      let isCorrect = false;
      if (Array.isArray(correctAnswer)) {
        // Multiple correct answers
        isCorrect = Array.isArray(userAnswer) && 
          correctAnswer.every(ans => userAnswer.includes(ans)) &&
          userAnswer.every(ans => correctAnswer.includes(ans));
      } else {
        // Single correct answer
        isCorrect = userAnswer === correctAnswer;
      }

      const points = isCorrect ? question.points : 0;
      totalScore += points;

      gradedAnswers.push({
        questionId: question.id,
        answer: userAnswer,
        isCorrect,
        points
      });
    }

    // Get quiz config to determine passing score
    const configQuery = `
      SELECT metadata->'quizConfig' as quiz_config
      FROM module_content
      WHERE id = $1
    `;
    
    const configResult = await db.query(configQuery, [contentId]);
    const quizConfig = configResult.rows[0]?.quiz_config || {};
    const passingScore = quizConfig.passingScore || 70;
    const passed = (totalScore / maxScore * 100) >= passingScore;

    // Get current attempt number
    const attemptQuery = `
      SELECT COALESCE(MAX(attempt_number), 0) + 1 as next_attempt
      FROM quiz_attempts
      WHERE user_id = $1 AND content_id = $2
    `;
    
    const attemptResult = await db.query(attemptQuery, [userId, contentId]);
    const attemptNumber = attemptResult.rows[0].next_attempt;

    // Start transaction
    await db.query('BEGIN');

    try {
      // Record quiz attempt
      const attemptInsertQuery = `
        INSERT INTO quiz_attempts (
          user_id, module_id, content_id, attempt_number, 
          score, max_score, passed, completed_at, time_spent
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), $8)
        RETURNING id
      `;

      const attemptInsertResult = await db.query(attemptInsertQuery, [
        userId, moduleId, contentId, attemptNumber,
        totalScore, maxScore, passed, timeSpent
      ]);

      const attemptId = attemptInsertResult.rows[0].id;

      // Record individual answers
      for (const answer of gradedAnswers) {
        await db.query(`
          INSERT INTO quiz_answers (attempt_id, question_id, answer, is_correct, points)
          VALUES ($1, $2, $3, $4, $5)
        `, [
          attemptId,
          answer.questionId,
          JSON.stringify(answer.answer),
          answer.isCorrect,
          answer.points
        ]);
      }

      // If passed, mark content as completed
      if (passed) {
        await db.query(`
          INSERT INTO content_progress (user_id, content_id, completed, time_spent, last_accessed)
          VALUES ($1, $2, true, $3, NOW())
          ON CONFLICT (user_id, content_id)
          DO UPDATE SET 
            completed = true,
            time_spent = content_progress.time_spent + $3,
            last_accessed = NOW()
        `, [userId, contentId, timeSpent]);
      }

      await db.query('COMMIT');

      const response: ApiResponse = {
        success: true,
        data: {
          attemptId,
          attemptNumber,
          score: totalScore,
          maxScore,
          percentage: (totalScore / maxScore * 100).toFixed(1),
          passed,
          passingScore,
          answers: gradedAnswers,
          timeSpent
        },
        timestamp: new Date().toISOString()
      };

      res.json(response);
    } catch (error) {
      await db.query('ROLLBACK');
      throw error;
    }
  } catch (error) {
    logger.error('Error submitting quiz:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to submit quiz',
      timestamp: new Date().toISOString()
    });
  }
});

// GET /progress/quiz/:moduleId - Get quiz history for a module
router.get('/quiz/:moduleId', async (req: Request, res: Response) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    const { moduleId } = req.params;

    const query = `
      SELECT 
        qa.*,
        mc.title as content_title,
        (
          SELECT json_agg(
            json_build_object(
              'questionId', qan.question_id,
              'answer', qan.answer,
              'isCorrect', qan.is_correct,
              'points', qan.points
            )
          )
          FROM quiz_answers qan
          WHERE qan.attempt_id = qa.id
        ) as answers
      FROM quiz_attempts qa
      JOIN module_content mc ON qa.content_id = mc.id
      WHERE qa.user_id = $1 AND qa.module_id = $2
      ORDER BY qa.completed_at DESC
    `;

    const result = await db.query(query, [userId, moduleId]);
    
    res.json({
      success: true,
      data: result.rows.map((row: any) => ({
        ...row,
        percentage: (row.score / row.max_score * 100).toFixed(1),
        answers: row.answers || []
      })),
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    logger.error('Error fetching quiz history:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch quiz history',
      timestamp: new Date().toISOString()
    });
  }
});

export { router as progressRouter };