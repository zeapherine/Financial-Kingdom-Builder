import { Router, Request, Response } from 'express';

const router = Router();

router.get('/', async (req: Request, res: Response) => {
  res.json({
    message: 'Leaderboard service placeholder - to be implemented',
    leaderboard: [],
  });
});

export { router as leaderboardRouter };