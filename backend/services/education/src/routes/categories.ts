import { Router, Request, Response } from 'express';
import { DatabaseManager } from '../../../shared/src/database/manager';
import { ApiResponse, EducationCategory } from '../../../shared/src/types';
import { logger } from '../utils/logger';

const router = Router();
const db = DatabaseManager.getInstance();

// GET /categories - Get all education categories
router.get('/', async (req: Request, res: Response) => {
  try {
    const { includeInactive = 'false' } = req.query;
    
    let query = `
      SELECT 
        ec.*,
        COUNT(em.id) as module_count,
        COUNT(em.id) FILTER (WHERE em.status = 'published') as published_module_count
      FROM education_categories ec
      LEFT JOIN education_modules em ON em.category = ec.name
    `;

    if (includeInactive !== 'true') {
      query += ` WHERE ec.is_active = true`;
    }

    query += `
      GROUP BY ec.id
      ORDER BY ec.order_index, ec.name
    `;

    const result = await db.query(query);
    
    const categories = result.rows.map((row: any) => ({
      id: row.id,
      name: row.name,
      description: row.description,
      icon: row.icon,
      color: row.color,
      order: row.order_index,
      parentId: row.parent_id,
      isActive: row.is_active,
      moduleCount: parseInt(row.module_count),
      publishedModuleCount: parseInt(row.published_module_count)
    }));

    const response: ApiResponse<EducationCategory[]> = {
      success: true,
      data: categories,
      timestamp: new Date().toISOString()
    };

    res.json(response);
  } catch (error) {
    logger.error('Error fetching categories:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch categories',
      timestamp: new Date().toISOString()
    });
  }
});

// GET /categories/:id - Get specific category
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    const query = `
      SELECT 
        ec.*,
        COUNT(em.id) as module_count,
        COUNT(em.id) FILTER (WHERE em.status = 'published') as published_module_count,
        COALESCE(
          JSON_AGG(
            JSON_BUILD_OBJECT(
              'id', em.id,
              'title', em.title,
              'description', em.description,
              'tier', em.tier,
              'difficulty', em.difficulty,
              'estimatedDuration', em.estimated_duration,
              'xpReward', em.xp_reward,
              'status', em.status
            ) ORDER BY em.tier, em.created_at
          ) FILTER (WHERE em.id IS NOT NULL),
          '[]'
        ) as modules
      FROM education_categories ec
      LEFT JOIN education_modules em ON em.category = ec.name
      WHERE ec.id = $1
      GROUP BY ec.id
    `;

    const result = await db.query(query, [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Category not found',
        timestamp: new Date().toISOString()
      });
    }

    const category = result.rows[0];
    
    const response: ApiResponse = {
      success: true,
      data: {
        id: category.id,
        name: category.name,
        description: category.description,
        icon: category.icon,
        color: category.color,
        order: category.order_index,
        parentId: category.parent_id,
        isActive: category.is_active,
        moduleCount: parseInt(category.module_count),
        publishedModuleCount: parseInt(category.published_module_count),
        modules: category.modules || []
      },
      timestamp: new Date().toISOString()
    };

    res.json(response);
  } catch (error) {
    logger.error('Error fetching category:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch category',
      timestamp: new Date().toISOString()
    });
  }
});

// POST /categories - Create new category (admin only)
router.post('/', async (req: Request, res: Response) => {
  try {
    const {
      name,
      description,
      icon,
      color,
      order = 0,
      parentId,
      isActive = true
    } = req.body;

    if (!name || !description) {
      return res.status(400).json({
        success: false,
        error: 'Name and description are required',
        timestamp: new Date().toISOString()
      });
    }

    const query = `
      INSERT INTO education_categories (
        name, description, icon, color, order_index, parent_id, is_active
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *
    `;

    const result = await db.query(query, [
      name, description, icon, color, order, parentId, isActive
    ]);

    const category = result.rows[0];

    const response: ApiResponse<EducationCategory> = {
      success: true,
      data: {
        id: category.id,
        name: category.name,
        description: category.description,
        icon: category.icon,
        color: category.color,
        order: category.order_index,
        parentId: category.parent_id,
        isActive: category.is_active
      },
      message: 'Category created successfully',
      timestamp: new Date().toISOString()
    };

    res.status(201).json(response);
  } catch (error) {
    logger.error('Error creating category:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create category',
      timestamp: new Date().toISOString()
    });
  }
});

// PUT /categories/:id - Update category
router.put('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const updates = req.body;

    const updateFields = [];
    const updateValues = [];
    let paramCount = 0;

    Object.keys(updates).forEach(key => {
      if (key === 'order') {
        updateFields.push(`order_index = $${++paramCount}`);
        updateValues.push(updates[key]);
      } else if (key === 'parentId') {
        updateFields.push(`parent_id = $${++paramCount}`);
        updateValues.push(updates[key]);
      } else if (key === 'isActive') {
        updateFields.push(`is_active = $${++paramCount}`);
        updateValues.push(updates[key]);
      } else if (['name', 'description', 'icon', 'color'].includes(key)) {
        updateFields.push(`${key} = $${++paramCount}`);
        updateValues.push(updates[key]);
      }
    });

    if (updateFields.length === 0) {
      return res.status(400).json({
        success: false,
        error: 'No valid fields to update',
        timestamp: new Date().toISOString()
      });
    }

    updateFields.push(`updated_at = NOW()`);
    
    const query = `
      UPDATE education_categories 
      SET ${updateFields.join(', ')}
      WHERE id = $${++paramCount}
      RETURNING *
    `;
    
    updateValues.push(id);
    const result = await db.query(query, updateValues);

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Category not found',
        timestamp: new Date().toISOString()
      });
    }

    res.json({
      success: true,
      message: 'Category updated successfully',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    logger.error('Error updating category:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update category',
      timestamp: new Date().toISOString()
    });
  }
});

// DELETE /categories/:id - Deactivate category
router.delete('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;

    // Check if category has modules
    const moduleCheck = await db.query(`
      SELECT COUNT(*) as module_count
      FROM education_modules em
      JOIN education_categories ec ON em.category = ec.name
      WHERE ec.id = $1
    `, [id]);

    const moduleCount = parseInt(moduleCheck.rows[0].module_count);

    if (moduleCount > 0) {
      return res.status(400).json({
        success: false,
        error: `Cannot delete category with ${moduleCount} associated modules`,
        timestamp: new Date().toISOString()
      });
    }

    // Deactivate instead of delete
    await db.query(`
      UPDATE education_categories 
      SET is_active = false, updated_at = NOW()
      WHERE id = $1
    `, [id]);

    res.json({
      success: true,
      message: 'Category deactivated successfully',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    logger.error('Error deleting category:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete category',
      timestamp: new Date().toISOString()
    });
  }
});

export { router as categoriesRouter };