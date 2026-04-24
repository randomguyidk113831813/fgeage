self.addEventListener('install', (e) => {
  console.log('Service Worker: Installed');
});

self.addEventListener('fetch', (e) => {
  // Pass through everything
  e.respondWith(fetch(e.request));
});
