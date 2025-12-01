import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

ApplicationWindow {
    id: window
    width: 1200
    height: 800
    visible: true
    title: budgetData.currentFilePath.length > 0 ? "Comptine - " + budgetData.currentFilePath.split('/').pop() : "Comptine"

    menuBar: MenuBar {
        Menu {
            title: qsTr("&File")
            Action {
                text: qsTr("&Open...")
                shortcut: StandardKey.Open
                onTriggered: openDialog.open()
            }
            Action {
                text: qsTr("&Save")
                shortcut: StandardKey.Save
                enabled: budgetData.currentFilePath.length > 0
                onTriggered: budgetData.saveToYaml(budgetData.currentFilePath)
            }
            Action {
                text: qsTr("&Save As...")
                shortcut: StandardKey.SaveAs
                onTriggered: saveDialog.open()
            }
            MenuSeparator {}
            Action {
                text: qsTr("&Import CSV...")
                shortcut: "Ctrl+Shift+I"
                onTriggered: csvDialog.open()
            }
            MenuSeparator {}
            Action {
                text: qsTr("&Quit")
                shortcut: StandardKey.Quit
                onTriggered: Qt.quit()
            }
        }
        Menu {
            title: qsTr("&Help")
            Action {
                text: qsTr("&About")
                onTriggered: aboutDialog.open()
            }
        }
    }

    FileDialog {
        id: openDialog
        title: qsTr("Open Budget File")
        fileMode: FileDialog.OpenFile
        nameFilters: ["YAML files (*.yaml *.yml)", "All files (*)"]
        onAccepted: {
            budgetData.loadFromYaml(selectedFile.toString().replace("file://", ""));
        }
    }

    FileDialog {
        id: saveDialog
        title: qsTr("Save Budget File")
        fileMode: FileDialog.SaveFile
        nameFilters: ["YAML files (*.yaml *.yml)", "All files (*)"]
        onAccepted: {
            budgetData.saveToYaml(selectedFile.toString().replace("file://", ""));
        }
    }

    FileDialog {
        id: csvDialog
        title: qsTr("Import CSV File")
        fileMode: FileDialog.OpenFile
        nameFilters: ["CSV files (*.csv)", "All files (*)"]
        onAccepted: {
            budgetData.importFromCsv(selectedFile.toString().replace("file://", ""));
        }
    }

    Dialog {
        id: aboutDialog
        title: qsTr("About Comptine")
        standardButtons: Dialog.Ok

        Label {
            text: qsTr("Comptine v0.1\n\nPersonal Budget Management Software\n\nImport and manage your bank account data.")
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        TabBar {
            id: tabBar
            Layout.fillWidth: true

            TabButton {
                text: qsTr("Opérations")
            }
            TabButton {
                text: qsTr("Budget")
            }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex

            // Operations view
            OperationView {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            // Budget view
            BudgetView {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }
}
