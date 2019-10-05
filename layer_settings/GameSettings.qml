import QtQuick 2.8
import QtGraphicalEffects 1.0
import QtMultimedia 5.9
import QtQuick.Layouts 1.11
import "qrc:/qmlutils" as PegasusUtils
import "../layer_grid"
import "../utils.js" as Utils

Item {
  id: root

  property int padding: vpx(50)
  property int cornerradius: vpx(8)
  property int numbuttons: 4
  property int currentsetting: 0
  property int settingsetpoint: -1
  
  // settings values
  // ----------------------------------- Orange ----- Red ----- Purple -- Green ----- Blue ---- Yellow -- Sky Blue --- Brown------Black
  property var settingsHighlightColor: ["#FF9E12", "#CC0000", "#CC00CC", "#33CC33", "#3333FF", "#E6E600", "#66CCFF", "#996600"]
  property var settingsBackgroundColor: ["#CC7700", "#990000", "#800080", "#1F7A1F", "#000080", "#808000", "#005580", "#4d3300", "#000000"]
  property var settingsScrollSpeed: [200, 300, 500] //medium, fast, slow - used by flickable game description.
  property var settingsBackgroundArt: ["Default", "FanArt", "Screenshot", "Color"] //What to show in backgrounds, Default, FanArt, Screenshot, or highlight color.
  property var settingsGridTileArt: ["Wheel", "Tile", "Screenshot", "BoxArt", "Cartridge"] //What to show on the grid tiles, Tile, Wheel art, Screenshots, or box art.
  property var settingsUpdate: [0, 1] //perform theme update, 0 = no, 1 = yes.
  property var settingsGenesis: [0, 1] //Are we displaying Genesis instead of Megadrive, 1 = genesis.
  property var settingsUpdateCommand: "cd && cd /home/pi/.config/pegasus-frontend/themes/pegasus-theme-gpiOS && git pull"
  property var settingsList: ["GridTileArt", "BackgroundArt", "BackgroundColor", "HighlightColor", "Scrollspeed", "Genesis","UpdateTheme", "About"]
  property var settingsDescription: ["Game Grid Art: (What art for grid)", "Background Art: (What art for background)", "Background Color: (When background art is Color)", "Highlight Color: (Accent color)", "Description Scrolling: (speed)", "Show genesis/tg16 instead", "Updating the theme: (info about updating)", "About this theme"]
  
  signal settingsCloseRequested

  onFocusChanged: {
    if(focus) {
      nextBtn.focus = true
      currentsetting = 0;
      settingsetpoint = -1;
      refreshSetting();
    }
  }

  visible: (backgroundbox.opacity == 0) ? false : true

  // Empty area for closing out of bounds
  Item {
    anchors.fill: parent
    PegasusUtils.HorizontalSwipeArea {
        anchors.fill: parent
        onClicked: closesettings()
    }

  }

  Keys.onPressed: {
    
    if (event.isAutoRepeat)
      return;

    if (api.keys.isCancel(event)) {
      event.accepted = true;
      closesettings();
      return;
    }
    //Hack to check if it was the Gamepad Select button
    if (event.key.toString() == "1048586" && !event.isAutoRepeat) {
      event.accepted = true;
      closesettings();
      return;
    }
    
  }


  function closesettings() {
    settingsCloseRequested();
  }

    Rectangle {
      id: backgroundbox
      anchors {
        horizontalCenter: parent.horizontalCenter
        verticalCenter: parent.verticalCenter
      }
      width: parent.width - vpx(182)
      height: vpx(700)
      color: "#1a1a1a"//"#ee1a1a1a"
      radius: cornerradius
      opacity: 0
      Behavior on opacity { NumberAnimation { duration: 100 } }

      scale: 1.03
      Behavior on scale { NumberAnimation { duration: 100 } }
      // DropShadow
      layer.enabled: true
      layer.effect: DropShadow {
          horizontalOffset: 0
          verticalOffset: 0
          radius: 20.0
          samples: 17
          color: "#80000000"
          transparentBorder: true
      }

	
        // NOTE: Settings section
        Item {
          id: settings
          anchors {
            top: parent.top; topMargin: vpx(0)
            left: parent.left;
            leftMargin: vpx(5)
            bottom: parent.bottom; right: parent.right
          }

          Text {
            id: settingsTitle

            anchors { top: parent.top; topMargin: vpx(15) }
            width: parent.width
            text: "Theme Settings"
            color: "white"
            font.pixelSize: vpx(60)
            font.family: titleFont.name
            font.bold: true
            //font.capitalization: Font.AllUppercase
            elide: Text.ElideRight
            opacity: 1
          }

        
	Text {
            id: settingsDescBox

            anchors { top: settingsTitle.bottom; topMargin: vpx(60) }
            width: parent.width
            text: settingsDescription[currentsetting];
            color: "white"
            font.pixelSize: vpx(60)
            font.family: titleFont.name
            font.bold: true
            //font.capitalization: Font.AllUppercase
            elide: Text.ElideRight
            opacity: 1
        }

	Text {
            id: settingsValueBox

            anchors { top: settingsDescBox.bottom; topMargin: vpx(60) }
            width: parent.width
            text: "Current Value: " + currentsetting;
            color: "white"
            font.pixelSize: vpx(60)
            font.family: titleFont.name
            font.bold: true
            //font.capitalization: Font.AllUppercase
            elide: Text.ElideRight
            opacity: 1
	    wrapMode: Text.WordWrap
        }	
	
      

      // NOTE: Navigation
      Item {
        id: navigation
        anchors.fill: parent
        width: parent.width
        height: parent.height

        Rectangle {
          id: navigationbox
          anchors {
            bottom: parent.bottom;
            left: parent.left; right: parent.right;
          }
          color: "#16ffffff"
          width: parent.width
          height: vpx(80)

          // Buttons
          Row {
            id: panelbuttons
            width: parent.width
            height: parent.height
            anchors.fill: parent

             // Next button
            GamePanelButton {
              id: nextBtn
              text: "Next"
              width: parent.width/numbuttons
              height: parent.height

              onFocusChanged: {
                if (focus)
                  navSound.play()
              }

              KeyNavigation.left: closeBtn
              KeyNavigation.right: toggleBtn
              Keys.onPressed: {
                if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                  event.accepted = true;
                  nextSetting();
                }
              }
              onClicked: {
                focus = true
                nextSetting();
		}
              }
            Rectangle {
              width: vpx(1)
              height: parent.height
              color: "#1a1a1a"
            }

	    
	    // Toggle button
            GamePanelButton {
              id: toggleBtn
              text: "Toggle"
              width: parent.width/numbuttons
              height: parent.height

              onFocusChanged: {
                if (focus)
                  navSound.play()
              }

              KeyNavigation.left: nextBtn
              KeyNavigation.right: applyBtn
              Keys.onPressed: {
                  if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                      event.accepted = true;
                      toggleSetting();
                  }
              }

              onClicked: {
                  focus = true;
                  toggleSetting();
              }

            }

            Rectangle {
              width: vpx(1)
              height: parent.height
              color: "#1a1a1a"
            }
	    
	    // Apply button
            GamePanelButton {
              id: applyBtn
              text: "Apply"
              width: parent.width/numbuttons
              height: parent.height

              onFocusChanged: {
                if (focus) {
                  navSound.play()
                }
              }

              KeyNavigation.left: toggleBtn
              KeyNavigation.right: closeBtn
              Keys.onPressed: {
                if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                  event.accepted = true;
                  applySetting();
                }
              }
              onClicked: {
                focus = true;
                applySetting();
              }
            }

            Rectangle {
              width: vpx(1)
              height: parent.height
              color: "#1a1a1a"
            }
	    

            // Close button
            GamePanelButton {
              id: closeBtn
              text: "Close"
              width: parent.width/numbuttons
              height: parent.height
              onFocusChanged: {
                if (focus)
                  navSound.play()
              }

              KeyNavigation.left: applyBtn
              KeyNavigation.right: nextBtn
              Keys.onPressed: {
                if (api.keys.isAccept(event) && !event.isAutoRepeat) {
                  event.accepted = true;
                  closesettings();
                }
              }
              onClicked: {
                focus = true;
                closesettings();
              }
            }

          }
        }


        // Round those corners!
        layer.enabled: true
        layer.effect: OpacityMask {
          maskSource: Item {
            width: navigation.width
            height: navigation.height
            Rectangle {
              anchors.centerIn: parent
              width: navigation.width
              height: navigation.height
              radius: cornerradius
            }
          }
        }
      }
    

      // Empty area for swiping on touch
      Item {
        anchors.fill: parent
        PegasusUtils.HorizontalSwipeArea {
            anchors { top: parent.top; left: parent.left; right: parent.right; bottom: parent.bottom; bottomMargin: vpx(60) }
            //visible: root.focus
            //onSwipeRight: if (showVideo) { toggleVideo() }
            //onSwipeLeft: if (!showVideo) { toggleVideo() }
            //onClicked: toggleVideo()
        }

      }

        }
    }

    function intro() {
        backgroundbox.opacity = 1;
        backgroundbox.scale = 1;
        menuIntroSound.play()
    }

    function outro() {
        backgroundbox.opacity = 0;
        backgroundbox.scale = 1.03;
        menuIntroSound.play()
    }
    
    //settings menu functions
    function nextSetting() {
	    if (currentsetting <= (settingsList.length - 1)) {
		    currentsetting++;
		    settingsetpoint = -1;
		  }
		  if (currentsetting == settingsList.length) {
		    currentsetting = 0;
		    settingsetpoint = -1;
		  }
		  refreshSetting();
	  }

	  function refreshSetting() {
		  settingsValueBox.text = "Press Next or Toggle button.";
		  settingsValueBox.color = "white";
	    settingsDescBox.text = settingsDescription[currentsetting];
	  }
	
	  function toggleSetting() {
	    switch (currentsetting) {

      case 0: {
        // Game Grid Art toggle: Wheel, Tile, Screenshot, BoxArt, Cartridge
		    if (settingsetpoint <= (settingsGridTileArt.length - 1)) {
		      settingsetpoint++;
		    }
		    if (settingsetpoint == settingsGridTileArt.length) {
		      settingsetpoint = 0;
		    }
		    settingsDescBox.text = settingsDescription[currentsetting];
		    if (settingsGridTileArt[settingsetpoint] == "Tile") { settingsValueBox.text = "STEAM TILE";}
		    if (settingsGridTileArt[settingsetpoint] == "Wheel") { settingsValueBox.text = "WHEEL ART";}
		    if (settingsGridTileArt[settingsetpoint] == "Screenshot") { settingsValueBox.text = "SCREENSHOT";}
        if (settingsGridTileArt[settingsetpoint] == "BoxArt") { settingsValueBox.text = "BOX ART";}
		    if (settingsGridTileArt[settingsetpoint] == "Cartridge") { settingsValueBox.text = "CARTRIDGE";}
		    break;
      }
      case 1: {
        // Background Art toggle: Default, FanArt, Screenshot, Color
		    if (settingsetpoint <= (settingsBackgroundArt.length - 1)) {
		      settingsetpoint++;
		    }
		    if (settingsetpoint == settingsBackgroundArt.length) {
		      settingsetpoint = 0;
		    }
		    settingsDescBox.text = settingsDescription[currentsetting];
		    if (settingsBackgroundArt[settingsetpoint] == "Default") { settingsValueBox.text = "DEFAULT IMAGE";}
		    if (settingsBackgroundArt[settingsetpoint] == "FanArt") { settingsValueBox.text = "FAN ART";}
		    if (settingsBackgroundArt[settingsetpoint] == "Screenshot") { settingsValueBox.text = "SCREENSHOT";}
        if (settingsBackgroundArt[settingsetpoint] == "Color") { settingsValueBox.text = "COLOR";}
		    break;
      }
      case 2: {
        // Change Background Color toggle
		    if (settingsetpoint <= (settingsBackgroundColor.length - 1)) {
		      settingsetpoint++;
		    }
		    if (settingsetpoint == settingsBackgroundColor.length) {
		      settingsetpoint = 0;
		    }
		    settingsDescBox.text = settingsDescription[currentsetting];
		    settingsValueBox.color = settingsBackgroundColor[settingsetpoint];
		    settingsValueBox.text = "color: " + settingsBackgroundColor[settingsetpoint];
        break;
      }
      case 3: {
        // Change Highlight Color toggle
		    if (settingsetpoint <= (settingsHighlightColor.length - 1)) {
		      settingsetpoint++;
		    }
		    if (settingsetpoint == settingsHighlightColor.length) {
		      settingsetpoint = 0;
		    }
		    settingsDescBox.text = settingsDescription[currentsetting];
		    settingsValueBox.color = settingsHighlightColor[settingsetpoint];
		    settingsValueBox.text = "color: " + settingsHighlightColor[settingsetpoint];
        break;
      }
      case 4: {
        // Description Scroll Speed toggle
		    if (settingsetpoint <= (settingsScrollSpeed.length - 1)) {
		      settingsetpoint++;
		    }
		    if (settingsetpoint == settingsScrollSpeed.length) {
		      settingsetpoint = 0;
		    }
		    settingsDescBox.text = settingsDescription[currentsetting];
		    if (settingsScrollSpeed[settingsetpoint] == 200) { settingsValueBox.text = "SLOW";}
		    if (settingsScrollSpeed[settingsetpoint] == 300) { settingsValueBox.text = "MEDIUM";}
		    if (settingsScrollSpeed[settingsetpoint] == 500) { settingsValueBox.text = "FAST";}
        break;
      }
      case 5: {
        //Show Genesis? toggle
		    if (settingsetpoint < (settingsGenesis.length)) {
		      settingsetpoint++;
		    }
		    if (settingsetpoint == settingsGenesis.length) {
		      settingsetpoint = 0;
		    }
		    settingsDescBox.text = settingsDescription[currentsetting];
		    if (settingsGenesis[settingsetpoint] == 0) { settingsValueBox.text = "NO";}
		    if (settingsGenesis[settingsetpoint] == 1) { settingsValueBox.text = "YES";}
        break;
      }
      case 6: {
        //Perform Theme Update? toggle
		    if (settingsetpoint < (settingsUpdate.length)) {
		      settingsetpoint++;
		    }
		    if (settingsetpoint == settingsUpdate.length) {
		      settingsetpoint = 0;
		    }
		    settingsDescBox.text = settingsDescription[currentsetting];
		    if (settingsUpdate[settingsetpoint] == 0) { settingsValueBox.text = "NO";}
		    if (settingsUpdate[settingsetpoint] == 1) { settingsValueBox.text = "YES";}
        break;
      }
      case 7: {
        //Show About information? toggle
		    if (settingsetpoint < (settingsUpdate.length)) {
		      settingsetpoint++;
		    }
		    if (settingsetpoint == settingsUpdate.length) {
		      settingsetpoint = 0;
		    }
		    settingsDescBox.text = settingsDescription[currentsetting];
		    if (settingsUpdate[settingsetpoint] == 0) { settingsValueBox.text = "NO";}
		    if (settingsUpdate[settingsetpoint] == 1) { settingsValueBox.text = "YES";}
        break;
      }
      default: {
	 	    settingsValueBox.color = "white";
	 	    settingsValueBox.text = "Something Went Wrong!";
		    settingsetpoint = -1;
        break;
      }
    }
	
	}
	

	function applySetting() {
		//apply and save.
		if (settingsetpoint == -1) {return;}
		switch (currentsetting) {
      
      case 0: {
        //What art to show on the game grid tiles? Apply and save
		    gamesettings.gridart = settingsGridTileArt[settingsetpoint];
		    api.memory.set('settingsGridTileArt', gamesettings.gridart) 
		    settingsValueBox.text = "Setting Saved!";
		    settingsetpoint = -1;
        break;
      }
      case 1: {
        // Background Art Apply and save
		    gamesettings.backgroundart = settingsBackgroundArt[settingsetpoint];
		    api.memory.set('settingsBackgroundArt', gamesettings.backgroundart)
		    settingsValueBox.text = "Setting Saved!";
		    settingsetpoint = -1;
        break;
      }
      case 2: {
        // Change Background Color Apply and save
		    gamesettings.backcolor = settingsBackgroundColor[settingsetpoint];
		    api.memory.set('settingsBackgroundColor', gamesettings.backcolor)
		    settingsValueBox.color = "white";
		    settingsValueBox.text = "Setting Saved!";
		    settingsetpoint = -1;
        break;
      }
	    case 3: {
        // Change Highlight Color Apply and save
		    gamesettings.highlight = settingsHighlightColor[settingsetpoint];
		    api.memory.set('settingsHighlight', gamesettings.highlight)
		    settingsValueBox.color = "white";
		    settingsValueBox.text = "Setting Saved!";
		    settingsetpoint = -1;
        break;
      }
      case 4: {
        // Description Scroll Speed Apply and save
		    gamesettings.scrollSpeed = settingsScrollSpeed[settingsetpoint];
		    api.memory.set('settingScrollSpeed', gamesettings.scrollSpeed)
		    settingsValueBox.text = "Setting Saved!";
		    settingsetpoint = -1;
        break;
      }
      case 5: {
        // Show Genesis Apply and save
		    gamesettings.genesis = settingsGenesis[settingsetpoint];
		    api.memory.set('settingsGenesis', gamesettings.genesis)
		    settingsValueBox.text = "Setting Saved!";
		    settingsetpoint = -1;
        break;
      }
      case 6: {
        //Perform Theme Update? Apply and save
		    settingsValueBox.text = "Please manually update by running the command:\n" + settingsUpdateCommand;
		    settingsetpoint = -1;
        break;
      }
      case 7: {
        //Display About Information?
		    settingsValueBox.text = "Original by PlayingKarrde, modded for Gpi by SinisterSpatula\nGithub.com/SinisterSpatula\nfacebook.com/groups/GPiUsers";
		    settingsetpoint = -1;
        break;
      }
      default: {
	 	    settingsValueBox.color = "white";
	 	    settingsValueBox.text = "Something Went wrong!";
		    settingsetpoint = -1;
        break;
      }
    }
	}
	
}
