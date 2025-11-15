from rest_framework import serializers

from core.models import Article, Course, Notification, Option, Question, Quiz, Session

class DashboardChartDataSerializer(serializers.Serializer):
    """ လစဉ်ဝင်ငွေ ဇယားအတွက် Data """
    month = serializers.CharField(max_length=10)
    revenue = serializers.DecimalField(max_digits=10, decimal_places=2)

class OwnerDashboardSerializer(serializers.Serializer):
    """ Owner Dashboard Data Structure """
    total_revenue = serializers.DecimalField(max_digits=10, decimal_places=2)
    total_students = serializers.IntegerField()
    active_courses = serializers.IntegerField()
    monthly_chart_data = DashboardChartDataSerializer(many=True)


class CourseSerializer(serializers.ModelSerializer):
    """ core.Course Model အတွက် CRUD Operations များတွင် အသုံးပြုရန် """
    class Meta:
        model = Course
        fields = ['id', 'title', 'code', 'description', 'total_duration_hours', 'max_session_duration_minutes', 'is_public']
        read_only_fields = ['id']


class OptionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Option
        fields = ['id', 'text', 'is_correct'] # Answer key for Admin/Owner only

class QuestionSerializer(serializers.ModelSerializer):
    options = OptionSerializer(many=True, read_only=True)
    # 💡 Admin/Owner အတွက် Question Creation မှာ Option တွေကို Nested Serializer နဲ့ ကိုင်တွယ်ဖို့ လိုအပ်နိုင်ပါသည်။
    class Meta:
        model = Question
        fields = ['id', 'text', 'qtype', 'options']

class QuizSerializer(serializers.ModelSerializer):
    """ Quiz List/Detail အတွက် """
    question_count = serializers.SerializerMethodField()
    
    class Meta:
        model = Quiz
        fields = ['id', 'title', 'course', 'time_limit_sec', 'is_published', 'question_count']
        
    def get_question_count(self, obj):
        return obj.questions.count()

# --- 2. Blog/Article Serializers ---
class ArticleSerializer(serializers.ModelSerializer):
    tags = serializers.SlugRelatedField(
        many=True,
        read_only=True,
        slug_field='name'
    )
    class Meta:
        model = Article
        fields = ['id', 'title', 'body', 'tags', 'published', 'created_at', 'updated_at']
        read_only_fields = ['created_at', 'updated_at']

# --- 3. Notification Serializers ---
class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ['id', 'title', 'body', 'is_read', 'created_at']
        read_only_fields = ['user', 'created_at']



class InstructorSessionSerializer(serializers.ModelSerializer):
    """ Instructor ရဲ့ Schedule ထဲက Session အသေးစိတ် """
    course_title = serializers.CharField(source='batch.course.title', read_only=True)
    batch_title = serializers.CharField(source='batch.title', read_only=True)

    class Meta:
        model = Session
        fields = ['id', 'course_title', 'batch_title', 'start_dt', 'end_dt', 'status']

class InstructorDashboardSerializer(serializers.Serializer):
    """ Instructor Dashboard Data Structure """
    today_schedule = InstructorSessionSerializer(many=True) # ယနေ့ အချိန်ဇယား
    pending_submissions_count = serializers.IntegerField()  # စစ်ဆေးရန် ကျန်ရှိသော Quiz အရေအတွက်
    pending_tips_count = serializers.IntegerField(default=0) # တိုင်ပင်ကြံဉာဏ် (ယာယီ)



class SessionCRUDSerializer(serializers.ModelSerializer):
    class Meta:
        model = Session
        fields = ['id', 'batch', 'start_dt', 'end_dt', 'status', 'reason']
        read_only_fields = ['id']
        
    # 💡 Validation: Session ရဲ့ 'batch' ဟာ လက်ရှိ Instructor ရဲ့ Batch ဖြစ်ရမည်
    def validate_batch(self, value):
        user = self.context['request'].user
        if not user.is_staff: # Admin မဟုတ်ရင် စစ်
            if value.instructor != user:
                raise serializers.ValidationError("သင်သည် ဤ Batch ၏ နည်းပြမဟုတ်ပါ။")
        return value



class StudentUpcomingSessionSerializer(serializers.ModelSerializer):
    """ ကျောင်းသား၏ လာမည့် Session အသေးစိတ် """
    batch_title = serializers.CharField(source='batch.title', read_only=True)
    
    class Meta:
        model = Session
        fields = ['id', 'batch_title', 'start_dt', 'end_dt', 'status']

class StudentDashboardSerializer(serializers.Serializer):
    """ Student Dashboard Data Structure """
    enrolled_course_count = serializers.IntegerField() # စာရင်းသွင်းထားသော သင်တန်းအရေအတွက်
    completed_sessions = serializers.IntegerField()    # ပြီးစီးသော Session အရေအတွက်
    total_sessions = serializers.IntegerField()        # စုစုပေါင်း Session အရေအတွက်
    progress_percentage = serializers.FloatField()     # တိုးတက်မှုနှုန်း (%)
    upcoming_sessions = StudentUpcomingSessionSerializer(many=True) # လာမည့် Session များ
    last_quiz_score = serializers.FloatField(allow_null=True) # နောက်ဆုံး Quiz ရလဒ်