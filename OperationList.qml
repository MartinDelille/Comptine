import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ListView {
    id: root

    // Track selection changes to force delegate updates
    property int selectionVersion: 0

    clip: true
    boundsBehavior: Flickable.StopAtBounds
    focus: true

    // Restore position when data is loaded or operations change
    Connections {
        target: budgetData
        function onDataLoaded() {
            root.currentIndex = budgetData.selectedOperationIndex;
            if (root.currentIndex >= 0 && root.currentIndex < root.count) {
                root.positionViewAtIndex(root.currentIndex, ListView.Center);
            }
        }
        function onOperationCountChanged() {
            root.currentIndex = budgetData.selectedOperationIndex;
            if (root.currentIndex >= 0 && root.currentIndex < root.count) {
                root.positionViewAtIndex(root.currentIndex, ListView.Center);
            }
        }
        function onSelectedOperationIndexChanged() {
            if (root.currentIndex !== budgetData.selectedOperationIndex) {
                root.currentIndex = budgetData.selectedOperationIndex;
                if (root.currentIndex >= 0 && root.currentIndex < root.count) {
                    root.positionViewAtIndex(root.currentIndex, ListView.Center);
                }
            }
        }
        function onSelectedOperationsChanged() {
            // Increment version to trigger delegate rebinding
            root.selectionVersion++;
        }
    }

    Keys.onUpPressed: event => {
        if (currentIndex > 0) {
            currentIndex--;
            if (event.modifiers & Qt.ShiftModifier) {
                // Shift+Up: extend selection
                budgetData.selectOperation(currentIndex, true);
            } else {
                // Plain Up: single selection
                budgetData.selectOperation(currentIndex, false);
            }
            positionViewAtIndex(currentIndex, ListView.Contain);
        }
    }

    Keys.onDownPressed: event => {
        if (currentIndex < count - 1) {
            currentIndex++;
            if (event.modifiers & Qt.ShiftModifier) {
                // Shift+Down: extend selection
                budgetData.selectOperation(currentIndex, true);
            } else {
                // Plain Down: single selection
                budgetData.selectOperation(currentIndex, false);
            }
            positionViewAtIndex(currentIndex, ListView.Contain);
        }
    }

    // Cmd+A to select all
    Keys.onPressed: event => {
        if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_A) {
            budgetData.selectRange(0, count - 1);
            event.accepted = true;
        }
    }

    delegate: OperationDelegate {
        required property int index
        width: root.width - scrollBar.width
        operation: budgetData.getOperation(index)
        balance: budgetData.balanceAtIndex(index)
        selected: root.selectionVersion >= 0 && budgetData.isOperationSelected(index)
        focused: root.currentIndex === index
        alternate: index % 2 === 0

        MouseArea {
            anchors.fill: parent
            onClicked: mouse => {
                root.currentIndex = parent.index;
                root.forceActiveFocus();

                if (mouse.modifiers & Qt.ControlModifier) {
                    // Cmd/Ctrl+click: toggle selection
                    budgetData.toggleOperationSelection(parent.index);
                } else if (mouse.modifiers & Qt.ShiftModifier) {
                    // Shift+click: range selection from last clicked
                    budgetData.selectRange(budgetData.selectedOperationIndex, parent.index);
                } else {
                    // Plain click: single selection (clear others)
                    budgetData.selectOperation(parent.index, false);
                }
            }
        }
    }

    ScrollBar.vertical: ScrollBar {
        id: scrollBar
    }
}
