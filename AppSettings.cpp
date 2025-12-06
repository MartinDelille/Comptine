#include "AppSettings.h"

AppSettings::AppSettings(QObject *parent) :
    QObject(parent) {
  _language = _settings.value("language", QString()).toString();
  _theme = _settings.value("theme", QString()).toString();
}

QString AppSettings::language() const {
  return _language;
}

void AppSettings::set_language(QString value) {
  if (_language != value) {
    _language = value;
    _settings.setValue("language", value);
    _settings.sync();
    emit languageChanged();
    emit languageChangeRequested();
  }
}

QString AppSettings::theme() const {
  return _theme;
}

void AppSettings::set_theme(QString value) {
  if (_theme != value) {
    _theme = value;
    _settings.setValue("theme", value);
    _settings.sync();
    emit themeChanged();
  }
}
