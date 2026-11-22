import { Router } from 'express';
import { ProductController } from '../controllers/product.controller';

export function createProductRouter(controller: ProductController): Router {
  const router = Router();

  // Search products: GET /api/v1/products/search?q=...
  router.get('/search', controller.search);

  // Featured products (Top 5): GET /api/v1/products/featured
  router.get('/featured', controller.getFeatured);

  // All products (supports ?featured=true and ?search=...): GET /api/v1/products
  router.get('/', controller.getAll);

  // Product by ID: GET /api/v1/products/:id
  router.get('/:id', controller.getById);

  return router;
}
