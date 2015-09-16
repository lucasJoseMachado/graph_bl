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
      $http.post("/proposers/clusterer.json", min_clusters: ($scope.min_clusters || 0)).success (data) ->
        $scope.reloadPoints()
        $scope.clustering = false

    $scope.propose = ->
      $scope.propose_params ||= {}
      $http.post("/proposers/propose.json", $scope.propose_params).success (data) ->
        return #TODO

    $scope.path = (point_a, point_b) ->
      $http.post("/proposers/path.json", point_a: point_a, point_b: point_b).success (data) ->
        return #TODO

    $scope.calculate_score = ->
      $http.post("/proposers/calculate_score.json").success (data) ->
        return #TODO

    $scope.get_pairs = (pairs_qt) ->
      $http.post("/proposers/get_pairs.json", pairs: pairs_qt).success (data) ->
        return #TODO
)
