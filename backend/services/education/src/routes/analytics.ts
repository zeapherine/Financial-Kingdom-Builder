import { Router, Request, Response } from 'express';
import { DatabaseManager } from '../../../shared/src/database/manager';
import { ApiResponse } from '../../../shared/src/types';
import { logger } from '../utils/logger';

const router = Router();
const db = DatabaseManager.getInstance();

// GET /analytics/overview - Get overall education analytics
router.get('/overview', async (req: Request, res: Response) => {
  try {
    const { period = '30' } = req.query;

    const overviewQuery = `
      WITH module_stats AS (
        SELECT 
          COUNT(*) as total_modules,
          COUNT(*) FILTER (WHERE status = 'published') as published_modules,
          COUNT(*) FILTER (WHERE status = 'draft') as draft_modules,
          AVG(completion_rate) as avg_completion_rate,
          AVG(average_score) as avg_score
        FROM education_modules
      ),
      user_stats AS (
        SELECT 
          COUNT(DISTINCT user_id) as active_users,
          COUNT(*) as total_progress_records,
          COUNT(*) FILTER (WHERE completed = true) as completed_modules,
          AVG(time_spent) as avg_time_spent
        FROM user_progress
        WHERE last_accessed >= CURRENT_DATE - INTERVAL '${period} days'
      ),
      quiz_stats AS (
        SELECT 
          COUNT(*) as total_quiz_attempts,
          COUNT(*) FILTER (WHERE passed = true) as passed_attempts,
          AVG(score::decimal / max_score * 100) as avg_quiz_score
        FROM quiz_attempts
        WHERE completed_at >= CURRENT_DATE - INTERVAL '${period} days'
      ),
      category_performance AS (
        SELECT 
          em.category,
          COUNT(DISTINCT up.user_id) as unique_users,
          AVG(up.progress) as avg_progress,
          COUNT(*) FILTER (WHERE up.completed = true) as completions
        FROM education_modules em
        LEFT JOIN user_progress up ON em.id = up.module_id
          AND up.last_accessed >= CURRENT_DATE - INTERVAL '${period} days'
        WHERE em.status = 'published'
        GROUP BY em.category
      )
      SELECT 
        ms.*,
        us.*,
        qs.*,
        (
          SELECT json_agg(
            json_build_object(
              'category', category,
              'uniqueUsers', unique_users,
              'avgProgress', ROUND(avg_progress, 2),
              'completions', completions
            )
          )
          FROM category_performance
        ) as category_performance
      FROM module_stats ms
      CROSS JOIN user_stats us
      CROSS JOIN quiz_stats qs
    `;

    const result = await db.query(overviewQuery);
    const stats = result.rows[0];

    // Get daily activity for the period
    const dailyActivityQuery = `
      SELECT 
        date,
        total_views,
        total_completions,
        unique_users,
        average_score
      FROM module_analytics_daily
      WHERE date >= CURRENT_DATE - INTERVAL '${period} days'
      ORDER BY date
    `;

    const dailyResult = await db.query(dailyActivityQuery);

    const response: ApiResponse = {
      success: true,
      data: {
        period: parseInt(period as string),
        modules: {
          total: parseInt(stats.total_modules) || 0,
          published: parseInt(stats.published_modules) || 0,
          draft: parseInt(stats.draft_modules) || 0,
          avgCompletionRate: parseFloat(stats.avg_completion_rate) || 0,
          avgScore: parseFloat(stats.avg_score) || 0
        },
        users: {
          active: parseInt(stats.active_users) || 0,
          totalProgressRecords: parseInt(stats.total_progress_records) || 0,
          completedModules: parseInt(stats.completed_modules) || 0,
          avgTimeSpent: parseFloat(stats.avg_time_spent) || 0
        },
        quizzes: {
          totalAttempts: parseInt(stats.total_quiz_attempts) || 0,
          passedAttempts: parseInt(stats.passed_attempts) || 0,
          passRate: stats.total_quiz_attempts > 0 ? 
            (stats.passed_attempts / stats.total_quiz_attempts * 100).toFixed(2) : '0.00',
          avgScore: parseFloat(stats.avg_quiz_score) || 0
        },
        categoryPerformance: stats.category_performance || [],
        dailyActivity: dailyResult.rows
      },
      timestamp: new Date().toISOString()
    };

    res.json(response);
  } catch (error) {
    logger.error('Error fetching analytics overview:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch analytics',
      timestamp: new Date().toISOString()
    });
  }
});

