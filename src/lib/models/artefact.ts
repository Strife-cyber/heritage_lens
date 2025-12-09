/**
 * Modèle pour un artefact
 * Structure flexible pour stocker les métadonnées d'un artefact
 */

export interface Artefact {
  // Identifiant unique (généré par Firestore)
  id?: string;

  // URLs des médias
  model3dUrl?: string; // URL vers le modèle 3D
  videoUrl?: string; // URL vers la vidéo
  imageUrl?: string; // URL vers l'image

  // Métadonnées de base
  title?: string;
  description?: string;
  category?: string;
  tags?: string[];

  // Informations de stockage Appwrite (IDs des fichiers)
  model3dFileId?: string; // ID du fichier 3D dans Appwrite Storage
  videoFileId?: string; // ID du fichier vidéo dans Appwrite Storage
  imageFileId?: string; // ID du fichier image dans Appwrite Storage

  // Métadonnées supplémentaires (flexible pour champs futurs)
  metadata?: Record<string, unknown>;

  // Timestamps
  createdAt?: Date | string;
  updatedAt?: Date | string;

  // Informations de création/modification
  createdBy?: string;
  updatedBy?: string;

  // Statut et visibilité
  status?: 'draft' | 'published' | 'archived';
  isPublic?: boolean;
}

/**
 * Type pour créer un nouvel artefact (sans les champs auto-générés)
 */
export type CreateArtefactInput = Omit<Artefact, 'id' | 'createdAt' | 'updatedAt'>;

/**
 * Type pour mettre à jour un artefact (tous les champs optionnels sauf id)
 */
export type UpdateArtefactInput = Partial<Omit<Artefact, 'id' | 'createdAt'>> & {
  updatedAt?: Date | string;
};

