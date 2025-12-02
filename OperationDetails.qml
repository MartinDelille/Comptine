import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    required property var operation
    required property double balance

    radius: Theme.cardRadius
    border.width: Theme.cardBorderWidth
    border.color: Theme.border
    color: Theme.surface

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingLarge
        spacing: Theme.spacingLarge

        Label {
            text: qsTr("Operation Details")
            font.pixelSize: Theme.fontSizeLarge
            font.bold: true
            color: Theme.textPrimary
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.border
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 1
            rowSpacing: Theme.spacingNormal
            visible: root.operation !== null

            Label {
                text: qsTr("Date:")
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                color: Theme.textSecondary
            }

            Label {
                Layout.fillWidth: true
                text: root.operation?.date ? root.operation.date.toLocaleDateString(Qt.locale(), Locale.LongFormat) : ""
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textPrimary
                wrapMode: Text.WordWrap
            }

            Label {
                text: qsTr("Description:")
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                color: Theme.textSecondary
                Layout.topMargin: Theme.spacingSmall
            }

            Label {
                Layout.fillWidth: true
                text: root.operation?.description ?? ""
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.textPrimary
                wrapMode: Text.WordWrap
            }

            Label {
                text: qsTr("Category:")
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                color: Theme.textSecondary
                Layout.topMargin: Theme.spacingSmall
            }

            Label {
                Layout.fillWidth: true
                text: root.operation?.category ?? qsTr("Uncategorized")
                font.pixelSize: Theme.fontSizeSmall
                color: root.operation?.category ? Theme.textPrimary : Theme.textMuted
                wrapMode: Text.WordWrap
            }

            Label {
                text: qsTr("Amount:")
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                color: Theme.textSecondary
                Layout.topMargin: Theme.spacingSmall
            }

            Label {
                Layout.fillWidth: true
                text: root.operation ? Theme.formatAmount(root.operation.amount) : ""
                font.pixelSize: Theme.fontSizeNormal
                font.bold: true
                color: Theme.amountColor(root.operation?.amount ?? 0)
                wrapMode: Text.WordWrap
            }

            Label {
                text: qsTr("Balance:")
                font.pixelSize: Theme.fontSizeSmall
                font.bold: true
                color: Theme.textSecondary
                Layout.topMargin: Theme.spacingSmall
            }

            Label {
                Layout.fillWidth: true
                text: root.operation ? Theme.formatAmount(root.balance) : ""
                font.pixelSize: Theme.fontSizeNormal
                font.bold: true
                color: Theme.balanceColor(root.balance)
                wrapMode: Text.WordWrap
            }
        }

        Label {
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: root.operation === null ? qsTr("Select an operation to view details") : ""
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.textMuted
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
        }
    }
}