// GET /analytics/modules/:moduleId - Get detailed module analytics
router.get('/modules/:moduleId', async (req: Request, res: Response) => {
  try {
    const { moduleId } = req.params;
    const { period = '30' } = req.query;

    const moduleAnalyticsQuery = `
      WITH module_info AS (
        SELECT 
          em.*,
          COUNT(up.user_id) as total_users,
          COUNT(*) FILTER (WHERE up.completed = true) as completed_users,
          AVG(up.progress) as avg_progress,
          AVG(up.time_spent) as avg_time_spent
        FROM education_modules em
        LEFT JOIN user_progress up ON em.id = up.module_id
          AND up.last_accessed >= CURRENT_DATE - INTERVAL '${period} days'
        WHERE em.id = $1
        GROUP BY em.id
      ),
      content_analytics AS (
        SELECT 
          mc.id,
          mc.title,
          mc.type,
          COUNT(cp.user_id) as user_count,
          COUNT(*) FILTER (WHERE cp.completed = true) as completion_count,
          AVG(cp.time_spent) as avg_time_spent,
          ca.drop_off_rate,
          ca.average_time_before_drop_off
        FROM module_content mc
        LEFT JOIN content_progress cp ON mc.id = cp.content_id
          AND cp.last_accessed >= CURRENT_DATE - INTERVAL '${period} days'
        LEFT JOIN content_analytics ca ON mc.id = ca.content_id
        WHERE mc.module_id = $1
        GROUP BY mc.id, mc.title, mc.type, ca.drop_off_rate, ca.average_time_before_drop_off
        ORDER BY mc.order_index
      ),
      quiz_performance AS (
        SELECT 
          mc.id as content_id,
          mc.title,
          COUNT(qa.id) as total_attempts,
          COUNT(*) FILTER (WHERE qa.passed = true) as passed_attempts,
          AVG(qa.score::decimal / qa.max_score * 100) as avg_score,
          AVG(qa.attempt_number) as avg_attempts_per_user
        FROM module_content mc
        LEFT JOIN quiz_attempts qa ON mc.id = qa.content_id
          AND qa.completed_at >= CURRENT_DATE - INTERVAL '${period} days'
        WHERE mc.module_id = $1 AND mc.type = 'quiz'
        GROUP BY mc.id, mc.title
      )
      SELECT 
        mi.*,
        (
          SELECT json_agg(
            json_build_object(
              'contentId', id,
              'title', title,
              'type', type,
              'userCount', user_count,
              'completionCount', completion_count,
              'completionRate', CASE WHEN user_count > 0 THEN (completion_count * 100.0 / user_count) ELSE 0 END,
              'avgTimeSpent', ROUND(avg_time_spent, 2),
              'dropOffRate', ROUND(drop_off_rate, 2),
              'avgTimeBeforeDropOff', average_time_before_drop_off
            ) ORDER BY mc.order_index
          )
          FROM content_analytics ca
          JOIN module_content mc ON ca.id = mc.id
        ) as content_performance,
        (
          SELECT json_agg(
            json_build_object(
              'contentId', content_id,
              'title', title,
              'totalAttempts', total_attempts,
              'passedAttempts', passed_attempts,
              'passRate', CASE WHEN total_attempts > 0 THEN (passed_attempts * 100.0 / total_attempts) ELSE 0 END,
              'avgScore', ROUND(avg_score, 2),
              'avgAttemptsPerUser', ROUND(avg_attempts_per_user, 2)
            )
          )
          FROM quiz_performance
        ) as quiz_performance
      FROM module_info mi
    `;

    const result = await db.query(moduleAnalyticsQuery, [moduleId]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Module not found',
        timestamp: new Date().toISOString()
      });
    }

    const moduleData = result.rows[0];

    // Get daily activity for this module
    const dailyQuery = `
      SELECT 
        date,
        total_views,
        total_completions,
        unique_users,
        average_score
      FROM module_analytics_daily
      WHERE module_id = $1 AND date >= CURRENT_DATE - INTERVAL '${period} days'
      ORDER BY date
    `;

    const dailyResult = await db.query(dailyQuery, [moduleId]);

    const response: ApiResponse = {
      success: true,
      data: {
        moduleId,
        title: moduleData.title,
        category: moduleData.category,
        tier: moduleData.tier,
        period: parseInt(period as string),
        overview: {
          totalUsers: parseInt(moduleData.total_users) || 0,
          completedUsers: parseInt(moduleData.completed_users) || 0,
          completionRate: moduleData.total_users > 0 ? 
            (moduleData.completed_users / moduleData.total_users * 100).toFixed(2) : '0.00',
          avgProgress: parseFloat(moduleData.avg_progress) || 0,
          avgTimeSpent: parseFloat(moduleData.avg_time_spent) || 0
        },
        contentPerformance: moduleData.content_performance || [],
        quizPerformance: moduleData.quiz_performance || [],
        dailyActivity: dailyResult.rows
      },
      timestamp: new Date().toISOString()
    };

    res.json(response);
  } catch (error) {
    logger.error('Error fetching module analytics:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch module analytics',
      timestamp: new Date().toISOString()
    });
  }
});

