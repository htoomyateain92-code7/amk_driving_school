// static/js/fcm_admin_config.js

document.addEventListener('DOMContentLoaded', function() {
    // 1. Firebase Config (သင့် Console မှ ကူးထည့်ပါ)
    const firebaseConfig = {
    apiKey: "AIzaSyCNPPugjniwDxlNecC8VLWIgzMfPlOQZvs",
    authDomain: "amk-driving-training-sch-285cb.firebaseapp.com",
    projectId: "amk-driving-training-sch-285cb",
    storageBucket: "amk-driving-training-sch-285cb.firebasestorage.app",
    messagingSenderId: "766958394314",
    appId: "1:766958394314:web:ce3ae1eb5e151077bdcd33"
    };

    // 2. Initialize Firebase
    if (!firebase.apps.length) {
        firebase.initializeApp(firebaseConfig);
    }
    const messaging = firebase.messaging();

    // 3. Permission တောင်းခံခြင်း & Token ရယူခြင်း
    function requestPermissionAndSaveToken() {
        Notification.requestPermission().then(permission => {
            if (permission === 'granted') {
                console.log('Notification permission granted.');
                
                // Get Token
                messaging.getToken({ vapidKey: "YOUR_VAPID_PUBLIC_KEY_HERE" }).then((currentToken) => {
                    if (currentToken) {
                        console.log('Admin Web Token:', currentToken);
                        // Token ကို Backend သို့ ပို့ပြီး သိမ်းဆည်းမည်
                        saveTokenToBackend(currentToken);
                    } else {
                        console.log('No registration token available.');
                    }
                }).catch((err) => {
                    console.log('An error occurred while retrieving token. ', err);
                });
            }
        });
    }

    // 4. Backend API သို့ Token ပို့ခြင်း
    function saveTokenToBackend(token) {
        fetch('/api/devices/register_admin/', { // Backend URL
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRFToken': getCookie('csrftoken'), // Django CSRF Token
            },
            body: JSON.stringify({ 
                token: token,
                platform: 'web_admin' 
            })
        }).then(response => {
            if (response.ok) console.log("Admin Token saved to server.");
        });
    }

    // CSRF Token Helper
    function getCookie(name) {
        let cookieValue = null;
        if (document.cookie && document.cookie !== '') {
            const cookies = document.cookie.split(';');
            for (let i = 0; i < cookies.length; i++) {
                const cookie = cookies[i].trim();
                if (cookie.substring(0, name.length + 1) === (name + '=')) {
                    cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                    break;
                }
            }
        }
        return cookieValue;
    }

    // Start Process
    requestPermissionAndSaveToken();
    
    // Foreground Message Handling (Optional - Toast ပြချင်ရင်)
    messaging.onMessage((payload) => {
        console.log('Message received. ', payload);
        alert("New Notification: " + payload.notification.title); 
        // ဒီနေရာမှာ window.location.reload() ထည့်ရင် Real-time refresh ဖြစ်မယ်
    });
});