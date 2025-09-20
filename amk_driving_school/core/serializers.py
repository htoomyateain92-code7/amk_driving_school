from optparse import Option
import random
from rest_framework import serializers
from .models import Article, Course, Batch, Question, Quiz, Session, DeviceToken, Submission

from django.db.models import Q
from .models import Enrollment, Session
from core import models




class CourseSer(serializers.ModelSerializer):
    class Meta: model=Course; fields="__all__"

class BatchSer(serializers.ModelSerializer):
    course = CourseSer(read_only=True)
    course_id = serializers.PrimaryKeyRelatedField(source="course", queryset=Course.objects.all(), write_only=True)
    class Meta: model=Batch; fields=("id","title","course","course_id","instructor","start_date","end_date")

class SessionSer(serializers.ModelSerializer):
    course_title = serializers.CharField(source="batch.course.title", read_only=True)
    class Meta: model=Session; fields=("id","batch","start_dt","end_dt","status","reason","course_title")

class DeviceTokenSer(serializers.ModelSerializer):
    class Meta: model=DeviceToken; fields=("token","platform")



class EnrollmentCreateSer(serializers.ModelSerializer):
    class Meta:
        model = Enrollment
        fields = ("user", "batch", "status")
        extra_kwargs = {"status": {"default": "active"}}

    def validate(self, attrs):
        user = attrs["user"]
        batch = attrs["batch"]

        # 1) duplicate
        if Enrollment.objects.filter(user=user, batch=batch, status="active").exists():
            raise serializers.ValidationError("Already enrolled.")

        # 2) time clash
        existing_sessions = Session.objects.filter(
            batch__enrollment__user=user,
            batch__enrollment__status="active",
            status="scheduled"
        )
        target_sessions = Session.objects.filter(batch=batch, status="scheduled")
        # overlap: A.start < B.end and A.end > B.start
        clash = existing_sessions.filter(
            Q(start_dt__lt=models.OuterRef("end_dt")) & # type: ignore
            Q(end_dt__gt=models.OuterRef("start_dt")) # type: ignore
        ).filter(
            models.Exists(target_sessions.values("start_dt","end_dt") # type: ignore
                        .filter(start_dt__lt=models.OuterRef("end_dt"), # type: ignore
                                end_dt__gt=models.OuterRef("start_dt"))) # type: ignore
        ).exists()

        # simpler & explicit (iterate target sessions)
        if not clash:
            for t in target_sessions:
                if existing_sessions.filter(start_dt__lt=t.end_dt,
                                            end_dt__gt=t.start_dt).exists():
                    clash = True
                    break

        if clash:
            raise serializers.ValidationError("Schedule conflict with your existing classes.")
        return attrs



class OptionPublicSer(serializers.ModelSerializer):
    class Meta:
        model = Option
        fields = ["id", "text"]  # is_correct မထုတ်!

class QuestionPublicSer(serializers.ModelSerializer):
    options = serializers.SerializerMethodField()
    order_items = serializers.SerializerMethodField()

    class Meta:
        model = Question
        fields = ["id", "text", "qtype", "options", "order_items"]

    def get_options(self, obj):
        if obj.qtype != "MCQ": return None
        items = list(obj.options.all())
        random.shuffle(items)
        return OptionPublicSer(items, many=True).data

    def get_order_items(self, obj):
        if obj.qtype != "ORDER": return None
        items = list(obj.order_items.all())
        random.shuffle(items)
        return [{"id": it.id, "text": it.text} for it in items]

class QuizDetailSer(serializers.ModelSerializer):
    questions = QuestionPublicSer(many=True, read_only=True)
    class Meta:
        model = Quiz
        fields = ["id", "title", "time_limit_sec", "questions"]

class SubmissionSer(serializers.ModelSerializer):
    class Meta:
        model = Submission
        fields = ["id", "quiz", "student", "score", "started_at", "finished_at"]
        read_only_fields = ["student", "score", "started_at", "finished_at"]



class ArticleSer(serializers.ModelSerializer):
    class Meta:
        model = Article
        fields = ["id","title","body","tags","published","created_at","updated_at"]
