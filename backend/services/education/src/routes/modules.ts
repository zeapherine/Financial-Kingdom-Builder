import { Router, Request, Response } from 'express';
import { DatabaseManager } from '../../../shared/src/database/manager';
import { EducationModule, ModuleContent, ApiResponse, PaginatedResponse } from '../../../shared/src/types';
import { logger } from '../utils/logger';
import { AppError } from '../utils/app-error';

const router = Router();
const db = DatabaseManager.getInstance();

// GET /modules - Get all available educational modules with filtering and pagination
router.get('/', async (req: Request, res: Response) => {
  try {
    const {
      category,
      tier,
      difficulty,
      status = 'published',
      page = '1',
      limit = '20',
      search,
      tags
    } = req.query;

    const offset = (parseInt(page as string) - 1) * parseInt(limit as string);
    let query = `
      SELECT 
        em.*,
        COUNT(*) OVER() as total_count,
        COALESCE(
          JSON_AGG(
            JSON_BUILD_OBJECT(
              'id', mc.id,
              'type', mc.type,
              'title', mc.title,
              'content', mc.content,
              'duration', mc.duration,
              'order', mc.order_index,
              'metadata', mc.metadata
            ) ORDER BY mc.order_index
          ) FILTER (WHERE mc.id IS NOT NULL),
          '[]'
        ) as content
      FROM education_modules em
      LEFT JOIN module_content mc ON em.id = mc.module_id
      WHERE 1=1
    `;

    const params: any[] = [];
    let paramCount = 0;

    if (category) {
      query += ` AND em.category = $${++paramCount}`;
      params.push(category);
    }

    if (tier) {
      query += ` AND em.tier = $${++paramCount}`;
      params.push(parseInt(tier as string));
    }

    if (difficulty) {
      query += ` AND em.difficulty = $${++paramCount}`;
      params.push(difficulty);
    }

    if (status) {
      query += ` AND em.status = $${++paramCount}`;
      params.push(status);
    }

    if (search) {
      query += ` AND (em.title ILIKE $${++paramCount} OR em.description ILIKE $${++paramCount})`;
      params.push(`%${search}%`, `%${search}%`);
    }

    if (tags) {
      const tagArray = Array.isArray(tags) ? tags : [tags];
      query += ` AND em.tags ?| $${++paramCount}`;
      params.push(tagArray);
    }

    query += `
      GROUP BY em.id
      ORDER BY em.tier ASC, em.created_at DESC
      LIMIT $${++paramCount} OFFSET $${++paramCount}
    `;
    
    params.push(parseInt(limit as string), offset);

    const result = await db.query(query, params);
    const modules = result.rows.map((row: any) => ({
      ...row,
      content: row.content || [],
      prerequisites: row.prerequisites || [],
      tags: row.tags || [],
      analytics: {
        totalViews: row.total_views,
        completionRate: row.completion_rate,
        averageScore: row.average_score,
        averageTimeSpent: row.average_time_spent,
        retryRate: row.retry_rate,
        lastUpdated: row.analytics_updated_at
      }
    }));

    const totalCount = result.rows.length > 0 ? parseInt(result.rows[0].total_count) : 0;
    const totalPages = Math.ceil(totalCount / parseInt(limit as string));

    const response: PaginatedResponse<EducationModule> = {
      success: true,
      data: modules,
      pagination: {
        page: parseInt(page as string),
        limit: parseInt(limit as string),
        total: totalCount,
        pages: totalPages
      },
      timestamp: new Date().toISOString()
    };

    res.json(response);
  } catch (error) {
    logger.error('Error fetching modules:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch modules',
      timestamp: new Date().toISOString()
    });
  }
});

