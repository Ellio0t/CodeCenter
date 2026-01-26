importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
    apiKey: 'AIzaSyB_wD8ZN_GuE03lkRZoeIJ1n0XzX224d2A',
    appId: '1:66500442999:web:cd02ce8832cf3c7e8c3f72',
    messagingSenderId: '66500442999',
    projectId: 'winitcode',
    authDomain: 'winitcode.firebaseapp.com',
    databaseURL: 'https://winitcode.firebaseio.com',
    storageBucket: 'winitcode.firebasestorage.app',
    measurementId: 'G-L8BEWKZFZD',
});

const messaging = firebase.messaging();

// Custom Logic for WinIt Web Notifications
messaging.onBackgroundMessage((payload) => {
    console.log('[firebase-messaging-sw.js] Received background message ', payload);

    // Default Title and Body
    let notificationTitle = payload.notification.title || "WinIt Code";
    const notificationBody = payload.notification.body || "New content available!";

    // 1. Tagging & Emojis
    // We expect 'type' in data payload: 'code', 'game_center', 'money_back'
    const type = payload.data && payload.data.type ? payload.data.type : 'default';
    let tag = 'winit_general';
    let icon = '/icons/large192x192.png'; // Default Large Icon
    let image = payload.notification.image || '/icons/big500x300.png'; // Default Big Picture

    // Categorization Logic
    switch (type) {
        case 'code':
            notificationTitle = `🎁 ${notificationTitle}`;
            tag = 'code';
            break;
        case 'game_center':
            notificationTitle = `🎮 ${notificationTitle}`;
            tag = 'game_center';
            break;
        case 'money_back':
            notificationTitle = `💲 ${notificationTitle}`;
            tag = 'money_back';
            break;
        case 'news': // Legacy support
            notificationTitle = `📰 ${notificationTitle}`;
            tag = 'news';
            break;
        default:
            notificationTitle = `🔔 ${notificationTitle}`;
            break;
    }

    const notificationOptions = {
        body: notificationBody,
        icon: icon, // Small/Square Icon (192x192)
        image: image, // Big Picture (Banner)
        tag: tag, // Grouping
        renotify: true, // Alert again even if tag exists
        data: payload.data, // Pass data to click handler
        badge: '/icons/Icon-maskable-192.png', // Monochrome badge if available
        actions: [
            {
                action: 'open_url',
                title: 'Ver Ahora'
            }
        ],
        requireInteraction: true // Keep until dismissed
    };

    return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Click Handler
self.addEventListener('notificationclick', function (event) {
    console.log('[firebase-messaging-sw.js] Notification click Received.', event);
    event.notification.close();

    // Open URL Logic
    const urlToOpen = event.notification.data.click_action || '/';
    event.waitUntil(
        clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function (windowClients) {
            // Check if already open
            for (let i = 0; i < windowClients.length; i++) {
                const client = windowClients[i];
                if (client.url === urlToOpen && 'focus' in client) {
                    return client.focus();
                }
            }
            if (clients.openWindow) {
                return clients.openWindow(urlToOpen);
            }
        })
    );
});
