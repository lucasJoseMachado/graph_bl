angular.module('graph_bl')

.controller('MapCtrl', ($scope, $http) ->
  $scope.pointLayers = []

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

  $scope.reloadPoints = ->
    $http.get("/layers/point.json").success (data) ->
      $scope.drawPoints(data)
      if $scope.bike_layer
        $scope.mapInstance.removeLayer($scope.bike_layer)
        $scope.mapInstance.addLayer($scope.bike_layer)

  $scope.reloadBikeLayer = ->
    $http.get("/layers/bike.json").success (data) ->
      if $scope.bike_layer
        $scope.mapInstance.removeLayer($scope.bike_layer)
      $scope.bike_layer = $scope.drawLayer(data, {geometryType: 'LineString', layerType: 'Bike'})

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
      pointToLayer: (( feature, latlng ) -> L.circleMarker( latlng )),
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
    if type == "Car"
      color = "#ff7800"
      fillColor = "#0000ff"
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

  $scope.clearPointLayers = () ->
    if $scope.pointLayers.length > 0
      for layer in $scope.pointLayers
        $scope.mapInstance.removeLayer(layer)
    $scope.pointLayers = []

  $scope.drawPoints = (points) ->
    $scope.clearPointLayers()
    for cluster_color of points
      $scope.pointLayers = $scope.pointLayers.concat $scope.drawLayer(points[cluster_color], {geometryType: 'Point', layerType: cluster_color})
)
