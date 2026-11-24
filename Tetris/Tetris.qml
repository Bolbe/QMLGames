import QtQuick 2.5
import QtQuick.Particles 2.0

Rectangle {
    id: tetris
    width: 500
    height: 800
    focus: true
    color: "#555"

    Rectangle {
        id: tetrion

        readonly property int runningStepTime: 500
        readonly property int droppingStepTime: 50
        property int stepTime: runningStepTime
        readonly property int minoSize: 30
        readonly property int rowCount: 24
        readonly property int columnCount: 10
        readonly property int firstRow: 20
        readonly property int playfieldHeight: minoSize*rowCount
        readonly property int playfieldWidth: minoSize*columnCount
        // coord of running tretro
        property int runningI: 3
        property int runningJ: 20
        property var groundTetro: []
        property var runningTetro: []
        property string currentTetro: ""
        property int currentTetroId: 0
        property var tetroGrid: [[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[],[]]
        property var minoList: []
        property bool setupNextTetro: false  // used to tag phase to disable animations, visibility, ...

        width: playfieldWidth
        height: playfieldHeight
        color: "black"
        anchors.centerIn: parent

        Timer {
            id: heartbeat
            interval: tetrion.stepTime
            repeat: true
            onTriggered: {
                if (tetrion.setupNextTetro) {
                    tetrion.stepTime = tetrion.runningStepTime
                    runningTetromino.anim = true
                    runningTetromino.visible = true
                    tetrion.setupNextTetro = false
                }

                var r = moveDown()
                if (!r) {
                    tetrion.setupNextTetro = true
                    //heartbeat.stop()
                    console.log("Tetromino reached BOTTOM !")
                    runningTetromino.visible = false
                    runningTetromino.anim = false
                    //tetrion.stepTime = tetrion.runningStepTime
                    runningTetromino.nextLetter()
                    tetrion.runningJ = 20
                    tetrion.runningI = 4
//                    runningTetromino.anim = true
//                    runningTetromino.visible = true
//                    heartbeat.restart()
                    // Add dead mino
                    //addDeadTetro()


                }
            }
        }

        Tetromino {
            id: runningTetromino
            minoSize: tetrion.minoSize
            letter: "L"
            i: tetrion.runningI
            j: tetrion.runningJ

            property bool anim: true

            Behavior on x {
                enabled: runningTetromino.anim
                NumberAnimation {
                    duration: tetrion.stepTime/5
                    alwaysRunToEnd: true
                }
            }
            Behavior on y {
                enabled: runningTetromino.anim
                NumberAnimation {
                    duration: tetrion.stepTime/2
                    alwaysRunToEnd: true
                }
            }
        }

        function printGrid() {
            for (var j=23; j>-1; j--) {
                var jstr = j<10?"0"+j:j
                console.log("Grid row ("+jstr+"): "+tetroGrid[j])
            }
        }

        function rebuildGrid() {
            for (var j=23; j>-1; j--) {
                for (var i=0; i<columnCount; i++) {
                    tetroGrid[j][i] = 0
                }
            }
            console.log("minoList size: "+minoList.length)
            for (var index=0; index<minoList.length; index++) {
                console.log("Mino at row "+minoList[index].j+" column "+minoList[index].i)
                tetroGrid[23-minoList[index].j][minoList[index].i] = 1
            }
            printGrid()
        }

        // Turn running tetro into dead minos
        function addDeadTetro() {
            
        }

        // Add dead mino at row jj column ii. Row 0 is the bottom row. ll gives the color.
        function addMino(jj,ii,ll) {
            var selectedIndex = -1
            for (var index=0; index<minoList.length; index++) {
                if (minoList[index]===null) {
                    selectedIndex = index
                    break;
                }
            }
            if (selectedIndex==-1) selectedIndex = minoList.length
            minoList[selectedIndex] = minoComponent.createObject(tetrion, {i:ii, j:23-jj, letter: ll})
            rebuildGrid()
        }

        Component.onCompleted: {
            addMino(5,3,"L")
            addMino(5,4,"L")
            addMino(5,5,"L")
            addMino(5,6,"L")
            heartbeat.start()
        }

        Rectangle {
            height: tetrion.minoSize*4
            width: tetrion.minoSize*10
            color: "#555"
            x:0
            y:0
        }
    }

    // return 0: all right, 1:Bottom collision, 2: Left collision, 3: Right collision, 4: Dead mino collision
    // j: top row of mino
    // i: left column of mino
    function gridCollision(j,i,minoList2) {
        console.log("Check collision j="+j+" : i="+i+" minoList="+minoList2)
        for (var index=0; index<minoList2.length; index++) {
            if (j-minoList2[index][1]<0) {
                console.log("BOTTOM Collision: Tetromino outside playground Tetrion")
                return 1
            }
            // if outside left not good
            if (i+minoList2[index][0]<0) {
                console.log("LEFT Collision: Tetromino outside playground Tetrion")
                return 2
            }
            if (i+minoList2[index][0]>9) {
                console.log("RIGHT Collision: Tetromino outside playground Tetrion")
                return 3
            }
            //console.log("Checking grid row "+(j+minoList2[index][1])+" column "+(i+minoList2[index][0]))
            if (tetrion.tetroGrid[j-minoList2[index][1]][i+minoList2[index][0]]===1) {
                console.log("Collision DEAD Mino: Tetromino collision with dead mino at row "+(j+minoList2[index][1])+" column "+(i+minoList2[index][0]))
                return 4
            }
        }
        return 0
    }

    function moveLeft() {
        var j = tetrion.runningJ+runningTetromino.squareSize-1
        var i = tetrion.runningI-1
        var minoList2 = runningTetromino.tetro[runningTetromino.rot%4]
        if (gridCollision(j,i,minoList2)>0) {
            return false
        }
        tetrion.runningI--
        return true
    }

    Keys.onLeftPressed: {
        moveLeft()
    }

    function moveRight() {
        var j = tetrion.runningJ+runningTetromino.squareSize-1
        var i = tetrion.runningI+1
        var minoList2 = runningTetromino.tetro[runningTetromino.rot%4]
        if (gridCollision(j,i,minoList2)>0) {
            return false
        }
        tetrion.runningI++
        return true
    }

    Keys.onRightPressed: {
        moveRight()
    }

    // clockwise (true or false)
    function rotate(clockwise) {
        var j = tetrion.runningJ+runningTetromino.squareSize-1
        var i = tetrion.runningI
        var minoList2 = runningTetromino.tetro[(runningTetromino.rot+1)%4]
        var collision = gridCollision(j,i,minoList2)
        // Bottom collision
        switch (collision) {
            // Collision on the left
            case 2:
                if (moveRight()) rotate(clockwise)
                return
            // Collision on the right
            case 3:
                if (moveLeft()) rotate(clockwise)
                return
            case 0:
                runningTetromino.rot = runningTetromino.rot + (clockwise?1:-1)
                return
        }
    }

    // Rotation
    Keys.onSpacePressed: {
        rotate(true)
    }

    Keys.onUpPressed: {
        tetrion.runningJ++
    }

    function moveDown() {
        var j = tetrion.runningJ+runningTetromino.squareSize-2
        var i = tetrion.runningI
        var minoList2 = runningTetromino.tetro[runningTetromino.rot%4]
        if (gridCollision(j,i,minoList2)>0) {
            return false
        }
        tetrion.runningJ--
        return true
    }

    Keys.onReturnPressed: {
        console.log("Return pressed. Increase step time to drop piece.")
        tetrion.stepTime = tetrion.droppingStepTime
    }

    Keys.onDownPressed: {
        moveDown()
    }
    Keys.onDigit0Pressed: {
        runningTetromino.nextLetter()
    }

    Component {
        id: minoComponent
        Mino {}
    }

}
