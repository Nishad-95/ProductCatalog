import { Request, Response, NextFunction } from 'express';
import { ProductService } from '../services/product.service';

export class ProductController {
  constructor(private readonly productService: ProductService) {}

  getAll = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const { featured, search } = req.query;

      if (featured === 'true') {
        const products = await this.productService.getFeaturedProducts(5);
        res.json({ data: products });
        return;
      }

      if (typeof search === 'string' && search.trim().length > 0) {
        const products = await this.productService.searchProducts(search);
        res.json({ data: products });
        return;
      }

      const products = await this.productService.getAllProducts();
      res.json({ data: products });
    } catch (error) {
      next(error);
    }
  };

  getFeatured = async (_req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const products = await this.productService.getFeaturedProducts(5);
      res.json({ data: products });
    } catch (error) {
      next(error);
    }
  };

  getById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const id = parseInt(req.params.id, 10);
      if (isNaN(id)) {
        res.status(400).json({
          error: {
            code: 'INVALID_ID',
            message: 'Product ID must be a valid number',
          },
        });
        return;
      }

      const product = await this.productService.getProductById(id);
      if (!product) {
        res.status(404).json({
          error: {
            code: 'NOT_FOUND',
            message: `Product with ID ${id} was not found`,
          },
        });
        return;
      }

      res.json({ data: product });
    } catch (error) {
      next(error);
    }
  };

  search = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const q = typeof req.query.q === 'string' ? req.query.q : '';
      const products = await this.productService.searchProducts(q);
      res.json({ data: products });
    } catch (error) {
      next(error);
    }
  };
}
