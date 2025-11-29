/// web/firebase-messaging-sw.js

// Firebase JS SDK ကို import လုပ်ခြင်း (v9 compatibility)
// Note: Service Worker ထဲမှာ ဒီလို importScripts ကို သုံးရပါမယ်။
importScripts('https://www.gstatic.com/firebasejs/9.6.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.6.1/firebase-messaging-compat.js');

// 💡 သင့်ရဲ့ Firebase Config အချက်အလက်များ
const firebaseConfig = {
  apiKey: "AIzaSyCNPPugjniwDxlNecC8VLWIgzMfPlOQZvs",
  authDomain: "amk-driving-training-sch-285cb.firebaseapp.com",
  projectId: "amk-driving-training-sch-285cb",
  storageBucket: "amk-driving-training-sch-285cb.firebasestorage.app",
  messagingSenderId: "766958394314",
  appId: "1:766958394314:web:ce3ae1eb5e151077bdcd33"
};

// Firebase ကို Initialize လုပ်ခြင်း
firebase.initializeApp(firebaseConfig);

// Firebase Messaging ကို ရယူခြင်း
const messaging = firebase.messaging();

console.log('Firebase Service Worker initialized.');

// -----------------------------------------------------
// Background Notification ကို ကိုင်တွယ်ခြင်း
// -----------------------------------------------------

messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message: ', payload);

  // Notification Data ကို စစ်ဆေးခြင်း
  const notificationTitle = payload.notification ? payload.notification.title : 'New Notification';
  const notificationOptions = {
    body: payload.notification ? payload.notification.body : 'You have a new message.',
    icon: '/favicon.png', // 💡 သင့် Web favicon ကို သုံးရန်
    data: payload.data // Data payload ကို သိမ်းဆည်းထားခြင်း
  };

  // Notification ကို ပြသခြင်း
  return self.registration.showNotification(notificationTitle, notificationOptions);
});