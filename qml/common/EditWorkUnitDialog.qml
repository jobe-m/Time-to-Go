import QtQuick 2.0
import Sailfish.Silica 1.0
import harbour.Time2Go.DatabaseQuery 1.0

Dialog {
    id: editWorkUnitDialog

    property Time2GoWorkUnit workUnit: null
    property int projectUid: 0
    property date start
    property date end
    property int breakTime: 0
    property string notes: ""

    SilicaFlickable {
        anchors.fill: parent
        contentWidth: parent.width
        contentHeight: column.height

        VerticalScrollDecorator {}

        Column {
            id: column

            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader {
                acceptText: qsTr("Save")
                cancelText: qsTr("Discard")
                title: qsTr("Edit Work Unit")
            }

            SectionHeader {
                text: qsTr("Begin and end of work unit")
            }

            DateTimeLine {
                id: workDateTimeLine

                onStartChanged: {
                    start = workUnit.start = dateTime
                }
                onEndChanged: {
                    end = workUnit.end = dateTime
                }
            }

            SectionHeader {
                text: qsTr("Notes")
            }
        }
    }

    Connections {
        target: workUnit
        onTimeChanged: {
            console.log("start end validity: " + workUnit.start, workUnit.end, workUnit.validStartDateTime, workUnit.validEndDateTime)

            if (workUnit.validStartDateTime) {
                workDateTimeLine.setStartDateTime(workUnit.start)
            }
            if (workUnit.validEndDateTime) {
                workDateTimeLine.setEndDateTime(workUnit.end)
            }
        }
    }

    onDone: {
        if (result === DialogResult.Accepted) {
        }
    }

    Component.onCompleted: {}
}
