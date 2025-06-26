// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'async_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userProfileHash() => r'ffd0faac4293ec1331becb3fb1972e4fe65302f4';

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

/// Example async provider demonstrating AsyncValue patterns
/// This serves as a template for future API integrations
///
/// Copied from [userProfile].
@ProviderFor(userProfile)
const userProfileProvider = UserProfileFamily();

/// Example async provider demonstrating AsyncValue patterns
/// This serves as a template for future API integrations
///
/// Copied from [userProfile].
class UserProfileFamily extends Family<AsyncValue<UserProfile>> {
  /// Example async provider demonstrating AsyncValue patterns
  /// This serves as a template for future API integrations
  ///
  /// Copied from [userProfile].
  const UserProfileFamily();

  /// Example async provider demonstrating AsyncValue patterns
  /// This serves as a template for future API integrations
  ///
  /// Copied from [userProfile].
  UserProfileProvider call(String userId) {
    return UserProfileProvider(userId);
  }

  @override
  UserProfileProvider getProviderOverride(
    covariant UserProfileProvider provider,
  ) {
    return call(provider.userId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userProfileProvider';
}

/// Example async provider demonstrating AsyncValue patterns
/// This serves as a template for future API integrations
///
/// Copied from [userProfile].
class UserProfileProvider extends AutoDisposeFutureProvider<UserProfile> {
  /// Example async provider demonstrating AsyncValue patterns
  /// This serves as a template for future API integrations
  ///
  /// Copied from [userProfile].
  UserProfileProvider(String userId)
    : this._internal(
        (ref) => userProfile(ref as UserProfileRef, userId),
        from: userProfileProvider,
        name: r'userProfileProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userProfileHash,
        dependencies: UserProfileFamily._dependencies,
        allTransitiveDependencies: UserProfileFamily._allTransitiveDependencies,
        userId: userId,
      );

  UserProfileProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

  @override
  Override overrideWith(
    FutureOr<UserProfile> Function(UserProfileRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserProfileProvider._internal(
        (ref) => create(ref as UserProfileRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<UserProfile> createElement() {
    return _UserProfileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserProfileProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserProfileRef on AutoDisposeFutureProviderRef<UserProfile> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _UserProfileProviderElement
    extends AutoDisposeFutureProviderElement<UserProfile>
    with UserProfileRef {
  _UserProfileProviderElement(super.provider);

  @override
  String get userId => (origin as UserProfileProvider).userId;
}

String _$educationContentHash() => r'46e2f56a80a61833d75844402266f3bbc81ada2a';

/// Async provider for loading educational content
///
/// Copied from [educationContent].
@ProviderFor(educationContent)
final educationContentProvider =
    AutoDisposeFutureProvider<List<EducationContent>>.internal(
      educationContent,
      name: r'educationContentProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$educationContentHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EducationContentRef =
    AutoDisposeFutureProviderRef<List<EducationContent>>;
String _$marketDataHash() => r'425a513a893773af5678081b0d009f9298ac6be3';

/// Async provider for market data (for future trading features)
///
/// Copied from [marketData].
@ProviderFor(marketData)
const marketDataProvider = MarketDataFamily();

/// Async provider for market data (for future trading features)
///
/// Copied from [marketData].
class MarketDataFamily extends Family<AsyncValue<MarketData>> {
  /// Async provider for market data (for future trading features)
  ///
  /// Copied from [marketData].
  const MarketDataFamily();

  /// Async provider for market data (for future trading features)
  ///
  /// Copied from [marketData].
  MarketDataProvider call(String symbol) {
    return MarketDataProvider(symbol);
  }

  @override
  MarketDataProvider getProviderOverride(
    covariant MarketDataProvider provider,
  ) {
    return call(provider.symbol);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'marketDataProvider';
}

/// Async provider for market data (for future trading features)
///
/// Copied from [marketData].
class MarketDataProvider extends AutoDisposeFutureProvider<MarketData> {
  /// Async provider for market data (for future trading features)
  ///
  /// Copied from [marketData].
  MarketDataProvider(String symbol)
    : this._internal(
        (ref) => marketData(ref as MarketDataRef, symbol),
        from: marketDataProvider,
        name: r'marketDataProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$marketDataHash,
        dependencies: MarketDataFamily._dependencies,
        allTransitiveDependencies: MarketDataFamily._allTransitiveDependencies,
        symbol: symbol,
      );

  MarketDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.symbol,
  }) : super.internal();

  final String symbol;

  @override
  Override overrideWith(
    FutureOr<MarketData> Function(MarketDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MarketDataProvider._internal(
        (ref) => create(ref as MarketDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        symbol: symbol,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<MarketData> createElement() {
    return _MarketDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MarketDataProvider && other.symbol == symbol;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, symbol.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MarketDataRef on AutoDisposeFutureProviderRef<MarketData> {
  /// The parameter `symbol` of this provider.
  String get symbol;
}

class _MarketDataProviderElement
    extends AutoDisposeFutureProviderElement<MarketData>
    with MarketDataRef {
  _MarketDataProviderElement(super.provider);

  @override
  String get symbol => (origin as MarketDataProvider).symbol;
}

String _$saveUserProgressHash() => r'df2b5fd526aa0e7e36f95817a309ff26a54ffc85';

/// Async provider for saving user progress (demonstrates error handling)
///
/// Copied from [saveUserProgress].
@ProviderFor(saveUserProgress)
const saveUserProgressProvider = SaveUserProgressFamily();

/// Async provider for saving user progress (demonstrates error handling)
///
/// Copied from [saveUserProgress].
class SaveUserProgressFamily extends Family<AsyncValue<bool>> {
  /// Async provider for saving user progress (demonstrates error handling)
  ///
  /// Copied from [saveUserProgress].
  const SaveUserProgressFamily();

  /// Async provider for saving user progress (demonstrates error handling)
  ///
  /// Copied from [saveUserProgress].
  SaveUserProgressProvider call(UserProgressData data) {
    return SaveUserProgressProvider(data);
  }

  @override
  SaveUserProgressProvider getProviderOverride(
    covariant SaveUserProgressProvider provider,
  ) {
    return call(provider.data);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'saveUserProgressProvider';
}

/// Async provider for saving user progress (demonstrates error handling)
///
/// Copied from [saveUserProgress].
class SaveUserProgressProvider extends AutoDisposeFutureProvider<bool> {
  /// Async provider for saving user progress (demonstrates error handling)
  ///
  /// Copied from [saveUserProgress].
  SaveUserProgressProvider(UserProgressData data)
    : this._internal(
        (ref) => saveUserProgress(ref as SaveUserProgressRef, data),
        from: saveUserProgressProvider,
        name: r'saveUserProgressProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$saveUserProgressHash,
        dependencies: SaveUserProgressFamily._dependencies,
        allTransitiveDependencies:
            SaveUserProgressFamily._allTransitiveDependencies,
        data: data,
      );

  SaveUserProgressProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.data,
  }) : super.internal();

  final UserProgressData data;

  @override
  Override overrideWith(
    FutureOr<bool> Function(SaveUserProgressRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SaveUserProgressProvider._internal(
        (ref) => create(ref as SaveUserProgressRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        data: data,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _SaveUserProgressProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SaveUserProgressProvider && other.data == data;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, data.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SaveUserProgressRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `data` of this provider.
  UserProgressData get data;
}

class _SaveUserProgressProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with SaveUserProgressRef {
  _SaveUserProgressProviderElement(super.provider);

  @override
  UserProgressData get data => (origin as SaveUserProgressProvider).data;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
