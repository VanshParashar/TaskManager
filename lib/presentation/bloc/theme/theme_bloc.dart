import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/toggle_theme.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ToggleTheme toggleTheme;

  ThemeBloc({required this.toggleTheme}) : super(ThemeInitial()) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<ToggleThemeEvent>(_onToggleTheme);
  }

  Future<void> _onLoadTheme(LoadThemeEvent event, Emitter<ThemeState> emit) async {
    try {
      final isDarkMode = await toggleTheme.getCurrentTheme();
      emit(ThemeLoaded(isDarkMode));
    } catch (e) {
      emit(const ThemeLoaded(false));
    }
  }

  Future<void> _onToggleTheme(ToggleThemeEvent event, Emitter<ThemeState> emit) async {
    try {
      final isDarkMode = await toggleTheme();
      emit(ThemeLoaded(isDarkMode));
    } catch (e) {
      if (state is ThemeLoaded) {
        final currentState = state as ThemeLoaded;
        emit(ThemeLoaded(!currentState.isDarkMode));
      }
    }
  }
}