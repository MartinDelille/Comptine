import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    required property double balance
    required property int transactionCount

    function formatAmount(amount) {
        return amount.toFixed(2).replace('.', ',') + " €";
    }

    Layout.fillWidth: true
    Layout.preferredHeight: 50
    color: "#f5f5f5"
    border.width: 1
    border.color: "#ddd"
    radius: 4

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10

        Label {
            text: qsTr("Current Balance:")
            font.pixelSize: 16
            color: "#666"
        }

        Label {
            text: root.formatAmount(root.balance)
            font.pixelSize: 20
            font.bold: true
            color: root.balance < 0 ? "#d32f2f" : "#388e3c"
        }

        Item {
            Layout.fillWidth: true
        }

        Label {
            text: qsTr("%1 transactions").arg(root.transactionCount)
            font.pixelSize: 14
            color: "#666"
        }
    }
}
