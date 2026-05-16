// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'games_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$GamesListState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<BoardGameEntity> games) loaded,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<BoardGameEntity> games)? loaded,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<BoardGameEntity> games)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GLInitial value) initial,
    required TResult Function(_GLLoading value) loading,
    required TResult Function(_GLLoaded value) loaded,
    required TResult Function(_GLError value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GLInitial value)? initial,
    TResult? Function(_GLLoading value)? loading,
    TResult? Function(_GLLoaded value)? loaded,
    TResult? Function(_GLError value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GLInitial value)? initial,
    TResult Function(_GLLoading value)? loading,
    TResult Function(_GLLoaded value)? loaded,
    TResult Function(_GLError value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GamesListStateCopyWith<$Res> {
  factory $GamesListStateCopyWith(
    GamesListState value,
    $Res Function(GamesListState) then,
  ) = _$GamesListStateCopyWithImpl<$Res, GamesListState>;
}

/// @nodoc
class _$GamesListStateCopyWithImpl<$Res, $Val extends GamesListState>
    implements $GamesListStateCopyWith<$Res> {
  _$GamesListStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GamesListState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$GLInitialImplCopyWith<$Res> {
  factory _$$GLInitialImplCopyWith(
    _$GLInitialImpl value,
    $Res Function(_$GLInitialImpl) then,
  ) = __$$GLInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GLInitialImplCopyWithImpl<$Res>
    extends _$GamesListStateCopyWithImpl<$Res, _$GLInitialImpl>
    implements _$$GLInitialImplCopyWith<$Res> {
  __$$GLInitialImplCopyWithImpl(
    _$GLInitialImpl _value,
    $Res Function(_$GLInitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GamesListState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$GLInitialImpl implements _GLInitial {
  const _$GLInitialImpl();

  @override
  String toString() {
    return 'GamesListState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$GLInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<BoardGameEntity> games) loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<BoardGameEntity> games)? loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<BoardGameEntity> games)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GLInitial value) initial,
    required TResult Function(_GLLoading value) loading,
    required TResult Function(_GLLoaded value) loaded,
    required TResult Function(_GLError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GLInitial value)? initial,
    TResult? Function(_GLLoading value)? loading,
    TResult? Function(_GLLoaded value)? loaded,
    TResult? Function(_GLError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GLInitial value)? initial,
    TResult Function(_GLLoading value)? loading,
    TResult Function(_GLLoaded value)? loaded,
    TResult Function(_GLError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _GLInitial implements GamesListState {
  const factory _GLInitial() = _$GLInitialImpl;
}

/// @nodoc
abstract class _$$GLLoadingImplCopyWith<$Res> {
  factory _$$GLLoadingImplCopyWith(
    _$GLLoadingImpl value,
    $Res Function(_$GLLoadingImpl) then,
  ) = __$$GLLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GLLoadingImplCopyWithImpl<$Res>
    extends _$GamesListStateCopyWithImpl<$Res, _$GLLoadingImpl>
    implements _$$GLLoadingImplCopyWith<$Res> {
  __$$GLLoadingImplCopyWithImpl(
    _$GLLoadingImpl _value,
    $Res Function(_$GLLoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GamesListState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$GLLoadingImpl implements _GLLoading {
  const _$GLLoadingImpl();

  @override
  String toString() {
    return 'GamesListState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$GLLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<BoardGameEntity> games) loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<BoardGameEntity> games)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<BoardGameEntity> games)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GLInitial value) initial,
    required TResult Function(_GLLoading value) loading,
    required TResult Function(_GLLoaded value) loaded,
    required TResult Function(_GLError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GLInitial value)? initial,
    TResult? Function(_GLLoading value)? loading,
    TResult? Function(_GLLoaded value)? loaded,
    TResult? Function(_GLError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GLInitial value)? initial,
    TResult Function(_GLLoading value)? loading,
    TResult Function(_GLLoaded value)? loaded,
    TResult Function(_GLError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _GLLoading implements GamesListState {
  const factory _GLLoading() = _$GLLoadingImpl;
}

/// @nodoc
abstract class _$$GLLoadedImplCopyWith<$Res> {
  factory _$$GLLoadedImplCopyWith(
    _$GLLoadedImpl value,
    $Res Function(_$GLLoadedImpl) then,
  ) = __$$GLLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<BoardGameEntity> games});
}

/// @nodoc
class __$$GLLoadedImplCopyWithImpl<$Res>
    extends _$GamesListStateCopyWithImpl<$Res, _$GLLoadedImpl>
    implements _$$GLLoadedImplCopyWith<$Res> {
  __$$GLLoadedImplCopyWithImpl(
    _$GLLoadedImpl _value,
    $Res Function(_$GLLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GamesListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? games = null}) {
    return _then(
      _$GLLoadedImpl(
        null == games
            ? _value._games
            : games // ignore: cast_nullable_to_non_nullable
                  as List<BoardGameEntity>,
      ),
    );
  }
}

/// @nodoc

class _$GLLoadedImpl implements _GLLoaded {
  const _$GLLoadedImpl(final List<BoardGameEntity> games) : _games = games;

  final List<BoardGameEntity> _games;
  @override
  List<BoardGameEntity> get games {
    if (_games is EqualUnmodifiableListView) return _games;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_games);
  }

  @override
  String toString() {
    return 'GamesListState.loaded(games: $games)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GLLoadedImpl &&
            const DeepCollectionEquality().equals(other._games, _games));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_games));

  /// Create a copy of GamesListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GLLoadedImplCopyWith<_$GLLoadedImpl> get copyWith =>
      __$$GLLoadedImplCopyWithImpl<_$GLLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<BoardGameEntity> games) loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(games);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<BoardGameEntity> games)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(games);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<BoardGameEntity> games)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(games);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GLInitial value) initial,
    required TResult Function(_GLLoading value) loading,
    required TResult Function(_GLLoaded value) loaded,
    required TResult Function(_GLError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GLInitial value)? initial,
    TResult? Function(_GLLoading value)? loading,
    TResult? Function(_GLLoaded value)? loaded,
    TResult? Function(_GLError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GLInitial value)? initial,
    TResult Function(_GLLoading value)? loading,
    TResult Function(_GLLoaded value)? loaded,
    TResult Function(_GLError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _GLLoaded implements GamesListState {
  const factory _GLLoaded(final List<BoardGameEntity> games) = _$GLLoadedImpl;

  List<BoardGameEntity> get games;

  /// Create a copy of GamesListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GLLoadedImplCopyWith<_$GLLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GLErrorImplCopyWith<$Res> {
  factory _$$GLErrorImplCopyWith(
    _$GLErrorImpl value,
    $Res Function(_$GLErrorImpl) then,
  ) = __$$GLErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$GLErrorImplCopyWithImpl<$Res>
    extends _$GamesListStateCopyWithImpl<$Res, _$GLErrorImpl>
    implements _$$GLErrorImplCopyWith<$Res> {
  __$$GLErrorImplCopyWithImpl(
    _$GLErrorImpl _value,
    $Res Function(_$GLErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GamesListState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$GLErrorImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$GLErrorImpl implements _GLError {
  const _$GLErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'GamesListState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GLErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of GamesListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GLErrorImplCopyWith<_$GLErrorImpl> get copyWith =>
      __$$GLErrorImplCopyWithImpl<_$GLErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<BoardGameEntity> games) loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<BoardGameEntity> games)? loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<BoardGameEntity> games)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GLInitial value) initial,
    required TResult Function(_GLLoading value) loading,
    required TResult Function(_GLLoaded value) loaded,
    required TResult Function(_GLError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GLInitial value)? initial,
    TResult? Function(_GLLoading value)? loading,
    TResult? Function(_GLLoaded value)? loaded,
    TResult? Function(_GLError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GLInitial value)? initial,
    TResult Function(_GLLoading value)? loading,
    TResult Function(_GLLoaded value)? loaded,
    TResult Function(_GLError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _GLError implements GamesListState {
  const factory _GLError(final String message) = _$GLErrorImpl;

  String get message;

  /// Create a copy of GamesListState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GLErrorImplCopyWith<_$GLErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$GameDetailState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(BoardGameEntity game) loaded,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(BoardGameEntity game)? loaded,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(BoardGameEntity game)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GDInitial value) initial,
    required TResult Function(_GDLoading value) loading,
    required TResult Function(_GDLoaded value) loaded,
    required TResult Function(_GDError value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GDInitial value)? initial,
    TResult? Function(_GDLoading value)? loading,
    TResult? Function(_GDLoaded value)? loaded,
    TResult? Function(_GDError value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GDInitial value)? initial,
    TResult Function(_GDLoading value)? loading,
    TResult Function(_GDLoaded value)? loaded,
    TResult Function(_GDError value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameDetailStateCopyWith<$Res> {
  factory $GameDetailStateCopyWith(
    GameDetailState value,
    $Res Function(GameDetailState) then,
  ) = _$GameDetailStateCopyWithImpl<$Res, GameDetailState>;
}

/// @nodoc
class _$GameDetailStateCopyWithImpl<$Res, $Val extends GameDetailState>
    implements $GameDetailStateCopyWith<$Res> {
  _$GameDetailStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameDetailState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$GDInitialImplCopyWith<$Res> {
  factory _$$GDInitialImplCopyWith(
    _$GDInitialImpl value,
    $Res Function(_$GDInitialImpl) then,
  ) = __$$GDInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GDInitialImplCopyWithImpl<$Res>
    extends _$GameDetailStateCopyWithImpl<$Res, _$GDInitialImpl>
    implements _$$GDInitialImplCopyWith<$Res> {
  __$$GDInitialImplCopyWithImpl(
    _$GDInitialImpl _value,
    $Res Function(_$GDInitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameDetailState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$GDInitialImpl implements _GDInitial {
  const _$GDInitialImpl();

  @override
  String toString() {
    return 'GameDetailState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$GDInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(BoardGameEntity game) loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(BoardGameEntity game)? loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(BoardGameEntity game)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GDInitial value) initial,
    required TResult Function(_GDLoading value) loading,
    required TResult Function(_GDLoaded value) loaded,
    required TResult Function(_GDError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GDInitial value)? initial,
    TResult? Function(_GDLoading value)? loading,
    TResult? Function(_GDLoaded value)? loaded,
    TResult? Function(_GDError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GDInitial value)? initial,
    TResult Function(_GDLoading value)? loading,
    TResult Function(_GDLoaded value)? loaded,
    TResult Function(_GDError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _GDInitial implements GameDetailState {
  const factory _GDInitial() = _$GDInitialImpl;
}

/// @nodoc
abstract class _$$GDLoadingImplCopyWith<$Res> {
  factory _$$GDLoadingImplCopyWith(
    _$GDLoadingImpl value,
    $Res Function(_$GDLoadingImpl) then,
  ) = __$$GDLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GDLoadingImplCopyWithImpl<$Res>
    extends _$GameDetailStateCopyWithImpl<$Res, _$GDLoadingImpl>
    implements _$$GDLoadingImplCopyWith<$Res> {
  __$$GDLoadingImplCopyWithImpl(
    _$GDLoadingImpl _value,
    $Res Function(_$GDLoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameDetailState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$GDLoadingImpl implements _GDLoading {
  const _$GDLoadingImpl();

  @override
  String toString() {
    return 'GameDetailState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$GDLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(BoardGameEntity game) loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(BoardGameEntity game)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(BoardGameEntity game)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GDInitial value) initial,
    required TResult Function(_GDLoading value) loading,
    required TResult Function(_GDLoaded value) loaded,
    required TResult Function(_GDError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GDInitial value)? initial,
    TResult? Function(_GDLoading value)? loading,
    TResult? Function(_GDLoaded value)? loaded,
    TResult? Function(_GDError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GDInitial value)? initial,
    TResult Function(_GDLoading value)? loading,
    TResult Function(_GDLoaded value)? loaded,
    TResult Function(_GDError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _GDLoading implements GameDetailState {
  const factory _GDLoading() = _$GDLoadingImpl;
}

/// @nodoc
abstract class _$$GDLoadedImplCopyWith<$Res> {
  factory _$$GDLoadedImplCopyWith(
    _$GDLoadedImpl value,
    $Res Function(_$GDLoadedImpl) then,
  ) = __$$GDLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({BoardGameEntity game});
}

/// @nodoc
class __$$GDLoadedImplCopyWithImpl<$Res>
    extends _$GameDetailStateCopyWithImpl<$Res, _$GDLoadedImpl>
    implements _$$GDLoadedImplCopyWith<$Res> {
  __$$GDLoadedImplCopyWithImpl(
    _$GDLoadedImpl _value,
    $Res Function(_$GDLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameDetailState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? game = null}) {
    return _then(
      _$GDLoadedImpl(
        null == game
            ? _value.game
            : game // ignore: cast_nullable_to_non_nullable
                  as BoardGameEntity,
      ),
    );
  }
}

/// @nodoc

class _$GDLoadedImpl implements _GDLoaded {
  const _$GDLoadedImpl(this.game);

  @override
  final BoardGameEntity game;

  @override
  String toString() {
    return 'GameDetailState.loaded(game: $game)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GDLoadedImpl &&
            (identical(other.game, game) || other.game == game));
  }

  @override
  int get hashCode => Object.hash(runtimeType, game);

  /// Create a copy of GameDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GDLoadedImplCopyWith<_$GDLoadedImpl> get copyWith =>
      __$$GDLoadedImplCopyWithImpl<_$GDLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(BoardGameEntity game) loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(game);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(BoardGameEntity game)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(game);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(BoardGameEntity game)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(game);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GDInitial value) initial,
    required TResult Function(_GDLoading value) loading,
    required TResult Function(_GDLoaded value) loaded,
    required TResult Function(_GDError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GDInitial value)? initial,
    TResult? Function(_GDLoading value)? loading,
    TResult? Function(_GDLoaded value)? loaded,
    TResult? Function(_GDError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GDInitial value)? initial,
    TResult Function(_GDLoading value)? loading,
    TResult Function(_GDLoaded value)? loaded,
    TResult Function(_GDError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _GDLoaded implements GameDetailState {
  const factory _GDLoaded(final BoardGameEntity game) = _$GDLoadedImpl;

  BoardGameEntity get game;

  /// Create a copy of GameDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GDLoadedImplCopyWith<_$GDLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GDErrorImplCopyWith<$Res> {
  factory _$$GDErrorImplCopyWith(
    _$GDErrorImpl value,
    $Res Function(_$GDErrorImpl) then,
  ) = __$$GDErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$GDErrorImplCopyWithImpl<$Res>
    extends _$GameDetailStateCopyWithImpl<$Res, _$GDErrorImpl>
    implements _$$GDErrorImplCopyWith<$Res> {
  __$$GDErrorImplCopyWithImpl(
    _$GDErrorImpl _value,
    $Res Function(_$GDErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameDetailState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$GDErrorImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$GDErrorImpl implements _GDError {
  const _$GDErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'GameDetailState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GDErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of GameDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GDErrorImplCopyWith<_$GDErrorImpl> get copyWith =>
      __$$GDErrorImplCopyWithImpl<_$GDErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(BoardGameEntity game) loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(BoardGameEntity game)? loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(BoardGameEntity game)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GDInitial value) initial,
    required TResult Function(_GDLoading value) loading,
    required TResult Function(_GDLoaded value) loaded,
    required TResult Function(_GDError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GDInitial value)? initial,
    TResult? Function(_GDLoading value)? loading,
    TResult? Function(_GDLoaded value)? loaded,
    TResult? Function(_GDError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GDInitial value)? initial,
    TResult Function(_GDLoading value)? loading,
    TResult Function(_GDLoaded value)? loaded,
    TResult Function(_GDError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _GDError implements GameDetailState {
  const factory _GDError(final String message) = _$GDErrorImpl;

  String get message;

  /// Create a copy of GameDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GDErrorImplCopyWith<_$GDErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$GuideState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(GameGuideEntity guide) loaded,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(GameGuideEntity guide)? loaded,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(GameGuideEntity guide)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GuInitial value) initial,
    required TResult Function(_GuLoading value) loading,
    required TResult Function(_GuLoaded value) loaded,
    required TResult Function(_GuError value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GuInitial value)? initial,
    TResult? Function(_GuLoading value)? loading,
    TResult? Function(_GuLoaded value)? loaded,
    TResult? Function(_GuError value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GuInitial value)? initial,
    TResult Function(_GuLoading value)? loading,
    TResult Function(_GuLoaded value)? loaded,
    TResult Function(_GuError value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GuideStateCopyWith<$Res> {
  factory $GuideStateCopyWith(
    GuideState value,
    $Res Function(GuideState) then,
  ) = _$GuideStateCopyWithImpl<$Res, GuideState>;
}

/// @nodoc
class _$GuideStateCopyWithImpl<$Res, $Val extends GuideState>
    implements $GuideStateCopyWith<$Res> {
  _$GuideStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GuideState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$GuInitialImplCopyWith<$Res> {
  factory _$$GuInitialImplCopyWith(
    _$GuInitialImpl value,
    $Res Function(_$GuInitialImpl) then,
  ) = __$$GuInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GuInitialImplCopyWithImpl<$Res>
    extends _$GuideStateCopyWithImpl<$Res, _$GuInitialImpl>
    implements _$$GuInitialImplCopyWith<$Res> {
  __$$GuInitialImplCopyWithImpl(
    _$GuInitialImpl _value,
    $Res Function(_$GuInitialImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GuideState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$GuInitialImpl implements _GuInitial {
  const _$GuInitialImpl();

  @override
  String toString() {
    return 'GuideState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$GuInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(GameGuideEntity guide) loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(GameGuideEntity guide)? loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(GameGuideEntity guide)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GuInitial value) initial,
    required TResult Function(_GuLoading value) loading,
    required TResult Function(_GuLoaded value) loaded,
    required TResult Function(_GuError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GuInitial value)? initial,
    TResult? Function(_GuLoading value)? loading,
    TResult? Function(_GuLoaded value)? loaded,
    TResult? Function(_GuError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GuInitial value)? initial,
    TResult Function(_GuLoading value)? loading,
    TResult Function(_GuLoaded value)? loaded,
    TResult Function(_GuError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _GuInitial implements GuideState {
  const factory _GuInitial() = _$GuInitialImpl;
}

/// @nodoc
abstract class _$$GuLoadingImplCopyWith<$Res> {
  factory _$$GuLoadingImplCopyWith(
    _$GuLoadingImpl value,
    $Res Function(_$GuLoadingImpl) then,
  ) = __$$GuLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$GuLoadingImplCopyWithImpl<$Res>
    extends _$GuideStateCopyWithImpl<$Res, _$GuLoadingImpl>
    implements _$$GuLoadingImplCopyWith<$Res> {
  __$$GuLoadingImplCopyWithImpl(
    _$GuLoadingImpl _value,
    $Res Function(_$GuLoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GuideState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$GuLoadingImpl implements _GuLoading {
  const _$GuLoadingImpl();

  @override
  String toString() {
    return 'GuideState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$GuLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(GameGuideEntity guide) loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(GameGuideEntity guide)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(GameGuideEntity guide)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GuInitial value) initial,
    required TResult Function(_GuLoading value) loading,
    required TResult Function(_GuLoaded value) loaded,
    required TResult Function(_GuError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GuInitial value)? initial,
    TResult? Function(_GuLoading value)? loading,
    TResult? Function(_GuLoaded value)? loaded,
    TResult? Function(_GuError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GuInitial value)? initial,
    TResult Function(_GuLoading value)? loading,
    TResult Function(_GuLoaded value)? loaded,
    TResult Function(_GuError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _GuLoading implements GuideState {
  const factory _GuLoading() = _$GuLoadingImpl;
}

/// @nodoc
abstract class _$$GuLoadedImplCopyWith<$Res> {
  factory _$$GuLoadedImplCopyWith(
    _$GuLoadedImpl value,
    $Res Function(_$GuLoadedImpl) then,
  ) = __$$GuLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({GameGuideEntity guide});
}

/// @nodoc
class __$$GuLoadedImplCopyWithImpl<$Res>
    extends _$GuideStateCopyWithImpl<$Res, _$GuLoadedImpl>
    implements _$$GuLoadedImplCopyWith<$Res> {
  __$$GuLoadedImplCopyWithImpl(
    _$GuLoadedImpl _value,
    $Res Function(_$GuLoadedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GuideState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? guide = null}) {
    return _then(
      _$GuLoadedImpl(
        null == guide
            ? _value.guide
            : guide // ignore: cast_nullable_to_non_nullable
                  as GameGuideEntity,
      ),
    );
  }
}

/// @nodoc

class _$GuLoadedImpl implements _GuLoaded {
  const _$GuLoadedImpl(this.guide);

  @override
  final GameGuideEntity guide;

  @override
  String toString() {
    return 'GuideState.loaded(guide: $guide)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GuLoadedImpl &&
            (identical(other.guide, guide) || other.guide == guide));
  }

  @override
  int get hashCode => Object.hash(runtimeType, guide);

  /// Create a copy of GuideState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GuLoadedImplCopyWith<_$GuLoadedImpl> get copyWith =>
      __$$GuLoadedImplCopyWithImpl<_$GuLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(GameGuideEntity guide) loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(guide);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(GameGuideEntity guide)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(guide);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(GameGuideEntity guide)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(guide);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GuInitial value) initial,
    required TResult Function(_GuLoading value) loading,
    required TResult Function(_GuLoaded value) loaded,
    required TResult Function(_GuError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GuInitial value)? initial,
    TResult? Function(_GuLoading value)? loading,
    TResult? Function(_GuLoaded value)? loaded,
    TResult? Function(_GuError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GuInitial value)? initial,
    TResult Function(_GuLoading value)? loading,
    TResult Function(_GuLoaded value)? loaded,
    TResult Function(_GuError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class _GuLoaded implements GuideState {
  const factory _GuLoaded(final GameGuideEntity guide) = _$GuLoadedImpl;

  GameGuideEntity get guide;

  /// Create a copy of GuideState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GuLoadedImplCopyWith<_$GuLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$GuErrorImplCopyWith<$Res> {
  factory _$$GuErrorImplCopyWith(
    _$GuErrorImpl value,
    $Res Function(_$GuErrorImpl) then,
  ) = __$$GuErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$GuErrorImplCopyWithImpl<$Res>
    extends _$GuideStateCopyWithImpl<$Res, _$GuErrorImpl>
    implements _$$GuErrorImplCopyWith<$Res> {
  __$$GuErrorImplCopyWithImpl(
    _$GuErrorImpl _value,
    $Res Function(_$GuErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GuideState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$GuErrorImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$GuErrorImpl implements _GuError {
  const _$GuErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'GuideState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GuErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of GuideState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GuErrorImplCopyWith<_$GuErrorImpl> get copyWith =>
      __$$GuErrorImplCopyWithImpl<_$GuErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(GameGuideEntity guide) loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(GameGuideEntity guide)? loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(GameGuideEntity guide)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_GuInitial value) initial,
    required TResult Function(_GuLoading value) loading,
    required TResult Function(_GuLoaded value) loaded,
    required TResult Function(_GuError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_GuInitial value)? initial,
    TResult? Function(_GuLoading value)? loading,
    TResult? Function(_GuLoaded value)? loaded,
    TResult? Function(_GuError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_GuInitial value)? initial,
    TResult Function(_GuLoading value)? loading,
    TResult Function(_GuLoaded value)? loaded,
    TResult Function(_GuError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _GuError implements GuideState {
  const factory _GuError(final String message) = _$GuErrorImpl;

  String get message;

  /// Create a copy of GuideState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GuErrorImplCopyWith<_$GuErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
