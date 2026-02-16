import rateLimit from 'express-rate-limit';

// General rate limiter for API routes
export const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: {
    success: false,
    error: {
      message: 'Too many requests from this IP, please try again later.',
      code: 'RATE_LIMIT_EXCEEDED',
    },
    timestamp: new Date(),
  },
  standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers
});

// Stricter rate limiter for authentication routes
export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // Limit each IP to 5 requests per windowMs
  message: {
    success: false,
    error: {
      message: 'Too many authentication attempts, please try again later.',
      code: 'AUTH_RATE_LIMIT_EXCEEDED',
    },
    timestamp: new Date(),
  },
  standardHeaders: true,
  legacyHeaders: false,
  skipSuccessfulRequests: true, // Don't count successful requests
});

// AI route limiter (more restrictive due to API costs)
export const aiLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 20, // Limit each IP to 20 AI requests per hour
  message: {
    success: false,
    error: {
      message: 'Too many AI requests, please try again later.',
      code: 'AI_RATE_LIMIT_EXCEEDED',
    },
    timestamp: new Date(),
  },
  standardHeaders: true,
  legacyHeaders: false,
});
