import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: preferencesDialog
    title: qsTr("Preferences")
    standardButtons: Dialog.Ok | Dialog.Cancel
    modal: true

    property string originalLanguage: ""
    property string originalTheme: ""

    onOpened: {
        // Save original values to restore on cancel
        originalLanguage = appSettings.language;
        originalTheme = appSettings.theme;

        // Set initial language combo box value
        if (appSettings.language === "") {
            languageComboBox.currentIndex = 0;
        } else if (appSettings.language === "en") {
            languageComboBox.currentIndex = 1;
        } else if (appSettings.language === "fr") {
            languageComboBox.currentIndex = 2;
        }

        // Set initial theme combo box value
        if (appSettings.theme === "") {
            themeComboBox.currentIndex = 0;
        } else if (appSettings.theme === "light") {
            themeComboBox.currentIndex = 1;
        } else if (appSettings.theme === "dark") {
            themeComboBox.currentIndex = 2;
        }
    }

    onRejected: {
        // Restore original values on cancel
        if (appSettings.language !== originalLanguage) {
            appSettings.language = originalLanguage;
        }
        if (appSettings.theme !== originalTheme) {
            appSettings.theme = originalTheme;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        GridLayout {
            columns: 2
            columnSpacing: 20
            rowSpacing: 15

            Label {
                text: qsTr("Language:")
            }

            ComboBox {
                id: languageComboBox
                Layout.preferredWidth: 200
                model: [qsTr("System Default"), "English", "Français"]

                onActivated: {
                    var newLanguage = "";
                    if (currentIndex === 1) {
                        newLanguage = "en";
                    } else if (currentIndex === 2) {
                        newLanguage = "fr";
                    }
                    appSettings.language = newLanguage;
                }
            }

            Label {
                text: qsTr("Theme:")
            }

            ComboBox {
                id: themeComboBox
                Layout.preferredWidth: 200
                model: [qsTr("System Default"), qsTr("Light"), qsTr("Dark")]

                onActivated: {
                    var newTheme = "";
                    if (currentIndex === 1) {
                        newTheme = "light";
                    } else if (currentIndex === 2) {
                        newTheme = "dark";
                    }
                    appSettings.theme = newTheme;
                }
            }
        }
    }
}
