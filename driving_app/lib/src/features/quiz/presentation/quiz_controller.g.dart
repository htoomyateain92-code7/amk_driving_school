// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$quizzesForCourseControllerHash() =>
    r'a458ea0da5fda5a5516086acf83e0abd4dbaf07c';

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

abstract class _$QuizzesForCourseController
    extends BuildlessAutoDisposeAsyncNotifier<List<QuizInfo>> {
  late final int courseId;

  FutureOr<List<QuizInfo>> build(
    int courseId,
  );
}

/// See also [QuizzesForCourseController].
@ProviderFor(QuizzesForCourseController)
const quizzesForCourseControllerProvider = QuizzesForCourseControllerFamily();

/// See also [QuizzesForCourseController].
class QuizzesForCourseControllerFamily
    extends Family<AsyncValue<List<QuizInfo>>> {
  /// See also [QuizzesForCourseController].
  const QuizzesForCourseControllerFamily();

  /// See also [QuizzesForCourseController].
  QuizzesForCourseControllerProvider call(
    int courseId,
  ) {
    return QuizzesForCourseControllerProvider(
      courseId,
    );
  }

  @override
  QuizzesForCourseControllerProvider getProviderOverride(
    covariant QuizzesForCourseControllerProvider provider,
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
  String? get name => r'quizzesForCourseControllerProvider';
}

/// See also [QuizzesForCourseController].
class QuizzesForCourseControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<QuizzesForCourseController,
        List<QuizInfo>> {
  /// See also [QuizzesForCourseController].
  QuizzesForCourseControllerProvider(
    int courseId,
  ) : this._internal(
          () => QuizzesForCourseController()..courseId = courseId,
          from: quizzesForCourseControllerProvider,
          name: r'quizzesForCourseControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$quizzesForCourseControllerHash,
          dependencies: QuizzesForCourseControllerFamily._dependencies,
          allTransitiveDependencies:
              QuizzesForCourseControllerFamily._allTransitiveDependencies,
          courseId: courseId,
        );

  QuizzesForCourseControllerProvider._internal(
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
  FutureOr<List<QuizInfo>> runNotifierBuild(
    covariant QuizzesForCourseController notifier,
  ) {
    return notifier.build(
      courseId,
    );
  }

  @override
  Override overrideWith(QuizzesForCourseController Function() create) {
    return ProviderOverride(
      origin: this,
      override: QuizzesForCourseControllerProvider._internal(
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
  AutoDisposeAsyncNotifierProviderElement<QuizzesForCourseController,
      List<QuizInfo>> createElement() {
    return _QuizzesForCourseControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is QuizzesForCourseControllerProvider &&
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
mixin QuizzesForCourseControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<QuizInfo>> {
  /// The parameter `courseId` of this provider.
  int get courseId;
}

class _QuizzesForCourseControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<QuizzesForCourseController,
        List<QuizInfo>> with QuizzesForCourseControllerRef {
  _QuizzesForCourseControllerProviderElement(super.provider);

  @override
  int get courseId => (origin as QuizzesForCourseControllerProvider).courseId;
}

String _$quizDetailControllerHash() =>
    r'8a8a89be06efe4b6fbe1465995fb5c71d737d6a1';

abstract class _$QuizDetailController
    extends BuildlessAutoDisposeAsyncNotifier<QuizDetail> {
  late final int quizId;

  FutureOr<QuizDetail> build(
    int quizId,
  );
}

/// See also [QuizDetailController].
@ProviderFor(QuizDetailController)
const quizDetailControllerProvider = QuizDetailControllerFamily();

/// See also [QuizDetailController].
class QuizDetailControllerFamily extends Family<AsyncValue<QuizDetail>> {
  /// See also [QuizDetailController].
  const QuizDetailControllerFamily();

  /// See also [QuizDetailController].
  QuizDetailControllerProvider call(
    int quizId,
  ) {
    return QuizDetailControllerProvider(
      quizId,
    );
  }

  @override
  QuizDetailControllerProvider getProviderOverride(
    covariant QuizDetailControllerProvider provider,
  ) {
    return call(
      provider.quizId,
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
  String? get name => r'quizDetailControllerProvider';
}

/// See also [QuizDetailController].
class QuizDetailControllerProvider extends AutoDisposeAsyncNotifierProviderImpl<
    QuizDetailController, QuizDetail> {
  /// See also [QuizDetailController].
  QuizDetailControllerProvider(
    int quizId,
  ) : this._internal(
          () => QuizDetailController()..quizId = quizId,
          from: quizDetailControllerProvider,
          name: r'quizDetailControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$quizDetailControllerHash,
          dependencies: QuizDetailControllerFamily._dependencies,
          allTransitiveDependencies:
              QuizDetailControllerFamily._allTransitiveDependencies,
          quizId: quizId,
        );

  QuizDetailControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.quizId,
  }) : super.internal();

  final int quizId;

  @override
  FutureOr<QuizDetail> runNotifierBuild(
    covariant QuizDetailController notifier,
  ) {
    return notifier.build(
      quizId,
    );
  }

  @override
  Override overrideWith(QuizDetailController Function() create) {
    return ProviderOverride(
      origin: this,
      override: QuizDetailControllerProvider._internal(
        () => create()..quizId = quizId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        quizId: quizId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<QuizDetailController, QuizDetail>
      createElement() {
    return _QuizDetailControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is QuizDetailControllerProvider && other.quizId == quizId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, quizId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin QuizDetailControllerRef
    on AutoDisposeAsyncNotifierProviderRef<QuizDetail> {
  /// The parameter `quizId` of this provider.
  int get quizId;
}

class _QuizDetailControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<QuizDetailController,
        QuizDetail> with QuizDetailControllerRef {
  _QuizDetailControllerProviderElement(super.provider);

  @override
  int get quizId => (origin as QuizDetailControllerProvider).quizId;
}

String _$quizStartControllerHash() =>
    r'296ecd5b18d3fb2a62dc34db2988b48f1a9deb45';

/// See also [QuizStartController].
@ProviderFor(QuizStartController)
final quizStartControllerProvider =
    AutoDisposeNotifierProvider<QuizStartController, QuizStartState>.internal(
  QuizStartController.new,
  name: r'quizStartControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$quizStartControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$QuizStartController = AutoDisposeNotifier<QuizStartState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
