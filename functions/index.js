const { onRequest } = require('firebase-functions/v2/https');
const { setGlobalOptions } = require('firebase-functions/v2/options');
const admin = require('firebase-admin');

admin.initializeApp();
setGlobalOptions({ maxInstances: 10 });

const db = admin.firestore();
const listings = db.collection('listings');

function sendError(response, status, message) {
  response.status(status).json({ error: message });
}

function listingPayload(data, id) {
  return {
    id,
    ...data,
    createdAt: data.createdAt?.toDate?.()?.toISOString() ?? null,
  };
}

async function requireUser(request, response) {
  const header = request.get('authorization') || '';
  if (!header.startsWith('Bearer ')) {
    sendError(response, 401, 'Authentication is required.');
    return null;
  }

  try {
    return await admin.auth().verifyIdToken(header.substring(7));
  } catch (_) {
    sendError(response, 401, 'Invalid authentication token.');
    return null;
  }
}

exports.listingsApi = onRequest({ cors: true }, async (request, response) => {
  const user = await requireUser(request, response);
  if (!user) return;

  const pathParts = request.path.split('/').filter(Boolean);
  const documentId = pathParts[0] === 'listings' ? pathParts[1] : null;

  try {
    if (request.method === 'GET' && !documentId) {
      // Do not require createdAt yet; existing development documents may not
      // have that field until the data is backfilled.
      const snapshot = await listings.get();
      response.json({
        data: snapshot.docs.map((doc) => listingPayload(doc.data(), doc.id)),
      });
      return;
    }

    if (request.method === 'POST' && !documentId) {
      const body = request.body || {};
      if (!String(body.itemName || '').trim()) {
        sendError(response, 400, 'itemName is required.');
        return;
      }

      const document = {
        ownerId: user.uid,
        userName: body.userName || user.email?.split('@')[0] || 'User',
        itemName: String(body.itemName).trim(),
        itemImage: body.itemImage || '',
        rarity: body.rarity || 'Common',
        category: body.category || 'RPG Item',
        description: body.description || '',
        isAvailable: body.isAvailable !== false,
        tradeFor: body.tradeFor || '',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      };
      const created = await listings.add(document);
      const saved = await created.get();
      response.status(201).json(listingPayload(saved.data(), saved.id));
      return;
    }

    if (!documentId) {
      sendError(response, 404, 'Listing route not found.');
      return;
    }

    const reference = listings.doc(documentId);
    const existing = await reference.get();
    if (!existing.exists) {
      sendError(response, 404, 'Listing not found.');
      return;
    }
    if (existing.data().ownerId !== user.uid) {
      sendError(response, 403, 'You do not own this listing.');
      return;
    }

    if (request.method === 'PUT') {
      const body = request.body || {};
      const updates = {
        itemName: String(body.itemName || '').trim(),
        itemImage: body.itemImage || '',
        rarity: body.rarity || 'Common',
        category: body.category || 'RPG Item',
        description: body.description || '',
        isAvailable: body.isAvailable !== false,
        tradeFor: body.tradeFor || '',
      };
      if (!updates.itemName) {
        sendError(response, 400, 'itemName is required.');
        return;
      }
      await reference.update(updates);
      const updated = await reference.get();
      response.json(listingPayload(updated.data(), updated.id));
      return;
    }

    if (request.method === 'DELETE') {
      await reference.delete();
      response.status(204).send();
      return;
    }

    sendError(response, 405, 'Method not allowed.');
  } catch (error) {
    console.error(error);
    sendError(response, 500, 'The listings request failed.');
  }
});
