import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import org.qgis 1.0
import org.qfield 1.0
import Theme 1.0

import '.'

Popup {
  id: trackInformationPopup
  parent: mainWindow.contentItem

  x: Theme.popupScreenEdgeMargin
  y: Theme.popupScreenEdgeMargin
  padding: 0
  width: parent.width - Theme.popupScreenEdgeMargin * 2
  height: parent.height - Theme.popupScreenEdgeMargin * 2
  modal: true
  closePolicy: Popup.CloseOnEscape

  property var tracker: undefined
  onTrackerChanged: {
    if (tracker != undefined) {
      featureModel.currentLayer = tracker.vectorLayer
    }
  }

  Page {
    focus: true
    anchors.fill: parent

    header: PageHeader {
      title: qsTr("Tracker Settings")

      showApplyButton: false
      showCancelButton: false
      showBackButton: true

      onBack: {
        if (tracker != undefined) {
          trackingModel.stopTracker(tracker.vectorLayer)
        }
        close();
      }
    }

    ScrollView {
      padding: 20
      ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
      ScrollBar.vertical.policy: ScrollBar.AsNeeded
      contentWidth: trackerSettingsGrid.width
      contentHeight: trackerSettingsGrid.height
      anchors.fill: parent
      clip: true

      GridLayout {
        id: trackerSettingsGrid
        width: parent.parent.width
        Layout.fillWidth: true

        columns: 2
        columnSpacing: 0
        rowSpacing: 5


        Label {
          text: qsTr("Activate time constraint")
          font: Theme.defaultFont
          wrapMode: Text.WordWrap
          Layout.fillWidth: true

          MouseArea {
            anchors.fill: parent
            onClicked: timeInterval.toggle()
          }
        }

        QfSwitch {
          id: timeInterval
          Layout.preferredWidth: implicitContentWidth
          Layout.alignment: Qt.AlignTop
          checked: positioningSettings.trackerTimeIntervalConstraint
          onCheckedChanged: {
            positioningSettings.trackerTimeIntervalConstraint = checked
          }
        }

        Label {
          text: qsTr("Minimum time [sec]")
          font: Theme.defaultFont
          wrapMode: Text.WordWrap
          enabled: timeInterval.checked
          visible: timeInterval.checked
          Layout.leftMargin: 8
          Layout.fillWidth: true
        }

        QfTextField {
          id: timeIntervalValue
          width: timeInterval.width
          font: Theme.defaultFont
          enabled: timeInterval.checked
          visible: timeInterval.checked
          horizontalAlignment: TextInput.AlignHCenter
          Layout.preferredWidth: 60
          Layout.preferredHeight: font.height + 20

          inputMethodHints: Qt.ImhFormattedNumbersOnly
          validator: DoubleValidator { locale: 'C' }

          Component.onCompleted: {
            text = isNaN(positioningSettings.trackerTimeInterval) ? '' : positioningSettings.trackerTimeInterval
          }

          onTextChanged: {
            if( text.length === 0 || isNaN(text) ) {
              positioningSettings.trackerTimeInterval = NaN
            } else {
              positioningSettings.trackerTimeInterval = parseFloat( text )
            }
          }
        }

        Label {
          text: qsTr("Activate distance constraint")
          font: Theme.defaultFont
          wrapMode: Text.WordWrap
          Layout.fillWidth: true

          MouseArea {
            anchors.fill: parent
            onClicked: minimumDistance.toggle()
          }
        }

        QfSwitch {
          id: minimumDistance
          Layout.preferredWidth: implicitContentWidth
          Layout.alignment: Qt.AlignTop
          checked: positioningSettings.trackerMinimumDistanceConstraint
          onCheckedChanged: {
            positioningSettings.trackerMinimumDistanceConstraint = checked
          }
        }

        DistanceArea {
          id: infoDistanceArea
          project: qgisProject
          crs: qgisProject ? qgisProject.crs : CoordinateReferenceSystemUtils.invalidCrs()
        }

        Label {
          text: qsTr("Minimum distance [%1]").arg( UnitTypes.toAbbreviatedString( infoDistanceArea.lengthUnits ) )
          font: Theme.defaultFont
          wrapMode: Text.WordWrap
          enabled: minimumDistance.checked
          visible: minimumDistance.checked
          Layout.leftMargin: 8
          Layout.fillWidth: true
        }

        QfTextField {
          id: minimumDistanceValue
          width: minimumDistance.width
          font: Theme.defaultFont
          enabled: minimumDistance.checked
          visible: minimumDistance.checked
          horizontalAlignment: TextInput.AlignHCenter
          Layout.preferredWidth: 60
          Layout.preferredHeight: font.height + 20

          inputMethodHints: Qt.ImhFormattedNumbersOnly
          validator: DoubleValidator { locale: 'C' }

          Component.onCompleted: {
            text = isNaN(positioningSettings.trackerMinimumDistance) ? '' : positioningSettings.trackerMinimumDistance
          }

          onTextChanged: {
            if( text.length === 0 || isNaN(text) ) {
              positioningSettings.trackerMinimumDistance = NaN
            } else {
              positioningSettings.trackerMinimumDistance = parseFloat( text )
            }
          }
        }

        Label {
          text: qsTr("Activate sensor constraint")
          font: Theme.defaultFont
          wrapMode: Text.WordWrap
          Layout.fillWidth: true

          MouseArea {
            anchors.fill: parent
            onClicked: sensorCapture.toggle()
          }
        }

        QfSwitch {
          id: sensorCapture
          Layout.preferredWidth: implicitContentWidth
          Layout.alignment: Qt.AlignTop
          checked: positioningSettings.trackerSensorCaptureConstraint
          onCheckedChanged: {
            positioningSettings.trackerSensorCaptureConstraint = checked
          }
        }

        Label {
          text: qsTr("Record when all active constraints are met")
          font: Theme.defaultFont
          wrapMode: Text.WordWrap
          Layout.fillWidth: true
          enabled: (timeInterval.checked + minimumDistance.checked + sensorCapture.checked) > 1
          visible: (timeInterval.checked + minimumDistance.checked + sensorCapture.checked) > 1

          MouseArea {
            anchors.fill: parent
            onClicked: allConstraints.toggle()
          }
        }

        QfSwitch {
          id: allConstraints
          Layout.preferredWidth: implicitContentWidth
          Layout.alignment: Qt.AlignTop
          enabled: (timeInterval.checked + minimumDistance.checked + sensorCapture.checked) > 1
          visible: (timeInterval.checked + minimumDistance.checked + sensorCapture.checked) > 1
          checked: positioningSettings.trackerMeetAllConstraints
          onCheckedChanged: {
            positioningSettings.trackerMeetAllConstraints = checked
          }
        }

        Label {
          text: qsTr( "When enabled, vertices with only be recorded when all active constraints are met. If the setting is disabled, individual constraints met will trigger a vertex addition." )
          font: Theme.tipFont
          color: Theme.secondaryTextColor
          textFormat: Qt.RichText
          wrapMode: Text.WordWrap
          Layout.fillWidth: true
          enabled: (timeInterval.checked + minimumDistance.checked + sensorCapture.checked) > 1
          visible: (timeInterval.checked + minimumDistance.checked + sensorCapture.checked) > 1
        }


        Label {
          text: sensorCapture.checked
                ? qsTr( "When the sensor constraint is activated alone, vertex additions will occur whenever sensor has captured new data." )
                : qsTr( "When all constraints are disabled, vertex additions will occur as frequently as delivered by the positioning device." )
          font: Theme.tipFont
          color: Theme.secondaryTextColor
          textFormat: Qt.RichText
          wrapMode: Text.WordWrap
          Layout.fillWidth: true
          visible: !timeInterval.checked && !minimumDistance.checked
        }

        Item {
          Layout.preferredWidth: allConstraints.width
          Layout.columnSpan: 2
        }



        Label {
          text: qsTr("Erroneous distance safeguard")
          font: Theme.defaultFont
          wrapMode: Text.WordWrap
          Layout.fillWidth: true

          MouseArea {
            anchors.fill: parent
            onClicked: maximumDistance.toggle()
          }
        }

        QfSwitch {
          id: erroneousDistanceSafeguard
          Layout.preferredWidth: implicitContentWidth
          Layout.alignment: Qt.AlignTop
          checked: positioningSettings.trackerErroneousDistanceSafeguard
          onCheckedChanged: {
            positioningSettings.trackerErroneousDistanceSafeguard = checked
          }
        }

        Label {
          text: qsTr("Maximum tolerated distance [%1]").arg( UnitTypes.toAbbreviatedString( infoDistanceArea.lengthUnits ) )
          font: Theme.defaultFont
          wrapMode: Text.WordWrap
          enabled: erroneousDistanceSafeguard.checked
          visible: erroneousDistanceSafeguard.checked
          Layout.leftMargin: 8
          Layout.fillWidth: true
        }

        QfTextField {
          id: erroneousDistanceValue
          width: erroneousDistanceSafeguard.width
          font: Theme.defaultFont
          enabled: erroneousDistanceSafeguard.checked
          visible: erroneousDistanceSafeguard.checked
          horizontalAlignment: TextInput.AlignHCenter
          Layout.preferredWidth: 60
          Layout.preferredHeight: font.height + 20

          inputMethodHints: Qt.ImhFormattedNumbersOnly
          validator: DoubleValidator { locale: 'C' }

          Component.onCompleted: {
            text = isNaN(positioningSettings.trackerErroneousDistance) ? '' : positioningSettings.trackerErroneousDistance
          }

          onTextChanged: {
            if( text.length === 0 || isNaN(text) ) {
              positioningSettings.trackerErroneousDistance = NaN
            } else {
              positioningSettings.trackerErroneousDistance = parseFloat( text )
            }
          }
        }

        Label {
            text: qsTr( "When erroneous distance safeguard is enabled, position readings that have a distance beyond the specified tolerance value will be discarded." )
            font: Theme.tipFont
            color: Theme.secondaryTextColor

            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.columnSpan: 2
        }

        Label {
            id: measureLabel
            Layout.fillWidth: true
            Layout.columnSpan: 2
            text: qsTr( "Measure (M) value attached to vertices:" )
            font: Theme.defaultFont

            wrapMode: Text.WordWrap
        }

        ComboBox {
            id: measureComboBox
            enabled: LayerUtils.hasMValue(featureModel.currentLayer)
            Layout.fillWidth: true
            Layout.columnSpan: 2
            Layout.alignment: Qt.AlignVCenter
            font: Theme.defaultFont

            popup.font: Theme.defaultFont
            popup.topMargin: mainWindow.sceneTopMargin
            popup.bottomMargin: mainWindow.sceneTopMargin

            property bool loaded: false
            Component.onCompleted: {
                // This list matches the Tracker::MeasureType enum
                var measurements = [
                  qsTr("Elapsed time (seconds since start of tracking)"),
                  qsTr("Timestamp (milliseconds since epoch)"),
                  qsTr("Ground speed"),
                  qsTr("Bearing"),
                  qsTr("Horizontal accuracy"),
                  qsTr("Vertical accuracy"),
                  qsTr("PDOP"),
                  qsTr("HDOP"),
                  qsTr("VDOP")
                ];

                model = measurements;
                currentIndex = positioningSettings.trackerMeasureType;
                loaded = true;
            }

            onCurrentIndexChanged: {
              if (loaded) {
                positioningSettings.trackerMeasureType = currentIndex;
              }
            }
        }

        Label {
            id: measureTipLabel
            visible: !LayerUtils.hasMValue(featureModel.currentLayer)
            Layout.fillWidth: true
            text: qsTr( "To active the measurement functionality, make sure the vector layer's geometry type used for the tracking session has an M dimension." )
            font: Theme.tipFont
            color: Theme.secondaryTextColor

            wrapMode: Text.WordWrap
        }

        Item {
            // spacer item
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        QfButton {
          id: trackingButton
          Layout.topMargin: 8
          Layout.fillWidth: true
          Layout.columnSpan: 2
          text: qsTr( "Start tracking")
          icon.source: Theme.getThemeVectorIcon( 'directions_walk_24dp' )

          onClicked: {
            tracker.timeInterval = timeIntervalValue.text.length == 0 || !timeInterval.checked ? 0.0 : timeIntervalValue.text
            tracker.minimumDistance = minimumDistanceValue.text.length == 0 || !minimumDistance.checked ? 0.0 : minimumDistanceValue.text
            tracker.maximumDistance = erroneousDistanceValue.text.length == 0 || !erroneousDistanceSafeguard.checked ? 0.0 : erroneousDistanceValue.text
            tracker.sensorCapture = sensorCapture.checked
            tracker.conjunction = (timeInterval.checked + minimumDistance.checked + sensorCapture.checked) > 1 && allConstraints.checked
            tracker.measureType = measureComboBox.currentIndex

            featureModel.resetAttributes()
            if (embeddedAttributeFormModel.rowCount() > 0 && !featureModel.suppressFeatureForm()) {
              embeddedFeatureForm.active = true
            } else {
              trackingModel.startTracker(tracker.vectorLayer)
              displayToast(qsTr('Track on layer %1 started').arg(tracker.vectorLayer.name))
            }
          }
        }

        Item {
          // spacer item
          Layout.fillWidth: true
          Layout.fillHeight: true
        }
      }
    }
  }

  FeatureModel {
    id: featureModel
    project: qgisProject

    geometry: Geometry {
      id: featureModelGeometry
      rubberbandModel: rubberbandModel
      vectorLayer: featureModel.currentLayer
    }

    positionInformation: coordinateLocator.positionInformation
    positionLocked: true
    cloudUserInformation: cloudConnection.userInformation
  }

  AttributeFormModel {
    id: embeddedAttributeFormModel
    featureModel: featureModel
  }

  Loader {
    id: embeddedFeatureForm

    sourceComponent: embeddedFeatureFormComponent
    active: false
    onLoaded: {
      item.open()
    }
  }

  Component {
    id: embeddedFeatureFormComponent

    Popup {
      id: embeddedFeatureFormPopup
      parent: mainWindow.contentItem

      x: Theme.popupScreenEdgeMargin
      y: Theme.popupScreenEdgeMargin
      padding: 0
      width: parent.width - Theme.popupScreenEdgeMargin * 2
      height: parent.height - Theme.popupScreenEdgeMargin * 2
      modal: true
      closePolicy: Popup.CloseOnEscape

      FeatureForm {
        id: form
        model: embeddedAttributeFormModel

        focus: true
        setupOnly: true
        embedded: true
        toolbarVisible: true

        anchors.fill: parent

        state: 'Add'

        onTemporaryStored: {
          tracker.feature = featureModel.feature
          embeddedFeatureForm.active = false
          trackingModel.startTracker(tracker.vectorLayer)
          displayToast(qsTr('Track on layer %1 started').arg(tracker.vectorLayer.name))
          trackerSettings.close()
        }

        onCancelled: {
          embeddedFeatureForm.active = false
          embeddedFeatureForm.focus = false
          trackingModel.stopTracker(tracker.vectorLayer)
          trackerSettings.close()
        }
      }

      onClosed: {
        form.confirm()
      }
    }
  }
}
