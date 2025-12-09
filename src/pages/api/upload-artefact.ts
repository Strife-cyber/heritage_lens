import type { APIRoute } from 'astro';
import { uploadFile, getFileDownload } from '../../lib/appwrite/storage';
import { createArtefact } from '../../lib/services/artefact.service';
import type { CreateArtefactInput } from '../../lib/models/artefact';

export const POST: APIRoute = async ({ request }) => {
  try {
    const formData = await request.formData();

    // Récupérer les fichiers
    const modelFile = formData.get('model3d') as File | null;
    const videoFile = formData.get('video') as File | null;
    const imageFile = formData.get('image') as File | null;

    // Récupérer les métadonnées
    const title = formData.get('title') as string | null;
    const description = formData.get('description') as string | null;
    const category = formData.get('category') as string | null;
    const tags = formData.get('tags') as string | null;
    const status = (formData.get('status') as string | null) || 'draft';
    const isPublic = formData.get('isPublic') === 'true';

    // Uploader les fichiers vers Appwrite Storage
    let model3dFileId: string | undefined;
    let videoFileId: string | undefined;
    let imageFileId: string | undefined;
    let model3dUrl: string | undefined;
    let videoUrl: string | undefined;
    let imageUrl: string | undefined;

    if (modelFile && modelFile.size > 0) {
      model3dFileId = await uploadFile(modelFile, undefined, 'models');
      model3dUrl = getFileDownload(model3dFileId);
    }

    if (videoFile && videoFile.size > 0) {
      videoFileId = await uploadFile(videoFile, undefined, 'videos');
      videoUrl = getFileDownload(videoFileId);
    }

    if (imageFile && imageFile.size > 0) {
      imageFileId = await uploadFile(imageFile, undefined, 'images');
      imageUrl = getFileDownload(imageFileId);
    }

    // Préparer les données de l'artefact
    const artefactData: CreateArtefactInput = {
      title: title || undefined,
      description: description || undefined,
      category: category || undefined,
      tags: tags ? tags.split(',').map((tag) => tag.trim()) : undefined,
      model3dUrl,
      videoUrl,
      imageUrl,
      model3dFileId,
      videoFileId,
      imageFileId,
      status: status as 'draft' | 'published' | 'archived',
      isPublic,
    };

    // Créer l'artefact dans Firestore
    const artefactId = await createArtefact(artefactData);

    return new Response(
      JSON.stringify({
        success: true,
        id: artefactId,
        message: 'Artefact créé avec succès',
      }),
      {
        status: 200,
        headers: {
          'Content-Type': 'application/json',
        },
      }
    );
  } catch (error) {
    console.error('Erreur lors de l\'upload:', error);
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : 'Erreur inconnue',
      }),
      {
        status: 500,
        headers: {
          'Content-Type': 'application/json',
        },
      }
    );
  }
};

