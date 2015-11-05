angular.module('graph_bl')

.controller('NewUserSuggestionCtrl', ($scope, $http, $controller, toastr) ->
    angular.extend(this, $controller('MapCtrl', $scope: $scope, $http: $http))

    $scope.suggestion = {}

    $scope.mapInstance = new L.Map 'mapOnlyRead'
    start_point = [-26.29918, -48.82080]
    start_zoom = 12
    $scope.mapInstance.setView start_point, start_zoom
    $scope.geoJson = L.geoJson().addTo($scope.mapInstance);
    $scope.add_osm_layer()
    $http.get("/layers/bike.json").success (data) ->
      $scope.clearLineLayers()
      $scope.onlyRead = true
      for cluster_color of data
        $scope.lineLayers = $scope.lineLayers.concat $scope.drawLayer(data[cluster_color], {geometryType: 'LineString', layerType: 'FF0000'})
      $scope.onlyRead = false

    $scope.saveSuggestion = (suggestion) ->
      $http.post("/user_suggestions.json", user_suggestion: $scope.suggestion).success (data) ->
        $scope.suggestion = {}
)

.controller('UserSuggestionCtrl', ($scope, $http, $controller, toastr) ->
    $http.get('/user_suggestions.json').success (data) ->
      $scope.suggestions = data

    $scope.destroySuggestion = (suggestion, index) ->
      $http.delete("/user_suggestions/#{suggestion.id}.json").success (data) ->
        $scope.suggestions.splice(index, 1)
)
