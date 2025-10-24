import 'package:driving_app/src/features/courses/data/course_repository.dart';
import 'package:driving_app/src/features/courses/data/models/course_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'courses_controller.g.dart';

// AsyncNotifier จะจัดการ state loading, data, error ให้เราอัตโนมัติ
@riverpod
class CoursesController extends _$CoursesController {
  // build() method จะถูกเรียกครั้งแรกที่ provider นี้ถูกใช้งาน
  // และจะ return Future<List<Course>> ที่เราต้องการ
  @override
  FutureOr<List<Course>> build() {
    // ดึง Repository มาแล้วเรียก method เพื่อโหลดข้อมูลทันที
    return ref.read(courseRepositoryProvider).fetchCourses();
  }
}
