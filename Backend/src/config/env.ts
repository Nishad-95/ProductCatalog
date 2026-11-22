import dotenv from 'dotenv';
import { z } from 'zod';

dotenv.config();

const envSchema = z.object({
  PORT: z.coerce.number().default(3000),
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  FAKESTORE_API_BASE_URL: z.string().url().default('https://fakestoreapi.com'),
  SALES_EMAIL: z.string().email().default('sales@productcatalog.local'),
  EMAIL_PROVIDER: z.enum(['console', 'mock', 'smtp']).default('console'),
  CACHE_TTL_SECONDS: z.coerce.number().default(300),
  FEATURED_PRODUCT_IDS: z.string().optional().default('1,2,3,5,11'),
});

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  console.error('Invalid environment configuration:', parsed.error.format());
  throw new Error('Environment configuration validation failed');
}

export const config = parsed.data;
export type Config = typeof config;

export const configuredFeaturedIds: number[] = config.FEATURED_PRODUCT_IDS
  ? config.FEATURED_PRODUCT_IDS.split(',')
      .map((id) => parseInt(id.trim(), 10))
      .filter((n) => !isNaN(n))
  : [1, 2, 3, 5, 11];
