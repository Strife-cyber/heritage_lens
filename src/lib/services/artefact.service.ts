import { adminDb } from '../firebase/admin';
import type { Artefact, CreateArtefactInput, UpdateArtefactInput } from '../models/artefact';

const COLLECTION_NAME = 'artefacts';

/**
 * Service pour gérer les artefacts dans Firestore
 */

// Créer un nouvel artefact
export const createArtefact = async (data: CreateArtefactInput): Promise<string> => {
  const now = new Date().toISOString();
  const artefactData: Artefact = {
    ...data,
    createdAt: now,
    updatedAt: now,
  };

  const docRef = await adminDb.collection(COLLECTION_NAME).add(artefactData);
  return docRef.id;
};

// Obtenir un artefact par ID
export const getArtefact = async (id: string): Promise<Artefact | null> => {
  const docRef = adminDb.collection(COLLECTION_NAME).doc(id);
  const docSnap = await docRef.get();

  if (!docSnap.exists) {
    return null;
  }

  return {
    id: docSnap.id,
    ...docSnap.data(),
  } as Artefact;
};

// Obtenir tous les artefacts
export const getAllArtefacts = async (): Promise<Artefact[]> => {
  const snapshot = await adminDb.collection(COLLECTION_NAME).get();
  return snapshot.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  })) as Artefact[];
};

// Obtenir les artefacts avec filtres
export const getArtefacts = async (filters?: {
  status?: Artefact['status'];
  isPublic?: boolean;
  category?: string;
  limit?: number;
}): Promise<Artefact[]> => {
  let query = adminDb.collection(COLLECTION_NAME) as FirebaseFirestore.Query;

  if (filters?.status) {
    query = query.where('status', '==', filters.status);
  }

  if (filters?.isPublic !== undefined) {
    query = query.where('isPublic', '==', filters.isPublic);
  }

  if (filters?.category) {
    query = query.where('category', '==', filters.category);
  }

  if (filters?.limit) {
    query = query.limit(filters.limit);
  }

  const snapshot = await query.get();
  return snapshot.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  })) as Artefact[];
};

// Mettre à jour un artefact
export const updateArtefact = async (
  id: string,
  data: UpdateArtefactInput
): Promise<void> => {
  const updateData = {
    ...data,
    updatedAt: new Date().toISOString(),
  };

  await adminDb.collection(COLLECTION_NAME).doc(id).update(updateData);
};

// Supprimer un artefact
export const deleteArtefact = async (id: string): Promise<void> => {
  await adminDb.collection(COLLECTION_NAME).doc(id).delete();
};

// Rechercher des artefacts par titre ou description
export const searchArtefacts = async (searchTerm: string): Promise<Artefact[]> => {
  const snapshot = await adminDb.collection(COLLECTION_NAME).get();
  const searchLower = searchTerm.toLowerCase();

  const artefacts = snapshot.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  })) as Artefact[];

  return artefacts.filter((artefact) => {
    const title = artefact.title?.toLowerCase() || '';
    const description = artefact.description?.toLowerCase() || '';
    return title.includes(searchLower) || description.includes(searchLower);
  });
};
