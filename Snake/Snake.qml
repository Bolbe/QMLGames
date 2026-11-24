import QtQuick 2.5
import QtQuick.Particles 2.0

Rectangle {
    id: screen
    width: 1200
    height: 750
    focus: true
    color: "#133333"

    readonly property int iCount: 40
    readonly property int jCount: 25
    readonly property int stepTime: 150
    readonly property int berryLifeSpan: 10000
    readonly property int berryCount: 10
    readonly property int birdCount: 8
    property int birdIndex: 0

    property int headDirection: 3
    property int chunkCount: 0

    property int strawberryEaten: 0
    property var chunkList: []
    property var berryList: []
    property var birdList: []
    property int headX: 0
    property int headY: 0
    property int tailX: chunkList[chunkCount-1] ? chunkList[chunkCount-1].x : 0
    property int tailY: chunkList[chunkCount-1] ? chunkList[chunkCount-1].y : 0
    property int tailDirection: chunkList[chunkCount-1] ? chunkList[chunkCount-1].pdirection : -1
    property bool gameOver: false
    property double startTime: 0

    // Playground is iCountxjCount, with 30x30 unit square
    Item {
        id: playground
        width: iCount*30
        height: jCount*30
        anchors.centerIn: parent

        Rectangle { width:40; height:2; anchors.left: parent.left; anchors.top: parent.top; color: "yellow"}
        Rectangle { width:40; height:2; anchors.left: parent.left; anchors.bottom: parent.bottom; color: "yellow"}
        Rectangle { width:40; height:2; anchors.right: parent.right; anchors.top: parent.top; color: "yellow"}
        Rectangle { width:40; height:2; anchors.right: parent.right; anchors.bottom: parent.bottom; color: "yellow"}

        Rectangle { width:2; height:40; anchors.left: parent.left; anchors.top: parent.top; color: "yellow"}
        Rectangle { width:2; height:40; anchors.left: parent.left; anchors.bottom: parent.bottom; color: "yellow"}
        Rectangle { width:2; height:40; anchors.right: parent.right; anchors.top: parent.top; color: "yellow"}
        Rectangle { width:2; height:40; anchors.right: parent.right; anchors.bottom: parent.bottom; color: "yellow"}


        Image {
            id: chopHeadSprite
            source: "head.png"

            property int toX: 0
            property int toY: 0
            property int spinAngle: 0

            transform: Rotation { origin.x: 15; origin.y: 15; angle: chopHeadSprite.spinAngle}

            function chop() {
                chopHeadSprite.visible = true
                chopHeadSprite.opacity = 1
                trailsNormal.enabled = true
                chopHeadAnim.start()
            }

            ParallelAnimation {
                id: chopHeadAnim

                PropertyAnimation {
                    target: chopHeadSprite
                    properties: "x"
                    to: chopHeadSprite.toX
                    duration: 2000
                }
                PropertyAnimation {
                    target: chopHeadSprite
                    properties: "y"
                    to: chopHeadSprite.toY
                    duration: 2000
                }
                PropertyAnimation {
                    target: chopHeadSprite
                    properties: "opacity"
                    easing.type: Easing.InCubic
                    to: 0
                    duration: 2000
                }
                PropertyAnimation {
                    target: chopHeadSprite
                    properties: "spinAngle"
                    loops: Animation.Infinite
                    from: 0
                    to: 360
                    duration: 250
                }

            }
        }

        ParticleSystem {
            id: particles
            anchors.fill: parent
            z: 1
            ImageParticle {
                source: "qrc:///particleresources/glowdot.png"
                groups: ["dots"]
            }
            ImageParticle {
                source: "qrc:///particleresources/star.png"
                colorVariation: 0.5
                groups: ["stars"]
            }
            ImageParticle {
                source: "qrc:///particleresources/star.png"
                groups: ["monostars"]
            }

            property int tailAngle: tailDirection==0 ? 90:
                                    tailDirection==1 ? 270:
                                    tailDirection==3 ? 180: 0

            Emitter {
                id: berryEmitter
                group: "stars"
                lifeSpan: 750
                lifeSpanVariation: 500
                enabled: false
                velocity: AngleDirection{magnitude: 200; angleVariation: 360; magnitudeVariation: 40}
                size: 25
                sizeVariation: 8
            }

            Emitter {
                id: tailEmitter
                x: tailX+15
                y: tailY+15
                group: "dots"
                enabled: tailDirection!=-1
                emitRate: 10
                lifeSpan: 500
                velocity: AngleDirection{angle: particles.tailAngle; magnitude: 200; magnitudeVariation: 40; angleVariation: 30}
                size: 50
                sizeVariation: 20
            }

            Emitter {
                id: trailsNormal
                enabled: false

                y: chopHeadSprite.y
                x: chopHeadSprite.x

                group: "monostars"
                emitRate: 200
                lifeSpan: 1000

                velocity: AngleDirection{magnitude: 30; angleVariation: 45}
                acceleration: PointDirection {xVariation: 10; yVariation: 10;}
                velocityFromMovement: 8

                size: 40
                sizeVariation: 20
            }
        }

        Text {
            id: scoreText
            visible: scoreTextAnim.running
            font.pixelSize: 50
            font.bold: true
            color: "white"
            text: strawberryEaten
            z: 1

            property int xx: 0
            property int yy: 0

            function run(x,y) {
                xx = x
                yy = y
                scoreText.x = xx
                scoreText.y = yy
                scoreTextAnim.restart()
            }

            ParallelAnimation {
                id: scoreTextAnim

                PropertyAnimation {
                    target: scoreText
                    property: "scale"
                    from: 1
                    to: 2
                    duration: 1000
                }
                PropertyAnimation {
                    target: scoreText
                    property: "y"
                    from: scoreText.yy
                    to: scoreText.yy-250
                    duration: 1000
                    easing.type: Easing.OutQuart
                }
                PropertyAnimation {
                    target: scoreText
                    property: "opacity"
                    from: 1.0
                    to: 0.0
                    duration: 1000
                    easing.type: Easing.InQuart
                }
            }

        }
    }

    Rectangle {
        id: gameOverRecap
        visible: gameOver
        color: "black"
        anchors.centerIn: playground
        width: playground.width/2.5
        height: playground.height/2.5
        radius: 50
        border.width: 2
        border.color: "yellow"

        Row {
            height: 40
            anchors.top: parent.top
            anchors.topMargin: 40
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 20

            Image {
                source: "head.png"
                sourceSize.width: 30
                sourceSize.height: 30
                anchors.verticalCenter: parent.verticalCenter
                mirror: true
                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    running: gameOverRecap.visible
                    PropertyAnimation { to: 1; duration: 750 }
                    PropertyAnimation { to: 1.5; duration: 250; easing.type: Easing.OutCubic}
                }
            }
            Text {
                text: "GAME OVER"
                color: "white"
                font.pixelSize: 40
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }
            Image {
                source: "head.png"
                sourceSize.width: 30
                sourceSize.height: 30
                anchors.verticalCenter: parent.verticalCenter
                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    running: gameOverRecap.visible
                    PropertyAnimation { to: 1; duration: 750 }
                    PropertyAnimation { to: 1.5; duration: 250; easing.type: Easing.OutCubic}
                }
            }
        }


        Image {
            id: gameoverstrawberry
            source: "strawberry.png"
            sourceSize.width: 30
            sourceSize.height: 30
            y: strawberryCountText.y-30
            x: strawberryCountText.x-30
            SequentialAnimation {
                running: gameOverRecap.visible
                loops: Animation.Infinite
                NumberAnimation { target: gameoverstrawberry; property: "x"; from:strawberryCountText.x-30; to:strawberryCountText.x+strawberryCountText.width; duration: 1000 }
                NumberAnimation { target: gameoverstrawberry; property: "y"; from:strawberryCountText.y-30; to:strawberryCountText.y+strawberryCountText.height; duration: 200 }
                NumberAnimation { target: gameoverstrawberry; property: "x"; from:strawberryCountText.x+strawberryCountText.width; to:strawberryCountText.x-30; duration: 1000 }
                NumberAnimation { target: gameoverstrawberry; property: "y"; from:strawberryCountText.y+strawberryCountText.height; to:strawberryCountText.y-30; duration: 200 }
            }

        }

        Text {
            id: strawberryCountText
            text: strawberryEaten>1 ? strawberryEaten + " fraises avalées !" : strawberryEaten + " fraise avalée !"
            color: "white"
            font.pixelSize: 25
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Row {
            height: 30
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.bottomMargin: 40
            anchors.leftMargin: 40

            Image {
                source: "back.png"
                sourceSize.width: 30
                sourceSize.height: 30
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: " : quitter"
                color: "white"
                font.pixelSize: 25
                anchors.verticalCenter: parent.verticalCenter
            }

        }

        Text {
            text: "OK : recommencer"
            color: "white"
            font.pixelSize: 25
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.bottomMargin: 40
            anchors.rightMargin: 40
        }
    }

    Component.onCompleted: {
        berryList[0] = strawberryComponent.createObject(playground, {i:30, j:15, index:0});
        for (var i=1; i<berryCount; i++) {
            berryList[i] = strawberryComponent.createObject(playground, {i:Math.random()*iCount, j:Math.random()*jCount, index:i});
        }
        for (var i=0; i<birdCount; i++) {
            birdList[i] = birdComponent.createObject(playground, {i:Math.random()*(iCount-1), j:Math.random()*(jCount-1), index:i});
        }
        restart()
    }

    function restart() {
        chopHeadAnim.stop()
        trailsNormal.enabled = false
        chopHeadSprite.visible = false
        gameOver = false
        strawberryEaten = 0
        for (var i=0; i<chunkCount; i++) {
            chunkList[i].visible = false
            delete chunkList[i];
        }
        chunkList[0] = chunkComponent.createObject(playground, {i:25, j:jCount-1, x:25*30, y:(jCount-1)*30, position:0});
        chunkList[0].visible = true
        chunkCount = 25
        for (var i=1; i<chunkCount; i++) {
            chunkList[i] = chunkComponent.createObject(playground, {i:chunkList[0].i-i, j:chunkList[0].j, x:(chunkList[0].i-i)*30, y:chunkList[0].j*30, position:i});
        }
        headDirection = 3

        // respawn berries
        for (var b=0; b<berryCount; b++) {
            respawnstrawberry(b)
        }
        //respawn birds
        for (var d=0; d<birdCount; d++) {
            respawnbird()
        }

        heartbeat.start()
        startTime = startTime = new Date().getTime();
    }

    function headCollision() {
        heartbeat.stop()
        chopHead()
        timerToGameOver.start()
    }

    function birdCollision(index) {
        birdList[index].swallow();
    }

    function respawnstrawberry(index) {
        var keepLooping = true
        while (keepLooping) {
            berryList[index].i = Math.random()*iCount
            berryList[index].j = Math.random()*jCount
            keepLooping = false
            for (var counter=0; counter<chunkCount; counter++) {
                if (berryList[index].i===chunkList[counter].i && berryList[index].j===chunkList[counter].j) keepLooping = true
            }
        }
        berryList[index].reset()
    }

    function respawnbird() {
        birdIndex++;
        if (birdIndex==birdCount) birdIndex = 0
        birdList[birdIndex].i = Math.random()*(iCount-1)
        birdList[birdIndex].j = Math.random()*(jCount-1)
    }

    Timer {
        id: heartbeat
        interval: stepTime
        repeat: true
        onTriggered: {
            // move body slices
            for (var i=chunkCount-1; i>0; i--) {
                chunkList[i].move(chunkList[i-1].pdirection);
            }
            // move head
            var heading = -1
            // if reaching corners, no choice
            if (chunkList[0].i===0 && chunkList[0].j===0 && headDirection==0) heading=3
            else if (chunkList[0].i===0 && chunkList[0].j===0 && headDirection==2) heading=1
            else if (chunkList[0].i===iCount-1 && chunkList[0].j===0 && headDirection==3) heading=1
            else if (chunkList[0].i===iCount-1 && chunkList[0].j===0 && headDirection==0) heading=2
            else if (chunkList[0].i===iCount-1 && chunkList[0].j===jCount-1 && headDirection==1) heading=2
            else if (chunkList[0].i===iCount-1 && chunkList[0].j===jCount-1 && headDirection==3) heading=0
            else if (chunkList[0].i===0 && chunkList[0].j===jCount-1 && headDirection==2) heading=0
            else if (chunkList[0].i===0 && chunkList[0].j===jCount-1 && headDirection==1) heading=3
            // if reaching borders with other body chunk blocking
            // Collision: vertical on the left
            else if (chunkList[0].i===0 && headDirection==2) for (var i1=1; i1<chunkCount; i1++) {
                if (chunkList[i1].i===0 && chunkList[i1].j!==chunkList[0].j) {
                    heading = chunkList[i1].j>chunkList[0].j ? 0 : 1
                    break;
                }
            }
            // Collision: vertical on the right
            else if (chunkList[0].i===iCount-1 && headDirection==3) for (var i2=1; i2<chunkCount; i2++) {
                if (chunkList[i2].i===iCount-1 && chunkList[i2].j!==chunkList[0].j) {
                    heading = chunkList[i2].j>chunkList[0].j ? 0 : 1
                    break;
                }
            }
            // Collision: horizontal top
            else if (chunkList[0].j===0 && headDirection==0) for (var i3=1; i3<chunkCount; i3++) {
                if (chunkList[i3].j===0 && chunkList[i3].i!==chunkList[0].i) {
                    heading = chunkList[i3].i>chunkList[0].i ? 2 : 3
                    break;
                }
            }
            // Collision: horizontal bottom
            else if (chunkList[0].j===jCount-1 && headDirection==1) for (var i4=1; i4<chunkCount; i4++) {
                if (chunkList[i4].j===jCount-1 && chunkList[i4].i!==chunkList[0].i) {
                    heading = chunkList[i4].i>chunkList[0].i ? 2 : 3
                    break;
                }
            }

            if (heading == -1) {
                // Default behavior when collision with borders
                if ((chunkList[0].i===0 && headDirection==2) || (chunkList[0].i===iCount-1 && headDirection==3)) {
                    if (chunkList[0].j<jCount/2) heading = 1
                    else heading = 0
                }
                else if ((chunkList[0].j===0 && headDirection==0) || (chunkList[0].j===jCount-1 && headDirection==1)) {
                    if (chunkList[0].i<iCount/2) heading = 3
                    else heading = 2
                }
            }
            if (heading!=-1) headDirection = heading
            chunkList[0].move(headDirection)
            headX = chunkList[0].x
            headY = chunkList[0].y
            // Check collision between head and other parts
            for (var index=1; index<chunkCount; index++) {
                if (chunkList[0].i===chunkList[index].i && chunkList[0].j===chunkList[index].j) {
                    headCollision()
                }
            }
            // check collision with birds
            for (var b=0; b<birdCount; b++) {
                if (chunkList[0].i>=birdList[b].i &&
                    chunkList[0].i<=birdList[b].i+1 &&
                    chunkList[0].j>=birdList[b].j &&
                    chunkList[0].j<=birdList[b].j+1) {

                    birdCollision(b)
                    headCollision()
                }
            }

            // check if a strawberry is eaten
            for (index=0; index<berryCount; index++) {
                if (chunkList[0].i===berryList[index].i && chunkList[0].j===berryList[index].j && berryList[index].dropping===false) {
                    berryEmitter.x = berryList[index].i*30
                    berryEmitter.y = berryList[index].j*30
                    berryEmitter.burst(500)
                    scoreText.run(berryList[index].i*30, berryList[index].j*30);
                    strawberryEaten++;
                    addchunk();
                    respawnstrawberry(index);
                    respawnbird();
                }
            }
        }
    }

    Timer {
        id: timerToGameOver
        interval: 2000
        onTriggered: {
            gameOver = true
        }
    }

    Timer {
        id: swallow
        interval: 50

        property int index
        onTriggered: {
            chunkList[index].chunkBigAnim()
            index++;
            if (index<chunkCount) swallow.start()
        }
        function run() {
            index=0;
            swallow.start()
        }
    }

    function chopHead() {
        chunkList[0].visible = false
        chopHeadSprite.x = chunkList[0].x
        chopHeadSprite.y = chunkList[0].y
        switch (headDirection) {
            case 0:
                chopHeadSprite.toX = chopHeadSprite.x
                chopHeadSprite.toY = -30
                break;
            case 1:
                chopHeadSprite.toX = chopHeadSprite.x
                chopHeadSprite.toY = jCount*30
                break;
            case 2:
                chopHeadSprite.toY = chopHeadSprite.y
                chopHeadSprite.toX = -30
                break;
            case 3:
                chopHeadSprite.toY = chopHeadSprite.y
                chopHeadSprite.toX = iCount*30
                break;
        }
        chopHeadSprite.chop()
    }

    function addchunk() {
        var ii = chunkList[chunkCount-1].i
        var jj = chunkList[chunkCount-1].j
        switch (chunkList[chunkCount-1].pdirection) {
            case 0:
                jj++;
                break;
            case 1:
                jj--;
                break;
            case 2:
                ii++;
                break;
            case 3:
                ii--;
                break;
        }
        if (jj<0) jj=(playground.height/30)-1
        else if (jj>=playground.height/30) jj=0
        if (ii<0) ii=(playground.width/30)-1
        else if (ii>=playground.width/30) ii=0
        chunkList[chunkCount] = chunkComponent.createObject(playground, {i:ii, j:jj, x:ii*30, y:jj*30, position:chunkCount});
        swallow.run()
        chunkCount++;
    }

    Keys.onUpPressed: {
        if (chunkList[0].j===0) return;
        if (chunkList[0].pdirection===1) return;
        headDirection = 0
    }
    Keys.onDownPressed: {
        if (chunkList[0].j===jCount-1) return;
        if (chunkList[0].pdirection===0) return;
        headDirection = 1
    }
    Keys.onLeftPressed: {
        if (chunkList[0].i===0) return;
        if (chunkList[0].pdirection===3) return;
        headDirection = 2
    }
    Keys.onRightPressed: {
        if (chunkList[0].i===iCount-1) return;
        if (chunkList[0].pdirection===2) return;
        headDirection = 3
    }

    Keys.onReturnPressed: {
        if (!gameOver) return;
        restart()
    }

    Keys.onDigit1Pressed: {
        if (!gameOver) return;
        restart()
    }

    Keys.onDigit2Pressed: {
        headCollision()
    }
    Keys.onDigit9Pressed: {
        addchunk()
    }


    Component {
        id: birdComponent

        Item {
            id: bird

            function swallow() {
                swallowAnim.start()
            }

            width: 60
            height: 60

            property int i: 0
            property int j: 0
            property int index: 0
            property int jitterX: 0
            property int jitterY: 0
            property int durationX: 500
            property int durationY: 500
            property int easingX: 0
            property int easingY: 0

            x: i*30+jitterX
            y: j*30+jitterY

            Image {
                source: index%2 == 0 ? "bird1.png" : "bird2.png"
                height: 70
                width: 70
                mirror: headX/30 < i
                anchors.centerIn: parent
            }

            SequentialAnimation on scale {
                id: swallowAnim
                PropertyAnimation { from:1; to:3; duration:100 }
                PropertyAnimation { from:3; to:1; duration:300 }
            }

            Behavior on i {
                NumberAnimation {
                    duration: 600
                    easing.type: Easing.OutQuad
                    alwaysRunToEnd: true
                }
            }

            Behavior on j {
                NumberAnimation {
                    duration: 600
                    easing.type: Easing.OutQuad
                    alwaysRunToEnd: true
                }
            }

            ParallelAnimation {
                id: tweetAnim
                running: true
                PropertyAnimation {
                    target: bird
                    properties: "jitterX"
                    from:-5; to:5;
                    duration: durationX
                    easing.type: easingX%2==0 ? Easing.OutInElastic : Easing.InOutElastic

                }
                PropertyAnimation {
                    target: bird
                    properties: "jitterY"
                    from:-5; to:5;
                    duration: durationY
                    easing.type: easingY%2==0 ? Easing.OutInElastic : Easing.InOutElastic

                }
                onStopped: {
                    durationX = 300+Math.random()*400
                    durationY = 300+Math.random()*400
                    easingX = Math.random()*100
                    easingY = Math.random()*100
                    tweetAnim.start()
                }
            }


        }
    }


    Component {
        id: strawberryComponent
        // strawberry
        Item {
            id: strawberry
            width: 30
            height: 30

            property int i: 0
            property int j: 0
            property int index: 0

            property bool dropping: false

            function reset() {
                dropping = false
                rotting.restart()
            }

            x: i*width
            y: j*height

            SequentialAnimation {
                id: rotting
                running: false

                PropertyAnimation {
                    target: strawberryImage
                    property: "opacity"
                    easing.type: Easing.InQuint
                    from: 1.0
                    to: 0.0
                    duration: berryLifeSpan
                }

                ScriptAction {
                    script: {
                        dropping = true
                    }
                }

                PropertyAnimation {
                    id: dropAnim
                    target: strawberry
                    easing.type: Easing.InQuad
                    property: "y"
                    to: y+750
                    duration: 1000
                }

                onStopped: respawnstrawberry(index)

            }

            Image {
                id: strawberryImageBlue
                anchors.centerIn: parent
                mirror: (i+j)%2==0
                width: 40
                height: 40
                source: "strawberryblue.png"
            }

            Image {
                id: strawberryImage
                anchors.centerIn: parent
                mirror: (i+j)%2==0
                width: 40
                height: 40
                source: "strawberry.png"
            }
        }
    }

    Component {
        id: chunkComponent
        Item {
            id: chunkItem
            width: 30
            height: 30
            z: chunkItem.head ? 1 : 0
            scale: chunkItem.head ? 1.2 : 1

            property int pdirection: 3
            property int position: 0
            property bool vertical: pdirection==0 || pdirection==1
            property bool horizontal: !vertical
            property bool even: position%2==0
            property bool head: position==0
            property bool tail: position===chunkCount-1

            property int i: 0
            property int j: 0
            property int rotationAngle: (pdirection==0 && !head) ? 90 :
                                        (pdirection==1 && !head) ? -90 :
                                        (pdirection==0 && tail) ? -90 :
                                        (pdirection==1 && head) ? 180 :
                                        0

            transform: Rotation { origin.x: 15; origin.y: 15; angle: rotationAngle}

            Behavior on rotationAngle {
                NumberAnimation {
                    duration: stepTime
                }
            }

            function chunkBigAnim() {
                chunkBig.start()
            }

            function move(direction) {
                var xjitter = 0
                var yjitter = 0
                switch (direction) {
                    case 0:
                        j--;
                        break;
                    case 1:
                        j++;
                        break;
                    case 2:
                        i--;
                        break;
                    case 3:
                        i++
                        break;
                }
                xbehave.enabled = true
                ybehave.enabled = true
                x = i*width+Math.random()*4-2
                y = j*height+Math.random()*4-2
                pdirection = direction
            }

            Behavior on x {
                id: xbehave
                enabled: false
                NumberAnimation {
                    duration: stepTime
                    alwaysRunToEnd: true
                }
            }
            Behavior on y {
                id: ybehave
                enabled: false
                NumberAnimation {
                    duration: stepTime
                    alwaysRunToEnd: true
                }
            }

            Image {
                id: chunk

                property int widthMax:  (chunkItem.head && chunkItem.vertical) ? parent.width+10:
                        (chunkItem.head && chunkItem.horizontal) ? parent.width+14:
                        chunkItem.horizontal ? parent.width+10:
                        parent.width+6

                property int heightMax: (chunkItem.head && chunkItem.vertical) ? parent.height+14:
                        (chunkItem.head && chunkItem.horizontal) ? parent.height+10:
                        chunkItem.vertical ? parent.height+10:
                        parent.height+6

                width: widthMax
                height: heightMax
                source: chunkItem.head ? "head.png" :
                        chunkItem.tail ? "tail.png" :
                        position%2==0 ? "chunka.png" : "chunkb.png"

                mirror: chunkItem.tail && pdirection==3 // mirror tail for this specific direction

                anchors.centerIn: parent

                SequentialAnimation on width {
                    running: !chunkItem.even && chunkItem.vertical && !chunkItem.head && !chunkItem.tail
                    loops: Animation.Infinite
                    PropertyAnimation { to: chunk.widthMax }
                    PropertyAnimation { to: chunk.widthMax-6 }
                }

                SequentialAnimation on height {
                    running: chunkItem.even && chunkItem.horizontal && !chunkItem.head && !chunkItem.tail
                    loops: Animation.Infinite
                    PropertyAnimation { to: chunk.heightMax }
                    PropertyAnimation { to: chunk.heightMax-6 }
                }

                PropertyAnimation {
                    id: chunkBig
                    target: chunk
                    properties: "scale";
                    from: 2
                    to: 1
                    duration: chunkItem.head ? 500 : 100
                }

            }
        }
    }
}
