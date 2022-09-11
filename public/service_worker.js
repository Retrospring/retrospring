self.addEventListener('push', function (event) {
  if (event.data) {
    const notification = event.data.json();
    console.log(event.data);

    event.waitUntil(self.registration.showNotification(notification.title, {
      body: notification.body
    }));
  } else {
    console.error("Push event received, but it didn't contain any data.", event);
  }
});
