import os; from celery import Celery
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "amk_driving_school.settings")
app = Celery("amk_driving_school")
app.config_from_object("django.conf:settings", namespace="CELERY")
app.autodiscover_tasks()
