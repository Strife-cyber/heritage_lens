import { Client, Storage } from 'appwrite';

// Configuration Appwrite
const endpoint = import.meta.env.VITE_APPWRITE_ENDPOINT || 'https://cloud.appwrite.io/v1';
const projectId = import.meta.env.VITE_APPWRITE_PROJECT_ID || '';
const bucketId = import.meta.env.VITE_APPWRITE_STORAGE_BUCKET_ID;

// Initialiser le client Appwrite
const client = new Client()
  .setEndpoint(endpoint)
  .setProject(projectId);

// Initialiser Storage
export const storage: Storage = new Storage(client);
export const appwriteClient = client;
export { bucketId };

