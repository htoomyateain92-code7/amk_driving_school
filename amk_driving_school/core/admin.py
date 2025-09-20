# core/admin.py

from django.contrib import admin
from django.utils import timezone
from django.utils.timezone import localtime
from .models import Answer, Article, Course, Batch, Option, OrderItem, Question, Quiz, Session, Enrollment, DeviceToken, Submission


# ---------- Inlines ----------
class SessionInline(admin.TabularInline):
    model = Session
    extra = 0
    fields = ("start_dt", "end_dt", "status", "reason")
    readonly_fields = ()
    ordering = ("start_dt",)
    show_change_link = True


class EnrollmentInline(admin.TabularInline):
    model = Enrollment
    extra = 0
    fields = ("user", "status")
    autocomplete_fields = ("user",)
    show_change_link = True


class BatchInline(admin.TabularInline):
    model = Batch
    extra = 0
    fields = ("title", "instructor", "start_date", "end_date")
    autocomplete_fields = ("instructor",)
    show_change_link = True


# ---------- Admins ----------
@admin.register(Course)
class CourseAdmin(admin.ModelAdmin):
    list_display = ("id", "title", "code", "is_public", "batches_count")
    list_filter = ("is_public",)
    search_fields = ("title", "code")
    inlines = [BatchInline]

    @admin.display(description="Batches")
    def batches_count(self, obj):
        return obj.batches.count()


@admin.register(Batch)
class BatchAdmin(admin.ModelAdmin):
    list_display = ("id", "title", "course", "instructor", "start_date", "end_date", "sessions_count")
    list_filter = ("course", "instructor",)
    search_fields = ("title", "course__title", "instructor__username")
    date_hierarchy = "start_date"
    autocomplete_fields = ("course", "instructor")
    inlines = [SessionInline, EnrollmentInline]

    @admin.display(description="Sessions")
    def sessions_count(self, obj):
        return obj.sessions.count()

    def get_queryset(self, request):
        qs = super().get_queryset(request)
        return qs.select_related("course", "instructor")


@admin.action(description="Mark selected sessions as CANCELED")
def mark_sessions_canceled(modeladmin, request, queryset):
    queryset.update(status="canceled", reason="Admin canceled")


@admin.register(Session)
class SessionAdmin(admin.ModelAdmin):
    list_display = ("id", "batch", "course_title", "start_local", "end_local", "status")
    list_filter = ("status", "batch__course")
    search_fields = ("batch__title", "batch__course__title")
    ordering = ("start_dt",)
    actions = [mark_sessions_canceled]

    @admin.display(description="Course")
    def course_title(self, obj):
        return obj.batch.course.title

    @admin.display(description="Start (Local)")
    def start_local(self, obj):
        return localtime(obj.start_dt).strftime("%Y-%m-%d %H:%M")

    @admin.display(description="End (Local)")
    def end_local(self, obj):
        return localtime(obj.end_dt).strftime("%Y-%m-%d %H:%M")

    def get_queryset(self, request):
        qs = super().get_queryset(request)
        return qs.select_related("batch", "batch__course")


@admin.register(Enrollment)
class EnrollmentAdmin(admin.ModelAdmin):
    list_display = ("id", "user", "batch", "status")
    list_filter = ("status", "batch__course")
    search_fields = ("user__username", "batch__title")
    autocomplete_fields = ("user", "batch")

    def get_queryset(self, request):
        qs = super().get_queryset(request)
        return qs.select_related("user", "batch", "batch__course")


@admin.register(DeviceToken)
class DeviceTokenAdmin(admin.ModelAdmin):
    list_display = ("id", "user", "platform", "updated_at_short")
    list_filter = ("platform",)
    search_fields = ("user__username", "token")
    autocomplete_fields = ("user",)

    @admin.display(description="Updated")
    def updated_at_short(self, obj):
        return timezone.localtime(obj.updated_at).strftime("%Y-%m-%d %H:%M")




# admin.site.register(Quiz)
# admin.site.register(Question)
# admin.site.register(Option)
# admin.site.register(OrderItem)
# admin.site.register(Submission)
# admin.site.register(Answer)


# admin.site.register(Article)

class OptionInline(admin.TabularInline):
    model = Option
    extra = 1

class OrderItemInline(admin.TabularInline):
    model = OrderItem
    extra = 1

class QuestionAdmin(admin.ModelAdmin):
    list_display = ("id", "quiz", "qtype", "short_text")
    list_filter  = ("qtype", "quiz")
    search_fields = ("text", "quiz__title")
    inlines = [OptionInline, OrderItemInline]
    ordering = ("quiz", "id")

    @admin.display(description="Question")
    def short_text(self, obj):
        return (obj.text[:60] + "…") if len(obj.text) > 60 else obj.text

class QuestionInline(admin.StackedInline):
    model = Question
    extra = 0
    show_change_link = True

@admin.register(Quiz)
class QuizAdmin(admin.ModelAdmin):
    list_display  = ("id", "title", "course", "time_limit_sec", "is_published")
    list_filter   = ("is_published", "course")
    search_fields = ("title", "course__title")
    inlines       = [QuestionInline]
    ordering      = ("title",)

admin.site.register(Question, QuestionAdmin)

class AnswerInline(admin.TabularInline):
    model = Answer
    extra = 0
    readonly_fields = ("question", "selected_option", "given_order")

@admin.register(Submission)
class SubmissionAdmin(admin.ModelAdmin):
    list_display  = ("id", "quiz", "student", "score", "started_at", "finished_at")
    list_filter   = ("quiz", "started_at", "finished_at")
    search_fields = ("student__username", "quiz__title")
    date_hierarchy = "started_at"
    inlines       = [AnswerInline]
    ordering      = ("-started_at",)

@admin.register(Answer)
class AnswerAdmin(admin.ModelAdmin):
    list_display  = ("id", "submission", "question", "selected_option", "short_order")
    search_fields = ("submission__student__username", "question__text")
    list_filter   = ("question__quiz",)
    readonly_fields = ("submission", "question", "selected_option", "given_order")

    @admin.display(description="Order")
    def short_order(self, obj):
        if obj.given_order:
            return ",".join(map(str, obj.given_order[:6])) + ("…" if len(obj.given_order) > 6 else "")
        return "-"


@admin.register(Article)
class ArticleAdmin(admin.ModelAdmin):
    list_display  = ("id", "title", "published", "tag_list", "created_at", "updated_at")
    list_filter   = ("published", "created_at")
    search_fields = ("title", "body")
    date_hierarchy = "created_at"
    ordering      = ("-created_at",)

    @admin.display(description="Tags")
    def tag_list(self, obj):
        return ", ".join(obj.tags or [])