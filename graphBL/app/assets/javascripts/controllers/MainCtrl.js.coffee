angular.module('graph_bl')

.controller('MainCtrl', ($scope, $http, $controller) ->
    angular.extend(this, $controller('MapCtrl', $scope: $scope, $http: $http))

    $scope.init()
    $scope.reloadBikeLayer()
    $scope.reloadPoints()
    $scope.processing = false

    $scope.clusterer = (min_clusters) ->
      $scope.processing = true
      $http.post("/proposer/clusterer.json", min_clusters: min_clusters || 0).success (data) ->
        $scope.reloadPoints()
        $scope.processing = false

    $scope.calculate_score = ->
      $scope.processing = true
      $http.post("/proposer/calculate_score.json").success (data) ->
        $scope.reloadPoints()
        $scope.processing = false

    $scope.get_pairs = (pairs_qt) ->
      $scope.processing = true
      $http.post("/proposer/get_pairs.json", pairs: pairs_qt || 1).success (data) ->
        $scope.processing = false
        return #TODO

    $scope.path = (point_a, point_b) ->
      $scope.processing = true
      $http.post("/proposer/path.json", point_a: point_a, point_b: point_b).success (data) ->
        $scope.processing = false
        return #TODO

    $scope.propose = ->
      $scope.processing = true
      $scope.propose_params ||= {}
      $http.post("/proposer/propose.json", $scope.propose_params).success (data) ->
        $scope.processing = false
        return #TODO
)
