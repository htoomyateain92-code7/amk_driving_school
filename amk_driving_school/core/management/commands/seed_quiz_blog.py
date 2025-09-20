from django.core.management.base import BaseCommand
from core.models import Quiz, Question, Option, OrderItem
from core.models import Article

class Command(BaseCommand):
    def handle(self, *args, **kwargs):
        qz, _ = Quiz.objects.get_or_create(title="Basic Driving Rules", time_limit_sec=0, is_published=True)
        q1 = Question.objects.get_or_create(quiz=qz, text="Stop sign color?", qtype="MCQ")[0]
        Option.objects.get_or_create(question=q1, text="Red", is_correct=True)
        Option.objects.get_or_create(question=q1, text="Blue", is_correct=False)
        Option.objects.get_or_create(question=q1, text="Green", is_correct=False)

        q2 = Question.objects.get_or_create(quiz=qz, text="Order for starting car", qtype="ORDER")[0]
        OrderItem.objects.get_or_create(question=q2, text="Seatbelt on", order_index=0)
        OrderItem.objects.get_or_create(question=q2, text="Mirrors check", order_index=1)
        OrderItem.objects.get_or_create(question=q2, text="Start engine", order_index=2)

        Article.objects.get_or_create(
            title="Traffic Signs 101",
            body="Basic signs you must know …",
            tags=["traffic-signs","safety"],
            published=True,
        )
        self.stdout.write(self.style.SUCCESS("Seeded quiz & articles"))
