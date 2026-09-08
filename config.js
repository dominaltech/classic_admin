// CLASSIC COLLECTION SOLAPUR ADMIN CONFIGURATION

const SUPABASE_URL = "https://mizbiarhnxzrpfuodqnj.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1pemJpYXJobnh6cnBmdW9kcW5qIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg0OTg3NTYsImV4cCI6MjEwNDA3NDc1Nn0.plMkDTZJ7wy2D6yLWtRmJU_gvJ9z-zZYXumbOlWHCrU";

window.UR_CONFIG = {
  BRAND_NAME: "Classic Collection Solapur",
  DOMAIN: "classicsolapur.com",

  // Supabase Database & Auth Credentials
  SUPABASE_URL: SUPABASE_URL,
  SUPABASE_ANON_KEY: SUPABASE_ANON_KEY,

  // Cashfree Payment Gateway Credentials (READ FROM VERCEL ENV VARS)
  CASHFREE_APP_ID: (typeof process !== 'undefined' && process.env && process.env.CASHFREE_APP_ID) || "",
  CASHFREE_SECRET_KEY: (typeof process !== 'undefined' && process.env && process.env.CASHFREE_SECRET_KEY) || "",
  CASHFREE_ENV: "PRODUCTION",

  // Web Push Notifications VAPID Keys
  VAPID_SUBJECT: "mailto:support@classicsolapur.com",
  VAPID_PUBLIC_KEY: "",
  VAPID_PRIVATE_KEY: ""
};

window.CLASSIC_CONFIG = window.UR_CONFIG;
