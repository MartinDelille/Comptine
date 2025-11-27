import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

ApplicationWindow {
    id: window
    width: 1200
    height: 800
    visible: true
    title: qsTr("Comptine - Personal Budget Manager")

    menuBar: MenuBar {
        Menu {
            title: qsTr("&File")
            Action {
                text: qsTr("&Import CSV...")
                onTriggered: fileDialog.open()
            }
            MenuSeparator {}
            Action {
                text: qsTr("&Quit")
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
        id: fileDialog
        title: qsTr("Import CSV File")
        fileMode: FileDialog.OpenFile
        nameFilters: ["CSV files (*.csv)", "All files (*)"]
        onAccepted: {
            transactionModel.loadFromCsv(selectedFile.toString().replace("file://", ""));
            statusBar.text = qsTr("Loaded %1 transactions").arg(transactionModel.count);
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

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true
            boundsBehavior: Flickable.StopAtBounds

            model: transactionModel.model

            delegate: Rectangle {
                width: ListView.view.width - scrollBar.width
                height: 50
                border.width: 1
                border.color: "#ddd"

                required property int index
                property var transaction: transactionModel.getTransaction(index)

                color: {
                    if (index % 2 === 0)
                        return "#f9f9f9";
                    return "white";
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    Label {
                        text: transaction?.accountingDate ?? ""
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: 14
                        color: "#333"
                        Layout.preferredWidth: 100
                    }

                    Label {
                        Layout.fillWidth: true
                        text: transaction?.simplifiedLabel ?? ""
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                        font.pixelSize: 14
                        color: "#333"
                    }

                    Label {
                        text: transaction?.amount ?? ""
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignRight
                        font.pixelSize: 14
                        color: {
                            var amt = parseFloat(transaction?.amount ?? "0");
                            return amt < 0 ? "#d32f2f" : "#388e3c";
                        }
                        font.bold: true
                        Layout.preferredWidth: 100
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {
                id: scrollBar
            }
        }
    }
}
