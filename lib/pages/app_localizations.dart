import 'dart:async';
import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void changeLocale(Locale newLocale) {
    if (_locale != newLocale) {
      _locale = newLocale;
      notifyListeners();
    }
  }
}

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  static Future<AppLocalizations> load(Locale locale) async {
    final AppLocalizations localizations = AppLocalizations(locale);
    return localizations;
  }

  String translate(String key) {
    // Fetch the localized value based on the language
    // Placeholder logic; this should map to your localized strings
    switch (key) {
      case 'settings':
        return locale.languageCode == 'es' ? 'Configuración' : 'Settings';
      case 'dark_mode':
        return locale.languageCode == 'es' ? 'Modo oscuro' : 'Dark Mode';
      case 'notifications':
        return locale.languageCode == 'es' ? 'Notificaciones' : 'Notifications';
      case 'language':
        return locale.languageCode == 'es' ? 'Idioma' : 'Language';
      case 'location_services':
        return locale.languageCode == 'es'
            ? 'Servicios de ubicación'
            : 'Location Services';
      case 'about_us':
        return locale.languageCode == 'es' ? 'Acerca de nosotros' : 'About Us';
      case 'select_language':
        return locale.languageCode == 'es'
            ? 'Seleccionar idioma'
            : 'Select Language';
      default:
        return key;
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
