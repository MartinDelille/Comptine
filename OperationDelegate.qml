import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    required property var operation
    required property double balance
    required property bool selected
    required property bool alternate

    width: parent ? parent.width : 0
    height: 50
    radius: 4
    border.width: 1
    border.color: Theme.border

    color: {
        if (root.selected)
            return Theme.backgroundSelected;
        if (root.alternate)
            return Theme.backgroundAlt;
        return Theme.background;
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacingNormal
        spacing: Theme.spacingNormal

        Label {
            text: root.operation?.date ? root.operation.date.toLocaleDateString(Qt.locale(), Locale.ShortFormat) : ""
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Theme.fontSizeNormal
            color: Theme.textPrimary
            Layout.preferredWidth: 100
        }

        Label {
            Layout.fillWidth: true
            text: root.operation?.description ?? ""
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            font.pixelSize: Theme.fontSizeNormal
            color: Theme.textPrimary
        }

        Label {
            text: Theme.formatAmount(root.operation?.amount ?? 0)
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            font.pixelSize: Theme.fontSizeNormal
            color: Theme.amountColor(root.operation?.amount ?? 0)
            font.bold: true
            Layout.preferredWidth: 100
        }

        Label {
            text: Theme.formatAmount(root.balance)
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            font.pixelSize: Theme.fontSizeNormal
            color: Theme.balanceColor(root.balance)
            Layout.preferredWidth: 100
        }
    }
}
