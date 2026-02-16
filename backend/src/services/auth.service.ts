import bcrypt from 'bcryptjs';
import jwt, { SignOptions } from 'jsonwebtoken';
import { config } from '../config/server.config';
import { UserRegistrationData, UserLoginData, AuthResponse } from '../types/user.types';
import { createUser, getUserByEmail } from './firebase.service';
import { AppError } from '../types/api.types';

const SALT_ROUNDS = 10;

export const hashPassword = async (password: string): Promise<string> => {
  return bcrypt.hash(password, SALT_ROUNDS);
};

export const comparePassword = async (
  password: string,
  hash: string
): Promise<boolean> => {
  return bcrypt.compare(password, hash);
};

export const generateToken = (userId: string): string => {
  const options: SignOptions = {
    expiresIn: config.jwt.expiresIn as any,
  };
  return jwt.sign({ userId }, config.jwt.secret, options);
};

export const registerUser = async (
  userData: UserRegistrationData
): Promise<AuthResponse> => {
  // Check if user already exists
  const existingUser = await getUserByEmail(userData.email);
  if (existingUser) {
    throw new AppError(400, 'User with this email already exists', 'EMAIL_EXISTS');
  }

  // Hash password
  const passwordHash = await hashPassword(userData.password);

  // Create user
  const user = await createUser({
    email: userData.email,
    username: userData.username,
    passwordHash,
    createdAt: new Date(),
    updatedAt: new Date(),
    profile: {
      fullName: userData.fullName,
    },
    stats: {
      totalRides: 0,
      totalDistance: 0,
      totalDuration: 0,
      averageSpeed: 0,
    },
  });

  // Generate token
  const token = generateToken(user.id);

  // Return user without password hash
  const { passwordHash: _, ...userWithoutPassword } = user;

  return {
    token,
    user: userWithoutPassword,
  };
};

export const loginUser = async (
  loginData: UserLoginData
): Promise<AuthResponse> => {
  // Find user by email
  const user = await getUserByEmail(loginData.email);
  if (!user) {
    throw new AppError(401, 'Invalid email or password', 'INVALID_CREDENTIALS');
  }

  // Verify password
  const isPasswordValid = await comparePassword(loginData.password, user.passwordHash);
  if (!isPasswordValid) {
    throw new AppError(401, 'Invalid email or password', 'INVALID_CREDENTIALS');
  }

  // Generate token
  const token = generateToken(user.id);

  // Return user without password hash
  const { passwordHash: _, ...userWithoutPassword } = user;

  return {
    token,
    user: userWithoutPassword,
  };
};

export const verifyToken = (token: string): { userId: string } => {
  try {
    return jwt.verify(token, config.jwt.secret) as { userId: string };
  } catch (error) {
    throw new AppError(401, 'Invalid or expired token', 'INVALID_TOKEN');
  }
};
