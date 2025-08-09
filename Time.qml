pragma Singleton

import Quickshell
import QtQuick

Singleton {

    property var monthNames: [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
    ]

    property var date: new Date()

    property int month: date.getMonth()
    property string monthName: monthNames[month]
    property int day: date.getDate()
    property int year: date.getFullYear()
    property int hour: date.getHours()
    property int minute: date.getMinutes()
    property int second: date.getSeconds()
    
    // in the format of HH:MM:SS - Month DD, YYYY
    property string time: hour.toString().padStart(2, "0") + 
        ":" + minute.toString().padStart(2, "0") + 
        ":" + second.toString().padStart(2, "0") + 
        " " + monthName + 
        " " + day.toString().padStart(2, "0") + 
        ", " + year

    Timer {
        interval: 250
        running: true
        repeat: true
        onTriggered: date = new Date()
    }
}