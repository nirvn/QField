/***************************************************************************
                            NavigationBar.qml
                              -------------------
              begin                : 10.12.2014
              copyright            : (C) 2014 by Matthias Kuhn
              email                : matthias (at) opengis.ch
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/


import QtQuick 2.12

import org.qgis 1.0
import Theme 1.0

Rectangle {
  id: toolBar

  property string currentName: ''
  property bool showEditButtons
  property MultiFeatureListModel model
  property FeatureListModelSelection selection
  property FeaturelistExtentController extentController

  signal statusIndicatorClicked
  signal editAttributesButtonClicked
  signal editGeometryButtonClicked
  signal save
  signal cancel

  anchors.top:parent.top
  anchors.left: parent.left
  anchors.right: parent.right
  height: 48

  clip: true

  states: [
    State {
      name: "Navigation"
    },
    State {
      name: "Indication"
    },
    State {
      name: "Edit"
    }
  ]

  state: "Indication"

  Rectangle {
    id: navigationStatusIndicator
    anchors.fill: parent
    height: 48

    color: ( featureFormList.model.constraintsHardValid && featureFormList.model.constraintsSoftValid ) || parent.state !== "Edit" ? Theme.mainColor : !featureFormList.model.constraintsHardValid ? Theme.errorColor : Theme.warningColor

    clip: true

    focus: true

    Text {
      font: Theme.strongFont
      color: "#FFFFFF"
      anchors.centerIn: parent

      text: {
        if ( model && selection.selection > -1 ) {
          ( selection.selection + 1 ) + '/' + model.count + ': ' + currentName
        }
        else {
          qsTr('Features')
        }
      }
    }

    MouseArea {
      anchors.fill: parent

      onClicked: {
        toolBar.statusIndicatorClicked()
      }
    }
  }

  QfToolButton {
    id: nextButton

    anchors.right: parent.right

    width: ( parent.state == "Navigation" ? 48: 0 )
    height: 48
    clip: true

    iconSource: Theme.getThemeIcon( "ic_chevron_right_white_24dp" )

    enabled: ( toolBar.model && ( selection.focusedItem + 1 ) < toolBar.model.count )

    onClicked: {
      selection.focusedItem = selection.focusedItem + 1
    }

    Behavior on width {
      PropertyAnimation {
        easing.type: Easing.InQuart
      }
    }
  }

  QfToolButton {
    id: saveButton
    anchors.left: parent.left
    width: ( parent.state == "Edit" ? 48: 0 )
    height: 48
    clip: true
    visible: !qfieldSettings.autoSave

    iconSource: featureFormList.model.constraintsHardValid ? Theme.getThemeIcon( "ic_check_white_48dp" ) : Theme.getThemeIcon( "ic_check_gray_48dp" )
    onClicked: {
     if( featureFormList.model.constraintsHardValid ) {
       toolBar.save()
     } else {
       displayToast( "Constraints not valid" )
     }
    }
    Behavior on width {
      PropertyAnimation {
        easing.type: Easing.InQuart
      }
    }
  }

  QfToolButton {
    id: cancelButton
    visible: !qfieldSettings.autoSave

    anchors.right: parent.right

    width: ( parent.state == "Edit" ? 48: 0 )
    height: 48
    clip: true

    iconSource: Theme.getThemeIcon( "ic_clear_white_24dp" )

    onClicked: {
      selection.selectionChanged()
      toolBar.cancel()
    }

    Behavior on width {
      PropertyAnimation {
        easing.type: Easing.InQuart
      }
    }
  }

  QfToolButton {
    id: editGeomButton

    property bool readOnly: false

    visible: stateMachine.state === "digitize"
             && ! selection.focusedGeometry.isNull
             && ! selection.selectedLayer.customProperty( "QFieldSync/is_geometry_locked", false )

    anchors.right: editButton.left

    iconSource: Theme.getThemeIcon( "ic_edit_geometry_white" )

    width: ( parent.state == "Navigation" && !readOnly ? 48: 0 )
    height: 48
    clip: true

    onClicked: {
      extentController.zoomToSelected(true)
      toolBar.editGeometryButtonClicked()
    }

    Behavior on width {
      PropertyAnimation {
        easing.type: Easing.InQuart
      }
    }

    Connections {
      target: selection

      onFocusedItemChanged:
      {
        editGeomButton.readOnly = selection.focusedLayer.readOnly
      }
    }
  }

  QfToolButton {
    id: editButton

    property bool readOnly: false

    anchors.right: nextButton.left

    width: ( parent.state == "Navigation" && !readOnly ? 48: 0 )
    height: 48
    clip: true

    iconSource: Theme.getThemeIcon( "ic_edit_attributes_white" )

    onClicked: {
      toolBar.editAttributesButtonClicked()
    }

    Behavior on width {
      PropertyAnimation {
        easing.type: Easing.InQuart
      }
    }

    Connections {
      target: selection

      onFocusedItemChanged:
      {
        editButton.readOnly = selection.focusedLayer.readOnly
      }
    }
  }

  QfToolButton {
    id: followCurrentButton
    
    visible: !selection.focusedGeometry.isNull

    anchors.left: previousButton.right

    width: ( parent.state == "Navigation" ? 48: 0 )
    height: 48
    clip: true
    checkable: true
    checked: extentController.autoZoom

    iconSource: Theme.getThemeIcon( "ic_fullscreen_white_24dp" )

    Behavior on width {
      PropertyAnimation {
        easing.type: Easing.InQuart
      }
    }

    MouseArea {
      anchors.fill: parent

      onClicked: {
        extentController.zoomToSelected()
      }

      onPressAndHold: {
        extentController.autoZoom = !extentController.autoZoom
      }
    }
  }

  QfToolButton {
    id: previousButton

    anchors.left: parent.left

    width: ( parent.state == "Navigation" ? 48: 0 )
    height: 48
    clip: true

    iconSource: Theme.getThemeIcon( "ic_chevron_left_white_24dp" )

    enabled: ( selection.focusedItem > 0 )

    onClicked: {
      selection.focusedItem = selection.focusedItem - 1
    }

    Behavior on width {
      PropertyAnimation {
        easing.type: Easing.InQuart
      }
    }
  }
}
