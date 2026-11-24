import QtQuick 2.5

Rectangle {
    property int i: 0
    property int j: 0
    property string borderColor: "white"

    x: i*30+5
    y: j*30+5
    width: 20
    height: 20
    radius: 10
    color: "transparent"
    border.width: 2
    border.color: borderColor
}
