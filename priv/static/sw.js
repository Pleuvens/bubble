const CACHE = "bubble-v1";
const STATIC_ASSETS = ["/assets/app.css", "/assets/app.js"];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE).then((cache) => cache.addAll(STATIC_ASSETS))
  );
  self.skipWaiting();
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener("fetch", (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // Only handle same-origin GET requests
  if (request.method !== "GET" || url.origin !== self.location.origin) return;

  // Skip LiveView WebSocket and API paths
  if (url.pathname.startsWith("/live") || url.pathname.startsWith("/phoenix")) return;

  // Cache-first for static assets
  if (url.pathname.startsWith("/assets/") || url.pathname.startsWith("/icons/")) {
    event.respondWith(
      caches.match(request).then((cached) => cached || fetch(request))
    );
    return;
  }

  // Network-first for pages — fall back to a minimal offline response
  event.respondWith(
    fetch(request).catch(() =>
      caches.match(request).then(
        (cached) =>
          cached ||
          new Response("<h1>Bubble</h1><p>You are offline.</p>", {
            headers: { "Content-Type": "text/html" }
          })
      )
    )
  );
});
