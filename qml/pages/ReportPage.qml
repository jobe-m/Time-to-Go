
import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.Time2Go.DatabaseQuery 1.0


Page {
    id: reportPage

    SilicaListView {
        id: listView
        currentIndex: -1
        model: applicationWindow.reportModel
        anchors.fill: parent
        header: PageHeader {
            title: qsTr("Time2Go reports")
        }

        delegate: BackgroundItem {
            id: delegate

            Label {
                x: Theme.paddingLarge
                text: "start: " + model.workstart.getHours() + ":" + model.workstart.getMinutes() +
                      " end: " + model.workend.getHours() + ":" + model.workend.getMinutes() +
                      " work time: " + model.worktime
                anchors.verticalCenter: parent.verticalCenter
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            }
            onClicked: {}
        }

        VerticalScrollDecorator {}
    }

    Component.onCompleted:  {
        console.log("Load report")
        applicationWindow.reportModel.loadReport()
    }
}
