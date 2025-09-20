from firebase_admin import messaging

def push(tokens, title, body, data=None):
    """
    Helper to send FCM multicast push notifications.
    tokens: list of device tokens
    title, body: notification text
    data: optional dict payload
    """
    if not tokens:
        return
    message = messaging.MulticastMessage(
        tokens=tokens,
        notification=messaging.Notification(title=title, body=body),
        data={k: str(v) for k, v in (data or {}).items()},
    )
    messaging.send_multicast(message)
