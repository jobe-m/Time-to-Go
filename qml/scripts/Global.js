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
var activeProject = "Conti"


function setWorkingStart() {
    if (!working && !paused) {
        workingStart = new Date()
        working = true
        paused = false
    }
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

function getActiveProject() {
    return activeProject
}

function getWorkingTime() {
    var msec = 0.0
    if (working) {
        var now = new Date()
        msec = now.getTime() - workingStart.getTime()
    } else if (paused) {
        msec = breakStart.getTime() - workingStart.getTime()
    }
    var sec = (msec/10).toFixedDown(0)
    var min = (sec/60).toFixedDown(0)
    var hour = (min/60).toFixedDown(0)
    return (hour < 10 ? "0" : "") + (hour).toString() + ":" +
            (min%60 < 10 ? "0" : "") + (min%60).toString() + ":" +
            (sec%60 < 10 ? "0" : "") + (sec%60).toString()
}

function getBreakTime() {
    var msec = 0.0
    if (paused) {
        var now = new Date()
        msec = now.getTime() - breakStart.getTime()
    } else if (breakEnd !== 0 && breakStart !== 0){
        msec = breakEnd.getTime() - breakStart.getTime()
    }
    var sec = (msec/10).toFixedDown(0)
    var min = (sec/60).toFixedDown(0)
    var hour = (min/60).toFixedDown(0)
    return (hour < 10 ? "0" : "") + (hour).toString() + ":" +
            (min%60 < 10 ? "0" : "") + (min%60).toString() + ":" +
            (sec%60 < 10 ? "0" : "") + (sec%60).toString()
}

// Function to truncate a float number instead of round up/down
Number.prototype.toFixedDown = function(digits) {
    var re = new RegExp("(\\d+\\.\\d{" + digits + "})(\\d)")
    var m = this.toString().match(re)
    return m ? parseFloat(m[1]) : this.valueOf()
}