// GET /analytics/users/:userId - Get user learning analytics
router.get('/users/:userId', async (req: Request, res: Response) => {
  try {
    const { userId } = req.params;
    const { period = '30' } = req.query;

    const userAnalyticsQuery = `
      WITH user_overview AS (
        SELECT 
          COUNT(*) as modules_started,
          COUNT(*) FILTER (WHERE completed = true) as modules_completed,
          AVG(progress) as avg_progress,
          SUM(time_spent) as total_time_spent,
          MAX(last_accessed) as last_activity
        FROM user_progress
        WHERE user_id = $1
          AND last_accessed >= CURRENT_DATE - INTERVAL '${period} days'
      ),
      quiz_performance AS (
        SELECT 
          COUNT(*) as total_quiz_attempts,
          COUNT(*) FILTER (WHERE passed = true) as passed_quizzes,
          AVG(score::decimal / max_score * 100) as avg_quiz_score,
          COUNT(DISTINCT module_id) as quizzes_taken
        FROM quiz_attempts
        WHERE user_id = $1
          AND completed_at >= CURRENT_DATE - INTERVAL '${period} days'
      ),
      category_progress AS (
        SELECT 
          em.category,
          COUNT(*) as modules_in_category,
          COUNT(*) FILTER (WHERE up.completed = true) as completed_in_category,
          AVG(up.progress) as avg_progress_in_category
        FROM education_modules em
        LEFT JOIN user_progress up ON em.id = up.module_id AND up.user_id = $1
        WHERE em.status = 'published'
        GROUP BY em.category
      ),
      recent_activity AS (
        SELECT 
          em.title,
          em.category,
          up.progress,
          up.completed,
          up.last_accessed
        FROM user_progress up
        JOIN education_modules em ON up.module_id = em.id
        WHERE up.user_id = $1
        ORDER BY up.last_accessed DESC
        LIMIT 10
      )
      SELECT 
        uo.*,
        qp.*,
        (
          SELECT json_agg(
            json_build_object(
              'category', category,
              'modulesInCategory', modules_in_category,
              'completedInCategory', completed_in_category,
              'progressInCategory', ROUND(avg_progress_in_category, 2)
            )
          )
          FROM category_progress
        ) as category_progress,
        (
          SELECT json_agg(
            json_build_object(
              'title', title,
              'category', category,
              'progress', progress,
              'completed', completed,
              'lastAccessed', last_accessed
            )
          )
          FROM recent_activity
        ) as recent_activity
      FROM user_overview uo
      CROSS JOIN quiz_performance qp
    `;

    const result = await db.query(userAnalyticsQuery, [userId]);
    const userData = result.rows[0];

    // Calculate learning streak
    const streakQuery = `
      WITH daily_activity AS (
        SELECT 
          DATE(last_accessed) as activity_date,
          COUNT(*) as modules_accessed
        FROM user_progress
        WHERE user_id = $1
          AND last_accessed >= CURRENT_DATE - INTERVAL '30 days'
        GROUP BY DATE(last_accessed)
        ORDER BY activity_date DESC
      ),
      streak_calculation AS (
        SELECT 
          activity_date,
          ROW_NUMBER() OVER (ORDER BY activity_date DESC) as day_number,
          activity_date - (ROW_NUMBER() OVER (ORDER BY activity_date DESC) - 1) as streak_group
        FROM daily_activity
        WHERE activity_date <= CURRENT_DATE
      )
      SELECT COUNT(*) as current_streak
      FROM streak_calculation
      WHERE streak_group = (
        SELECT streak_group 
        FROM streak_calculation 
        WHERE activity_date = CURRENT_DATE
        LIMIT 1
      )
    `;

    const streakResult = await db.query(streakQuery, [userId]);
    const currentStreak = streakResult.rows[0]?.current_streak || 0;

    const response: ApiResponse = {
      success: true,
      data: {
        userId,
        period: parseInt(period as string),
        overview: {
          modulesStarted: parseInt(userData.modules_started) || 0,
          modulesCompleted: parseInt(userData.modules_completed) || 0,
          avgProgress: parseFloat(userData.avg_progress) || 0,
          totalTimeSpent: parseInt(userData.total_time_spent) || 0,
          lastActivity: userData.last_activity,
          currentStreak: parseInt(currentStreak)
        },
        quizPerformance: {
          totalAttempts: parseInt(userData.total_quiz_attempts) || 0,
          passedQuizzes: parseInt(userData.passed_quizzes) || 0,
          passRate: userData.total_quiz_attempts > 0 ? 
            (userData.passed_quizzes / userData.total_quiz_attempts * 100).toFixed(2) : '0.00',
          avgScore: parseFloat(userData.avg_quiz_score) || 0,
          quizzesTaken: parseInt(userData.quizzes_taken) || 0
        },
        categoryProgress: userData.category_progress || [],
        recentActivity: userData.recent_activity || []
      },
      timestamp: new Date().toISOString()
    };

    res.json(response);
  } catch (error) {
    logger.error('Error fetching user analytics:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch user analytics',
      timestamp: new Date().toISOString()
    });
  }
});

// POST /analytics/refresh - Refresh analytics data
router.post('/refresh', async (req: Request, res: Response) => {
  try {
    const { moduleIds } = req.body;

    if (moduleIds && Array.isArray(moduleIds)) {
      // Refresh specific modules
      for (const moduleId of moduleIds) {
        await db.query('SELECT update_module_analytics($1)', [moduleId]);
      }
    } else {
      // Refresh all modules
      const modulesResult = await db.query(
        "SELECT id FROM education_modules WHERE status = 'published'"
      );
      
      for (const module of modulesResult.rows) {
        await db.query('SELECT update_module_analytics($1)', [module.id]);
      }
    }

    res.json({
      success: true,
      message: 'Analytics refreshed successfully',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    logger.error('Error refreshing analytics:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to refresh analytics',
      timestamp: new Date().toISOString()
    });
  }
});

export { router as analyticsRouter };