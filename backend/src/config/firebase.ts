import admin from 'firebase-admin';
import { config } from './index';

let firebaseInitialized = false;

export const initializeFirebase = () => {
  if (firebaseInitialized) {
    return admin;
  }

  try {
    if (config.firebase.projectId && config.firebase.privateKey && config.firebase.clientEmail) {
      admin.initializeApp({
        credential: admin.credential.cert({
          projectId: config.firebase.projectId,
          privateKey: config.firebase.privateKey,
          clientEmail: config.firebase.clientEmail,
        }),
      });
      firebaseInitialized = true;
      console.log('Firebase initialized successfully');
    } else {
      console.warn('Firebase credentials not provided. Running without Firebase.');
    }
  } catch (error) {
    console.error('Error initializing Firebase:', error);
  }

  return admin;
};

export const getFirestore = () => {
  if (!firebaseInitialized) {
    initializeFirebase();
  }
  return admin.firestore();
};

export const getAuth = () => {
  if (!firebaseInitialized) {
    initializeFirebase();
  }
  return admin.auth();
};
