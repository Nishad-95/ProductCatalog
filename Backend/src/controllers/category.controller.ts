import { Request, Response, NextFunction } from 'express';
import { ProductService } from '../services/product.service';

export class CategoryController {
  constructor(private readonly productService: ProductService) {}

  getAll = async (_req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const categories = await this.productService.getCategories();
      res.json({ data: categories });
    } catch (error) {
      next(error);
    }
  };

  getCategoryView = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const category = req.params.category;
      if (!category) {
        res.status(400).json({
          error: {
            code: 'INVALID_CATEGORY',
            message: 'Category parameter is required',
          },
        });
        return;
      }

      const topRatedLimit = req.query.topRated ? parseInt(req.query.topRated as string, 10) : 2;
      const categoryView = await this.productService.getCategoryView(category, isNaN(topRatedLimit) ? 2 : topRatedLimit);
      res.json({ data: categoryView });
    } catch (error) {
      next(error);
    }
  };
}
