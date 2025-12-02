import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: root

    property int selectedYear: new Date().getFullYear()
    property int selectedMonth: new Date().getMonth() + 1

    signal monthChanged(int year, int month)

    function monthName(month) {
        var months = [qsTr("January"), qsTr("February"), qsTr("March"), qsTr("April"), qsTr("May"), qsTr("June"), qsTr("July"), qsTr("August"), qsTr("September"), qsTr("October"), qsTr("November"), qsTr("December")];
        return months[month - 1];
    }

    function previousMonth() {
        if (selectedMonth === 1) {
            selectedMonth = 12;
            selectedYear--;
        } else {
            selectedMonth--;
        }
        monthChanged(selectedYear, selectedMonth);
    }

    function nextMonth() {
        if (selectedMonth === 12) {
            selectedMonth = 1;
            selectedYear++;
        } else {
            selectedMonth++;
        }
        monthChanged(selectedYear, selectedMonth);
    }

    Layout.fillWidth: true
    Layout.alignment: Qt.AlignHCenter
    spacing: Theme.spacingXLarge

    Button {
        text: "<"
        onClicked: previousMonth()
        implicitWidth: 40
    }

    Label {
        text: monthName(selectedMonth) + " " + selectedYear
        font.pixelSize: Theme.fontSizeXLarge
        font.bold: true
        color: Theme.textPrimary
        horizontalAlignment: Text.AlignHCenter
        Layout.preferredWidth: 200
    }

    Button {
        text: ">"
        onClicked: nextMonth()
        implicitWidth: 40
    }
}
