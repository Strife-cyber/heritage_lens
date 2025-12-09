import adminSdkConfig from '../../../admin-sdk.json';
import { getFirestore, type Firestore } from 'firebase-admin/firestore';
import { initializeApp, getApps, cert, type App } from 'firebase-admin/app';

// Initialiser Firebase Admin SDK avec admin-sdk.json
let adminApp: App;
if (getApps().length === 0) {
  adminApp = initializeApp({
    credential: cert({
      projectId: adminSdkConfig.project_id,
      privateKey: adminSdkConfig.private_key,
      clientEmail: adminSdkConfig.client_email,
    }),
    projectId: adminSdkConfig.project_id,
  });
} else {
  adminApp = getApps()[0];
}

// Exporter les services Admin
export const adminDb: Firestore = getFirestore(adminApp);

