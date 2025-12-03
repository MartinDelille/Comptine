import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    objectName: "OperationView"
    spacing: Theme.spacingNormal

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacingNormal

        ComboBox {
            id: accountSelector
            Layout.preferredWidth: 200
            model: budgetData.accountModel
            textRole: "name"
            currentIndex: budgetData.currentAccountIndex
            enabled: budgetData.accountCount > 0
            displayText: budgetData.currentAccount?.name ?? qsTr("No account")
            onActivated: {
                budgetData.currentAccountIndex = currentIndex;
            }
            delegate: ItemDelegate {
                required property int index
                required property string name
                width: accountSelector.width
                text: name
                highlighted: accountSelector.highlightedIndex === index
            }
        }

        BalanceHeader {
            Layout.fillWidth: true
            balance: budgetData.operationModel.count > 0 ? budgetData.operationModel.data(budgetData.operationModel.index(0, 0), 261) : 0
            operationCount: budgetData.operationModel.count
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Theme.spacingNormal

        OperationList {
            id: operationList
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        OperationDetails {
            Layout.preferredWidth: 300
            Layout.fillHeight: true
            currentIndex: operationList.currentIndex
        }
    }
}
