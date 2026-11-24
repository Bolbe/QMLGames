import QtQuick 2.5

Image {

    property int size: 30
    property string letter: "J"
    property int rotationStep: 0
    property int i: 0
    property int j: 0

    x: i*size
    y: j*size
    sourceSize.height: size
    sourceSize.width: size
    source: letter==="I" ? "Icyan.png" :
                           letter==="J" ? "Jblue.png" :
                           letter==="L" ? "Lorange.png" :
                           letter==="O" ? "Oyellow.png" :
                           letter==="S" ? "Sgreen.png" :
                           letter==="Z" ? "Zred.png" :
                           letter==="T" ? "Tmagenta.png" :
                           ""

    transformOrigin: Item.Center
//    rotation: rotationStep*90 // Uncomment this to make the mino rotate

    Behavior on rotation {
        NumberAnimation {
            duration: 100
            alwaysRunToEnd: true
        }
    }

    Behavior on x {
        NumberAnimation {
            duration: 100
            alwaysRunToEnd: true
        }
    }
    Behavior on y {
        NumberAnimation {
            duration: 100
            alwaysRunToEnd: true
        }
    }

}
