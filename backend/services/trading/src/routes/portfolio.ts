import { Router, Request, Response } from 'express';
import { AppError } from '../utils/app-error';

const router = Router();

router.get('/', async (req: Request, res: Response) => {
  const userId = req.headers['x-user-id'] as string;
  
  res.json({
    userId,
    portfolio: {
      totalValue: 10000,
      availableBalance: 8500,
      positions: [],
    },
    message: 'Portfolio service placeholder - to be implemented',
  });
});

export { router as portfolioRouter };