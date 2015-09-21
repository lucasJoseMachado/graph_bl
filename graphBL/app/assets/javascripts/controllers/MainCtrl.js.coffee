angular.module('graph_bl')

.controller('MainCtrl', ($scope, $http, $controller) ->
    angular.extend(this, $controller('MapCtrl', $scope: $scope, $http: $http))

    $scope.init()
    $scope.reloadBikeLayer()
    $scope.reloadPoints()
    $scope.processing = false
    $scope.params = {
      clusters: 2,
      scorer: true,
      pairs_to_pick: 1,
      paths_to_calculate: 0
    }

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
      $http.post("/proposer/get_pairs.json", pairs: pairs_qt).success (data) ->
        $scope.pairs = data
        $scope.processing = false

    $scope.get_path = (pair) ->
      $scope.processing = true
      $http.post("/proposer/path.json", point_a: pair.origin.id, point_b: pair.destination.id).success (data) ->
        pair.path = data
        $scope.processing = false

    $scope.show_path = (path) ->
      path_array = path.map (relation) -> geometry
      $scope.drawLayer(path_array, {geometryType: 'LineString', layerType: 'Car'})
      return # TODO corrigir este metodo

    $scope.path_length = (path) ->
      total = 0
      for relation in path
        total += relation.length
      total

    $scope.add_path = (path) ->
      return #TODO adicionar caminho no grafo como apenas ciclovias

    $scope.propose = ->
      $scope.processing = true
      $http.post("/proposer/propose.json", $scope.params).success (data) ->
        $scope.reloadPoints()
        $scope.pairs = data
        $scope.processing = false
)
