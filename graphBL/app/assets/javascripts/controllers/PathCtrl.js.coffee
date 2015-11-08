angular.module('graph_bl')

.controller('PathCtrl', ['$scope', '$http', '$controller', 'toastr', ($scope, $http, $controller, toastr) ->
  angular.extend(this, $controller('MapCtrl', $scope: $scope, $http: $http))

  $scope.show_path = (index_pair) ->
    pair = $scope.pairs[index_pair]
    first_point = JSON.parse(pair.path.relationships[0].geometry)[0]
    $scope.mapInstance.setView(new L.latLng(first_point.reverse()), 14)
    geojson_parts = $scope.mount_path_geojson(pair.path)
    $scope.clear_current_path()
    $scope.current_path = {
      geojson: geojson_parts,
      layer: $scope.addGeoJsonLayer(geojson_parts, 'NewBikeLane')
    }

  $scope.mount_path_geojson = (path) ->
    path.relationships.map (relation) ->
      {
        "type": "LineString",
        "coordinates": JSON.parse(relation.geometry)
      }

  $scope.clear_current_path = () ->
    if $scope.current_path
      $scope.mapInstance.removeLayer($scope.current_path.layer)
      $scope.current_path = null

  $scope.add_path = (index_pair) ->
    path = $scope.pairs[index_pair].path
    $http.post("/proposer/add_bike_lane.json", path: path)
      .success (data) ->
        $scope.addGeoJsonLayer($scope.mount_path_geojson(path), 'Bike')
        $scope.clear_current_path()
        $scope.pairs.splice(index_pair, 1)
])
