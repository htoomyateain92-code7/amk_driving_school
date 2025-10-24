// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$courseDetailControllerHash() =>
    r'7ee7d665714cf316108ee906f3ea50aa9fc52b98';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$CourseDetailController
    extends BuildlessAutoDisposeAsyncNotifier<Course> {
  late final int courseId;

  FutureOr<Course> build(
    int courseId,
  );
}

/// See also [CourseDetailController].
@ProviderFor(CourseDetailController)
const courseDetailControllerProvider = CourseDetailControllerFamily();

/// See also [CourseDetailController].
class CourseDetailControllerFamily extends Family<AsyncValue<Course>> {
  /// See also [CourseDetailController].
  const CourseDetailControllerFamily();

  /// See also [CourseDetailController].
  CourseDetailControllerProvider call(
    int courseId,
  ) {
    return CourseDetailControllerProvider(
      courseId,
    );
  }

  @override
  CourseDetailControllerProvider getProviderOverride(
    covariant CourseDetailControllerProvider provider,
  ) {
    return call(
      provider.courseId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'courseDetailControllerProvider';
}

/// See also [CourseDetailController].
class CourseDetailControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<CourseDetailController,
        Course> {
  /// See also [CourseDetailController].
  CourseDetailControllerProvider(
    int courseId,
  ) : this._internal(
          () => CourseDetailController()..courseId = courseId,
          from: courseDetailControllerProvider,
          name: r'courseDetailControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$courseDetailControllerHash,
          dependencies: CourseDetailControllerFamily._dependencies,
          allTransitiveDependencies:
              CourseDetailControllerFamily._allTransitiveDependencies,
          courseId: courseId,
        );

  CourseDetailControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.courseId,
  }) : super.internal();

  final int courseId;

  @override
  FutureOr<Course> runNotifierBuild(
    covariant CourseDetailController notifier,
  ) {
    return notifier.build(
      courseId,
    );
  }

  @override
  Override overrideWith(CourseDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: CourseDetailControllerProvider._internal(
        () => create()..courseId = courseId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        courseId: courseId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<CourseDetailController, Course>
      createElement() {
    return _CourseDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CourseDetailControllerProvider &&
        other.courseId == courseId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, courseId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CourseDetailControllerRef on AutoDisposeAsyncNotifierProviderRef<Course> {
  /// The parameter `courseId` of this provider.
  int get courseId;
}

class _CourseDetailControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<CourseDetailController,
        Course> with CourseDetailControllerRef {
  _CourseDetailControllerProviderElement(super.provider);

  @override
  int get courseId => (origin as CourseDetailControllerProvider).courseId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
