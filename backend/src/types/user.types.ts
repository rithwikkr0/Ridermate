export interface User {
  id: string;
  email: string;
  username: string;
  passwordHash: string;
  createdAt: Date;
  updatedAt: Date;
  profile?: {
    fullName?: string;
    avatar?: string;
    bio?: string;
  };
  stats?: {
    totalRides: number;
    totalDistance: number;
    totalDuration: number;
    averageSpeed: number;
  };
}

export interface UserRegistrationData {
  email: string;
  username: string;
  password: string;
  fullName?: string;
}

export interface UserLoginData {
  email: string;
  password: string;
}

export interface AuthResponse {
  token: string;
  user: Omit<User, 'passwordHash'>;
}
