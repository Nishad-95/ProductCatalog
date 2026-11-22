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
});

const parsed = envSchema.safeParse(process.env);

if (!parsed.success) {
  console.error('Invalid environment configuration:', parsed.error.format());
  throw new Error('Environment configuration validation failed');
}

export const config = parsed.data;
export type Config = typeof config;
