const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNewCodeNotification = functions.firestore
  .document("codes/{codeId}")
  .onCreate(async (snapshot, context) => {
    const data = snapshot.data();

    if (!data) {
      console.log("No data associated with the event");
      return;
    }

    const siteName = data.siteName || "Unknown Site";
    const codeValue = data.codeValue || "No Code";
    const imageUrl = data.imageUrl || null;

    // Hardcoded green image for big picture as requested, or fall back to code image
    const promoImage = "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgUo7RQZp3ciVbcBdBQLHOpna7750wrFMX-67uNP5Ao2PJY4XzadlZ3UDnbjbUEVhwBGwP4gMAs4aRnlR9YrwIShLOcUEJEkyxvpJMxat2ND_N3_mNKfMYqfYT680ZcCiNb0SU_1qX6dZbVf8Mhgnxi1IbOzwWGAk42igyHwtNcETFqUx-gUSzga_hQ1G9T/s16000/winitbig.png";

    const payload = {
      notification: {
        title: "WinIt Code Center",
        body: `🚀 New code for ${siteName}! Claim it now before it expires!`,
      },
      android: {
        notification: {
          channelId: "high_importance_channel",
          imageUrl: promoImage
        }
      },
      topic: "new_codes",
    };

    // If document has specific image, use it? Or always use big green one?
    // User said: "vea la notificacion como en la anterior imagen" (Green Code Logo)
    // So we use promoImage.

    try {
      const response = await admin.messaging().send(payload);
      console.log("Successfully sent message:", response);
    } catch (error) {
      console.log("Error sending message:", error);
    }
  });
