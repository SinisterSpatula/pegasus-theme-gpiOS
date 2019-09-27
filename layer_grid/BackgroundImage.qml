import QtQuick 2.8
import QtGraphicalEffects 1.0

Item {
  id: root
  property var gameData//: currentCollection.games.get(gameList.currentIndex)
  property real dimopacity: 0.54 //0.96

  property string bgDefault: '../assets/images/defaultbg.png'
  property string bgSource: (gamesettings.backgroundart == "FanArt" && gameData.assets.background) ? gameData.assets.background : (gamesettings.backgroundart == "Screenshot" && gameData.assets.screenshots[0]) ? gameData.assets.screenshots[0] : (gamesettings.backgroundart == "Default") ? bgDefault : (gamesettings.backgroundart == "Color") ? "" : bgDefault

  Item {
    id: bg

    anchors.fill: parent


    Image {
        id: rect
        anchors.fill: parent
        visible: gameData
        asynchronous: true
        source: bgSource
        sourceSize { width: 320; height: 240 }
        fillMode: Image.PreserveAspectCrop
        smooth: false
    }

    //state: "fadeInRect2"

  }

    Rectangle {
    id: backgroundcolor
    anchors.fill: parent
    color: gamesettings.backcolor
    opacity: 1.0
    z: rect.z + 1
    visible: (gamesettings.backgroundart == "Color")
  }


  LinearGradient {
    z: parent.z + 2
    width: parent.width
    height: parent.height
    anchors {
      top: parent.top; topMargin: vpx(200)
      right: parent.right
      bottom: parent.bottom
    }
    start: Qt.point(0, 0)
    end: Qt.point(0, height)
    gradient: Gradient {
      GradientStop { position: 0.0; color: "#00000000" }
      GradientStop { position: 0.7; color: "#ff000000" }
    }
  }
  

  Rectangle {
    id: backgrounddim
    anchors.fill: parent
    color: "#15181e" //15181e //697796

    opacity: dimopacity

    Behavior on opacity { NumberAnimation { duration: 100 } }
  }



}
