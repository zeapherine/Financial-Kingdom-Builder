import { Router, Request, Response } from 'express';

const router = Router();

router.get('/', async (req: Request, res: Response) => {
  const userId = req.headers['x-user-id'] as string;
  
  res.json({
    message: 'Achievements service placeholder - to be implemented',
    userId,
    achievements: [],
  });
});

export { router as achievementsRouter };