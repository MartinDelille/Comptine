import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: importDialog
    title: qsTr("Import CSV")
    standardButtons: Dialog.Ok | Dialog.Cancel
    modal: true

    property string filePath: ""

    // Use a separate model with "New account" option enabled
    property var importAccountModel: null

    Component.onCompleted: {
        // Create a model with includeNewAccountOption enabled
        // This is done once since accountModel from budgetData doesn't have this option
    }

    onOpened: {
        // Enable "New account" option
        budgetData.accountModel.includeNewAccountOption = true;
        // Default to "New account" (last item in the list)
        accountComboBox.currentIndex = budgetData.accountModel.count - 1;
    }

    onClosed: {
        // Disable "New account" option when dialog closes
        budgetData.accountModel.includeNewAccountOption = false;
    }

    onAccepted: {
        var accountName = "";
        // If not the "New account" option, use existing account name
        if (!budgetData.accountModel.isNewAccountOption(accountComboBox.currentIndex)) {
            var account = budgetData.getAccount(accountComboBox.currentIndex);
            accountName = account ? account.name : "";
        }
        // Empty accountName will create a new account in importFromCsv
        budgetData.importFromCsv(filePath, accountName);
        budgetData.currentTabIndex = 0;
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacingNormal

        Label {
            text: qsTr("Import into account:")
        }

        ComboBox {
            id: accountComboBox
            Layout.fillWidth: true
            Layout.preferredWidth: 250
            model: budgetData.accountModel
            textRole: "name"
            delegate: ItemDelegate {
                required property int index
                required property string name
                width: accountComboBox.width
                text: budgetData.accountModel.isNewAccountOption(index) ? qsTr("New account") : name
                highlighted: accountComboBox.highlightedIndex === index
            }
            displayText: {
                if (budgetData.accountModel.isNewAccountOption(currentIndex)) {
                    return qsTr("New account");
                }
                return budgetData.getAccount(currentIndex)?.name ?? qsTr("New account");
            }
        }
    }
}
