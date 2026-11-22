import express, { Express } from 'express';
import cors from 'cors';
import { requestLogger } from './middleware/request-logger';
import { errorHandler } from './middleware/error-handler';
import { AppDependencies, createApiRouter } from './routes';

export function createApp(deps?: AppDependencies): Express {
  const app = express();

  // Middleware
  app.use(cors());
  app.use(express.json());
  app.use(requestLogger);

  // Mount API v1
  app.use('/api/v1', createApiRouter(deps));

  // Catch-all 404 handler
  app.use((_req, res) => {
    res.status(404).json({
      error: {
        code: 'NOT_FOUND',
        message: 'Endpoint not found',
      },
    });
  });

  // Global error handler
  app.use(errorHandler);

  return app;
}
