from rest_framework import serializers

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