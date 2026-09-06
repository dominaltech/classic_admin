// Classic Admin PWA Service Worker
const CACHE_NAME = 'classic-admin-v1';
const ASSETS_TO_CACHE = [
  './index.html',
  './orders.html',
  './categories.html',
  './materials.html',
  './all-products.html',
  './add-product.html',
  './banners.html',
  './users.html',
  './styles.css',
  './config.js',
  './admin.js',
  './manifest.json'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(ASSETS_TO_CACHE);
    })
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys.map((key) => {
          if (key !== CACHE_NAME) {
            return caches.delete(key);
          }
        })
      );
    })
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  // Only cache GET requests that are not to Supabase API
  if (event.request.method !== 'GET' || event.request.url.includes('supabase.co')) {
    return;
  }

  event.respondWith(
    fetch(event.request).catch(() => {
      return caches.match(event.request);
    })
  );
});
