import QtQuick 2.5

Item {
    id: pacman
    width: 30
    height: 30

    property int stepDuration: 100
    property int direction: 2 // 0:up, 1:down, 2:left, 3:right
    property int requestedDirection: 2
    property int step: 0
    property int i: 14
    property int j: 23
    property bool moving: false
    property bool smoothAnim: true
    property bool doppelganger: false
    property var vpos: [i,j]
    property var vdirection:  direction === 0 ? [0,-1] :
                        direction === 1 ? [0,1] :
                        direction === 2 ? [-1,0] :
                        direction === 3 ? [1,0] : [0,0]

    x: i*30
    y: j*30

    Image {
        id: pacmanImage
        anchors.centerIn: parent
        source: !moving ? "pacman_full.png":
                step === 0 ? "pacman_full.png":
                (direction === 2 || direction === 3) && (step === 1 || step === 3) ? "pacman_quater.png":
                direction === 0 && (step === 1 || step === 3) ? "pacman_quater0.png":
                direction === 1 && (step === 1 || step === 3) ? "pacman_quater1.png":
                (direction === 2 || direction === 3) && step === 2 ? "pacman_half.png":
                direction === 0 && step === 2 ? "pacman_half0.png":
                direction === 1 && step === 2 ? "pacman_half1.png": ""

        mirror: direction === 2
    }
    Image {
        visible: doppelganger
        source: pacmanImage.source
        mirror: pacmanImage.mirror
        x: direction === 2 ? pacmanImage.x + 840 : direction === 3 ? pacmanImage.x - 840 : pacmanImage.x
        y: direction === 0 ? pacmanImage.y + 930 : direction === 1 ? pacmanImage.y - 930 : pacmanImage.y
    }

    Rectangle {
        visible: requestedDirection !== direction
        x: requestedDirection === 2 ? -15 : requestedDirection === 3 ? 37 : 11
        y: requestedDirection === 0 ? -15 : requestedDirection === 1 ? 37 : 11
        color: "orange"
        width: 8
        height: 8
        radius: 4

    }

    Timer {
        interval: 100
        repeat: true
        running: moving
        onTriggered: {
            step += 1
            if (step>3) step = 0
        }
    }

    Behavior on x {
        id: xAnim
        enabled: smoothAnim
        NumberAnimation {
            duration: stepDuration
            alwaysRunToEnd: true
        }
    }

    Behavior on y {
        id: yAnim
        enabled: smoothAnim
        NumberAnimation {
            duration: stepDuration
            alwaysRunToEnd: true
        }
    }

}