// GET /modules/:id - Get specific module with full content
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const userId = req.headers['x-user-id'] as string;

    // Get module with content
    const moduleQuery = `
      SELECT 
        em.*,
        COALESCE(
          JSON_AGG(
            JSON_BUILD_OBJECT(
              'id', mc.id,
              'type', mc.type,
              'title', mc.title,
              'content', mc.content,
              'duration', mc.duration,
              'order', mc.order_index,
              'metadata', mc.metadata
            ) ORDER BY mc.order_index
          ) FILTER (WHERE mc.id IS NOT NULL),
          '[]'
        ) as content
      FROM education_modules em
      LEFT JOIN module_content mc ON em.id = mc.module_id
      WHERE em.id = $1 AND em.status = 'published'
      GROUP BY em.id
    `;

    const moduleResult = await db.query(moduleQuery, [id]);
    
    if (moduleResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Module not found',
        timestamp: new Date().toISOString()
      });
    }

    const module = moduleResult.rows[0];

    // Get user progress if userId provided
    let userProgress = null;
    if (userId) {
      const progressQuery = `
        SELECT 
          up.*,
          COALESCE(
            JSON_AGG(
              JSON_BUILD_OBJECT(
                'contentId', cp.content_id,
                'completed', cp.completed,
                'timeSpent', cp.time_spent,
                'lastAccessed', cp.last_accessed
              )
            ) FILTER (WHERE cp.content_id IS NOT NULL),
            '[]'
          ) as content_progress
        FROM user_progress up
        LEFT JOIN content_progress cp ON up.user_id = cp.user_id 
          AND cp.content_id IN (
            SELECT id FROM module_content WHERE module_id = $1
          )
        WHERE up.user_id = $2 AND up.module_id = $1
        GROUP BY up.id
      `;
      
      const progressResult = await db.query(progressQuery, [id, userId]);
      userProgress = progressResult.rows[0] || null;

      // Track module view
      await db.query(`
        INSERT INTO user_progress (user_id, module_id, progress, started_at, last_accessed)
        VALUES ($1, $2, 0, NOW(), NOW())
        ON CONFLICT (user_id, module_id) 
        DO UPDATE SET last_accessed = NOW()
      `, [userId, id]);
    }

    const response: ApiResponse<EducationModule & { userProgress?: any }> = {
      success: true,
      data: {
        ...module,
        content: module.content || [],
        prerequisites: module.prerequisites || [],
        tags: module.tags || [],
        userProgress,
        analytics: {
          totalViews: module.total_views,
          completionRate: module.completion_rate,
          averageScore: module.average_score,
          averageTimeSpent: module.average_time_spent,
          retryRate: module.retry_rate,
          lastUpdated: module.analytics_updated_at
        }
      },
      timestamp: new Date().toISOString()
    };

    res.json(response);
  } catch (error) {
    logger.error('Error fetching module:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch module',
      timestamp: new Date().toISOString()
    });
  }
});

// POST /modules - Create new educational module (admin only)
router.post('/', async (req: Request, res: Response) => {
  try {
    const userId = req.headers['x-user-id'] as string;
    const {
      title,
      description,
      tier,
      category,
      difficulty,
      estimatedDuration,
      xpReward,
      prerequisites = [],
      content = [],
      tags = [],
      scheduledAt
    } = req.body;

    // Validate required fields
    if (!title || !description || !tier || !category || !difficulty) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields',
        timestamp: new Date().toISOString()
      });
    }

    // Start transaction
    await db.query('BEGIN');

    try {
      // Create module
      const moduleQuery = `
        INSERT INTO education_modules (
          title, description, tier, category, difficulty, 
          estimated_duration, xp_reward, prerequisites, 
          created_by, tags, scheduled_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
        RETURNING *
      `;

      const moduleResult = await db.query(moduleQuery, [
        title, description, tier, category, difficulty,
        estimatedDuration, xpReward, JSON.stringify(prerequisites),
        userId, JSON.stringify(tags), scheduledAt
      ]);

      const module = moduleResult.rows[0];

      // Create content items
      if (content.length > 0) {
        for (let i = 0; i < content.length; i++) {
          const contentItem = content[i];
          await db.query(`
            INSERT INTO module_content (
              module_id, type, title, content, duration, order_index, metadata
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7)
          `, [
            module.id,
            contentItem.type,
            contentItem.title,
            contentItem.content,
            contentItem.duration,
            i + 1,
            JSON.stringify(contentItem.metadata || {})
          ]);
        }
      }

      await db.query('COMMIT');

      const response: ApiResponse<EducationModule> = {
        success: true,
        data: module,
        message: 'Module created successfully',
        timestamp: new Date().toISOString()
      };

      res.status(201).json(response);
    } catch (error) {
      await db.query('ROLLBACK');
      throw error;
    }
  } catch (error) {
    logger.error('Error creating module:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create module',
      timestamp: new Date().toISOString()
    });
  }
});

