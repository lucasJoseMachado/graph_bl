angular.module('graph_bl')

.controller('MapCtrl', ($scope, $http) ->
  $scope.init = ->
    $scope.mapInstance = new L.Map 'map'
    start_point = [-26.29918, -48.82080]
    start_zoom = 12
    $scope.mapInstance.setView start_point, start_zoom
    $scope.geoJson = L.geoJson().addTo($scope.mapInstance);
    $scope.add_osm_layer()
    $scope.addClickHandler()

  $scope.addClickHandler = ->
    $scope.mapInstance.on 'contextmenu', (e) ->
      point = e.latlng
      layer.on 'dblclick', (e) ->
        $scope.user_add_path_points ||= []
        $scope.user_add_path_points.push point
        $scope.user_add_path_points = $.unique($scope.user_add_path_points)
        if $scope.user_add_path_points.length == 2
          $http.post("/proposer/add_bike_lane", points: $scope.user_add_path_points)
            .success (data) ->
              #TODO adicionar toastr para notificar usuário
          $scope.user_add_path_points = []
      layer.on 'contextmenu', (e) ->
        if $scope.user_add_path_points
          $scope.user_add_path_points.pop()

  $scope.reloadBikeLayer = ->
    $http.get("/layers/bike.json").success (data) ->
      $scope.drawLines(data)

  $scope.add_osm_layer = ->
    osmTile = new L.tileLayer 'http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'
    osmTile.addTo($scope.mapInstance)

  $scope.drawLayer = (geometryArray, options={geometryType: 'LineString', layerType: 'Bike'}) ->
    json_layer = $scope.parseArrayToGeoJsonLayer( geometryArray, options.geometryType )
    $scope.addGeoJsonLayer( json_layer, options.layerType )

  $scope.addGeoJsonLayer = (json_layer, layerType) ->
    L.geoJson(
      json_layer,
      style: $scope.layerStyle( layerType ),
      onEachFeature: ((feature, layer) ->
        if feature.type == "LineString"
          layer.on 'dblclick', (e) ->
            $http.post("/proposer/change_edge_type", edge: e.target.feature.geometry.id)
            #TODO adicionar toastr para informar o usuário
            $scope.reloadBikeLayer()
      )
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
    color = null
    fillColor = null
    if type == "NewBikeLane"
      return {
        color: "#000000",
        fillColor: "#000000",
        weight: 12,
        radius: 1,
        opacity: 0.75,
        fillOpacity: 0
      }
    else if type == "Bike"
      color = "#0098ff"
      fillColor = "#ff0000"
    else
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

  $scope.clearLineLayers = () ->
    if $scope.lineLayers
      for layer in $scope.lineLayers
        $scope.mapInstance.removeLayer(layer)
    $scope.lineLayers = []

  $scope.drawLines = (lines) ->
    $scope.clearLineLayers()
    for cluster_color of lines
      $scope.lineLayers = $scope.lineLayers.concat $scope.drawLayer(lines[cluster_color], {geometryType: 'LineString', layerType: cluster_color || 'Bike'})
)
