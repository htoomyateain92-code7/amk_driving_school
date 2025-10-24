// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$availableSessionsControllerHash() =>
    r'06b9b62f379145dc8358a8f879a9d60053c6792b';

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

abstract class _$AvailableSessionsController
    extends BuildlessAutoDisposeAsyncNotifier<List<Session>> {
  late final int batchId;

  FutureOr<List<Session>> build(
    int batchId,
  );
}

/// See also [AvailableSessionsController].
@ProviderFor(AvailableSessionsController)
const availableSessionsControllerProvider = AvailableSessionsControllerFamily();

/// See also [AvailableSessionsController].
class AvailableSessionsControllerFamily
    extends Family<AsyncValue<List<Session>>> {
  /// See also [AvailableSessionsController].
  const AvailableSessionsControllerFamily();

  /// See also [AvailableSessionsController].
  AvailableSessionsControllerProvider call(
    int batchId,
  ) {
    return AvailableSessionsControllerProvider(
      batchId,
    );
  }

  @override
  AvailableSessionsControllerProvider getProviderOverride(
    covariant AvailableSessionsControllerProvider provider,
  ) {
    return call(
      provider.batchId,
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
  String? get name => r'availableSessionsControllerProvider';
}

/// See also [AvailableSessionsController].
class AvailableSessionsControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<AvailableSessionsController,
        List<Session>> {
  /// See also [AvailableSessionsController].
  AvailableSessionsControllerProvider(
    int batchId,
  ) : this._internal(
          () => AvailableSessionsController()..batchId = batchId,
          from: availableSessionsControllerProvider,
          name: r'availableSessionsControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$availableSessionsControllerHash,
          dependencies: AvailableSessionsControllerFamily._dependencies,
          allTransitiveDependencies:
              AvailableSessionsControllerFamily._allTransitiveDependencies,
          batchId: batchId,
        );

  AvailableSessionsControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.batchId,
  }) : super.internal();

  final int batchId;

  @override
  FutureOr<List<Session>> runNotifierBuild(
    covariant AvailableSessionsController notifier,
  ) {
    return notifier.build(
      batchId,
    );
  }

  @override
  Override overrideWith(AvailableSessionsController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AvailableSessionsControllerProvider._internal(
        () => create()..batchId = batchId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        batchId: batchId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<AvailableSessionsController,
      List<Session>> createElement() {
    return _AvailableSessionsControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AvailableSessionsControllerProvider &&
        other.batchId == batchId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, batchId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AvailableSessionsControllerRef
    on AutoDisposeAsyncNotifierProviderRef<List<Session>> {
  /// The parameter `batchId` of this provider.
  int get batchId;
}

class _AvailableSessionsControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<AvailableSessionsController,
        List<Session>> with AvailableSessionsControllerRef {
  _AvailableSessionsControllerProviderElement(super.provider);

  @override
  int get batchId => (origin as AvailableSessionsControllerProvider).batchId;
}

String _$bookingSubmitControllerHash() =>
    r'1377395ee79a361c7de4620c8d8c13692ee2d3e2';

/// See also [BookingSubmitController].
@ProviderFor(BookingSubmitController)
final bookingSubmitControllerProvider =
    AutoDisposeAsyncNotifierProvider<BookingSubmitController, void>.internal(
  BookingSubmitController.new,
  name: r'bookingSubmitControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$bookingSubmitControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BookingSubmitController = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
