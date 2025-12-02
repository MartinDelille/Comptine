#pragma once

#include <QObject>
#include <QSettings>
#include <QString>
#include "PropertyMacros.h"

class AppSettings : public QObject {
  Q_OBJECT

  // Language: empty string = system default, "en" = English, "fr" = French
  PROPERTY_RW_CUSTOM(QString, language, QString())

  // Theme: empty string = system default, "light" = Light, "dark" = Dark
  PROPERTY_RW_CUSTOM(QString, theme, QString())

public:
  explicit AppSettings(QObject *parent = nullptr);

signals:
  void languageChangeRequested();

private:
  QSettings _settings;
};
