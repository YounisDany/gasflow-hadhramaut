/**
 * GasFlow Cloud Functions — push delivery for in-app notifications.
 *
 * Whenever a document is created in the `notifications` collection (the app
 * writes one on every approval / order event), this fans it out as an FCM push
 * to every registered device token. Targeting can be tightened by reading the
 * `to` field (uid / role / 'all') and querying only matching users.
 */
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();

exports.onNotificationCreated = onDocumentCreated(
    "notifications/{id}",
    async (event) => {
      const snap = event.data;
      if (!snap) return;
      const data = snap.data();

      // Collect FCM tokens. For now broadcast to everyone; filter by data.to
      // (e.g. where('role','==', data.to)) to target a single recipient.
      const usersSnap = await getFirestore().collection("users").get();
      const tokens = [];
      usersSnap.forEach((doc) => {
        const t = doc.get("fcmTokens");
        if (Array.isArray(t)) tokens.push(...t);
      });
      if (tokens.length === 0) return;

      const message = {
        notification: {
          title: data.titleAr || data.titleEn || "GasFlow",
          body: data.bodyAr || data.bodyEn || "",
        },
        tokens: [...new Set(tokens)],
      };

      const res = await getMessaging().sendEachForMulticast(message);
      console.log(`Sent ${res.successCount}/${tokens.length} pushes`);
    },
);
