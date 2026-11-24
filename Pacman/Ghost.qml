import QtQuick 2.5

Item {
    id: ghost
    width: 30
    height: 30

    property string nickname: "blinky"
    property string color: "white"
    property string colorAlt: "white"
    property alias movingTimer: movingTimer
    property int mode: 0 // 0: de-activated (stand still), 1:scatter, 2:chase, 3:freighten, 4:eyes
    property int stepDuration: 100
    property int direction: 0 // 0:up, 1:down, 2:left, 3:right
    property bool stepOne: true // used to get alternate sprites
    property int i: 13
    property int j: 11
    property var sightLine: []
    property var target: mode === 1 ? scatterTarget : mode === 2 ? chaseTarget : houseTarget
    property var scatterTarget: [12,14]
    property var chaseTarget: [12,14]
    property var houseTarget: [13,11]
    property var startPosition: [13,11]
    property bool doppelganger: false
    property bool smoothAnim: true
    property var vpos: [i,j]
    property int di: direction === 2 ? -1 : direction === 3 ? 1 : 0
    property int dj: direction === 0 ? -1 : direction === 1 ? 1 : 0
    property var vdirection:  direction === 0 ? [0,-1] :
                            direction === 1 ? [0,1] :
                            direction === 2 ? [-1,0] :
                            direction === 3 ? [1,0] : [0,0]    // latest move that brought to current i,j

    property int sqDistanceToChaseTarget: Math.pow(chaseTarget[0]-i,2)+Math.pow(chaseTarget[1]-j,2)

    x: i*30
    y: j*30

    Image {
        id: ghostImage
        anchors.centerIn: parent
        source: ghost.mode===0 && stepOne ? nickname+'-still1.png' :
                ghost.mode===0 && !stepOne ? nickname+'-still2.png' :
                mode===3 && stepOne ? nickname+'-freight1.png' :
                mode===3 && !stepOne ? nickname+'-freight2.png' :
                direction===0 && stepOne ? nickname+'-up1.png' :
                direction===0 && !stepOne ? nickname+'-up2.png' :
                direction===1 && stepOne ? nickname+'-down1.png' :
                direction===1 && !stepOne ? nickname+'-down2.png' :
                direction===2 && stepOne ? nickname+'1.png' :
                direction===2 && !stepOne ? nickname+'2.png' :
                direction===3 && stepOne ? nickname+'1.png' :
                direction===3 && !stepOne ? nickname+'2.png' : ""

        mirror: direction===2

    }
    Image {
        visible: doppelganger
        source: ghostImage.source
        mirror: ghostImage.mirror
        x: direction === 2 ? ghostImage.x + 840 : direction === 3 ? ghostImage.x - 840 : ghostImage.x
        y: direction === 0 ? ghostImage.y + 930 : direction === 1 ? ghostImage.y - 930 : ghostImage.y
    }

    Timer {
        interval: 150
        repeat: true
        running: true
        onTriggered: {
            stepOne = !stepOne
        }
    }

    Timer {
        id: movingTimer
        repeat: true
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
