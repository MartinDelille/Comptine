#include <QGuiApplication>
#include <QLocale>
#include <QQmlApplicationEngine>
#include <QTranslator>
#include "AppState.h"

int main(int argc, char *argv[]) {
  QGuiApplication app(argc, argv);
  app.setOrganizationDomain("martin.delille.org");
  app.setApplicationName("Comptine");

  QTranslator translator;
  QQmlApplicationEngine engine;

  // Get the AppState singleton created by QML engine
  auto *appState = engine.singletonInstance<AppState *>("Comptine", "AppState");
  Q_ASSERT(appState);

  // Translation loading helper
  auto loadTranslation = [&translator, &app, appState]() {
    app.removeTranslator(&translator);

    QString lang = appState->settings()->language();
    if (lang.isEmpty()) {
      // System default
      if (translator.load(QLocale(), "comptine", "_", ":/i18n")) {
        app.installTranslator(&translator);
      }
    } else if (lang == "fr") {
      if (translator.load(":/i18n/comptine_fr.qm")) {
        app.installTranslator(&translator);
      }
    }
    // If lang == "en", don't load any translator (English is source)
  };

  loadTranslation();

  // Handle QML creation failure
  QObject::connect(
      &engine, &QQmlApplicationEngine::objectCreationFailed, &app,
      []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);

  // Load initial file after QML engine is fully initialized
  QObject::connect(
      &engine, &QQmlApplicationEngine::objectCreated, &app,
      [appState](QObject *obj, const QUrl &) {
        if (obj) {
          appState->file()->loadInitialFile(QCoreApplication::arguments());
        }
      },
      Qt::QueuedConnection);

  engine.loadFromModule("Comptine", "Main");

  // Live language switching
  QObject::connect(appState->settings(), &AppSettings::languageChangeRequested,
                   [&loadTranslation, &engine]() {
                     loadTranslation();
                     engine.retranslate();
                   });

  return app.exec();
}
