import QtQuick 2.8
import QtGraphicalEffects 1.0
import QtMultimedia 5.9


Rectangle {
  id: root
  property var collection//: api.collections.current
  property var backgroundcontainer

  color: "black"
  opacity: 0

  SequentialAnimation {
    id: switchanimation;
    OpacityAnimator { target: switchoverlay; from: 0; to: 0.94; duration: 1; }
    OpacityAnimator { target: logo; from: 0; to: 1.0; duration: 100; }
    PauseAnimation { duration: 1000; } //duration: 300;
    OpacityAnimator { target: switchoverlay; from: 0.54; to: 0; duration: 300; }
  }

  Image {
    id: logo

    width: parent.width //vpx(600)
    height: parent.height
    sourceSize { width: 512; height: 512 }
    fillMode: Image.PreserveAspectFit
    source: {
      if (collection.shortName == "megadrive" && gamesettings.genesis == 1)
        "../assets/images/logos/genesis.svg"
      else if (collection.shortName == "pcengine" && gamesettings.genesis == 1)
        "../assets/images/logos/turbografx16.svg"
      else
        "../assets/images/logos/" + collection.shortName + ".svg"
    }
    asynchronous: true
    anchors.centerIn: parent
    opacity: 0
  }

  Text {
    id: gameTitle

    anchors { top: parent.top; topMargin: vpx(60)}
    width: parent.width
    text: collection.name
    color: "white"
    font.pixelSize: vpx(140) //vpx(70)
    font.family: titleFont.name
    font.bold: true
    font.capitalization: Font.AllUppercase
    anchors.centerIn: parent
    elide: Text.ElideRight
    wrapMode: Text.WordWrap
    horizontalAlignment: Text.AlignHCenter
    visible: (logo.status == Image.Error)
  }


  onCollectionChanged: {
    logo.opacity = 0
    switchanimation.restart()
    switchanimation.running = true
  }
}
