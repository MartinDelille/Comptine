import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ListView {
    id: root

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
    }

    Keys.onUpPressed: {
        if (currentIndex > 0) {
            currentIndex--;
            budgetData.selectedOperationIndex = currentIndex;
            positionViewAtIndex(currentIndex, ListView.Contain);
        }
    }

    Keys.onDownPressed: {
        if (currentIndex < count - 1) {
            currentIndex++;
            budgetData.selectedOperationIndex = currentIndex;
            positionViewAtIndex(currentIndex, ListView.Contain);
        }
    }

    delegate: OperationDelegate {
        required property int index
        width: root.width - scrollBar.width
        operation: budgetData.getOperation(index)
        balance: budgetData.balanceAtIndex(index)
        selected: root.currentIndex === index
        alternate: index % 2 === 0
        highlighted: index === budgetData.lastImportedOperationIndex

        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.currentIndex = parent.index;
                budgetData.selectedOperationIndex = parent.index;
                root.forceActiveFocus();
            }
        }
    }

    ScrollBar.vertical: ScrollBar {
        id: scrollBar
    }
}
