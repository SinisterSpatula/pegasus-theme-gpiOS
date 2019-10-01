import QtQuick 2.8
import QtGraphicalEffects 1.0
import QtMultimedia 5.9
import "qrc:/qmlutils" as PegasusUtils

Item {
  id: root

  signal alphaCloseRequested

  property alias alphawidth: alphabar.width

  Keys.onLeftPressed: closeMenu()
  Keys.onRightPressed: closeMenu()
  Keys.onUpPressed: alphaList.decrementCurrentIndex()
  Keys.onDownPressed: alphaList.incrementCurrentIndex()

  Keys.onPressed: {
      if (event.isAutoRepeat)
          return;
      if (api.keys.isAccept(event)) {
          event.accepted = true;
          gamegrid.jumpTheGrid(lettersList[alphaList.currentIndex]);
          closeMenu();
          return;
      }
      if (api.keys.isCancel(event)) {
        event.accepted = true;
        closeMenu();
          return;
      }
      if (api.keys.isFilters(event)) {
        event.accepted = true;
        alphaCloseRequested();
        return;
      }
      return;
  }

  function closeMenu() {
    alphaCloseRequested();
  }

  property var backgroundcontainer
  property var lettersList: ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]

  width: parent.width
  height: parent.height

  Item {
    id: alphabg
    x: -width
    Behavior on x {
      PropertyAnimation {
        duration: 300;
        easing.type: Easing.OutQuart;
        easing.amplitude: 2.0;
        easing.period: 1.5
      }
    }

    width: vpx(250)
    height: parent.height

    PegasusUtils.HorizontalSwipeArea {
        anchors.fill: parent
        onSwipeLeft: closeMenu()
    }

    Rectangle {
      id: alphabar
      property real contentWidth: width - vpx(100)

      width: parent.width
      height: parent.height
      color: "#000"
      opacity: 0

      }

      // Highlight
      Component {
        id: highlight
        Rectangle {
          width: alphaList.cellWidth; height: alphaList.cellHeight
          color: gamesettings.highlight
          x: alphaList.currentItem.x
          y: alphaList.currentItem.y
          Behavior on y { NumberAnimation {
            duration: 300;
            easing.type: Easing.OutQuart;
            easing.amplitude: 2.0;
            easing.period: 1.5}
          }
        }
      }

      // Menu
      ListView {
        id: alphaList
        width: parent.width

        preferredHighlightBegin: vpx(160); preferredHighlightEnd: vpx(160)
        highlightRangeMode: ListView.ApplyRange

        anchors {
          top: parent.top; topMargin: vpx(140)
          left: parent.left;
          right: parent.right
          bottom: parent.bottom; bottomMargin: vpx(160)
        }

        model: lettersList

        delegate: alphaListItemDelegate
        highlight: highlight
        highlightFollowsCurrentItem: true
        focus: true
      }

      // Menu item
      Component {
        id: alphaListItemDelegate

        Item {
          id: menuitem
          readonly property bool selected: ListView.isCurrentItem
          width: alphabar.width
          height: vpx(160)

          Text {
            text: {
                modelData
            }

            anchors.centerIn: parent // { left: parent.left; leftMargin: vpx(50)}
            color: selected ? "#fff" : "#666"
            Behavior on color {
              ColorAnimation {
                duration: 200;
                easing.type: Easing.OutQuart;
                easing.amplitude: 2.0;
                easing.period: 1.5
              }
            }
            font.pixelSize: vpx(160)
            font.family: titleFont.name
            //font.capitalization: Font.AllUppercase
            font.bold: true
            height: vpx(160)
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            style: Text.Outline; styleColor: "black"
          }
        }
    }
    LinearGradient {
          width: vpx(2)
          height: parent.height
          anchors {
              top: parent.top
              right: parent.right
              bottom: parent.bottom
          }
          /*start: Qt.point(0, 0)
          end: Qt.point(0, height)*/
          gradient: Gradient {
              GradientStop { position: 0.0; color: "#00ffffff" }
              GradientStop { position: 0.5; color: "#ffffffff" }
              GradientStop { position: 1.0; color: "#00ffffff" }
          }
          opacity: 0.2
      }

  }

  MouseArea {
      anchors {
          top: parent.top; left: alphabg.right
          bottom: parent.bottom; right: parent.right

      }
      onClicked: {toggleAlpha()}
      visible: parent.focus
  }

  function intro() {
      //bgblur.opacity = 1;
      alphabg.x = 0;
      menuIntroSound.play()
  }

  function outro() {
      //bgblur.opacity = 0;
      alphabg.x = -alphabar.width;
      menuIntroSound.play()
  }

}
