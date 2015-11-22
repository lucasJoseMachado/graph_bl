angular.module('graph_bl')

.controller('MapCtrl', ['$scope', '$http', ($scope, $http) ->
  $scope.add_osm_layer = ->
    L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo($scope.mapInstance)

  $scope.drawLayer = (geometryArray, options={geometryType: 'LineString', layerType: 'Bike'}) ->
    json_layer = $scope.parseArrayToGeoJsonLayer( geometryArray, options.geometryType )
    $scope.addGeoJsonLayer( json_layer, options.layerType )

  $scope.addGeoJsonLayer = (json_layer, layerType) ->
    L.geoJson(
      json_layer,
      style: $scope.layerStyle( layerType )
    ).addTo($scope.mapInstance)

  $scope.parseArrayToGeoJsonLayer = (geometryArray, geometryType, layerType) ->
    json_layer = []
    for value in geometryArray
      json_layer.push {
        type: geometryType,
        coordinates: value.geometry,
        id: value.id
      }
    json_layer

  $scope.layerStyle = (type) ->
    color = "##{type}"
    fillColor = "##{type}"
    {
      color: color,
      fillColor: fillColor,
      weight: 5,
      opacity: 1,
      radius: 4,
      fillOpacity: 1
    }
])
