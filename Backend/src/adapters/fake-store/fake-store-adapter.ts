import { Product } from '../../domain/models/product';
import { ProductDataSource } from '../../domain/ports/product-data-source';
import { SEED_PRODUCTS } from './seed-data';

export class FakeStoreAdapter implements ProductDataSource {
  private readonly baseUrl: string;
  private readonly cacheTtlMs: number;
  private cachedProducts: { data: Product[]; timestamp: number } | null = null;
  private cachedCategories: { data: string[]; timestamp: number } | null = null;

  constructor(baseUrl: string = 'https://fakestoreapi.com', cacheTtlSeconds: number = 300) {
    this.baseUrl = baseUrl.replace(/\/$/, '');
    this.cacheTtlMs = cacheTtlSeconds * 1000;
  }

  async getAllProducts(): Promise<Product[]> {
    const now = Date.now();
    if (this.cachedProducts && now - this.cachedProducts.timestamp < this.cacheTtlMs) {
      return this.cachedProducts.data;
    }

    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 5000);

      const response = await fetch(`${this.baseUrl}/products`, {
        signal: controller.signal,
        headers: { 'Accept': 'application/json' },
      });
      clearTimeout(timeoutId);

      if (!response.ok) {
        throw new Error(`Failed to fetch from FakeStore: ${response.status} ${response.statusText}`);
      }

      const products: Product[] = await response.json();
      if (Array.isArray(products) && products.length > 0) {
        this.cachedProducts = { data: products, timestamp: now };
        return products;
      }
      throw new Error('FakeStore returned empty product list');
    } catch (error) {
      console.warn('FakeStore API unreachable or errored. Falling back to built-in seed catalog:', (error as Error).message);
      // Fallback to offline seed catalog for maximum resilience
      this.cachedProducts = { data: SEED_PRODUCTS, timestamp: now };
      return SEED_PRODUCTS;
    }
  }

  async getProductById(id: number): Promise<Product | null> {
    const all = await this.getAllProducts();
    const found = all.find((p) => p.id === id);
    return found || null;
  }

  async getCategories(): Promise<string[]> {
    const now = Date.now();
    if (this.cachedCategories && now - this.cachedCategories.timestamp < this.cacheTtlMs) {
      return this.cachedCategories.data;
    }

    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 4000);

      const response = await fetch(`${this.baseUrl}/products/categories`, {
        signal: controller.signal,
        headers: { 'Accept': 'application/json' },
      });
      clearTimeout(timeoutId);

      if (response.ok) {
        const categories: string[] = await response.json();
        if (Array.isArray(categories) && categories.length > 0) {
          this.cachedCategories = { data: categories, timestamp: now };
          return categories;
        }
      }
      throw new Error('Failed to retrieve categories from FakeStore API');
    } catch {
      // Derive distinct categories from fallback catalog
      const all = await this.getAllProducts();
      const unique = Array.from(new Set(all.map((p) => p.category)));
      this.cachedCategories = { data: unique, timestamp: now };
      return unique;
    }
  }

  async getProductsByCategory(category: string): Promise<Product[]> {
    const all = await this.getAllProducts();
    const decodedCategory = decodeURIComponent(category).toLowerCase();
    return all.filter((p) => p.category.toLowerCase() === decodedCategory);
  }

  /**
   * Helper method to manually clear the adapter cache (useful in tests).
   */
  clearCache(): void {
    this.cachedProducts = null;
    this.cachedCategories = null;
  }
}
