
import random
from rest_framework import serializers # type: ignore

from accounts.serializers import SimpleUserSerializer
from .models import Article, Booking, Course, Batch, Notification, Option, Question, Quiz, Session, DeviceToken, Submission

from django.db.models import Q
from .models import  Session
from core import models
from django.utils import timezone
import pytz






class TimezoneAwareSerializer(serializers.ModelSerializer):
    start_dt = serializers.DateTimeField(format='%Y-%m-%dT%H:%M:%S%z', default_timezone= # type: ignore
                pytz.timezone('Asia/Yangon'))
    end_dt = serializers.DateTimeField(format='%Y-%m-%dT%H:%M:%S%z', default_timezone= # type: ignore
                pytz.timezone('Asia/Yangon'))





# --- BATCH SERIALIZERS ---

class BatchSerializer(serializers.ModelSerializer):
    """Batch တွေရဲ့ list ကိုပြ하기အတွက် ရိုးရှင်းသော serializer"""
    instructor = SimpleUserSerializer(read_only=True)
    # Course ရဲ့ id ကိုပဲပြမယ်၊ Course တစ်ခုလုံးကို nested မလုပ်ဘူး
    course_id = serializers.PrimaryKeyRelatedField(read_only=True)

    class Meta:
        model = Batch
        fields = ['id', 'title', 'start_date', 'end_date', 'instructor', 'course_id']



# --- COURSE SERIALIZERS ---

class CourseListSerializer(serializers.ModelSerializer):
    """Course တွေရဲ့ list ကိုပြ하기အတွက် ရိုးရှင်းသော serializer"""
    class Meta:
        model = Course
        fields =  "__all__"

# class CourseDetailSerializer(serializers.ModelSerializer):
#     """Course တစ်ခုရဲ့ အသေးစိတ်ကိုပြ하기အတွက် (nested batches ပါဝင်)"""
#     # ဒီ course နဲ့ဆိုင်တဲ့ batch တွေကိုပြတဲ့အခါ အပေါ်က ရိုးရှင်းတဲ့ BatchSerializer ကိုသုံးမယ်
#     batches = BatchSerializer(many=True, read_only=True)

#     class Meta:
#         model = Course
#         fields = ['id', 'title', 'code', 'description', 'is_public', 'total_duration_hours', 'batches']

class CourseDetailSerializer(serializers.ModelSerializer):
    """Course တစ်ခုရဲ့ အသေးစိတ်ကိုပြ하기အတွက် (nested batches ပါဝင်)"""
    batches = BatchSerializer(many=True, read_only=True)
    
    # ဤ Fields များကို ထပ်ထည့်ရန် လိုအပ်သည်
    required_sessions = serializers.IntegerField(read_only=True) 
    max_session_duration_minutes = serializers.IntegerField(read_only=True)

    class Meta:
        model = Course
        fields = [
            'id', 'title', 'code', 'description', 'is_public', 
            'total_duration_hours', 'required_sessions', 'max_session_duration_minutes', # ထပ်ထည့်လိုက်သော Fields များ
            'batches', 'price'
        ]


class SessionSer(serializers.ModelSerializer):
    course_title = serializers.CharField(source="batch.course.title", read_only=True)
    class Meta: model=Session; fields=("id","batch","start_dt","end_dt","status","reason","course_title")



class BatchDetailSerializer(serializers.ModelSerializer):
    """Batch တစ်ခုရဲ့ အသေးစိတ်ကိုပြ하기အတွက် (nested course နှင့် sessions ပါဝင်)"""
    # Course ရဲ့ အသေးစိတ်ကိုပြရန် (recursion မဖြစ်အောင် ListSerializer ကိုသုံးပါ)
    course = CourseListSerializer(read_only=True)

    # ဒီ batch နဲ့ဆိုင်တဲ့ session တွေအားလုံးကိုပြရန်
    sessions = SessionSer(many=True, read_only=True)

    # Use SimpleUserSerializer for consistency with BatchSerializer and Flutter's expectation
    instructor = SimpleUserSerializer(read_only=True)

    class Meta:
        model = Batch
        fields = ['id', 'title', 'start_date', 'end_date', 'course', 'instructor', 'sessions']


class DeviceTokenSer(serializers.ModelSerializer):
    class Meta: model=DeviceToken; fields=("token","platform")


class BookingListDetailSerializer(serializers.ModelSerializer):
    """
    Booking 。
    """
    student = SimpleUserSerializer(read_only=True)
    course = CourseListSerializer(read_only=True)
    sessions = SessionSer(many=True, read_only=True)

    class Meta:
        model = Booking
        fields = ['id', 'student', 'course', 'sessions', 'status', 'created_at']


