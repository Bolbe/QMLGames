import QtQuick 2.5
import QtQuick.Particles 2.0

Item {
    id: tetromino

    property int minoSize: 30
    // I 	J 	L 	O 	S 	Z 	T
    property string letter: "J"
    readonly property var letterList: ["I","O","J","L","S","T","Z"]
    property int letterIndex: 0
    property int squareSize: letter==="I" ? 4: letter==="O" ? 2: 3
    property int i: 0
    property int j: 0

    property int rot: 1000

    width: minoSize*squareSize
    height: width

    x: minoSize*i
    y: 720-minoSize*j-height


    function nextLetter() {
        letterIndex++
        if (letterIndex==letterList.length) letterIndex=0
        letter = letterList[letterIndex]
    }

    /*
       ---- -■-- ---- --■--
       ---- -■-- ---- --■--
       ---- -■-- ---- --■--
       ■■■■ -■-- ■■■■ --■--
    */
    readonly property var tetroI:   [[[0,3],[1,3],[2,3],[3,3]],
                                    [[1,0],[1,1],[1,2],[1,3]],
                                    [[3,3],[2,3],[1,3],[0,3]],
                                    [[2,3],[2,2],[2,1],[2,0]]]

    /*
        ■■ ■■ ■■ ■■
        ■■ ■■ ■■ ■■
    */
    readonly property var tetroO:   [[[0,0],[1,0],[1,1],[0,1]],
                                    [[1,0],[1,1],[0,1],[0,0]],
                                    [[1,1],[0,1],[0,0],[1,0]],
                                    [[0,1],[0,0],[1,0],[1,1]]]

    /*
        --- ■■- --- -■-
        ■-- ■-- ■■■ -■-
        ■■■ ■-- --■ ■■-
    */
    readonly property var tetroJ:       [[[0,1],[0,2],[1,2],[2,2]],
                                        [[1,0],[0,0],[0,1],[0,2]],
                                        [[2,2],[2,1],[1,1],[0,1]],
                                        [[0,2],[1,2],[1,1],[1,0]]]

    /*
        --- ■-- --- ■■-
        --■ ■-- ■■■ -■-
        ■■■ ■■- ■-- -■-
    */
    readonly property var tetroL:       [[[2,1],[2,2],[1,2],[0,2]],
                                        [[1,2],[0,2],[0,1],[0,0]],
                                        [[0,2],[0,1],[1,1],[2,1]],
                                        [[0,0],[1,0],[1,1],[1,2]]]

    /*
        --- ■-- --- ■--
        -■■ ■■- -■■ ■■-
        ■■- -■- ■■- -■-
    */
    readonly property var tetroS:       [[[0,2],[1,2],[1,1],[2,1]],
                                        [[0,0],[0,1],[1,1],[1,2]],
                                        [[2,1],[1,1],[1,2],[0,2]],
                                        [[1,2],[1,1],[0,1],[0,0]]]

    /*
        --- ■-- --- -■-
        -■- ■■- ■■■ ■■-
        ■■■ ■-- -■- -■-
    */
    readonly property var tetroT:       [[[1,1],[0,2],[1,2],[2,2]],
                                        [[1,1],[0,0],[0,1],[0,2]],
                                        [[1,2],[2,1],[1,1],[0,1]],
                                        [[0,1],[1,2],[1,1],[1,0]]]
    /*
        --- -■- --- -■-
        ■■- ■■- ■■- ■■-
        -■■ ■-- -■■ ■--
    */
    readonly property var tetroZ:       [[[0,1],[1,1],[1,2],[2,2]],
                                        [[1,0],[1,1],[0,1],[0,2]],
                                        [[2,2],[1,2],[1,1],[0,1]],
                                        [[0,2],[0,1],[1,1],[1,0]]]


    property var tetro: letter==="I" ? tetroI :
                        letter==="J" ? tetroJ :
                        letter==="L" ? tetroL :
                        letter==="O" ? tetroO :
                        letter==="S" ? tetroS :
                        letter==="Z" ? tetroZ :
                        letter==="T" ? tetroT :
                        tetroJ

    Mino {
        size: minoSize
        letter: tetromino.letter
        i: tetro[rot%4][0][0]
        j: tetro[rot%4][0][1]
        rotationStep: rot
    }

    Mino {
        size: minoSize
        letter: tetromino.letter
        i: tetro[rot%4][1][0]
        j: tetro[rot%4][1][1]
        rotationStep: rot
    }

    Mino {
        size: minoSize
        letter: tetromino.letter
        i: tetro[rot%4][2][0]
        j: tetro[rot%4][2][1]
        rotationStep: rot
    }

    Mino {
        size: minoSize
        letter: tetromino.letter
        i: tetro[rot%4][3][0]
        j: tetro[rot%4][3][1]
        rotationStep: rot
    }

    Component.onCompleted: {
        console.log("tetro:"+tetro)
        var i = [1,2,3]
        console.log("tetromino y:"+y)
    }


}
