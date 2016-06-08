'use strict';

angular.module('webApp')
.controller('MainCtrl', ['$scope', '$routeParams',
    function($scope,$routeParams) {
      $scope.msg = 'Welcome to 4Casters WebApp';
}]);
