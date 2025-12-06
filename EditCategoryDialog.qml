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
    property real originalBudgetLimit: 0

    onOpened: {
        categoryNameField.text = originalName;
        budgetLimitField.text = originalBudgetLimit.toFixed(2);
        categoryNameField.forceActiveFocus();
    }

    onAccepted: {
        let newBudgetLimit = parseFloat(budgetLimitField.text.replace(",", ".")) || 0;
        budgetData.editCategory(categoryIndex, categoryNameField.text, newBudgetLimit);
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
            inputMethodHints: Qt.ImhFormattedNumbersOnly
        }
    }
}
