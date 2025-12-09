import { ID } from 'appwrite';
import { storage, bucketId } from './config';

/**
 * Service Appwrite Storage pour la gestion des fichiers
 */

// Uploader un fichier
export const uploadFile = async (
  file: File | Blob,
  fileName?: string,
  folder?: string
): Promise<string> => {
  if (!bucketId) {
    throw new Error('VITE_APPWRITE_STORAGE_BUCKET_ID n\'est pas configuré');
  }

  const fileId = fileName || ID.unique();
  const filePath = folder ? `${folder}/${fileId}` : fileId;
  
  // Convertir Blob en File si nécessaire
  const fileToUpload = file instanceof File 
    ? file 
    : new File([file], fileId, { type: file.type });
  
  const result = await storage.createFile(bucketId, fileId, fileToUpload);
  return result.$id;
};

// Obtenir l'URL de prévisualisation d'un fichier
export const getFilePreview = (fileId: string, width?: number, height?: number): string => {
  if (!bucketId) {
    throw new Error('VITE_APPWRITE_STORAGE_BUCKET_ID n\'est pas configuré');
  }

  return storage.getFilePreview(bucketId, fileId, width, height);
};

// Obtenir l'URL de téléchargement d'un fichier
export const getFileDownload = (fileId: string): string => {
  if (!bucketId) {
    throw new Error('VITE_APPWRITE_STORAGE_BUCKET_ID n\'est pas configuré');
  }

  return storage.getFileDownload(bucketId, fileId);
};

// Obtenir les informations d'un fichier
export const getFile = async (fileId: string) => {
  if (!bucketId) {
    throw new Error('VITE_APPWRITE_STORAGE_BUCKET_ID n\'est pas configuré');
  }

  return await storage.getFile(bucketId, fileId);
};

// Lister les fichiers
export const listFiles = async (queries?: string[]) => {
  if (!bucketId) {
    throw new Error('VITE_APPWRITE_STORAGE_BUCKET_ID n\'est pas configuré');
  }

  return await storage.listFiles(bucketId, queries);
};

// Supprimer un fichier
export const deleteFile = async (fileId: string): Promise<void> => {
  if (!bucketId) {
    throw new Error('VITE_APPWRITE_STORAGE_BUCKET_ID n\'est pas configuré');
  }

  await storage.deleteFile(bucketId, fileId);
};

// Remplacer un fichier (supprime l'ancien et crée le nouveau)
export const replaceFile = async (
  fileId: string,
  file: File | Blob
): Promise<string> => {
  if (!bucketId) {
    throw new Error('VITE_APPWRITE_STORAGE_BUCKET_ID n\'est pas configuré');
  }

  // Supprimer l'ancien fichier s'il existe
  try {
    await storage.deleteFile(bucketId, fileId);
  } catch (error) {
    // Ignorer si le fichier n'existe pas
  }

  // Convertir Blob en File si nécessaire
  const fileToUpload = file instanceof File 
    ? file 
    : new File([file], fileId, { type: file.type });
  
  // Créer le nouveau fichier
  const result = await storage.createFile(bucketId, fileId, fileToUpload);
  return result.$id;
};

