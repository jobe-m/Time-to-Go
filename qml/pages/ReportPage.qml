
import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.Time2Go.DatabaseQuery 1.0
import "../common"

Page {
    id: reportPage

    property Time2GoReportListModel reportModel: null

    SilicaListView {
        id: listView
        currentIndex: -1
        model: applicationWindow.reportModel
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("Refresh report")
                onClicked: {
                    reportModel.loadReport()
                }
            }
        }

        header: Column {
            width: Screen.width
            height: children.height
            spacing: Theme.paddingSmall
            PageHeader {
                title: qsTr("Time sheet")
            }
            Item {
                width: parent.width
                height: headerLabel.height
                Label {
                    id: headerLabel
                    x: Theme.paddingLarge
                    text: qsTr("Start")
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.highlightColor
                }
                Label {
                    x: Theme.paddingLarge * 5
                    text: qsTr("End")
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.highlightColor
                }
                Label {
                    x: Theme.paddingLarge * 13
                    text: qsTr("Break")
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.highlightColor
                }
                Label {
                    x: Theme.paddingLarge * 17
                    text: qsTr("Work time")
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.highlightColor
                }
            }
        }
        section.property: "day"
        section.criteria: ViewSection.FullString
        section.delegate: Item {
            width: Screen.width
            height: sectionLabel.height
            Label {
                id: sectionLabel
                x: Theme.paddingLarge
                text: section
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.primaryColor
                opacity: 0.6
            }
            Rectangle {
                x: 0
                anchors.fill: parent
                color: "white"
                opacity: 0.1
            }
        }
        delegate: ReportListItem {}
        VerticalScrollDecorator {}
    }


    Time2GoWorkUnit {
        id: workUnitToDelete
    }


    Time2GoWorkUnit {
        id: workUnitToEdit

        onTimeChanged: {
//            console.log("from report page")
//            console.log("start end validity: " + start, end, validStartDateTime, validEndDateTime)
//            if (validStartDateTime) {
//                workDateTimeLine.setStartDateTime(start)
//            }
//            if (validEndDateTime) {
//                workDateTimeLine.setEndDateTime(end)
//            }
//            console.log("Update report model from workUnitForEdit onTimeChanged")
//            applicationWindow.reportModel.loadReport()
//            time2GoTimeCounterDay.reload()
//            time2GoTimeCounterWeek.reload()
//            time2GoTimeCounterMonth.reload()
//            applicationWindow.cover.workTimeReload()
        }
        onUnfinishedWorkUnit: {
        }
    }

    // The delegate for each section header

    Component.onCompleted: {
//        console.log("Reload report model from ReportPage onCompleted")
//        applicationWindow.reportModel.loadReport()
    }
}
