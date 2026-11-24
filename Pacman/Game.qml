import QtQuick 2.5
import QtQuick.Particles 2.0

// Maze is 28 x 31

// ghost mode: 0: stand still, 1: scatter, 2: chase, 3: frighten, eyes: 4
// game mode: 0: not running 1: scatter, 2: chase

Rectangle {
    id: game
    width: 1200
    height: 930
    focus: true
    color: "#222"

    property bool hudOn: false

    property int ghostStep: 250
    property int pacmanStep: 200
    property int gameMode: 0  // 0: not running, 1: scatter, 2:chase

    property int dotCount: 0

    Maze {
        id: maze
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 50

        Pacman {
            id: pacman
            stepDuration: game.pacmanStep

            Rectangle {
                visible: hudOn && clyde.visible && gameMode === 2
                anchors.centerIn: parent
                width: 480 // (16*30: 8 tiles away)
                height: 480
                radius: 240
                color: "transparent"
                border.width: 2
                border.color: clyde.color
            }
        }

        Item {
            visible: hudOn && inky.visible
            x: (pacman.i+2*pacman.vdirection[0])*30
            y: (pacman.j+2*pacman.vdirection[1])*30
            width: 30
            height: 30
            Rectangle {
                anchors.centerIn: parent
                color: "white"
                width: 20
                height: 2
            }
            Rectangle {
                anchors.centerIn: parent
                color: "white"
                width: 2
                height: 20
            }
            rotation: 45
        }

        Ghost {
            id: inky
            nickname: "inky"
            stepDuration: game.ghostStep
            color: "#00FFFF"
            colorAlt: "#5500FFFF"
            mode: 0
            direction: 3
            i: 12
            j: 14
            startPosition: [12,14]
            houseTarget: [13,11]
            chaseTarget: [2*(pacman.i+2*pacman.vdirection[0])-blinky.i,2*(pacman.j+2*pacman.vdirection[1])-blinky.j]
            scatterTarget: [27,30]
            movingTimer.interval: ghostStep
            movingTimer.onTriggered: {
                if (movingTimer.interval<ghostStep) movingTimer.interval=ghostStep
                moveGhost(inky)
            }
        }

        Target {
            id: inkyTarget
            visible: hudOn && inky.visible
            i: inky.target[0]
            j: inky.target[1]
            borderColor: inky.color
        }

        Ghost {
            id: pinky
            nickname: "pinky"
            stepDuration: game.ghostStep
            color: "#FFB7FF"
            colorAlt: "#55FFB7FF"
            direction: 3
            mode: 0
            i: 14
            j: 14
            houseTarget: [14,11]
            startPosition: [14,14]
            chaseTarget: [pacman.i+4*pacman.vdirection[0],pacman.j+4*pacman.vdirection[1]]
            scatterTarget: [-5,0]
            movingTimer.interval: ghostStep
            movingTimer.onTriggered: {
                if (movingTimer.interval<ghostStep) movingTimer.interval=ghostStep
                moveGhost(pinky)
            }
        }

        Target {
            visible: hudOn && pinky.visible
            i: pinky.target[0]
            j: pinky.target[1]
            borderColor: pinky.color
        }

        Ghost {
            id: clyde
            nickname: "clyde"
            stepDuration: game.ghostStep
            color: "#FFB751"
            colorAlt: "#55FFB751"
            direction: 2
            mode: ghostMode === 0 ? 0 : ghostMode === 2 ? 2 : sqDistanceToChaseTarget > 64 ? 1 : 0
            i: 16
            j: 14
            houseTarget: [14,11]
            startPosition: [16,14]
            chaseTarget: pacman.vpos
            scatterTarget: [0,30]
            movingTimer.interval: ghostStep
            movingTimer.onTriggered: {
                if (movingTimer.interval<ghostStep) movingTimer.interval=ghostStep
                moveGhost(clyde)
            }
        }


        Target {
            visible: hudOn && clyde.visible
            i: clyde.target[0]
            j: clyde.target[1]
            borderColor: clyde.color
        }

        Ghost {
            id: blinky
            nickname: "blinky"
            stepDuration: game.ghostStep
            color: "#FF0000"
            colorAlt: "#55FF0000"
            mode: 1
            i: 13
            j: 11
            startPosition: [13,11]
            direction: 2
            chaseTarget: pacman.vpos
            scatterTarget: [35,0]
            movingTimer.interval: ghostStep
            movingTimer.onTriggered: {
                if (blinky.movingTimer.interval<ghostStep) blinky.movingTimer.interval=ghostStep
                moveGhost(blinky)
            }
        }

        Target {
            visible: hudOn && blinky.visible
            i: blinky.target[0]
            j: blinky.target[1]
            borderColor: blinky.color
        }

    }

    property var ghostList: [blinky, pinky, inky, clyde]

    Item {
        id: board
        anchors.top: maze.top
        anchors.bottom: maze.bottom
        anchors.left: maze.right
        anchors.right: parent.right
        anchors.leftMargin: 20
        anchors.topMargin: 20

        Column {
            anchors.top: parent.top
            anchors.left: parent.left
            width: parent.width
            Text {
                color: "white"
                font.pixelSize: 16
                text: "0: Debug mode on/off\n1: Inky/Blinky visible / invisible\n2: Pinky visible / invisible\n3: Clyde visible / invisible\n4: change ghost mode\n8: move one step\n9: pause / run"
            }
            Item {
                height: 20
                width: 1
            }

            Text {
                text: "Dots: "+dotCount
                color: "white"
                font.pixelSize: 20
            }
            Text {
                text: "Mode: "+ghostModeName
                color: "white"
                font.pixelSize: 20
            }
        }
    }

    Canvas {
        id: hud
        visible: hudOn
        anchors.fill: maze
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0,0,width,height)
            for (var g=0; g<ghostList.length; g++) {
                var ghost = ghostList[g]
                if (ghost.sightLine.length<1 || !ghost.visible) continue
                ctx.lineWidth = 10;
                ctx.strokeStyle = ghost.colorAlt
                var x = ghost.i*30+ghost.width/2
                var y = ghost.j*30+ghost.height/2
                ctx.beginPath()
                ctx.moveTo(x,y)
                for (var i=0; i<ghost.sightLine.length; i++) {
                    x += ghost.sightLine[i][0]*30
                    y += ghost.sightLine[i][1]*30
                    ctx.lineTo(x,y)
                }
                ctx.stroke();
                if (ghost === inky && ghostMode===1) {
                    ctx.lineWidth = 2;
                    ctx.strokeStyle = "white"
                    ctx.beginPath()
                    ctx.moveTo(blinky.i*30+15,blinky.j*30+15)
                    ctx.lineTo(ghost.chaseTarget[0]*30+15,ghost.chaseTarget[1]*30+15)
                    ctx.stroke();
                }
            }

        }
    }

    Timer {
        id: pacmanTimer
        interval: pacmanStep
        repeat: true
        onTriggered: {
            if (interval<pacmanStep) interval=pacmanStep
            movePacman()
        }
    }

    Timer {
        id: hudTimer
        interval: ghostStep
        repeat: true
        onTriggered: {
            if (hudOn) hud.requestPaint()
        }
    }


    Keys.onUpPressed: {
        pacman.requestedDirection = 0
    }

    Keys.onDownPressed: {
        pacman.requestedDirection = 1
    }

    Keys.onLeftPressed: {
        pacman.requestedDirection = 2
    }

    Keys.onRightPressed: {
        pacman.requestedDirection = 3
    }

    Keys.onDigit8Pressed: {
        moveGhost(blinky)
        moveGhost(pinky)
        moveGhost(inky)
        moveGhost(clyde)
        movePacman()
    }

    Keys.onDigit1Pressed: {
        if (hudOn) {
            blinky.visible = !blinky.visible
            inky.visible = !inky.visible
        }
    }
    Keys.onDigit2Pressed: if (hudOn) pinky.visible = !pinky.visible
    Keys.onDigit3Pressed: if (hudOn) clyde.visible = !clyde.visible
    Keys.onDigit4Pressed: {
        ghostMode++
        if (ghostMode>2) ghostMode=0
        print("Ghost mode: "+ghostModeName)
    }

    Keys.onDigit0Pressed: {
        hudOn = !hudOn
        if (!hudOn) {
            blinky.visible = true
            pinky.visible = true
            inky.visible = true
            clyde.visible = true
        }
    }

    function pauseGame() {
        if (pacmanTimer.running) {
            pacmanTimer.stop()
            blinky.movingTimer.stop()
            pinky.movingTimer.stop()
            inky.movingTimer.stop()
            clyde.movingTimer.stop()
        } else {
            pacmanTimer.start()
            blinky.movingTimer.start()
            pinky.movingTimer.start()
            inky.movingTimer.start()
            clyde.movingTimer.start()
        }
    }

    Keys.onDigit9Pressed: {
        pauseGame()
    }

    Component.onCompleted: {
        for (var j=0; j<mazeMap.length; j++) {
            for (var i=0; i<mazeMap[j].length; i++) {
                mazeArray.push(mazeMap[j][i])
            }
        }
        maze.model = mazeArray
        pacmanTimer.start()
        blinky.movingTimer.start()
        pinky.movingTimer.start()
        inky.movingTimer.start()
        clyde.movingTimer.start()
        hudTimer.start()
    }

    onDotCountChanged: {
        if (dotCount==10) {
            inky.mode = 1
        }
        if (dotCount==20) {
            pinky.mode = 1
        }
        if (dotCount==25) {
            clyde.mode = 1
        }
    }

    function pacmanCanGoto(i,j) {
        var tile = mazeArray[j*28+i]
        if ((tile>='A' && tile<='O') || (tile>='a' && tile<='f') || tile==='<' || tile==='>' || tile==='=') return false
        return true
    }

    // i,j: current position
    // move: ii (0,1), jj (0,1)

    function ghostCanGoto(i,j,di,dj,noStepping) {
        // Not if tile occupied by a ghost
        // CANNOT GO on another ghost if directions are the same.
        if (noStepping) {
            for (var g=0; g<ghostList.length; g++) {
                var ghost = ghostList[g]
                if (ghost.i===i+di && ghost.j===j+dj && ghost.di===di && ghost.dj===dj) {
                    return false
                }
            }
        }
        var tile = mazeArray[(j+dj)*28+(i+di)]
        if ((tile>='A' && tile<='O') || (tile>='a' && tile<='f')) return false // solid wall
        if (tile==='R' && dj<0) return false // red zone (ghost below R)
        if ((tile==='<' || tile==='>' || tile==='=') && dj>0) return false // cannot enter ghost house

        return true
    }

    function dist(a, b) {
        return Math.pow(b[0]-a[0],2)+Math.pow(b[1]-a[1],2)
    }

    function shortestWayToTarget(origin,target,ways) {
        var min = 9999
        var index = -1
        for (var i=0; i<ways.length; i++) {
            var d = dist(vsum(origin,ways[i]), target)
            print("Distance for "+ways[i]+": "+d)
            if (d<min) {
                min = d
                index = i
            }
        }
        return ways[index]
    }

    // vector sum [i,j] + [k,l] = [i+k,j+l]
    function vsum(a,b) {
        return [a[0]+b[0], a[1]+b[1]]
    }

    function vequal(a,b) {
        return a[0]===b[0] && a[1]===b[1]
    }
    function vectorToDirection(v) {
        if (vequal([0,-1],v)) return 0
        if (vequal([0,1],v)) return 1
        if (vequal([-1,0],v)) return 2
        if (vequal([1,0],v)) return 3
        return -1
    }
    function directionToVector(d) {
        if (d===0) return [0,-1]
        if (d===1) return [0,+1]
        if (d===2) return [-1,0]
        if (d===3) return [+1,0]
        return [0,0]
    }

    // return array of possible directions based on position (i,j). No reverse move possible. Current move [0,1] passed as 2nd arg
    function possibleWays(i,j,currentMove, noStepping) {
        var ways = []
        if ((ghostCanGoto(i,j,0,-1,noStepping) && currentMove[1]!==1) || j===0) ways.push([0,-1])
        if ((ghostCanGoto(i,j,0,1,noStepping) && currentMove[1]!==-1) || j===30) ways.push([0,+1])
        if ((ghostCanGoto(i,j,-1,0,noStepping) && currentMove[0]!==1) || i===0) ways.push([-1,0])
        if ((ghostCanGoto(i,j,1,0,noStepping) && currentMove[0]!==-1) || i===27) ways.push([+1,0])
        return ways
    }

    function reverseDirection(d) {
        return d === 0 ? 1 : d === 1 ? 0 : d === 2 ? 3 : d === 3 ? 2 : -1
    }

    function reverseVector(v) {
        return [-v[0],-v[1]]
    }

    function bestMoveToTarget(ghost, target, currentMove, noStepping) {
        var ways = possibleWays(ghost[0], ghost[1], currentMove, noStepping)
        if (ways.length===0) {
            print("Dead end ??? Only one way out: Reverse")
            return reverseVector(currentMove)
        }
        print("Possible ways: "+ways)
        return shortestWayToTarget(ghost,target,ways)
    }

    function ghostStep(ghost) {
        switch (ghost.direction) {
            case 0:
                ghost.j--
                return
            case 1:
                ghost.j++
                return
            case 2:
                // check loop
                if (ghost.i===0) {
                    print(ghost.nickname+" preparing step left")
                    ghost.doppelganger = true
                    ghost.i=-1
                    return true
                }
                ghost.i--
                return
            case 3:
                // check loop
                if (ghost.i===27) {
                    print(ghost.nickname+" preparing step right")
                    ghost.doppelganger = true
                    ghost.i=28
                    return true
                }
                ghost.i++
                return
        }
    }

    function moveGhost(ghost) {
        print("\n####### Moving ghost "+ghost.nickname)
        if (ghost.mode===0) return // ghost deactivated

        if (ghost.mode===3) {   // fright mode
            var chosenWay = [0,0]
            var ways = possibleWays(ghost[0], ghost[1], ghost.vdirection, true) // no stepping
            if (ways.length===0) {
                print("Dead end in fright mode ??? Only one way out: Reverse")
                chosenWay = reverseVector(currentMove)
            }
            // chose randomly

            ghost.direction = vectorToDirection(chosenWay)
            return
        }

        if (ghost.mode===4 && ghost.i===ghost.houseTarget[0] && ghost.j===ghost.houseTarget[1]) {   // eye mode and reached house
            print(ghost.nickname+" reached house target. Go to mode 1 or 2 (game mode)")
            ghost.mode=gameMode
        }

        if (ghost.i===-1) {
            print(ghost.nickname+" out left")
            ghost.smoothAnim = false
            ghost.i=27
            ghost.doppelganger = false
            ghost.movingTimer.interval = 1
            return true
        }

        if (ghost.i===28) {
            print(ghost.nickname+" out right")
            ghost.smoothAnim = false
            ghost.i=0
            ghost.doppelganger = false
            ghost.movingTimer.interval = 1
            return true
        }

        ghost.smoothAnim = true
        var bestMove = bestMoveToTarget(ghost.vpos,ghost.target,ghost.vdirection, true)
        ghost.direction = vectorToDirection(bestMove)

        if (hudOn) {
            var moveList = []
            var pos = vsum(ghost.vpos, bestMove)
            var previousMove = bestMove
            for (var i=0; i<25; i++) {
                var nextMove = bestMoveToTarget(pos,ghost.target, previousMove, false)
                moveList.push(nextMove)
                pos = vsum(pos, nextMove)
                previousMove = nextMove
            }
            ghost.sightLine = moveList
        }

//        ghostStep(ghost)
        switch (ghost.direction) {
            case 0:
                ghost.j--
                return
            case 1:
                ghost.j++
                return
            case 2:
                // check loop
                if (ghost.i===0) {
                    print(ghost.nickname+" preparing step left")
                    ghost.doppelganger = true
                    ghost.i=-1
                    return true
                }
                ghost.i--
                return
            case 3:
                // check loop
                if (ghost.i===27) {
                    print(ghost.nickname+" preparing step right")
                    ghost.doppelganger = true
                    ghost.i=28
                    return true
                }
                ghost.i++
                return
        }
    }

    function movePacman() {

        if (pacman.i===-1) {
            print("Pacman out left")
            pacman.smoothAnim = false
            pacman.i=27
            pacman.doppelganger = false
            pacmanTimer.interval = 1
            return true
        }

        if (pacman.i===28) {
            print("Pacman out right")
            pacman.smoothAnim = false
            pacman.i=0
            pacman.doppelganger = false
            pacmanTimer.interval = 1
            return true
        }

        // check if dot to be eaten
        var tile = maze.tile(pacman.i,pacman.j)
        if (tile==='.') {
            maze.setTile(pacman.i,pacman.j,' ')
            game.dotCount++;
            //print("Dots: "+game.dots)
        }

        pacman.moving = true
        pacman.smoothAnim = true
        if (pacman.requestedDirection!=pacman.direction) {
            print("Pacman requesting direction "+pacman.requestedDirection)
            switch (pacman.requestedDirection) {
                case 0:
                    if (pacman.j>0 && pacmanCanGoto(pacman.i,pacman.j-1)) pacman.direction = 0
                    break;
                case 1:
                    if (pacman.j<30 && pacmanCanGoto(pacman.i,pacman.j+1)) pacman.direction = 1
                    break;
                case 2:
                    if (pacman.i>0 && pacmanCanGoto(pacman.i-1,pacman.j)) pacman.direction = 2
                    break;
                case 3:
                    if (pacman.i<28 && pacmanCanGoto(pacman.i+1,pacman.j)) pacman.direction = 3
                    break;
            }
        }
        switch (pacman.direction) {
            case 0:
                if (!pacmanCanGoto(pacman.i,pacman.j-1)) {
                    pacman.moving = false
                    return false
                }
                pacman.j--;
                break;
            case 1:
                if (!pacmanCanGoto(pacman.i,pacman.j+1)) {
                    pacman.moving = false
                    return false
                }
                pacman.j++;
                break;
            case 2:
                // check loop
                if (pacman.i===0) {
                    print("Pacman preparing step left")
                    pacman.doppelganger = true
                    pacman.i=-1
                    return true
                }

                if (!pacmanCanGoto(pacman.i-1,pacman.j)) {
                    pacman.moving = false
                    return false
                }
                pacman.i--;
                break;
            case 3:
                // check loop
                if (pacman.i===27) {
                    print("Pacman preparing step right")
                    pacman.doppelganger = true
                    pacman.i=28
                    return true
                }

                if (!pacmanCanGoto(pacman.i+1,pacman.j)) {
                    pacman.moving = false
                    return false
                }
                pacman.i++;
                break;
        }
        return true
    }


    // corners 0:top-left, 1:top-right, 2:bottom-right, 3:bottom-left
    // 4:horizontal-top, 5:horizontal-bottom, 6:vertical-left, 7:vertical-bottom

    property var mazeArray: []
    property var mazeMap : ["AEEEEEEEEEEEENMEEEEEEEEEEEEB",
                            "F............ff............G",
                            "F.aeeb.aeeeb.ff.aeeeb.aeeb.G",
                            "FPf  f.f   f.ff.f   f.f  fPG",
                            "F.deec.deeec.dc.deeec.deec.G",
                            "F..........................G",
                            "F.aeeb.ab.aeeeeeeb.ab.aeeb.G",
                            "F.deec.ff.deebaeec.ff.deec.G",
                            "F......ff....ff....ff......G",
                            "DHHHHJ.fdeeb ff aeecf.IHHHHC",
                            "     F.faeecRdcRdeebf.G     ",
                            "     F.ff          ff.G     ",
                            "     F.ff OOO==OOO ff.G     ",
                            "EEEEEK.dc O      O dc.LEEEEE",
                            "      .   O      O   .      ",
                            "HHHHHJ.ab O      O ab.IHHHHH",
                            "     F.ff OOOOOOOO ff.G     ",
                            "     F.ff          ff.G     ",
                            "     F.ff aeeeeeeb ff.G     ",
                            "AEEEEK.dc deebaeec dc.LEEEEB",
                            "F............ff............G",
                            "F.aeeb.aeeeb.ff.aeeeb.aeeb.G",
                            "F.debf.deeecRdcRdeeec.faec.G",
                            "FP..ff................ff..PG",
                            "deb.ff.ab.aeeeeeeb.ab.ff.aec",
                            "aec.dc.ff.deebaeec.ff.dc.deb",
                            "F......ff....ff....ff......G",
                            "F.aeeeecdeeb.ff.aeecdeeeeb.G",
                            "F.deeeeeeeec.dc.deeeeeeeec.G",
                            "F..........................G",
                            "DHHHHHHHHHHHHHHHHHHHHHHHHHHC"]

}
