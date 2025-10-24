import 'package:driving_app/src/features/courses/data/course_repository.dart';
import 'package:driving_app/src/features/courses/data/models/course_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'course_detail_controller.g.dart';

@riverpod
class CourseDetailController extends _$CourseDetailController {
  // Controller ကို courseId parameter တစ်ခုနဲ့ တည်ဆောက်ပါမယ်
  @override
  FutureOr<Course> build(int courseId) {
    return ref.read(courseRepositoryProvider).fetchCourseById(courseId);
  }
}
