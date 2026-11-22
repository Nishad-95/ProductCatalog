import { Router } from 'express';
import { CategoryController } from '../controllers/category.controller';

export function createCategoryRouter(controller: CategoryController): Router {
  const router = Router();

  // All categories: GET /api/v1/categories
  router.get('/', controller.getAll);

  // Category view (top-rated + additional products): GET /api/v1/categories/:category
  router.get('/:category', controller.getCategoryView);

  return router;
}
