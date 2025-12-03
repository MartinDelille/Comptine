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
        model: budgetData.operationModel

        clip: true
        boundsBehavior: Flickable.StopAtBounds
        focus: true
        keyNavigationEnabled: false  // We handle key navigation ourselves
        highlightFollowsCurrentItem: false  // Don't auto-scroll highlight

        // Restore focus when data is loaded
        Connections {
            target: budgetData
            function onDataLoaded() {
                if (listView.count > 0) {
                    listView.currentIndex = 0;
                    budgetData.operationModel.select(0, false);
                    listView.positionViewAtIndex(0, ListView.Beginning);
                }
                listView.forceActiveFocus();
            }
        }

        Keys.onUpPressed: event => {
            if (currentIndex > 0) {
                currentIndex--;
                if (event.modifiers & Qt.ShiftModifier) {
                    // Shift+Up: extend selection
                    budgetData.operationModel.select(currentIndex, true);
                } else {
                    // Plain Up: single selection
                    budgetData.operationModel.select(currentIndex, false);
                }
                positionViewAtIndex(currentIndex, ListView.Contain);
            }
        }

        Keys.onDownPressed: event => {
            if (currentIndex < count - 1) {
                currentIndex++;
                if (event.modifiers & Qt.ShiftModifier) {
                    // Shift+Down: extend selection
                    budgetData.operationModel.select(currentIndex, true);
                } else {
                    // Plain Down: single selection
                    budgetData.operationModel.select(currentIndex, false);
                }
                positionViewAtIndex(currentIndex, ListView.Contain);
            }
        }

        // Cmd+A to select all
        Keys.onPressed: event => {
            if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_A) {
                budgetData.operationModel.selectRange(0, count - 1);
                event.accepted = true;
            }
        }

        delegate: OperationDelegate {
            required property int index
            required property var model
            width: listView.width - scrollBar.width
            operation: model.operation
            balance: model.balance
            selected: model.selected
            focused: listView.activeFocus && listView.currentIndex === index
            alternate: index % 2 === 0

            MouseArea {
                anchors.fill: parent
                onClicked: mouse => {
                    listView.currentIndex = parent.index;
                    listView.forceActiveFocus();

                    if (mouse.modifiers & Qt.ControlModifier) {
                        // Cmd/Ctrl+click: toggle selection
                        budgetData.operationModel.toggleSelection(parent.index);
                    } else if (mouse.modifiers & Qt.ShiftModifier) {
                        // Shift+click: range selection from current
                        budgetData.operationModel.selectRange(listView.currentIndex, parent.index);
                    } else {
                        // Plain click: single selection (clear others)
                        budgetData.operationModel.select(parent.index, false);
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
}
