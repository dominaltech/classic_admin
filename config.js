// CLASSIC PWA ADMIN — CONFIGURATION & SUPABASE INITIALIZER
// Classic Collection Solapur (classicsolapur.com)

const SUPABASE_URL = "https://mizbiarhnxzrpfuodqnj.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1pemJpYXJobnh6cnBmdW9kcW5qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg0OTg3NTYsImV4cCI6MjEwNDA3NDc1Nn0.plMkDTZJ7wy2D6yLWtRmJU_gvJ9z-zZYXumbOlWHCrU";

window.CLASSIC_CONFIG = {
  BRAND_NAME: "Classic Collection Solapur",
  DOMAIN: "classicsolapur.com",
  SUPABASE_URL: SUPABASE_URL,
  SUPABASE_ANON_KEY: SUPABASE_ANON_KEY,
};

window.adminSupabase = null;

function initAdminSupabase() {
  if (window.adminSupabase) return window.adminSupabase;
  if (window.supabase && typeof window.supabase.createClient === 'function') {
    try {
      const client = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
        auth: {
          persistSession: true,
          autoRefreshToken: true,
          detectSessionInUrl: true,
        },
      });
      window.adminSupabase = client;
      console.log('Classic Admin Supabase client initialized.');
      return client;
    } catch (err) {
      console.error('Failed to initialize Supabase client:', err);
    }
  }
  return null;
}

initAdminSupabase();

let initRetries = 0;
const retryTimer = setInterval(() => {
  if (initAdminSupabase() || initRetries > 20) {
    clearInterval(retryTimer);
    document.dispatchEvent(new CustomEvent('adminSupabaseReady'));
  }
  initRetries++;
}, 100);
