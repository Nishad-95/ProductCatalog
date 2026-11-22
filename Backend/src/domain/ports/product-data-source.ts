import { Product } from '../models/product';

export interface ProductDataSource {
  /**
   * Retrieves all products from the data source.
   */
  getAllProducts(): Promise<Product[]>;

  /**
   * Retrieves a single product by its unique identifier.
   */
  getProductById(id: number): Promise<Product | null>;

  /**
   * Retrieves all unique category names.
   */
  getCategories(): Promise<string[]>;

  /**
   * Retrieves all products belonging to a given category.
   */
  getProductsByCategory(category: string): Promise<Product[]>;
}