class BookingCreateSerializer(serializers.ModelSerializer):
    """
    Flutter app
    """
    # Flutter から course_id と session_ids を受け取る
    course = serializers.PrimaryKeyRelatedField(queryset=Course.objects.all())
    sessions = serializers.PrimaryKeyRelatedField(queryset=Session.objects.all(), many=True)

    class Meta:
        model = Booking
        fields = ['course', 'sessions'] # status と student は view で自動的に設定されます

    def validate(self, attrs):
        course = attrs.get('course')
        sessions = attrs.get('sessions')

        # Validation 1: 選択されたセッションがすべて同じバッチに属しているか確認
        if len(set(s.batch for s in sessions)) > 1:
            raise serializers.ValidationError("All selected sessions must belong to the same batch.")

        # Validation 2: 選択されたセッションの合計時間がコースの合計時間と一致するか確認
        total_duration_minutes = sum((s.end_dt - s.start_dt).total_seconds() / 60 for s in sessions)
        required_duration_minutes = course.total_duration_hours * 60

        # 小さな誤差を許容するために round を使用
        if round(total_duration_minutes) != round(required_duration_minutes):
            raise serializers.ValidationError(
                f"The total duration of selected sessions ({total_duration_minutes} min) does not match "
                f"the required course duration ({required_duration_minutes} min)."
            )

        return attrs


# class EnrollmentCreateSer(serializers.ModelSerializer):
#     """
#     Serializer for creating a new enrollment.
#     """
#     user = serializers.StringRelatedField(read_only=True)

#     class Meta:
#         model = Enrollment
#         fields = ['id', 'user', 'batch', 'status']
#         read_only_fields = ['status']

#     def validate(self, attrs):

#         batch = attrs.get('batch')

#         user = self.context['request'].user


#         if Enrollment.objects.filter(user=user, batch=batch).exists():

#             raise serializers.ValidationError({"detail": "You are already enrolled in this batch."})

#         return attrs



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
        if obj.qtype != "MCQ": return None # None ကို ပြန်ပို့သည်
        items = list(obj.options.all())
        random.shuffle(items)
        return OptionPublicSer(items, many=True).data

    def get_order_items(self, obj):
        if obj.qtype != "ORDER": return None # None ကို ပြန်ပို့သည်
        # 💡 [CHECK]: related_name မှန်ကန်ကြောင်း သေချာပါစေ။
        try:
            items = list(obj.order_items.all())

            if not items:
                return []

            random.shuffle(items)
        # 💡 OptionPublicSer သည် Order Item များ၏ id, text ကိုသာ လိုအပ်သည်ဟု ယူဆပါသည်။
            return OptionPublicSer(items, many=True).data
        except Exception as e:
            print(f"Error in get_order_items: {e}")
            return [] # Error တက်ရင်တောင် [] ပြန်ပေးပါ။

    def to_representation(self, instance):
        # 1. Base representation ကို ခေါ်လိုက်တာနဲ့ get_options နှင့် get_order_items တို့ကို တွက်ပြီး data ထဲ ရောက်သွားပြီ။
        data = super().to_representation(instance)

        # 2. မေးခွန်းအမျိုးအစားအလိုက် မလိုအပ်သော key များကို တိကျစွာ ဖယ်ရှားခြင်း
        if instance.qtype == 'MCQ':
            # MCQ အတွက် options လိုအပ်ပြီး order_items မလိုအပ်ပါ။
            data.pop('order_items', None)

        elif instance.qtype == 'ORDER':
            # ORDER အတွက် order_items လိုအပ်ပြီး options မလိုအပ်ပါ။
            data.pop('options', None)

        else:
            # အခြား type များအတွက် နှစ်ခုလုံး ဖယ်ရှား
            data.pop('options', None)
            data.pop('order_items', None)
        return data

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


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ['id', 'title', 'body', 'is_read', 'created_at']




class AvailableSlotSerializer(serializers.Serializer):
    """
    AvailableSlotsView ကနေ တွက်ချက်ပြီး ပြန်ပေးမယ့် Time Slots များအတွက်
    """
    date = serializers.DateField(format="%Y-%m-%d", help_text="Session စမည့်နေ့စွဲ") # type: ignore
    start_time = serializers.TimeField(format="%H:%M", help_text="Session စမည့်အချိန်") # type: ignore
    end_time = serializers.TimeField(format="%H:%M", help_text="Session ပြီးဆုံးမည့်အချိန်") # type: ignore
    duration_minutes = serializers.IntegerField(help_text="Session ကြာချိန် (မိနစ်ဖြင့်)")
    instructor_id = serializers.IntegerField(help_text="ဆရာရဲ့ ID")
    batch_id = serializers.IntegerField(help_text="ဘိုကင်လုပ်မည့် Batch ID")