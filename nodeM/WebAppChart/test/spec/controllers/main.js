'use strict';

describe('Controller: MainCtrl', function () {

  // load the controller's module
  beforeEach(module('webApp'));

  var MainCtrl,
    scope;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope) {
    scope = $rootScope.$new();
    MainCtrl = $controller('MainCtrl', {
      $scope: scope
    });
  }));

  it('should be showed a Welcome massage', function () {
    //expect(scope.awesomeThings.length).toBe(3);
    expect(scope.msg).toEqual('Welcome to 4Casters WebApp');
  });
});
