import { Router, Request, Response } from 'express';

const router = Router();

router.get('/prices', async (req: Request, res: Response) => {
  res.json({
    message: 'Market data service placeholder - to be implemented',
    data: {
      BTC: { price: 45000, change24h: 2.5 },
      ETH: { price: 3000, change24h: -1.2 },
    },
  });
});

export { router as marketDataRouter };