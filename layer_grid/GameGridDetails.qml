import QtQuick 2.8
import QtQuick.Layouts 1.11
import QtGraphicalEffects 1.0
import "../utils.js" as Utils

Item {
  id: root

  property var collectionData //is our currentCollection
  property bool issteam: false
  anchors.horizontalCenter: parent.horizontalCenter
  clip: true


  Text {
    id: collectionName

    anchors {
      //verticalCenter: parent.verticalCenter
      fill: parent
      top: parent.top
      //topMargin: vpx(10)
    }
    width: parent.width //vpx(1080) //vpx(850)
    text: collectionData.name
    color: "white"
    font.pixelSize: vpx(100) //vpx(70)
    font.family: titleFont.name
    font.bold: true
    //font.capitalization: Font.AllUppercase
    elide: Text.ElideRight
    wrapMode: Text.WordWrap
    lineHeightMode: Text.FixedHeight
    lineHeight: vpx(90)
    //visible: (collectionData.assets.logo == "") ? true : false
    style: Text.Outline; styleColor: "#cc000000"
  }

  
}
