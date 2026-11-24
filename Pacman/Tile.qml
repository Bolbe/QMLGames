import QtQuick 2.5

Item {
    id: tile
    width: 30
    height: 30
    clip: (type >= 'a' && type <= 'd') ||
          (type >= 'A' && type <= 'N')

    property string type: ' '
    property int i: 0
    property int j: 0
    readonly property string wallColor: "blue"
    readonly property int wallRadius: 10

    x: i*30
    y: j*30

    // Dots
    Rectangle {
        visible: type === '.'
        color: "#eee"
        height: 8
        width: 8
        radius: 4
        anchors.centerIn: parent
    }

    // Energizer
    Rectangle {
        visible: type === 'P'
        color: "#eee"
        height: 24
        width: 24
        radius: 12
        anchors.centerIn: parent
    }

    // Corners double
    Rectangle {
        visible: type >= 'A' && type <= 'D'
        color: "black"
        x: type === 'A' || type === 'D' ? 3 : -13
        y: type === 'A' || type === 'B' ? 3 : -13
        height: 40
        width: 40
        border.width: 4
        border.color: wallColor
        radius: wallRadius
    }

    // Corners
    Rectangle {
        visible: type === 'a' || type === 'b' || type === 'c' || type === 'd' ||
                 type === 'A' || type === 'B' || type === 'C' || type === 'D' ||
                 type === 'I' || type === 'J' || type === 'K' || type === 'L'
        color: "black"
        x: type === 'a' || type === 'd' || type === 'A' ||
           type === 'D' || type === 'I' || type === 'L'? 13 : -13
        y: type === 'a' || type === 'b' || type === 'A' ||
           type === 'B' || type === 'I' || type === 'J' ? 13 : -13
        height: 30
        width: 30
        border.width: 4
        border.color: wallColor
        radius: wallRadius
    }

    Rectangle {
        visible: type === 'M' || type === 'N'
        color: "black"
        x: type === 'M' ? 13 : -13
        y: type === 'M' || type === 'N' ? 13 : -13
        height: 30
        width: 30
        border.width: 4
        border.color: wallColor
        radius: wallRadius
    }

    Rectangle {
        visible: type === 'M' || type === 'N'
        color: wallColor
        y: 3
        height: 4
        width: 30
    }


    // Corners double
    Rectangle {
        visible: type >= 'I' && type <= 'L'
        color: "black"
        x: type === 'I' || type === 'L' ? 23 : -33
        y: type === 'I' || type === 'J' ? 23 : -33
        height: 40
        width: 40
        border.width: 4
        border.color: wallColor
        radius: wallRadius
    }


    // Horizontal
    Rectangle {
        visible: type === 'E' || type === 'e' || type === 'H'
        color: wallColor
        height: 4
        width: 30
        y: 13
    }

    // Vertical
    Rectangle {
        visible: type === 'f' || type === 'F' || type === 'G'
        color: wallColor
        height: 30
        width: 4
        x: 13
    }

    // Horizontal outside
    Rectangle {
        visible: type === 'E' || type === 'H'
        color: wallColor
        height: 4
        width: 30
        y: type === 'E' ? 3 : 23
    }

    // Vertical outside
    Rectangle {
        visible: type === 'F' || type === 'G'
        color: wallColor
        height: 30
        width: 4
        x: type === 'F' ? 3 : 23
    }

}
