import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: root

    property int selectedYear: new Date().getFullYear()
    property int selectedMonth: new Date().getMonth() + 1

    signal monthChanged(int year, int month)

    function monthName(month) {
        var months = [qsTr("Janvier"), qsTr("Février"), qsTr("Mars"), qsTr("Avril"), qsTr("Mai"), qsTr("Juin"), qsTr("Juillet"), qsTr("Août"), qsTr("Septembre"), qsTr("Octobre"), qsTr("Novembre"), qsTr("Décembre")];
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
    spacing: 20

    Button {
        text: "<"
        onClicked: previousMonth()
        implicitWidth: 40
    }

    Label {
        text: monthName(selectedMonth) + " " + selectedYear
        font.pixelSize: 20
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        Layout.preferredWidth: 200
    }

    Button {
        text: ">"
        onClicked: nextMonth()
        implicitWidth: 40
    }
}
