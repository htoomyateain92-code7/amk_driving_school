from django.apps import AppConfig
import firebase_admin
from firebase_admin import credentials
from django.conf import settings
import os

class CoreConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'core'

    def ready(self):
        import core.signals
        cred_path = os.path.join(settings.BASE_DIR, 'firebase-service-account.json')
        if os.path.exists(cred_path) and not firebase_admin._apps:
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
            print("Firebase Admin SDK Initialized.")
