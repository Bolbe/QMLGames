import QtQuick 2.5

Item {
    id: ghostHouse
    width: 240
    height: 150

    property int i: 0
    property int j: 0
    readonly property string wallColor: "blue"
    readonly property int wallRadius: 10

    x: i*30
    y: j*30

    Rectangle {
        color: "black"
        x: 13
        y: 13
        width: parent.width - 26
        height: parent.height - 26
        border.width: 3
        border.color: wallColor
    }

    Rectangle {
        color: "black"
        x: 20
        y: 20
        width: parent.width - 40
        height: parent.height - 40
        border.width: 3
        border.color: wallColor
    }

    // Gate
    Rectangle {
        color: "pink"
        height: 12
        width: 100
        radius: 6
        y: 12
        x: 70
    }



}
