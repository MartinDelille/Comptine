import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    color: "#fafafa"

    property var budgetSummary: []

    function updateBudgetSummary() {
        budgetSummary = budgetData.monthlyBudgetSummary(budgetData.budgetYear, budgetData.budgetMonth);
    }

    function formatAmount(amount) {
        return amount.toFixed(2).replace('.', ',') + " €";
    }

    Component.onCompleted: updateBudgetSummary()

    Connections {
        target: budgetData
        function onDataLoaded() {
            // Update MonthSelector to match loaded state
            monthSelector.selectedYear = budgetData.budgetYear;
            monthSelector.selectedMonth = budgetData.budgetMonth;
            updateBudgetSummary();
        }
        function onCategoryCountChanged() {
            updateBudgetSummary();
        }
        function onBudgetYearChanged() {
            monthSelector.selectedYear = budgetData.budgetYear;
            updateBudgetSummary();
        }
        function onBudgetMonthChanged() {
            monthSelector.selectedMonth = budgetData.budgetMonth;
            updateBudgetSummary();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Month navigation
        MonthSelector {
            id: monthSelector
            selectedYear: budgetData.budgetYear
            selectedMonth: budgetData.budgetMonth
            onMonthChanged: (year, month) => {
                budgetData.budgetYear = year;
                budgetData.budgetMonth = month;
            }
        }

        // Budget list
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: budgetSummary
            spacing: 10
            clip: true

            delegate: Rectangle {
                required property var modelData
                required property int index

                width: ListView.view.width
                height: 80
                color: "white"
                border.color: "#e0e0e0"
                border.width: 1
                radius: 8

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true

                        Label {
                            text: modelData.name
                            font.pixelSize: 14
                            font.bold: true
                            color: "#333"
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Label {
                            text: modelData.budgetLimit > 0 && modelData.percentUsed > 100 ? qsTr("DÉPASSÉ") : ""
                            font.pixelSize: 12
                            font.bold: true
                            color: "#d32f2f"
                        }

                        Label {
                            text: formatAmount(modelData.spent) + " / " + formatAmount(modelData.budgetLimit)
                            font.pixelSize: 14
                            color: "#666"
                        }
                    }

                    // Custom progress bar using rectangles
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 16
                        color: "#e0e0e0"
                        radius: 4

                        Rectangle {
                            width: Math.min(modelData.percentUsed / 100, 1.0) * parent.width
                            height: parent.height
                            radius: 4
                            color: {
                                if (modelData.budgetLimit <= 0)
                                    return "#9e9e9e";
                                if (modelData.percentUsed > 100)
                                    return "#d32f2f";
                                if (modelData.percentUsed > 80)
                                    return "#f57c00";
                                return "#388e3c";
                            }
                        }
                    }

                    Label {
                        text: modelData.budgetLimit > 0 ? (modelData.remaining >= 0 ? qsTr("Reste: %1").arg(formatAmount(modelData.remaining)) : qsTr("Dépassement: %1").arg(formatAmount(-modelData.remaining))) : qsTr("Pas de budget défini")
                        font.pixelSize: 12
                        color: modelData.remaining >= 0 ? "#666" : "#d32f2f"
                    }
                }
            }
        }

        // Empty state
        Label {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: budgetSummary.length === 0
            text: qsTr("Aucune catégorie définie")
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 16
            color: "#999"
        }
    }
}
