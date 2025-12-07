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

    property string originalName: ""
    property real originalBudgetLimit: 0  // Signed: positive = income, negative = expense

    // Parse amount string with French format support (e.g., "1 015,58 €")
    function parseAmount(str) {
        let cleaned = str.trim();
        // Remove spaces (thousand separators), non-breaking spaces, and Euro symbol
        cleaned = cleaned.replace(/[\s\u00A0\u202F€]/g, "");
        // Handle plus sign for positive amounts
        let isPositive = cleaned.startsWith("+");
        if (isPositive) {
            cleaned = cleaned.substring(1);
        }
        // French decimal comma to dot
        cleaned = cleaned.replace(",", ".");
        let value = parseFloat(cleaned) || 0;
        return isPositive ? Math.abs(value) : value;
    }

    onOpened: {
        categoryNameField.text = originalName;
        budgetLimitField.text = originalBudgetLimit.toFixed(2);
        categoryNameField.forceActiveFocus();
        categoryNameField.selectAll();
    }

    onAccepted: {
        let newBudgetLimit = parseAmount(budgetLimitField.text);
        budgetData.editCategory(originalName, categoryNameField.text, newBudgetLimit);
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

        Label {
            text: qsTr("Budget Limit")
            font.pixelSize: Theme.fontSizeNormal
            color: Theme.textPrimary
        }

        TextField {
            id: budgetLimitField
            Layout.fillWidth: true
            placeholderText: qsTr("0.00")
            font.pixelSize: Theme.fontSizeNormal
            onActiveFocusChanged: if (activeFocus)
                selectAll()
        }

        Label {
            text: qsTr("Negative = expense, Positive = income")
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.textMuted
        }
    }
}
