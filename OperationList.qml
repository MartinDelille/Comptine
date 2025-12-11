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
        model: AppState.data.operationModel
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        focus: true
        keyNavigationEnabled: false  // We handle key navigation ourselves
        highlightFollowsCurrentItem: false  // Don't auto-scroll highlight
        currentIndex: AppState.navigation.currentOperationIndex

        // Restore focus when YAML file is loaded (not after CSV import, which handles its own selection)
        Connections {
            target: AppState.file
            function onYamlFileLoaded() {
                if (listView.count > 0) {
                    // Use the index from the file (already set in AppState.navigation.currentOperationIndex)
                    let idx = Math.min(AppState.navigation.currentOperationIndex, listView.count - 1);
                    if (idx < 0)
                        idx = 0;
                    AppState.navigation.currentOperationIndex = idx;
                    AppState.data.operationModel.select(idx, false);
                    listView.positionViewAtIndex(idx, ListView.Center);
                }
                listView.forceActiveFocus();
            }
            function onDataLoaded() {
                // For CSV import: sync ListView currentIndex with model selection
                // The model already has the correct selection, just update the view
                if (listView.count > 0 && AppState.navigation.currentOperationIndex < 0) {
                    AppState.navigation.currentOperationIndex = 0;
                }
                listView.positionViewAtIndex(AppState.navigation.currentOperationIndex >= 0 ? AppState.navigation.currentOperationIndex : 0, ListView.Contain);
                listView.forceActiveFocus();
            }
        }

        Connections {
            target: AppState.navigation
            function onOperationSelected(index) {
                // Navigate from CategoryDetailView: focus and scroll to the operation
                AppState.navigation.currentOperationIndex = index;
                listView.positionViewAtIndex(index, ListView.Center);
                listView.forceActiveFocus();
            }
        }

        Keys.onUpPressed: event => {
            AppState.navigation.previousOperation(event.modifiers & Qt.ShiftModifier);
            positionViewAtIndex(AppState.navigation.currentOperationIndex, ListView.Contain);
        }

        Keys.onDownPressed: event => {
            AppState.navigation.nextOperation(event.modifiers & Qt.ShiftModifier);
            positionViewAtIndex(AppState.navigation.currentOperationIndex, ListView.Contain);
        }

        // Cmd+A to select all
        Keys.onPressed: event => {
            if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_A) {
                AppState.data.operationModel.selectRange(0, count - 1);
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
                    AppState.navigation.currentOperationIndex = parent.index;
                    listView.forceActiveFocus();

                    if (mouse.modifiers & Qt.ControlModifier) {
                        // Cmd/Ctrl+click: toggle selection
                        AppState.data.operationModel.toggleSelection(parent.index);
                    } else if (mouse.modifiers & Qt.ShiftModifier) {
                        // Shift+click: range selection from current
                        AppState.data.operationModel.selectRange(AppState.navigation.currentOperationIndex, parent.index);
                    } else {
                        // Plain click: single selection (clear others)
                        AppState.data.operationModel.select(parent.index, false);
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
