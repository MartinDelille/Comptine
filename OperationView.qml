import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    spacing: Theme.spacingNormal

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.spacingNormal

        ComboBox {
            id: accountSelector
            Layout.preferredWidth: 200
            model: budgetData.accountCount
            displayText: budgetData.currentAccount?.name ?? qsTr("No account")
            onCurrentIndexChanged: {
                if (currentIndex >= 0) {
                    budgetData.currentAccountIndex = currentIndex;
                }
            }
            delegate: ItemDelegate {
                required property int index
                width: accountSelector.width
                text: budgetData.getAccount(index)?.name ?? ""
                highlighted: accountSelector.highlightedIndex === index
            }
        }

        BalanceHeader {
            Layout.fillWidth: true
            balance: budgetData.operationCount > 0 ? budgetData.balanceAtIndex(0) : 0
            operationCount: budgetData.operationCount
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
            model: budgetData.operationCount
        }

        OperationDetails {
            Layout.preferredWidth: 300
            Layout.fillHeight: true
            operation: operationList.currentIndex >= 0 ? budgetData.getOperation(operationList.currentIndex) : null
            balance: operationList.currentIndex >= 0 ? budgetData.balanceAtIndex(operationList.currentIndex) : 0
        }
    }
}
