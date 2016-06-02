'use strict';

describe('Controller: reportCtrl', function () {

  // load the controller's module
  beforeEach(module('webApp'));

  var reportCtrl, scope, timerCallback;
  var Model;

  // Initialize the controller and a mock scope
  beforeEach(inject(function ($controller, $rootScope, Help, AjaxService, _$q_) {
    timerCallback = jasmine.createSpy('timerCallback');
    
    jasmine.Clock.useMock();
    scope = $rootScope.$new();
    Help = Help;
    AjaxService = AjaxService;
    reportCtrl = $controller('reportCtrl', {
      $scope: scope,
      Help: Help,
      AjaxService: AjaxService
    });
  }));

  it('should be showed a Welcome massage', function () {
    expect(scope.msg).toEqual('Algo Report Page');
  });

 

  

});
