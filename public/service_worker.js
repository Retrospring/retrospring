const OFFLINE_CACHE_NAME = "offline";
// Bumping this version will force an update of the service worker
// eslint-disable-next-line @typescript-eslint/no-unused-vars
const OFFLINE_PAGE_VERSION = 1;
const OFFLINE_CACHE_PATHS = [
  "/pwa_offline.html",
  "/images/errors/small/404.png",
  "/images/errors/medium/404.png",
  "/images/errors/original/404.png"
];

self.addEventListener('push', function (event) {
  if (event.data) {
    const contents = event.data.json();
    navigator.setAppBadge(contents.data.badge);

    event.waitUntil(self.registration.showNotification(contents.title, contents));
  } else {
    console.error("Push event received, but it didn't contain any data.", event);
  }
});

self.addEventListener('notificationclick', async event => {
  if ("click_url" in event.notification.data) {
    event.preventDefault();
    return clients.openWindow(event.notification.data.click_url, "_blank").then(result => {
      event.notification.close();
      return result;
    });
  }
});

self.addEventListener('install', function (event) {
  event.waitUntil(
    (async () => {
      const cache = await caches.open(OFFLINE_CACHE_NAME);
      await cache.addAll(OFFLINE_CACHE_PATHS);
    })()
  );
  // Immediately activate new versions of the service worker instead of waiting
  self.skipWaiting();
});

self.addEventListener('fetch', function (event) {
  const url = new URL(event.request.url);
  if (event.request.method !== 'GET' || !OFFLINE_CACHE_PATHS.includes(url.pathname)) return;

  event.respondWith(
    (async () => {
      try {
        // Try to load the resource
        return await fetch(event.request);
      } catch (error) {
        // Show an error page if offline
        console.log("Fetch failed; returning offline page instead.", error);

        const cache = await caches.open(OFFLINE_CACHE_NAME);
        return await cache.match(OFFLINE_CACHE_PATHS[0]);
      }
    })()
  );
});
