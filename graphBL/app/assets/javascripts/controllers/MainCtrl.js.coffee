angular.module('graph_bl')

.controller('MainCtrl', ($scope, $http, $controller, toastr) ->
    angular.extend(this, $controller('MapCtrl', $scope: $scope, $http: $http))
    angular.extend(this, $controller('PathCtrl', $scope: $scope, $http: $http, toastr))

    $scope.graph_bl_secret = ''
    $scope.system_secret = 'ciclovias_bdes_2015'

    $scope.global_options = {mode: 'analytic'}
    $scope.init()
    $scope.reloadBikeLayer()
    $scope.processing = false
    $scope.params = {
      clusters: 2,
      scorer: true,
      paths_to_calculate: 0
    }

    $scope.restoreBackup = () ->
      $scope.processing = true
      $scope.pairs = null
      $http.get("/backups/restore").success (data) ->
        $scope.reloadBikeLayer()
        $scope.processing = false

    $scope.clusterer = (min_clusters) ->
      $scope.processing = true
      $http.post("/proposer/clusterer.json", min_clusters: min_clusters || 0).success (data) ->
        $scope.reloadBikeLayer()
        $scope.processing = false

    $scope.calculate_score = ->
      $scope.processing = true
      $http.post("/proposer/calculate_score.json").success (data) ->
        $scope.reloadBikeLayer()
        $scope.processing = false

    $scope.get_pairs = () ->
      $scope.processing = true
      $http.post("/proposer/get_pairs.json").success (data) ->
        $scope.pairs = data
        $scope.processing = false

    $scope.propose = ->
      $scope.processing = true
      $http.post("/proposer/propose.json", $scope.params).success (data) ->
        $scope.reloadBikeLayer()
        $scope.pairs = data
        $scope.processing = false
)
