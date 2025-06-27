import { Router, Request, Response } from 'express';

const router = Router();

router.get('/', async (req: Request, res: Response) => {
  const userId = req.headers['x-user-id'] as string;
  
  res.json({
    message: 'XP service placeholder - to be implemented',
    userId,
    xp: {
      total: 1250,
      level: 5,
      nextLevelXp: 1500,
    },
  });
});

export { router as xpRouter };