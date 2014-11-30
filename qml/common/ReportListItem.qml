
import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: reportListItem

    property string workStart: model.workstart
    property string workEnd: model.workend
    property string breakTime: model.breaktime
    property string workTime: model.worktime

    menu: contextMenuComponent
    contentHeight: Theme.itemSizeSmall
    width: parent ? parent.width : screen.width

    function listItemRemove() {
        workUnitForDeletion.uid = model.uid
        remorseAction("Deleting work unit", function(){
            workUnitForDeletion.deleteWorkUnit()
            reportPage.reportModel.deleteItem(model.uid)
        })
    }

    ListView.onAdd: AddAnimation {
        target: reportListItem
    }
    ListView.onRemove: RemoveAnimation {
        target: reportListItem
    }


    Label {
        x: Theme.paddingLarge
        anchors.verticalCenter: parent.verticalCenter
        text: workStart
        font.pixelSize: Theme.fontSizeMedium
        color: reportListItem.highlighted ? Theme.highlightColor : Theme.primaryColor
    }

    Label {
        x: Theme.paddingLarge * 5
        anchors.verticalCenter: parent.verticalCenter
        text: workEnd
        font.pixelSize: Theme.fontSizeMedium
        color: reportListItem.highlighted ? Theme.highlightColor : Theme.primaryColor
    }

    Label {
        x: Theme.paddingLarge * 13
        anchors.verticalCenter: parent.verticalCenter
        text: breakTime
        font.pixelSize: Theme.fontSizeMedium
        color: reportListItem.highlighted ? Theme.highlightColor : Theme.primaryColor
    }

    Label {
        x: Theme.paddingLarge * 17
        anchors.verticalCenter: parent.verticalCenter
        text: workTime
        font.pixelSize: Theme.fontSizeMedium
        color: reportListItem.highlighted ? Theme.highlightColor : Theme.primaryColor
    }

    onClicked: {
//        pageStack.push(Qt.resolvedUrl("EditWorkUnitDialog.qml").toString(),
//                       { "uid": model.uid })
    }

    Component {
        id: contextMenuComponent
        ContextMenu {
            id: contextMenu

            MenuItem {
                text: qsTr("Edit")
                onClicked: {
                }
            }
            MenuItem {
                text: qsTr("Delete")
                onClicked: {
                    listItemRemove()
                }
            }
        }
    } // end contextMenuComponent
}
