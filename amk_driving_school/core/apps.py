from django.apps import AppConfig


class CoreConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'core'

    def ready(self):
        import os
        from firebase_admin import credentials, initialize_app
        path = os.getenv("FIREBASE_CREDENTIALS")
        if path and not len(initialize_app._apps):  # type: ignore # init once
            cred = credentials.Certificate(path)
            try: initialize_app(cred)
            except ValueError: pass