// PUT /modules/:id - Update module
router.put('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const userId = req.headers['x-user-id'] as string;
    const updates = req.body;

    // Create new version before updating
    const versionQuery = `
      INSERT INTO content_versions (module_id, version, changes, created_by, content_snapshot)
      SELECT 
        id,
        version + 1,
        $2::jsonb,
        $3,
        json_build_object(
          'module', row_to_json(em),
          'content', (
            SELECT json_agg(mc ORDER BY mc.order_index)
            FROM module_content mc WHERE mc.module_id = em.id
          )
        )
      FROM education_modules em
      WHERE id = $1
      RETURNING version
    `;

    const versionResult = await db.query(versionQuery, [
      id,
      JSON.stringify(updates.changes || ['Updated module']),
      userId
    ]);

    // Update module
    const updateFields = [];
    const updateValues = [];
    let paramCount = 0;

    Object.keys(updates).forEach(key => {
      if (key !== 'content' && key !== 'changes') {
        updateFields.push(`${key} = $${++paramCount}`);
        updateValues.push(updates[key]);
      }
    });

    if (updateFields.length > 0) {
      updateFields.push(`updated_at = NOW()`);
      updateFields.push(`version = $${++paramCount}`);
      updateValues.push(versionResult.rows[0].version);
      
      const updateQuery = `
        UPDATE education_modules 
        SET ${updateFields.join(', ')}
        WHERE id = $${++paramCount}
        RETURNING *
      `;
      
      updateValues.push(id);
      await db.query(updateQuery, updateValues);
    }

    res.json({
      success: true,
      message: 'Module updated successfully',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    logger.error('Error updating module:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update module',
      timestamp: new Date().toISOString()
    });
  }
});

// POST /modules/:id/publish - Publish module
router.post('/:id/publish', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    await db.query(`
      UPDATE education_modules 
      SET status = 'published', published_at = NOW(), updated_at = NOW()
      WHERE id = $1 AND status = 'draft'
    `, [id]);

    res.json({
      success: true,
      message: 'Module published successfully',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    logger.error('Error publishing module:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to publish module',
      timestamp: new Date().toISOString()
    });
  }
});

// DELETE /modules/:id - Archive module
router.delete('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    await db.query(`
      UPDATE education_modules 
      SET status = 'archived', updated_at = NOW()
      WHERE id = $1
    `, [id]);

    res.json({
      success: true,
      message: 'Module archived successfully',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    logger.error('Error archiving module:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to archive module',
      timestamp: new Date().toISOString()
    });
  }
});

// GET /modules/:id/analytics - Get module analytics
router.get('/:id/analytics', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { period = '30' } = req.query;

    const analyticsQuery = `
      SELECT 
        em.total_views,
        em.completion_rate,
        em.average_score,
        em.average_time_spent,
        em.retry_rate,
        em.analytics_updated_at,
        (
          SELECT json_agg(
            json_build_object(
              'date', date,
              'views', total_views,
              'completions', total_completions,
              'averageScore', average_score,
              'uniqueUsers', unique_users
            ) ORDER BY date DESC
          )
          FROM module_analytics_daily
          WHERE module_id = em.id 
            AND date >= CURRENT_DATE - INTERVAL '${period} days'
        ) as daily_stats,
        (
          SELECT json_agg(
            json_build_object(
              'contentId', ca.content_id,
              'dropOffRate', ca.drop_off_rate,
              'averageTimeBeforeDropOff', ca.average_time_before_drop_off
            )
          )
          FROM content_analytics ca
          JOIN module_content mc ON ca.content_id = mc.id
          WHERE mc.module_id = em.id
        ) as content_analytics
      FROM education_modules em
      WHERE em.id = $1
    `;

    const result = await db.query(analyticsQuery, [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Module not found',
        timestamp: new Date().toISOString()
      });
    }

    res.json({
      success: true,
      data: result.rows[0],
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    logger.error('Error fetching analytics:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch analytics',
      timestamp: new Date().toISOString()
    });
  }
});

export { router as modulesRouter };