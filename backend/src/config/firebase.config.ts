import * as admin from 'firebase-admin';
import dotenv from 'dotenv';

dotenv.config();

let firebaseApp: admin.app.App;

export const initializeFirebase = (): admin.app.App => {
  if (firebaseApp) {
    return firebaseApp;
  }

  try {
    // Option 1: Use service account file
    if (process.env.FIREBASE_SERVICE_ACCOUNT_PATH) {
      const serviceAccount = require(process.env.FIREBASE_SERVICE_ACCOUNT_PATH);
      firebaseApp = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
    }
    // Option 2: Use individual environment variables
    else if (
      process.env.FIREBASE_PROJECT_ID &&
      process.env.FIREBASE_PRIVATE_KEY &&
      process.env.FIREBASE_CLIENT_EMAIL
    ) {
      firebaseApp = admin.initializeApp({
        credential: admin.credential.cert({
          projectId: process.env.FIREBASE_PROJECT_ID,
          privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
          clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        }),
      });
    } else {
      throw new Error('Firebase credentials not found in environment variables');
    }

    console.log('Firebase Admin SDK initialized successfully');
    return firebaseApp;
  } catch (error) {
    console.error('Error initializing Firebase Admin SDK:', error);
    throw error;
  }
};

export const getFirestore = (): admin.firestore.Firestore => {
  if (!firebaseApp) {
    initializeFirebase();
  }
  return admin.firestore();
};

export const getAuth = (): admin.auth.Auth => {
  if (!firebaseApp) {
    initializeFirebase();
  }
  return admin.auth();
};

export default { initializeFirebase, getFirestore, getAuth };
