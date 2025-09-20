# core/views.py
from datetime import date
from django.utils import timezone
from rest_framework import viewsets, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from drf_spectacular.utils import extend_schema, OpenApiExample
from .models import Article, Course, Batch, Quiz, Session, DeviceToken, Enrollment, Submission
from .serializers import ArticleSer, CourseSer, BatchSer, QuizDetailSer, SessionSer, DeviceTokenSer, EnrollmentCreateSer, SubmissionSer
from .services import generate_sessions
from django.db.models import Q
# Swagger/Redoc (drf-spectacular)
from drf_spectacular.utils import extend_schema, extend_schema_view


class IsInstructorOrAdmin(permissions.BasePermission):
    def has_permission(self, req, view):  # type: ignore
        # roles သုံးမယ်ဆို: return req.user.is_authenticated and req.user.role in ("owner","admin","instructor")
        return bool(req.user and req.user.is_authenticated and req.user.is_staff)


class IsAdminOrReadOnly(permissions.BasePermission):
    def has_permission(self, request, view):
        if request.method in permissions.SAFE_METHODS: return True
        return request.user and request.user.is_staff



class CourseViewSet(viewsets.ModelViewSet):
    queryset = Course.objects.all().order_by("title")
    serializer_class = CourseSer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        qs = super().get_queryset()
        public = self.request.query_params.get("public")
        return qs.filter(is_public=True) if public == "true" else qs


class BatchViewSet(viewsets.ModelViewSet):
    queryset = Batch.objects.select_related("course", "instructor")
    serializer_class = BatchSer
    permission_classes = [IsInstructorOrAdmin]

    @action(detail=False, methods=["GET"], permission_classes=[permissions.IsAuthenticated])
    def available_for_me(self, request):
        user = request.user
        # batch that has at least 1 session scheduled AND no overlap with user’s active sessions
        my_sessions = Session.objects.filter(batch__enrollment__user=user,
                                            batch__enrollment__status="active",
                                            status="scheduled")
        ok_batches = []
        for b in Batch.objects.all():
            ts = Session.objects.filter(batch=b, status="scheduled")
            if not ts.exists():  # no sessions yet → skip or include as you like
                continue
            overlap = False
            for s in ts:
                if my_sessions.filter(start_dt__lt=s.end_dt,
                                    end_dt__gt=s.start_dt).exists():
                    overlap = True; break
            if not overlap:
                ok_batches.append(b.id) # type: ignore
        qs = Batch.objects.filter(id__in=ok_batches)
        return Response(BatchSer(qs, many=True).data)


@extend_schema_view(
    list=extend_schema(description="List sessions", tags=["Sessions"]),
    retrieve=extend_schema(description="Retrieve a session", tags=["Sessions"]),
)
class SessionViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Session.objects.select_related("batch", "batch__course", "batch__instructor")
    serializer_class = SessionSer
    permission_classes = [permissions.IsAuthenticated]


    @action(detail=True, methods=["POST"], permission_classes=[IsInstructorOrAdmin])
    def mark_completed(self, request, pk=None):
        s = self.get_object()
        s.status = "completed"; s.save(update_fields=["status"])
        # notify enrolled students
        tokens = list(DeviceToken.objects.filter(
            user__enrollment__batch=s.batch,
            user__enrollment__status="active").values_list("token", flat=True).distinct())
        if tokens:
            messaging.send_multicast(messaging.MulticastMessage(
                tokens=tokens,
                notification=messaging.Notification(
                    title=f"{s.batch.course.title}",
                    body="Class marked as completed"),
                data={"type":"session.completed","session_id":str(s.id)}
            ))
        return Response({"ok": True})

    @extend_schema(
        description="Get today's sessions for the current instructor (Asia/Yangon).",
        responses={200: SessionSer(many=True)},
        tags=["Sessions"],
    )
    @action(detail=False, methods=["GET"], permission_classes=[permissions.IsAuthenticated])
    def today_for_teacher(self, request):
        ygn_today = timezone.localdate()
        qs = self.queryset.filter(
            start_dt__date=ygn_today,
            batch__instructor=request.user,
            status="scheduled",
        ).order_by("start_dt")
        return Response(SessionSer(qs, many=True).data)

    @extend_schema(
        description="Generate sessions from weekday template (60min×3days or 90min×2days).",
        request={
            "application/json": {
                "type": "object",
                "properties": {
                    "batch_id": {"type": "integer"},
                    "weekdays": {"type": "array", "items": {"type": "integer"}, "example": [0, 2, 4]},
                    "start_time": {"type": "string", "example": "16:00"},
                    "duration_min": {"type": "integer", "enum": [60, 90]},
                    "since": {"type": "string", "format": "date"},
                    "until": {"type": "string", "format": "date"},
                },
                "required": ["batch_id", "weekdays", "start_time", "duration_min", "since", "until"],
            }
        },
        responses={200: {"type": "object", "properties": {"created": {"type": "integer"}}}},
        tags=["Sessions"],
    )
    @action(detail=False, methods=["POST"], permission_classes=[IsInstructorOrAdmin])
    def generate(self, request):
        data = request.data
        batch = Batch.objects.get(id=data["batch_id"])
        created = generate_sessions(
            batch=batch,
            weekdays=list(map(int, data["weekdays"])),
            start_time=str(data["start_time"]),
            duration_min=int(data["duration_min"]),
            since=date.fromisoformat(data["since"]),
            until=date.fromisoformat(data["until"]),
        )
        return Response({"created": created})


