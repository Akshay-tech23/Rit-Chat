import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

/// Global BLoC Observer for logging all transitions and errors.
/// Useful for debugging & monitoring in development.
class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    if (kDebugMode) {
      debugPrint('📢 ${bloc.runtimeType} → Event: $event');
    }
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      debugPrint('🔄 ${bloc.runtimeType} → State change: $change');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    debugPrint('❌ ${bloc.runtimeType} → Error: $error');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      debugPrint('➡️ ${bloc.runtimeType} → Transition: $transition');
    }
  }
}
