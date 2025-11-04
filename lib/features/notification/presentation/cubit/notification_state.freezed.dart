// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NotificationState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NotificationState()';
}


}

/// @nodoc
class $NotificationStateCopyWith<$Res>  {
$NotificationStateCopyWith(NotificationState _, $Res Function(NotificationState) __);
}


/// Adds pattern-matching-related methods to [NotificationState].
extension NotificationStatePatterns on NotificationState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Loading value)?  loading,TResult Function( _Loaded value)?  loaded,TResult Function( _Error value)?  error,TResult Function( _NewMessageReceived value)?  newMessageReceived,TResult Function( _NavigateTo value)?  navigateTo,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
return error(_that);case _NewMessageReceived() when newMessageReceived != null:
return newMessageReceived(_that);case _NavigateTo() when navigateTo != null:
return navigateTo(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Loading value)  loading,required TResult Function( _Loaded value)  loaded,required TResult Function( _Error value)  error,required TResult Function( _NewMessageReceived value)  newMessageReceived,required TResult Function( _NavigateTo value)  navigateTo,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Loading():
return loading(_that);case _Loaded():
return loaded(_that);case _Error():
return error(_that);case _NewMessageReceived():
return newMessageReceived(_that);case _NavigateTo():
return navigateTo(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Loading value)?  loading,TResult? Function( _Loaded value)?  loaded,TResult? Function( _Error value)?  error,TResult? Function( _NewMessageReceived value)?  newMessageReceived,TResult? Function( _NavigateTo value)?  navigateTo,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Loading() when loading != null:
return loading(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
return error(_that);case _NewMessageReceived() when newMessageReceived != null:
return newMessageReceived(_that);case _NavigateTo() when navigateTo != null:
return navigateTo(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( List<dynamic> notifications)?  loaded,TResult Function( String message)?  error,TResult Function( Map<String, dynamic> message)?  newMessageReceived,TResult Function( String route)?  navigateTo,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.notifications);case _Error() when error != null:
return error(_that.message);case _NewMessageReceived() when newMessageReceived != null:
return newMessageReceived(_that.message);case _NavigateTo() when navigateTo != null:
return navigateTo(_that.route);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( List<dynamic> notifications)  loaded,required TResult Function( String message)  error,required TResult Function( Map<String, dynamic> message)  newMessageReceived,required TResult Function( String route)  navigateTo,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Loading():
return loading();case _Loaded():
return loaded(_that.notifications);case _Error():
return error(_that.message);case _NewMessageReceived():
return newMessageReceived(_that.message);case _NavigateTo():
return navigateTo(_that.route);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( List<dynamic> notifications)?  loaded,TResult? Function( String message)?  error,TResult? Function( Map<String, dynamic> message)?  newMessageReceived,TResult? Function( String route)?  navigateTo,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Loading() when loading != null:
return loading();case _Loaded() when loaded != null:
return loaded(_that.notifications);case _Error() when error != null:
return error(_that.message);case _NewMessageReceived() when newMessageReceived != null:
return newMessageReceived(_that.message);case _NavigateTo() when navigateTo != null:
return navigateTo(_that.route);case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements NotificationState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NotificationState.initial()';
}


}




/// @nodoc


class _Loading implements NotificationState {
  const _Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NotificationState.loading()';
}


}




/// @nodoc


class _Loaded implements NotificationState {
  const _Loaded(final  List<dynamic> notifications): _notifications = notifications;
  

 final  List<dynamic> _notifications;
 List<dynamic> get notifications {
  if (_notifications is EqualUnmodifiableListView) return _notifications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notifications);
}


/// Create a copy of NotificationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loaded&&const DeepCollectionEquality().equals(other._notifications, _notifications));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_notifications));

@override
String toString() {
  return 'NotificationState.loaded(notifications: $notifications)';
}


}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $NotificationStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 List<dynamic> notifications
});




}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of NotificationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? notifications = null,}) {
  return _then(_Loaded(
null == notifications ? _self._notifications : notifications // ignore: cast_nullable_to_non_nullable
as List<dynamic>,
  ));
}


}

/// @nodoc


class _Error implements NotificationState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of NotificationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'NotificationState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $NotificationStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of NotificationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _NewMessageReceived implements NotificationState {
  const _NewMessageReceived(final  Map<String, dynamic> message): _message = message;
  

 final  Map<String, dynamic> _message;
 Map<String, dynamic> get message {
  if (_message is EqualUnmodifiableMapView) return _message;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_message);
}


/// Create a copy of NotificationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NewMessageReceivedCopyWith<_NewMessageReceived> get copyWith => __$NewMessageReceivedCopyWithImpl<_NewMessageReceived>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NewMessageReceived&&const DeepCollectionEquality().equals(other._message, _message));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_message));

@override
String toString() {
  return 'NotificationState.newMessageReceived(message: $message)';
}


}

/// @nodoc
abstract mixin class _$NewMessageReceivedCopyWith<$Res> implements $NotificationStateCopyWith<$Res> {
  factory _$NewMessageReceivedCopyWith(_NewMessageReceived value, $Res Function(_NewMessageReceived) _then) = __$NewMessageReceivedCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> message
});




}
/// @nodoc
class __$NewMessageReceivedCopyWithImpl<$Res>
    implements _$NewMessageReceivedCopyWith<$Res> {
  __$NewMessageReceivedCopyWithImpl(this._self, this._then);

  final _NewMessageReceived _self;
  final $Res Function(_NewMessageReceived) _then;

/// Create a copy of NotificationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_NewMessageReceived(
null == message ? _self._message : message // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

/// @nodoc


class _NavigateTo implements NotificationState {
  const _NavigateTo(this.route);
  

 final  String route;

/// Create a copy of NotificationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NavigateToCopyWith<_NavigateTo> get copyWith => __$NavigateToCopyWithImpl<_NavigateTo>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NavigateTo&&(identical(other.route, route) || other.route == route));
}


@override
int get hashCode => Object.hash(runtimeType,route);

@override
String toString() {
  return 'NotificationState.navigateTo(route: $route)';
}


}

/// @nodoc
abstract mixin class _$NavigateToCopyWith<$Res> implements $NotificationStateCopyWith<$Res> {
  factory _$NavigateToCopyWith(_NavigateTo value, $Res Function(_NavigateTo) _then) = __$NavigateToCopyWithImpl;
@useResult
$Res call({
 String route
});




}
/// @nodoc
class __$NavigateToCopyWithImpl<$Res>
    implements _$NavigateToCopyWith<$Res> {
  __$NavigateToCopyWithImpl(this._self, this._then);

  final _NavigateTo _self;
  final $Res Function(_NavigateTo) _then;

/// Create a copy of NotificationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? route = null,}) {
  return _then(_NavigateTo(
null == route ? _self.route : route // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
