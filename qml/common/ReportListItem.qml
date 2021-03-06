
import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: reportListItem

    property string workStart: model.workstart
    property string workEnd: model.workend
    property string breakTimeHours: model.breaktimehours
    property string breakTimeMinutes: model.breaktimeminutes
    property string workTimeHours: model.worktimehours
    property string workTimeMinutes: model.worktimeminutes

    menu: contextMenuComponent
    contentHeight: Theme.itemSizeSmall
    width: parent ? parent.width : screen.width

    function listItemRemove() {
        workUnitToDelete.uid = model.uid
        remorseAction("Deleting work unit", function(){
            workUnitToDelete.deleteWorkUnit()
            // Update UI components
            applicationWindow.reportModel.deleteItem(model.uid)
            applicationWindow.mainPage.reloadWorkTime()
        })
    }

    function editItem() {
        workUnitToEdit.uid = model.uid
        var dialog = pageStack.push("EditWorkUnitDialog.qml", {
                                        "workUnit": workUnitToEdit,
                                        "projectUid": workUnitToEdit.projectUid
                                    })
                    dialog.accepted.connect(function() {
                        // Save changed work unit
                        workUnitToEdit.save()
                        // Update UI components
                        applicationWindow.mainPage.reloadWorkTime()
                        applicationWindow.reportModel.loadReport()
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

    HourMinutesSeconds {
        x: Theme.paddingLarge * 11
        anchors.verticalCenter: parent.verticalCenter
        showSeconds: false
        margin: Theme.paddingSmall
        textSize: Theme.fontSizeMedium
        symbolSize: Theme.fontSizeExtraSmall
        textColor: reportListItem.highlighted ? Theme.highlightColor : Theme.primaryColor
        hours: breakTimeHours
        minutes: breakTimeMinutes
    }

    HourMinutesSeconds {
        x: Theme.paddingLarge * 17
        anchors.verticalCenter: parent.verticalCenter
        showSeconds: false
        margin: Theme.paddingSmall
        textSize: Theme.fontSizeMedium
        symbolSize: Theme.fontSizeExtraSmall
        textColor: reportListItem.highlighted ? Theme.highlightColor : Theme.primaryColor
        hours: workTimeHours
        minutes: workTimeMinutes
    }

    onClicked: {
        editItem()
    }

    Component {
        id: contextMenuComponent
        ContextMenu {
            id: contextMenu

            MenuItem {
                text: qsTr("Edit")
                onClicked: {
                    editItem()
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