class PushViewSet(viewsets.ViewSet):
    permission_classes = [permissions.IsAuthenticated]

    def create(self, request):
        ser = DeviceTokenSer(data=request.data)
        ser.is_valid(raise_exception=True)
        DeviceToken.objects.update_or_create(
            user=request.user,
            token=ser.validated_data["token"],  # type: ignore
            defaults={"platform": ser.validated_data.get("platform", "android")},  # type: ignore
        )
        return Response({"ok": True})



class IsStudent(permissions.BasePermission):
    def has_permission(self, req, view): # type: ignore
        return req.user and req.user.is_authenticated



class EnrollmentViewSet(viewsets.ModelViewSet):
    queryset = Enrollment.objects.select_related("batch","user")
    permission_classes = [IsStudent]
    serializer_class = EnrollmentCreateSer






class QuizViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Quiz.objects.filter(is_published=True)
    serializer_class = QuizDetailSer
    permission_classes = [permissions.IsAuthenticated]

    @extend_schema(
        request=None,
        responses={"200": {"type": "object", "properties": {"submission_id": {"type": "integer"}}}},
        examples=[OpenApiExample("Start quiz", value={})],
    )
    @action(detail=True, methods=["post"], url_path="start")
    def start(self, request, pk=None):
        quiz = self.get_object()
        sub = Submission.objects.create(quiz=quiz, student=request.user)
        return Response({"submission_id": sub.id})


class SubmissionViewSet(viewsets.GenericViewSet):
    queryset = Submission.objects.all()
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = SubmissionSer

    @extend_schema(
        request={"application/json": {
            "type": "object",
            "properties": {
                "question_id": {"type": "integer"},
                "selected_option_id": {"type": "integer"},
                "ordered_item_ids": {"type": "array", "items": {"type": "integer"}}
            },
            "required": ["question_id"]
        }},
        responses={"200": {"type": "object", "properties": {"ok": {"type": "boolean"}}}},
        examples=[OpenApiExample("MCQ", value={"question_id":1,"selected_option_id":10}),
                OpenApiExample("ORDER", value={"question_id":2,"ordered_item_ids":[5,7,6,8]})],
    )
    @action(detail=True, methods=["post"], url_path="answer")
    def answer(self, request, pk=None):
        sub = self.get_object()
        qid = request.data["question_id"]
        q = Question.objects.get(id=qid)
        if q.qtype == "MCQ":
            opt = Option.objects.get(id=request.data["selected_option_id"], question=q)
            Answer.objects.update_or_create(
                submission=sub, question=q,
                defaults={"selected_option": opt, "given_order": None})
        else:
            ids = request.data["ordered_item_ids"]
            Answer.objects.update_or_create(
                submission=sub, question=q,
                defaults={"selected_option": None, "given_order": ids})
        return Response({"ok": True})

    @extend_schema(
        request=None,
        responses={"200": {"type": "object",
        "properties": {"score":{"type":"number"},"correct":{"type":"integer"},"total":{"type":"integer"}}}}
    )
    @action(detail=True, methods=["post"], url_path="finish")
    def finish(self, request, pk=None):
        sub = self.get_object()
        total = sub.quiz.questions.count()
        correct = 0
        for ans in sub.answers.select_related("question","selected_option").all():
            q = ans.question
            if q.qtype == "MCQ":
                if ans.selected_option and ans.selected_option.is_correct:
                    correct += 1
            else:
                expected = list(q.order_items.order_by("order_index").values_list("id", flat=True))
                if ans.given_order == expected:
                    correct += 1
        sub.score = round(100 * correct / max(total,1), 2)
        sub.save(update_fields=["score"])
        return Response({"score": sub.score, "correct": correct, "total": total})




class ArticleViewSet(viewsets.ModelViewSet):
    queryset = Article.objects.all()
    serializer_class = ArticleSer
    permission_classes = [IsAdminOrReadOnly]

    def get_queryset(self):
        qs = Article.objects.filter(published=True) if self.request.method == "GET" else Article.objects.all()
        q = self.request.query_params.get("q") # type: ignore
        tag = self.request.query_params.get("tag") # type: ignore
        if q:
            qs = qs.filter(Q(title__icontains=q) | Q(body__icontains=q))
        if tag:
            qs = qs.filter(tags__contains=[tag])
        return qs.order_by("-created_at")