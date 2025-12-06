import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: root
    title: qsTr("Edit Category")
    modal: true
    anchors.centerIn: parent
    width: 400
    standardButtons: Dialog.Ok | Dialog.Cancel

    property int categoryIndex: -1
    property string originalName: ""
    property real originalBudgetLimit: 0  // Signed: positive = income, negative = expense

    onOpened: {
        categoryNameField.text = originalName;
        incomeSwitch.checked = originalBudgetLimit > 0;
        budgetLimitField.text = Math.abs(originalBudgetLimit).toFixed(2);
        categoryNameField.forceActiveFocus();
        categoryNameField.selectAll();
    }

    onAccepted: {
        let limitValue = parseFloat(budgetLimitField.text.replace(",", ".")) || 0;
        // Apply sign: positive for income, negative for expense
        let signedLimit = incomeSwitch.checked ? limitValue : -limitValue;
        budgetData.editCategory(categoryIndex, categoryNameField.text, signedLimit);
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacingNormal

        Label {
            text: qsTr("Name")
            font.pixelSize: Theme.fontSizeNormal
            color: Theme.textPrimary
        }

        TextField {
            id: categoryNameField
            Layout.fillWidth: true
            placeholderText: qsTr("Category name")
            font.pixelSize: Theme.fontSizeNormal
            onActiveFocusChanged: if (activeFocus)
                selectAll()
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingNormal

            Label {
                text: qsTr("Income category")
                font.pixelSize: Theme.fontSizeNormal
                color: Theme.textPrimary
            }

            Item {
                Layout.fillWidth: true
            }

            Switch {
                id: incomeSwitch
            }
        }

        Label {
            text: incomeSwitch.checked ? qsTr("Expected Income") : qsTr("Budget Limit")
            font.pixelSize: Theme.fontSizeNormal
            color: Theme.textPrimary
        }

        TextField {
            id: budgetLimitField
            Layout.fillWidth: true
            placeholderText: qsTr("0.00")
            font.pixelSize: Theme.fontSizeNormal
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onActiveFocusChanged: if (activeFocus)
                selectAll()
        }

        Label {
            text: incomeSwitch.checked ? qsTr("Track positive transactions (salary, etc.)") : qsTr("Track negative transactions (expenses)")
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.textMuted
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }
}
