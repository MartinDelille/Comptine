#include <QDate>
#include <QFile>
#include <QGuiApplication>
#include <QLocale>
#include <QQmlApplicationEngine>
#include <QSettings>
#include <QTranslator>
#include "AppState.h"

int main(int argc, char *argv[]) {
  QGuiApplication app(argc, argv);
  app.setOrganizationDomain("martin.delille.org");
  app.setApplicationName("Comptine");

  // Load translations based on language preference
  QTranslator translator;
  QQmlApplicationEngine engine;

  // Get the AppState singleton created by QML engine
  auto *appState = engine.singletonInstance<AppState *>("Comptine", "AppState");
  Q_ASSERT(appState);

  auto loadTranslation = [&translator, &app, appState]() {
    // Remove existing translator if any
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

  // Set default budget year/month to current date (will be overridden when file loads)
  appState->navigation()->set_budgetYear(QDate::currentDate().year());
  appState->navigation()->set_budgetMonth(QDate::currentDate().month());

  // Save last opened file when YAML is loaded
  QSettings settings;
  QObject::connect(appState->file(), &FileController::yamlFileLoaded,
                   [&settings, appState]() {
                     if (!appState->file()->currentFilePath().isEmpty()) {
                       settings.setValue("lastFile",
                                         appState->file()->currentFilePath());
                     }
                   });

  // Save or clear last file when currentFilePath changes (e.g., Save As or File > New)
  QObject::connect(appState->file(), &FileController::currentFilePathChanged,
                   [&settings, appState]() {
                     if (!appState->file()->currentFilePath().isEmpty()) {
                       settings.setValue("lastFile",
                                         appState->file()->currentFilePath());
                     } else {
                       // Clear lastFile when File > New is used
                       settings.remove("lastFile");
                     }
                   });

  QObject::connect(
      &engine, &QQmlApplicationEngine::objectCreationFailed, &app,
      []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);

  // Load file after QML engine is fully initialized
  QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, &app,
                   [appState, &settings, argc, argv](QObject *obj, const QUrl &) {
                     if (!obj) return;  // Creation failed

                     // Load file: command line argument takes priority, otherwise use last opened file
                     if (argc > 1) {
                       QString filePath = QString::fromLocal8Bit(argv[1]);
                       if (filePath.endsWith(".comptine") || filePath.endsWith(".yaml") || filePath.endsWith(".yml")) {
                         appState->file()->loadFromYaml(filePath);
                       } else if (filePath.endsWith(".csv")) {
                         appState->file()->importFromCsv(filePath);
                       }
                     } else {
                       QString lastFile = settings.value("lastFile").toString();
                       if (!lastFile.isEmpty() && QFile::exists(lastFile)) {
                         appState->file()->loadFromYaml(lastFile);
                       }
                     }
                   }, Qt::QueuedConnection);

  engine.loadFromModule("Comptine", "Main");

  // Live language switching: reload translation and retranslate QML
  QObject::connect(appState->settings(), &AppSettings::languageChangeRequested,
                   [&loadTranslation, &engine]() {
                     loadTranslation();
                     engine.retranslate();
                   });

  return app.exec();
}
