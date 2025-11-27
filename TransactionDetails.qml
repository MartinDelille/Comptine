import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    required property var transaction
    required property double balance

    function formatAmount(amount) {
        return amount.toFixed(2).replace('.', ',') + " €";
    }

    border.width: 1
    border.color: "#ddd"
    color: "#fafafa"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        Label {
            text: qsTr("Transaction Details")
            font.pixelSize: 16
            font.bold: true
            color: "#333"
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#ddd"
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 1
            rowSpacing: 10
            visible: root.transaction !== null

            Label {
                text: qsTr("Date:")
                font.pixelSize: 12
                font.bold: true
                color: "#666"
            }

            Label {
                Layout.fillWidth: true
                text: root.transaction?.accountingDate ?? ""
                font.pixelSize: 12
                color: "#333"
                wrapMode: Text.WordWrap
            }

            Label {
                text: qsTr("Simplified Label:")
                font.pixelSize: 12
                font.bold: true
                color: "#666"
                Layout.topMargin: 5
            }

            Label {
                Layout.fillWidth: true
                text: root.transaction?.simplifiedLabel ?? ""
                font.pixelSize: 12
                color: "#333"
                wrapMode: Text.WordWrap
            }

            Label {
                text: qsTr("Amount:")
                font.pixelSize: 12
                font.bold: true
                color: "#666"
                Layout.topMargin: 5
            }

            Label {
                Layout.fillWidth: true
                text: root.transaction ? root.formatAmount(root.transaction.amount) : ""
                font.pixelSize: 14
                font.bold: true
                color: (root.transaction?.amount ?? 0) < 0 ? "#d32f2f" : "#388e3c"
                wrapMode: Text.WordWrap
            }

            Label {
                text: qsTr("Operation Label:")
                font.pixelSize: 12
                font.bold: true
                color: "#666"
                Layout.topMargin: 5
            }

            Label {
                Layout.fillWidth: true
                text: root.transaction?.operationLabel ?? ""
                font.pixelSize: 12
                color: "#333"
                wrapMode: Text.WordWrap
            }

            Label {
                text: qsTr("Operation Type:")
                font.pixelSize: 12
                font.bold: true
                color: "#666"
                Layout.topMargin: 5
            }

            Label {
                Layout.fillWidth: true
                text: root.transaction?.operationType ?? ""
                font.pixelSize: 12
                color: "#333"
                wrapMode: Text.WordWrap
            }

            Label {
                text: qsTr("Balance:")
                font.pixelSize: 12
                font.bold: true
                color: "#666"
                Layout.topMargin: 5
            }

            Label {
                Layout.fillWidth: true
                text: root.transaction ? root.formatAmount(root.balance) : ""
                font.pixelSize: 14
                font.bold: true
                color: root.balance < 0 ? "#d32f2f" : "#333"
                wrapMode: Text.WordWrap
            }
        }

        Label {
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: root.transaction === null ? qsTr("Select a transaction to view details") : ""
            font.pixelSize: 12
            color: "#999"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
        }
    }
}
