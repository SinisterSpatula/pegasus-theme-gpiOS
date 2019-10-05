// vgOS Frontend

import QtQuick 2.8
import QtGraphicalEffects 1.0
import QtMultimedia 5.9
import SortFilterProxyModel 0.2
import "qrc:/qmlutils" as PegasusUtils
import "layer_grid"
import "layer_menu"
import "layer_details"
import "layer_settings"

FocusScope {

  SortFilterProxyModel {
    id: lastPlayedFilter
    sourceModel: api.allGames
    sorters: RoleSorter {
      roleName: "lastPlayed"
      sortOrder: Qt.DescendingOrder
    }
  }

  SortFilterProxyModel {
    id: lastPlayedGames
    sourceModel: lastPlayedFilter
    filters: IndexFilter {
      maximumIndex: 49
    }
  }

  SortFilterProxyModel {
    id: favoriteGames
    sourceModel: api.allGames
    filters: ValueFilter {
      roleName: "favorite"
      value: true
    }
  }

  property var favoritesCollection: {
    return {
      name: "Favorites",
      shortName: "favorites",
      games: favoriteGames,
    }
  }

  property var lastPlayedCollection: {
    return {
      name: "Last Played",
      shortName: "lastplayed",
      games: lastPlayedGames,
    }
  }
  //form a collection which contains our favorites, last played, and all real collections.
  property var dynamicCollections: [favoritesCollection, lastPlayedCollection, ...api.collections.toVarArray()]
  
  
  // Loading the fonts here makes them usable in the rest of the theme
  // and can be referred to using their name and weight.
  FontLoader { id: titleFont; source: "fonts/AkzidenzGrotesk-BoldCond.otf" }
  FontLoader { id: subtitleFont; source: "fonts/Gotham-Bold.otf" }

  property bool menuactive: false

  //////////////////////////
  // Collection switching //

  function modulo(a,n) {
    return (a % n + n) % n;
  }

  property int collectionIndex: 0
  property var currentCollection: (collectionIndex >= 2) ? api.collections.get((collectionIndex - 2)) : (collectionIndex == 0) ? favoritesCollection : lastPlayedCollection
  property var backgndImage
  property string bgDefault: '../assets/images/defaultbg.png'
  property string bgArtSetting: api.memory.get('settingsBackgroundArt') || "Default";

  function nextCollection () {
    jumpToCollection(collectionIndex + 1);
  }

  function prevCollection() {
    jumpToCollection(collectionIndex - 1);
  }

  function jumpToCollection(idx) {
    api.memory.set('gameCollIndex' + collectionIndex, currentGameIndex); // save game index of current collection
    collectionIndex = modulo(idx, (api.collections.count + 2)); // new collection index
    currentGameIndex = api.memory.get('gameCollIndex' + collectionIndex) || 0; // restore game index for newly selected collection
    api.memory.set('collectionIndex', collectionIndex); //save the new collection index.
  }

  // End collection switching //
  //////////////////////////////

  ////////////////////
  // Game switching //

  property int currentGameIndex: 0
  readonly property var currentGame: (collectionIndex >= 2) ? currentCollection.games.get(currentGameIndex) : api.allGames.get(findCurrentGameFromProxy(currentGameIndex, collectionIndex))

  function findCurrentGameFromProxy (idx, collidx) {
    if (collidx == 0) {
      return favoriteGames.mapToSource(idx);
    }
    if (collidx == 1) {
      return lastPlayedFilter.mapToSource((lastPlayedGames.mapToSource(idx)));
    }
    return;
  }

  function changeGameIndex (idx) {
    currentGameIndex = idx
    if (collectionIndex && idx) {
    api.memory.set('gameIndex' + collectionIndex, idx);
    }
  }

  // End game switching //
  ////////////////////////

  ////////////////////
  // Launching game //

  Component.onCompleted: {
    collectionIndex = api.memory.get('collectionIndex') || 0;
    currentGameIndex = api.memory.get('gameCollIndex' + collectionIndex) || 0;
    gamesettings.highlight = api.memory.get('settingsHighlight') || "#FF9E12";
    gamesettings.backcolor = api.memory.get('settingsBackgroundColor') || "#CC7700";
    gamesettings.scrollSpeed = api.memory.get('settingScrollSpeed') || 300;
    gamesettings.backgroundart = api.memory.get('settingsBackgroundArt') || "Default";
    gamesettings.gridart = api.memory.get('settingsGridTileArt') || "Screenshot";
    gamesettings.genesis = api.memory.get('settingsGenesis') || 0;
    
    if (!api.memory.has('settingsHighlight')) {api.memory.set('settingsHighlight', gamesettings.highlight)}
    if (!api.memory.has('settingsBackgroundColor')) {api.memory.set('settingsBackgroundColor', gamesettings.backcolor)}
    if (!api.memory.has('settingScrollSpeed')) {api.memory.set('settingScrollSpeed', gamesettings.scrollSpeed)}
    if (!api.memory.has('settingsBackgroundArt')) {api.memory.set('settingsBackgroundArt', gamesettings.backgroundart)}
    if (!api.memory.has('settingsGridTileArt')) {api.memory.set('settingsGridTileArt', gamesettings.gridart)}
    if (!api.memory.has('settingsGenesis')) {api.memory.set('settingsGenesis', gamesettings.genesis)}
  }
  

  function launchGame() {
    api.memory.set('collectionIndex', collectionIndex);
    api.memory.set('gameCollIndex' + collectionIndex, currentGameIndex);
    currentGame.launch();
  }

  // End launching game //
  ////////////////////////

    function setBackground() {
    //set the background Art to user preference.
    if (!currentGame) {
      backgndImage = (bgArtSetting == "Color") ? "" : bgDefault; 
      return;
    }
    else if (bgArtSetting == "FanArt" && currentGame.assets.background) { backgndImage = currentGame.assets.background }
    else if (bgArtSetting == "Screenshot" && currentGame.assets.screenshots[0]) { backgndImage = currentGame.assets.screenshots[0] }
    else if (bgArtSetting == "Color") { backgndImage = "" }
    else {backgndImage = bgDefault }
    return;
    }
  
  function toggleMenu() {

    if (platformmenu.focus) {
      // Close the menu
      gamegrid.focus = true
      platformmenu.outro()
      content.opacity = 1
      contentcontainer.opacity = 1
      contentcontainer.x = 0
      collectiontitle.opacity = 1
    } else {
      // Open the menu
      platformmenu.focus = true
      platformmenu.intro()
      content.opacity = 0.3
      contentcontainer.opacity = 0.3
      contentcontainer.x = platformmenu.menuwidth
      collectiontitle.opacity = 0
    }

  }

  function toggleAlpha() {

    if (alphamenu.focus) {
      // Close the alphabet menu
      gamegrid.focus = true
      alphamenu.outro()
      content.opacity = 1
      contentcontainer.opacity = 1
      contentcontainer.x = 0
      collectiontitle.opacity = 1
    } else {
      // Open the menu
      alphamenu.focus = true
      alphamenu.intro()
      content.opacity = 0.3
      contentcontainer.opacity = 0.3
      contentcontainer.x = alphamenu.alphawidth
      collectiontitle.opacity = 0
    }

  }

  function toggleDetails() {
    if (gamedetails.active) {
      // Close the details
      gamegrid.focus = true
      gamegrid.visible = true
      content.opacity = 1
      backgroundimage.dimopacity = 0.54 //0.97
      gamedetails.active = false
      gamedetails.outro()
    } else {
      // Open details panel
      gamedetails.focus = true
      gamedetails.active = true
      gamegrid.visible = false
      content.opacity = 0
      backgroundimage.dimopacity = 0
      gamedetails.intro()
    }
  }
  
    function toggleSettings() {
    if (gamesettings.active) {
      // Close the settings
      gamegrid.focus = true
      gamegrid.visible = true
      content.opacity = 1
      backgroundimage.dimopacity = 0.54 //0.97
      gamesettings.active = false
      gamesettings.outro()
    } else {
      // Open settings panel
      gamesettings.focus = true
      gamesettings.active = true
      gamegrid.visible = false
      content.opacity = 0
      backgroundimage.dimopacity = 0
      gamesettings.intro()
    }
  }

  Item {
    id: everythingcontainer
    anchors {
      left: parent.left; right: parent.right
      top: parent.top; bottom: parent.bottom
    }
    width: parent.width
    height: parent.height

    BackgroundImage {
      id: backgroundimage
      anchors {
        left: parent.left; right: parent.right
        top: parent.top; bottom: parent.bottom
      }
      backgndImageinternal: backgndImage

    }

    Item {
      id: contentcontainer

      width: parent.width
      height: parent.height

      Behavior on x {
        PropertyAnimation {
          duration: 300;
          easing.type: Easing.OutQuart;
          easing.amplitude: 2.0;
          easing.period: 1.5
        }
      }

      Image {
        id: menuicon
        source: "assets/images/menuicon.svg"
        width: vpx(24)
        height: vpx(24)
        anchors { top: parent.top; topMargin: vpx(32); left: parent.left; leftMargin: vpx(32) }
        visible: false
      }

      Text {
        id: collectiontitle

        anchors {
          top: parent.top; topMargin: vpx(35);
          //horizontalCenter: menuicon.horizontalCenter
          left: menuicon.right; leftMargin: vpx(35)
        }

        Behavior on opacity { NumberAnimation { duration: 100 } }

        width: parent.width
        //  text: (api.filters.current.enabled) ? api.currentCollection.name + " | Favorites" : api.currentCollection.name
        color: "white"
        font.pixelSize: vpx(16)
        font.family: globalFonts.sans
        //font.capitalization: Font.AllUppercase
        elide: Text.ElideRight
        //opacity: 0.5

        // DropShadow
        layer.enabled: true
        layer.effect: DropShadow {
            horizontalOffset: 0
            verticalOffset: 0
            radius: 8.0
            samples: 17
            color: "#80000000"
            transparentBorder: true
        }
      }


      // Game details
      GameGridDetails {
        id: content

        collectionData: currentCollection

        height: vpx(200)
        width: parent.width - vpx(182)
        anchors { top: menuicon.bottom; topMargin: vpx(-20)}

        // Text doesn't look so good blurred so fade it out when blurring
        opacity: 1
        Behavior on opacity { OpacityAnimator { duration: 100 } }
      }


      // Game grid
      Item {
        id: gridcontainer
        clip: true

        width: parent.width
        //height: parent.height * 0.1

        anchors {
          top: content.bottom; //topMargin: vpx(75)
          //top: parent.top;
          bottom: parent.bottom;
          left: parent.left; right: parent.right
        }

        GameGrid {
          id: gamegrid

          collectionData: currentCollection
          gameData: (currentGame) ? currentGame : api.allGames.get(0)
          currentGameIdx: currentGameIndex

          focus: true
          Behavior on opacity { OpacityAnimator { duration: 100 } }
          gridWidth: parent.width - vpx(80) //- vpx(164)
          height: parent.height

          anchors {
            top: parent.top; topMargin: vpx(10)
            bottom: parent.bottom;
            left: parent.left; right: parent.right
          }

          onLaunchRequested: launchGame()
          onCollectionNext: nextCollection()
          onCollectionPrev: prevCollection()
          onMenuRequested: toggleMenu()
          onAlphaRequested: toggleAlpha()
          onDetailsRequested: toggleDetails()
          onSettingsRequested: toggleSettings()
          onGameChanged: changeGameIndex(currentIdx)
        }
      }


      GameDetails {
        id: gamedetails

        property bool active : false
        gameData: (currentGame) ? currentGame : api.allGames.get(0)

        anchors {
          left: parent.left; right: parent.right
          top: parent.top; bottom: parent.bottom
        }
        width: parent.width
        height: parent.height

        onDetailsCloseRequested: toggleDetails()
        onLaunchRequested: launchGame()

      }
      
      
      GameSettings {
        id: gamesettings

        property bool active : false
        property var highlight
        property var backcolor
        property int scrollSpeed
        property var backgroundart
        property var gridart
        property bool showfavorites
        property int genesis //is 1 if we should use genesis, 0 if we should use megadrive.
        
        anchors {
          left: parent.left; right: parent.right
          top: parent.top; bottom: parent.bottom
        }
        width: parent.width
        height: parent.height

        onSettingsCloseRequested: toggleSettings()
        
      }

    }

  }

  PlatformMenu {
    id: platformmenu
    collection: currentCollection
    collectionIdx: collectionIndex
    anchors {
      left: parent.left; right: parent.right
      top: parent.top; bottom: parent.bottom
    }
    width: parent.width
    height: parent.height
    backgroundcontainer: everythingcontainer
    onMenuCloseRequested: toggleMenu()
    onSwitchCollection: jumpToCollection(collectionIdx)
  }
  
  AlphaMenu {
    id: alphamenu
    anchors {
      left: parent.left; right: parent.right
      top: parent.top; bottom: parent.bottom
    }
    width: parent.width
    height: parent.height
    backgroundcontainer: everythingcontainer
    onAlphaCloseRequested: toggleAlpha()
  }

  // Switch collection overlay
  GameGridSwitcher {
    id: switchoverlay
    collection: currentCollection
    anchors.fill: parent
    width: parent.width
    height: parent.height
  }

  // Empty area for swiping on touch
  Item {
    anchors { top: parent.top; left: parent.left; bottom: parent.bottom; }
    width: vpx(75)
    PegasusUtils.HorizontalSwipeArea {
        anchors.fill: parent
        visible: gamegrid.focus
        onSwipeRight: toggleMenu()
        //onSwipeLeft: closeRequested()
        onClicked: toggleMenu()
    }
  }

  ///////////////////
  // SOUND EFFECTS //
  ///////////////////
  SoundEffect {
      id: navSound
      source: "assets/audio/tap-mellow.wav"
      volume: 1.0
  }

  SoundEffect {
      id: menuIntroSound
      source: "assets/audio/slide-scissors.wav"
      volume: 1.0
  }

  SoundEffect {
      id: toggleSound
      source: "assets/audio/tap-sizzle.wav"
      volume: 1.0
  }

}
