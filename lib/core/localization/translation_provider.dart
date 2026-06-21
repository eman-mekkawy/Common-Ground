import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_translations.dart';

class LanguageState {
  final String locale;
  final bool isRtl;

  LanguageState({required this.locale, required this.isRtl});

  LanguageState copyWith({String? locale, bool? isRtl}) {
    return LanguageState(
      locale: locale ?? this.locale,
      isRtl: isRtl ?? this.isRtl,
    );
  }
}

class LanguageNotifier extends StateNotifier<LanguageState> {
  LanguageNotifier() : super(LanguageState(locale: 'en', isRtl: false));

  void toggleLanguage() {
    if (state.locale == 'en') {
      state = LanguageState(locale: 'ar', isRtl: true);
    } else {
      state = LanguageState(locale: 'en', isRtl: false);
    }
  }

  void setLanguage(String languageCode) {
    state = LanguageState(
      locale: languageCode,
      isRtl: languageCode == 'ar',
    );
  }

  String translate(String key) {
    final translations = AppTranslations.values[state.locale];
    if (translations == null) return key;
    return translations[key] ?? key;
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, LanguageState>((ref) {
  return LanguageNotifier();
});
