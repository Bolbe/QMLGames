import QtQuick 2.5

// Maze is 28x31 unit square
Rectangle {
    id: maze
    color: "black"
    width: 840 // 28x30
    height: 930 // 31*30
    clip: true

    property alias model: mazeRepeater.model

    Repeater {
        id: mazeRepeater
        delegate: Tile {
            type: modelData
            i: (index%28)
            j: (index/28)
        }
    }

    House {
        i: 10
        j: 12
    }

    function setTile(i,j,c) {
        var tile = mazeRepeater.itemAt(j*28+i)
        tile.type=c
    }

    function tile(i,j) {
        var tile = mazeRepeater.itemAt(j*28+i)
        return tile.type
    }

    function setDebugTile(i,j,color) {
        var tile = mazeRepeater.itemAt(j*28+i)
        tile.debugColor = color
    }

}
