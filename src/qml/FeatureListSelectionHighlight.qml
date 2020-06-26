import QtQuick 2.12

import org.qgis 1.0
import org.qfield 1.0

Repeater {
  id: featureListSelectionHighlight
  property FeatureListModelSelection selectionModel
  property MapSettings mapSettings
  property color color: "yellow"
  property color focusedColor: "red"
  property color selectedColor: "green"

  model: selectionModel.model

  delegate: GeometryRenderer {
    mapSettings: featureListSelectionHighlight.mapSettings
    geometryWrapper.qgsGeometry: model.geometry
    geometryWrapper.crs: model.crs

    color: model.featureSelected ? featureListSelectionHighlight.selectedColor : selectionModel && model.index === selectionModel.focusedItem ? featureListSelectionHighlight.focusedColor : featureListSelectionHighlight.color
    borderColor: "white"
  }

}
