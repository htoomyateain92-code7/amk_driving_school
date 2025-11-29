document.addEventListener("DOMContentLoaded", function() {
    const navbarRight = document.querySelector('.navbar-nav.ml-auto');
    
    if (navbarRight) {
        // 1. Notification HTML Structure (Bootstrap 4 style used by Jazzmin)
        const notificationHTML = `
            <li class="nav-item dropdown">
                <a class="nav-link" data-toggle="dropdown" href="#" aria-expanded="false">
                    <i class="fas fa-bell"></i>
                    <span class="badge badge-danger navbar-badge" id="notif-badge" style="font-size: 0.6em; top: 0px; right: 0px;">0</span>
                </a>
                <div class="dropdown-menu dropdown-menu-lg dropdown-menu-right" id="notif-dropdown">
                    <span class="dropdown-item dropdown-header" id="notif-header">0 Notifications</span>
                    <div class="dropdown-divider"></div>
                    <div id="notif-list">
                        <a href="#" class="dropdown-item">No new notifications</a>
                    </div>
                    <div class="dropdown-divider"></div>
                    <a href="/admin/core/notification/" class="dropdown-item dropdown-footer">See All Notifications</a>
                </div>
            </li>
        `;

        // 2. UI ကို User Profile ဘေးနားမှာ ထည့်လိုက်မယ် (Prepend)
        navbarRight.insertAdjacentHTML('afterbegin', notificationHTML);

        // 3. Data လှမ်းဆွဲမည့် Function
        function fetchNotifications() {
            fetch('/api/v1/admin/notifications/')
                .then(response => response.json())
                .then(data => {
                    // Update Badge Count
                    const badge = document.getElementById('notif-badge');
                    const header = document.getElementById('notif-header');
                    const list = document.getElementById('notif-list');

                    badge.innerText = data.count;
                    header.innerText = data.count + " Notifications";
                    
                    // Badge အရောင်ပြောင်း (၀ ဆိုရင် ဖျောက်ထားမယ်)
                    if (data.count === 0) {
                        badge.style.display = 'none';
                    } else {
                        badge.style.display = 'inline-block';
                    }

                    // Update Dropdown List
                    list.innerHTML = '';
                    if (data.count > 0) {
                        data.notifications.forEach(notif => {
                            list.innerHTML += `
                                <a href="${notif.url}" class="dropdown-item">
                                    <i class="fas fa-envelope mr-2"></i> ${notif.title}
                                    <span class="float-right text-muted text-sm">${notif.time}</span>
                                </a>
                                <div class="dropdown-divider"></div>
                            `;
                        });
                    } else {
                        list.innerHTML = '<a href="#" class="dropdown-item">No new notifications</a>';
                    }
                });
        }

        // 4. ပထမအကြိမ် Data ဆွဲမယ်
        fetchNotifications();

        // 5. (Optional) 10 စက္ကန့်တစ်ခါ Auto Refresh လုပ်မယ် (Polling)
        // သို့မဟုတ် FCM onMessage တွင် fetchNotifications() ကို ခေါ်နိုင်သည်
        setInterval(fetchNotifications, 10000);
        
        // 6. FCM Real-time ချိတ်ဆက်ခြင်း (ယခင် FCM setup ရှိလျှင်)
        // အကယ်၍ သင့်တွင် firebase messaging object ရှိလျှင် အောက်ပါအတိုင်း ပေါင်းထည့်ပါ
        if (typeof messaging !== 'undefined') {
            messaging.onMessage((payload) => {
                console.log("Realtime update triggered");
                fetchNotifications(); // Notification ဝင်လာတာနဲ့ Count ကို ချက်ချင်း update လုပ်မယ်
            });
        }
    }
});