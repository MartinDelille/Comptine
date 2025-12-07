import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: root

    function monthName(month) {
        var months = [qsTr("January"), qsTr("February"), qsTr("March"), qsTr("April"), qsTr("May"), qsTr("June"), qsTr("July"), qsTr("August"), qsTr("September"), qsTr("October"), qsTr("November"), qsTr("December")];
        return months[month - 1];
    }

    Layout.fillWidth: true
    Layout.alignment: Qt.AlignHCenter
    spacing: Theme.spacingXLarge

    Button {
        text: "<"
        onClicked: budgetData.previousMonth()
        implicitWidth: 40
    }

    Label {
        text: monthName(budgetData.budgetMonth) + " " + budgetData.budgetYear
        font.pixelSize: Theme.fontSizeXLarge
        font.bold: true
        color: Theme.textPrimary
        horizontalAlignment: Text.AlignHCenter
        Layout.preferredWidth: 200
    }

    Button {
        text: ">"
        onClicked: budgetData.nextMonth()
        implicitWidth: 40
    }
}
