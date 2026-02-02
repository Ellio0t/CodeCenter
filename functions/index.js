const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// 1. Flavor-Specific Notification for New Codes
exports.sendNewCodeNotification = functions.firestore
  .document("codes/{codeId}")
  .onCreate(async (snapshot, context) => {
    const data = snapshot.data();

    if (!data) {
      console.log("No data associated with the event");
      return;
    }

    const siteName = data.siteName || "Unknown Site";
    // const codeValue = data.codeValue || "No Code"; // Unused in notification body currently
    const flavor = data.flavor ? data.flavor.toLowerCase() : "winit"; // Default to winit if missing

    // Determine Topic and Type based on content
    let topic = "new_codes";
    let type = "code";

    // Check for explicit label/category or infer from siteName
    const label = (data.label || data.category || "").toString().toLowerCase();
    const siteNameLower = siteName.toLowerCase();

    if (label.includes("money") || siteNameLower.includes("money back") || siteNameLower.includes("cashback")) {
      topic = "money_back";
      type = "money_back"; // APP maps this to Money Back section
    } else if (label.includes("game") || label.includes("juego") || siteNameLower.includes("game")) {
      topic = "game_center";
      type = "game_center"; // APP maps this to Games section
    } else {
      // Default: Code Logic
      if (flavor !== "winit") {
        topic = `new_codes_${flavor}`;
      }
    }

    // Common Promo Image (Green WinIt Logo)
    const promoImage = "https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEgUo7RQZp3ciVbcBdBQLHOpna7750wrFMX-67uNP5Ao2PJY4XzadlZ3UDnbjbUEVhwBGwP4gMAs4aRnlR9YrwIShLOcUEJEkyxvpJMxat2ND_N3_mNKfMYqfYT680ZcCiNb0SU_1qX6dZbVf8Mhgnxi1IbOzwWGAk42igyHwtNcETFqUx-gUSzga_hQ1G9T/s16000/winitbig.png";

    const payload = {
      notification: {
        title: "WinIt Code Center",
        body: `New update for ${siteName}! Check it out now!`,
      },
      data: {
        type: type, // Dynamic type
        flavor: flavor,
        click_action: "FLUTTER_NOTIFICATION_CLICK"
      },
      android: {
        notification: {
          channelId: "high_importance_channel_v2", // Updated channel ID logic
          imageUrl: promoImage
        }
      },
      topic: topic,
    };

    try {
      const response = await admin.messaging().send(payload);
      console.log(`Successfully sent message to topic ${topic}:`, response);
    } catch (error) {
      console.log("Error sending message:", error);
    }
  });

// 2. Global Alert System (Broadcast to ALL apps)
exports.sendGlobalAlert = functions.firestore
  .document("global_alerts/{alertId}")
  .onCreate(async (snapshot, context) => {
    const data = snapshot.data();

    if (!data) return;

    const title = data.title || "Announcement";
    const body = data.body || "Important update available!";
    const imageUrl = data.imageUrl || null;
    const type = data.type || "news";

    const payload = {
      notification: {
        title: title,
        body: body,
      },
      data: {
        type: type,
        click_action: "FLUTTER_NOTIFICATION_CLICK"
      },
      android: {
        notification: {
          channelId: "high_importance_channel_v2",
        }
      },
      topic: "center", // Global topic that ALL apps subscribe to
    };

    if (imageUrl) {
      payload.android.notification.imageUrl = imageUrl;
    }

    try {
      const response = await admin.messaging().send(payload);
      console.log("Successfully sent global alert to 'center':", response);
    } catch (error) {
      console.log("Error sending global alert:", error);
    }
  });
