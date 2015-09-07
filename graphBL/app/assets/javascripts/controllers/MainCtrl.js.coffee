angular.module('graph_bl')

.controller('MainCtrl', ($scope, $http, $controller) ->
    angular.extend(this, $controller('MapCtrl', $scope: $scope))
    $scope.min_clusters = null
    $scope.clustering = false

    $scope.reloadPoints = ->
      $http.get("/layers/point.json").success (data) ->
        $scope.drawPoints(data)

    $scope.reloadBikeLayer = ->
      $http.get("/layers/bike.json").success (data) ->
        $scope.drawLayer(data, {geometryType: 'LineString', layerType: 'Bike'})

    $scope.init()
    $scope.reloadBikeLayer()
    $scope.reloadPoints()

    $scope.clusterer = ->
      $scope.clustering = true
      $http.post("/layers/clusterer.json", min_clusters: ($scope.min_clusters || 0)).success (data) ->
        $scope.reloadPoints()
        $scope.clustering = false
)
