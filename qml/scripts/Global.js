.pragma library

// Constants used by infoBanner type
var none = 0
var info = 1
var warning = 2
var error = 3

// Variables for handling working and paused state
var working = false
var workingStart = 0
var workingEnd = 0
var paused = false
var breakStart = 0
var breakEnd = 0
var activeProject = "My amusing project"

var ms = 1000
var automaticBreakTime = 0

function setWorkingStart() {
    if (!working && !paused) {
        workingStart = new Date()
        working = true
        paused = false
    }
}

function updateWorkingStartDate(year, month, day) {
    workingStart.setFullYear(year, month, day)
}

function updateWorkingStartTime(hour, min) {
    workingStart.setHours(hour, min)
}

function updateWorkingEndDate(year, month, day) {
    workingEnd.setFullYear(year,month,day)
}

function updateWorkingEndTime(hour, min) {
    workingEnd.setHours(hour, min)
}

function setWorkingEnd() {
    if (working && !paused) {
        workingEnd = new Date()
        working = false
        paused = false
    }
}

function setBreakStart() {
    if (!paused && working) {
        breakStart = new Date()
        working = false
        paused = true
    }
}

function setBreakEnd() {
    if (paused && !working) {
        breakEnd = new Date()
        paused = false
        working = true
    }
}

function activateNextProject() {

}

function getActiveProject() {
    return activeProject
}

function getAutoBreakTime() {
    return automaticBreakTime
}

function getWorkBeginTime() {
    return workingStart.getTime()
}

function getWorkEndTime() {
    return workingEnd.getTime()
}

function getBreakBeginTime() {
    return breakStart.getTime()
}

function getBreakEndTime() {
    return breakEnd.getTime()
}

function getWorkingTime() {
    var msec = 0.0
    if (working) {
        var now = new Date()
        msec = now.getTime() - workingStart.getTime()
    } else if (paused) {
        msec = breakStart.getTime() - workingStart.getTime()
    }
    var sec = (msec/ms).toFixedDown(0)

    // check working time if automatic break needs to be applied
    if (breakStart === 0) {
        if (sec < 60*60*6) { // less than 6 hours work
            // no break
            automaticBreakTime = 0
        } else if (sec > 60*60*6 && sec < 60*60*(6+0.5)) {
            automaticBreakTime = sec - 60*60*6
            sec = 60*60*6
        } else if (sec > 60*60*(6+0.5) && sec < 60*60*(9+0.5)) {
            automaticBreakTime = 60*60*0.5
            sec = sec - 60*60*0.5
        } else if (sec > 60*60*(9+0.5) && sec < 60*60*(9+0.5+0.25)) {
            automaticBreakTime = sec - 60*60*9
            sec = 60*60*9
        } else if (sec > 60*60*(9+0.5+0.25)) {
            automaticBreakTime = 60*60*0.75
            sec = sec - 60*60*0.75
        }
//        console.log("worktime: " + sec/60/60 + "  autobreaktime: " + automaticBreakTime/60/60)
    }
    return sec
}

function getBreakTime() {
    var msec, now, work_sec, sec
    if (breakStart === 0) {
        sec = automaticBreakTime
    } else if (paused) {
        now = new Date()
        msec = now.getTime() - breakStart.getTime()
        sec = (msec/ms).toFixedDown(0)
    } else if (breakEnd !== 0 && breakStart !== 0){
        msec = breakEnd.getTime() - breakStart.getTime()
        sec = (msec/ms).toFixedDown(0)
    }
    return sec
}

// Function to truncate a float number instead of round up/down
Number.prototype.toFixedDown = function(digits) {
    var re = new RegExp("(\\d+\\.\\d{" + digits + "})(\\d)")
    var m = this.toString().match(re)
    return m ? parseFloat(m[1]) : this.valueOf()
}
