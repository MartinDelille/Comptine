import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

FocusScope {
    id: focusScope
    activeFocusOnTab: true  // Allow Tab to focus this component

    onActiveFocusChanged: {
        if (activeFocus) {
            listView.forceActiveFocus();
        }
    }

    ListView {
        id: listView
        anchors.fill: parent

        // Track selection changes to force delegate updates
        property int selectionVersion: 0

        clip: true
        boundsBehavior: Flickable.StopAtBounds
        focus: true
        keyNavigationEnabled: false  // We handle key navigation ourselves
        highlightFollowsCurrentItem: false  // Don't auto-scroll highlight

        // Restore position when data is loaded or operations change
        Connections {
            target: budgetData
            function onDataLoaded() {
                listView.currentIndex = budgetData.selectedOperationIndex;
                if (listView.currentIndex >= 0 && listView.currentIndex < listView.count) {
                    listView.positionViewAtIndex(listView.currentIndex, ListView.Center);
                }
                listView.forceActiveFocus();  // Ensure ListView has focus after loading
            }
            function onOperationCountChanged() {
                listView.currentIndex = budgetData.selectedOperationIndex;
                if (listView.currentIndex >= 0 && listView.currentIndex < listView.count) {
                    listView.positionViewAtIndex(listView.currentIndex, ListView.Center);
                }
            }
            function onSelectedOperationIndexChanged() {
                if (listView.currentIndex !== budgetData.selectedOperationIndex) {
                    listView.currentIndex = budgetData.selectedOperationIndex;
                    if (listView.currentIndex >= 0 && listView.currentIndex < listView.count) {
                        listView.positionViewAtIndex(listView.currentIndex, ListView.Center);
                    }
                }
            }
            function onSelectedOperationsChanged() {
                // Increment version to trigger delegate rebinding
                listView.selectionVersion++;
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
            width: listView.width - scrollBar.width
            operation: budgetData.getOperation(index)
            balance: budgetData.balanceAtIndex(index)
            selected: listView.selectionVersion >= 0 && budgetData.isOperationSelected(index)
            focused: listView.activeFocus && listView.currentIndex === index
            alternate: index % 2 === 0

            MouseArea {
                anchors.fill: parent
                onClicked: mouse => {
                    listView.currentIndex = parent.index;
                    listView.forceActiveFocus();

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

    // Expose properties for parent access
    property alias count: listView.count
    property alias currentIndex: listView.currentIndex
    property alias model: listView.model
}
