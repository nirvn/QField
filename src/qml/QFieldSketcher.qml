import QtQuick 2.15
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import Qt.labs.settings 1.0

import Theme 1.0
import org.qfield 1.0

Popup {
  id: sketcher

  signal finished(var path)
  signal cancelled()

  width: mainWindow.width
  height: mainWindow.height
  x: 0
  y: 0
  z: 10000 // 1000s are embedded feature forms, use a higher value to insure feature form popups always show above embedded feature formes
  padding: 0

  closePolicy: Popup.CloseOnEscape
  dim: true

  Settings {
    id: settings
    property color strokeColor: "#000000"
  }

  Page {
    width: parent.width
    height: parent.height
    padding: 0

    DrawingCanvas {
      id: drawingCanvas
      anchors.fill: parent

      fillColor: Theme.mainBackgroundColor
      frameColor: Theme.mainColor

      Behavior on zoomFactor {
        enabled: !pinchHandler.active
        NumberAnimation { duration: 100; easing.type: Easing.OutQuad; }
      }
    }

    PinchHandler {
      id: pinchHandler
      enabled: sketcher.visible
      target: null

      property point oldPosition

      onScaleChanged: (delta) => {
                        if (active) {
                          drawingCanvas.zoomFactor = drawingCanvas.zoomFactor * delta
                        }
                      }
      onTranslationChanged: (delta) => {
                              if (active) {
                                drawingCanvas.pan(Qt.point(0, 0), Qt.point(delta.x, delta.y))
                              }
                            }
    }

    DragHandler {
      id: stylusDragHandler
      enabled: sketcher.visible
      target: null
      acceptedButtons: Qt.NoButton | Qt.LeftButton | Qt.RightButton
      acceptedDevices: PointerDevice.Stylus | PointerDevice.Mouse
      grabPermissions: PointerHandler.CanTakeOverFromHandlersOfDifferentType | PointerHandler.ApprovesTakeOverByAnything
      dragThreshold: 1

      property point oldPosition

      onActiveChanged: {
        if (active) {
          if (centroid.pressedButtons !== Qt.RightButton) {
            drawingCanvas.strokeBegin(centroid.position, settings.strokeColor)
          } else {
            oldPosition = centroid.position
          }
        } else {
          drawingCanvas.strokeEnd(centroid.position)
        }
      }

      onCentroidChanged: {
        if (active) {
          if (centroid.pressedButtons === Qt.RightButton) {
            drawingCanvas.pan(oldPosition, centroid.position)
            oldPosition = centroid.position
          } else {
            drawingCanvas.strokeMove(centroid.position)
          }
        }
      }
    }

    DragHandler {
      id: dragHandler
      enabled: sketcher.visible
      target: null
      acceptedButtons: Qt.NoButton | Qt.LeftButton | Qt.RightButton
      acceptedDevices: PointerDevice.TouchScreen
      dragThreshold: 1

      property point oldPosition

      onActiveChanged: {
        if (active) {
          if (centroid.pressedButtons !== Qt.RightButton) {
            drawingCanvas.strokeBegin(centroid.position, settings.strokeColor)
          } else {
            oldPosition = centroid.position
          }
        } else {
          drawingCanvas.strokeEnd(centroid.position)
        }
      }

      onCentroidChanged: {
        if (active) {
          if (centroid.pressedButtons === Qt.RightButton) {
            drawingCanvas.pan(oldPosition, centroid.position)
            oldPosition = centroid.position
          } else {
            drawingCanvas.strokeMove(centroid.position)
          }
        }
      }
    }

    WheelHandler {
      enabled: sketcher.visible
      target: null

      onWheel: (event) => { drawingCanvas.zoomFactor = drawingCanvas.zoomFactor * (event.angleDelta.y > 0 ? 1.25 : 0.75) }
    }

    RowLayout {
      visible: !drawingCanvas.isEmpty
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      anchors.bottomMargin: mainWindow.sceneBottomMargin + 5
      spacing: 3

      Repeater {
        model: [["#000000","#ffffff"], ["#ffffff","#000000"], ["#e41a1c","#e41a1c"], ["#377eb8","#377eb8"], ["#4daf4a","#4daf4a"]]

        QfToolButton {
          property color colorValue: modelData[0]

          width: 48
          height: 48
          round: true
          borderColor: modelData[1]
          scale: settings.strokeColor == colorValue ? 1 : 0.66
          opacity: settings.strokeColor == colorValue ? 1 : 0.66

          Behavior on scale {
            enabled: true
            NumberAnimation { duration: 200; easing.type: Easing.OutQuad; }
          }
          Behavior on opacity {
            enabled: true
            NumberAnimation { duration: 200; easing.type: Easing.OutQuad; }
          }

          bgcolor: colorValue

          onClicked: {
            settings.strokeColor = colorValue
          }
        }
      }
    }

    Rectangle {
      id: templateContainer

      visible: drawingCanvas.isEmpty
      width: parent.width
      height: parent.height / 3
      x: 0
      y: parent.height / 7 * 4
      color: Theme.controlBackgroundAlternateColor

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        Text {
          Layout.fillWidth: true
          Layout.alignment: Qt.AlignHCenter
          text: qsTr('Select drawing template')
          font: Theme.defaultFont
          color: Theme.mainColor
          wrapMode: Text.WordWrap
          horizontalAlignment: Text.AlignHCenter
        }

        ListView {
          id: templateList
          Layout.preferredWidth: Math.min(parent.width, templateList.contentWidth)
          Layout.fillHeight: true
          Layout.alignment: Qt.AlignHCenter
          model: drawingTemplateModel
          orientation: ListView.Horizontal

          delegate: Rectangle {
            id: templateItem
            width: templateList.height
            height: templateList.height
            color: "transparent"

            Image {
              anchors.fill: parent
              anchors.margins: 5
              visible: templatePath !== ''
              fillMode: Image.PreserveAspectFit
              source: templatePath !== '' ? 'file://' + templatePath : ''
            }

            Rectangle {
              anchors.centerIn: parent
              anchors.margins: 5
              visible: templatePath === ''
              width: mainWindow.width > mainWindow.height ? parent.width : mainWindow.width * parent.height / mainWindow.height
              height: mainWindow.height > mainWindow.width ? parent.height : mainWindow.height * parent.width / mainWindow.width
              color: "#ffffff"
            }

            Rectangle {
              anchors.centerIn: parent
              width: titleText.contentWidth + 10
              height: titleText.contentHeight + 5
              radius: 4
              color: "#55000000"

              Text {
                anchors.centerIn: parent
                width: templateItem.width
                id: titleText
                text: templateTitle
                font: Theme.tipFont
                color: "#ffffff"
                horizontalAlignment: Text.AlignHCenter
              }
            }

            MouseArea {
              anchors.fill: parent
              onClicked: {
                if (templatePath !== '') {
                  drawingCanvas.createCanvasFromImage(templatePath)
                } else {
                  drawingCanvas.createBlankCanvas(mainWindow.width, mainWindow.height, "#ffffff")
                }
              }
            }
          }
        }
      }
    }

    QfToolButton {
      id: backButton

      anchors.left: parent.left
      anchors.leftMargin: 5
      anchors.top: parent.top
      anchors.topMargin: mainWindow.sceneTopMargin + 5

      iconSource: Theme.getThemeIcon("ic_chevron_left_white_24dp")
      iconColor: "white"
      bgcolor: Theme.darkGraySemiOpaque
      round: true

      onClicked: {
        sketcher.cancelled()
        sketcher.close()
      }
    }

    QfToolButton {
      id: saveButton
      visible: !drawingCanvas.isEmpty

      anchors.right: parent.right
      anchors.rightMargin: 5
      anchors.top: parent.top
      anchors.topMargin: mainWindow.sceneTopMargin + 5

      iconSource: Theme.getThemeIcon( 'ic_check_white_48dp' )
      iconColor: "white"
      bgcolor: drawingCanvas.isDirty ? Theme.mainColor : Theme.darkGraySemiOpaque
      round: true

      onClicked: {
        sketcher.finished(drawingCanvas.save())
        sketcher.close()
      }
    }
  }

  function loadImage(path) {
    drawingCanvas.createCanvasFromImage(path)
  }

  function clear() {
    drawingCanvas.clear();
  }
}
