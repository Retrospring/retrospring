self.addEventListener('push', function (event) {
  if (event.data) {
    const notification = event.data.json();

    event.waitUntil(self.registration.showNotification(notification.title, {
      body: notification.body,
      tag: notification.type,
      icon: notification.icon,
    }));
  } else {
    console.error("Push event received, but it didn't contain any data.", event);
  }
});

self.addEventListener('notificationclick', async event => {
  if (event.notification.tag === 'inbox') {
    event.preventDefault();
    return clients.openWindow("/inbox", "_blank").then(result => {
      event.notification.close();
      return result;
    });
  } else {
    console.warn(`Unhandled notification tag: ${event.notification.tag}`);
  }
});
