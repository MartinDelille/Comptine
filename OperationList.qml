import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

FocusScope {
    id: focusScope
    activeFocusOnTab: true  // Allow Tab to focus this component

    // Convenience property to access current account
    readonly property var currentAccount: AppState.navigation.currentAccount

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
        currentIndex: currentAccount ? currentAccount.currentOperationIndex : -1

        // Restore focus when YAML file is loaded (not after CSV import, which handles its own selection)
        Connections {
            target: AppState.file
            function onYamlFileLoaded() {
                if (listView.count > 0 && currentAccount) {
                    // Use the index from the file (already set in account.currentOperationIndex)
                    let idx = Math.min(currentAccount.currentOperationIndex, listView.count - 1);
                    if (idx < 0)
                        idx = 0;
                    currentAccount.currentOperationIndex = idx;
                    AppState.data.operationModel.select(idx, false);
                    listView.positionViewAtIndex(idx, ListView.Center);
                }
                listView.forceActiveFocus();
            }
            function onDataLoaded() {
                // For CSV import: sync ListView currentIndex with model selection
                // The model already has the correct selection, just update the view
                if (listView.count > 0 && currentAccount && currentAccount.currentOperationIndex < 0) {
                    currentAccount.currentOperationIndex = 0;
                }
                let idx = currentAccount ? currentAccount.currentOperationIndex : 0;
                listView.positionViewAtIndex(idx >= 0 ? idx : 0, ListView.Contain);
                listView.forceActiveFocus();
            }
        }

        Connections {
            target: AppState.navigation
            function onOperationSelected(index) {
                // Navigate from CategoryDetailView: focus and scroll to the operation
                if (currentAccount) {
                    currentAccount.currentOperationIndex = index;
                }
                listView.positionViewAtIndex(index, ListView.Center);
                listView.forceActiveFocus();
            }
            function onCurrentAccountChanged() {
                // When account changes, update the model selection and scroll
                if (!currentAccount)
                    return;
                let idx = currentAccount.currentOperationIndex;
                if (idx < 0 && listView.count > 0) {
                    // Account has no current operation yet, default to first operation
                    idx = 0;
                    currentAccount.currentOperationIndex = idx;
                }
                if (idx >= 0 && idx < listView.count) {
                    AppState.data.operationModel.select(idx, false);
                    listView.positionViewAtIndex(idx, ListView.Contain);
                }
            }
        }

        Connections {
            target: AppState.data.operationModel
            function onCurrentOperationChanged(index) {
                // Programmatic selection (e.g., after date edit): update current index and scroll
                if (currentAccount) {
                    currentAccount.currentOperationIndex = index;
                }
                listView.positionViewAtIndex(index, ListView.Center);
            }
        }

        Keys.onUpPressed: event => {
            AppState.navigation.previousOperation(event.modifiers & Qt.ShiftModifier);
            if (currentAccount) {
                positionViewAtIndex(currentAccount.currentOperationIndex, ListView.Contain);
            }
        }

        Keys.onDownPressed: event => {
            AppState.navigation.nextOperation(event.modifiers & Qt.ShiftModifier);
            if (currentAccount) {
                positionViewAtIndex(currentAccount.currentOperationIndex, ListView.Contain);
            }
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
                    listView.forceActiveFocus();

                    if (mouse.modifiers & Qt.ControlModifier) {
                        // Cmd/Ctrl+click: toggle selection
                        AppState.data.operationModel.toggleSelection(parent.index);
                    } else if (mouse.modifiers & Qt.ShiftModifier) {
                        // Shift+click: range selection from last clicked
                        AppState.data.operationModel.select(parent.index, true);
                    } else {
                        // Plain click: single selection (clear others)
                        AppState.data.operationModel.select(parent.index, false);
                    }

                    // Update current index after selection handling
                    if (currentAccount) {
                        currentAccount.currentOperationIndex = parent.index;
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
