import { OpenAI } from 'openai';
import dotenv from 'dotenv';

dotenv.config();

if (!process.env.OPENAI_API_KEY) {
  console.warn('Warning: OPENAI_API_KEY not set in environment variables');
}

export const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY || '',
});

export const OPENAI_MODEL = process.env.OPENAI_MODEL || 'gpt-4';

export default { openai, OPENAI_MODEL };
