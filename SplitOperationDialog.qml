import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: root

    property int operationIndex: -1
    property double totalAmount: 0

    // Category list for ComboBoxes - refreshed on open
    property var categoryList: []

    title: qsTr("Split Operation")
    modal: true
    parent: Overlay.overlay
    anchors.centerIn: parent
    width: Math.min(500, parent.width - 40)
    standardButtons: Dialog.Ok | Dialog.Cancel

    // Calculate remaining amount
    readonly property double allocatedAmount: {
        let sum = 0;
        for (let i = 0; i < allocationModel.count; i++) {
            sum += allocationModel.get(i).amount;
        }
        return sum;
    }
    readonly property double remainingAmount: totalAmount - allocatedAmount
    readonly property bool allCategoriesSelected: {
        if (allocationModel.count === 0)
            return false;
        for (let i = 0; i < allocationModel.count; i++) {
            if (allocationModel.get(i).category === "")
                return false;
        }
        return true;
    }
    readonly property bool hasDuplicateCategories: {
        let seen = new Set();
        for (let i = 0; i < allocationModel.count; i++) {
            let cat = allocationModel.get(i).category;
            if (cat !== "" && seen.has(cat))
                return true;
            seen.add(cat);
        }
        return false;
    }
    readonly property bool isValid: Math.abs(remainingAmount) < 0.01 && allocationModel.count > 0 && allCategoriesSelected && !hasDuplicateCategories

    // Disable OK button when invalid
    onOpened: {
        // Refresh category list when dialog opens
        root.categoryList = [""].concat(budgetData.categoryNames());

        let okButton = footer.standardButton(Dialog.Ok);
        if (okButton) {
            okButton.enabled = Qt.binding(function () {
                return root.isValid;
            });
        }
    }

    ListModel {
        id: allocationModel
    }

    function initialize(opIndex, amount, allocations, currentCategory) {
        operationIndex = opIndex;
        totalAmount = amount;
        allocationModel.clear();

        if (allocations && allocations.length > 0) {
            // Existing split - load allocations
            for (let i = 0; i < allocations.length; i++) {
                allocationModel.append({
                    category: allocations[i].category,
                    amount: allocations[i].amount
                });
            }
        } else {
            // New split - start with current category and full amount
            allocationModel.append({
                category: currentCategory ?? "",
                amount: totalAmount
            });
        }
    }

    function addAllocation() {
        allocationModel.append({
            category: "",
            amount: remainingAmount
        });
    }

    function removeAllocation(index) {
        if (allocationModel.count > 1) {
            allocationModel.remove(index);
        }
    }

    onAccepted: {
        // Build allocations array and call splitOperation
        let allocations = [];
        for (let i = 0; i < allocationModel.count; i++) {
            let item = allocationModel.get(i);
            if (item.category !== "" && Math.abs(item.amount) > 0.001) {
                allocations.push({
                    category: item.category,
                    amount: item.amount
                });
            }
        }
        if (allocations.length > 0) {
            budgetData.splitOperation(operationIndex, allocations);
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacingLarge

        // Header showing total amount
        RowLayout {
            Layout.fillWidth: true

            Label {
                text: qsTr("Total Amount:")
                font.bold: true
                color: Theme.textSecondary
            }

            Label {
                text: Theme.formatAmount(root.totalAmount)
                font.bold: true
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.amountColor(root.totalAmount)
            }

            Item {
                Layout.fillWidth: true
            }

            Label {
                text: qsTr("Remaining:")
                font.bold: true
                color: Theme.textSecondary
            }

            Label {
                text: Theme.formatAmount(root.remainingAmount)
                font.bold: true
                font.pixelSize: Theme.fontSizeLarge
                color: Math.abs(root.remainingAmount) < 0.01 ? Theme.positive : Theme.warning
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.border
        }

        // Allocations list
        ListView {
            id: allocationListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 150
            model: allocationModel
            spacing: Theme.spacingSmall
            clip: true

            delegate: RowLayout {
                width: allocationListView.width
                spacing: Theme.spacingNormal

                required property int index
                required property string category
                required property double amount

                ComboBox {
                    id: categoryCombo
                    Layout.fillWidth: true
                    model: root.categoryList
                    currentIndex: {
                        if (category === "")
                            return 0;
                        let idx = root.categoryList.indexOf(category);
                        return idx >= 0 ? idx : 0;
                    }
                    displayText: currentIndex === 0 ? qsTr("Select category...") : currentText
                    onActivated: idx => {
                        allocationModel.setProperty(index, "category", idx === 0 ? "" : root.categoryList[idx]);
                    }
                }

                AmountField {
                    id: amountField
                    Layout.preferredWidth: 120
                    value: amount
                    onEdited: newValue => {
                        allocationModel.setProperty(index, "amount", newValue);
                    }
                }

                ToolButton {
                    text: "-"
                    font.bold: true
                    font.pixelSize: Theme.fontSizeLarge
                    enabled: allocationModel.count > 1
                    opacity: enabled ? 1.0 : 0.3
                    focusPolicy: Qt.NoFocus
                    onClicked: root.removeAllocation(index)
                }
            }
        }

        // Add allocation button
        Button {
            Layout.alignment: Qt.AlignLeft
            text: qsTr("+ Add Category")
            onClicked: root.addAllocation()
        }

        // Validation message (always takes space to prevent dialog resize)
        Label {
            Layout.fillWidth: true
            opacity: !root.isValid && allocationModel.count > 0 ? 1.0 : 0.0
            text: {
                if (Math.abs(root.remainingAmount) >= 0.01)
                    return qsTr("Allocations must equal the total amount");
                if (!root.allCategoriesSelected)
                    return qsTr("All allocations must have a category");
                if (root.hasDuplicateCategories)
                    return qsTr("Each category can only be used once");
                return qsTr("At least one allocation is required");
            }
            color: Theme.warning
            font.pixelSize: Theme.fontSizeSmall
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
