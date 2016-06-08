'use strict';


var app = angular
  .module('webApp', [
    'ngAnimate',
    'ngCookies',
    'ngResource',
    'ngRoute',
    'ngSanitize',
    'ngTouch',
    'ui.bootstrap'
]);


app.factory('AjaxService', ['$http', function($http) {

  var _getCSV = function() {
    //var url = "http://52.88.34.166:9091/history/csv";

    var url = "/proxy";
    return $http.post(url, {urlData: "http://52.88.34.166:9091/history/csv", param: {}, method: "GET"})
  }; 

  return {    
    getCSV: function() { return _getCSV() }
  };

}]);


app.factory('Help', function() {
  //1open, 2close, 3guadagno/2, 4direzione, 6 open date, 7 close date
  //-1,1.13026,1.12931,95,1,1,04/2016/21 10:30,04/2016/21 12:19,1,-1,-1,EURUSD,1.14096,1.11956,0,0,commento,1002,103353209,

  var _csvToArr = function(strData,strDelimiter){
    strDelimiter = (strDelimiter || ",");
    var objPattern = new RegExp(
        ( "(\\" + strDelimiter + "|\\r?\\n|\\r|^)" + "(?:\"([^\"]*(?:\"\"[^\"]*)*)\"|" + "([^\"\\" + strDelimiter + "\\r\\n]*))" ),"gi");
    var arrData = [];
    var arrMatches = null;
    while (arrMatches = objPattern.exec( strData )){
        var strMatchedDelimiter = arrMatches[ 1 ];
        if ( strMatchedDelimiter.length && (strMatchedDelimiter != strDelimiter) ){
            //arrData.push( {date:'',open:'',high:'',low:'',close:'',volume:'',magic:'',profit:''} );
        }
        if (arrMatches[ 2 ]){ var strMatchedValue = arrMatches[ 2 ].replace( new RegExp( "\"\"", "g" ), "\"" );
        }else{ var strMatchedValue = arrMatches[ 3 ]; }
        var strMatchedValueArr = strMatchedValue.split(",");
        
        if (strMatchedValueArr.length > 1) {
          if (_searchStringInArray('Rollover',strMatchedValueArr) != -1) {
            //console.log("dd0: ",strMatchedValueArr);
            arrData.push( {
              openDate: Date.parse(strMatchedValueArr[6]),
              open: parseFloat(strMatchedValueArr[1]),
              closeDate: Date.parse(strMatchedValueArr[7]),
              close: parseFloat(strMatchedValueArr[2]),
              profit: parseInt(strMatchedValueArr[3]),
              opType: parseInt(strMatchedValueArr[4]),
              cross: strMatchedValueArr[11],
              high: parseFloat(strMatchedValueArr[12]),
              low: parseFloat(strMatchedValueArr[13]),
              magic: parseInt(strMatchedValueArr[17]),
              opId:parseFloat(strMatchedValueArr[18]),
            } );
          }else{
            //console.log("dd: ",strMatchedValueArr);
          }
        }
        //arrData[ arrData.length - 1 ].push( strMatchedValue );
    }
    return arrData;
  };

  var _searchStringInArray = function(str, strArray) {
    var match=0; 
    for (var j=0; j<strArray.length; j++) {
      if (strArray[j].match(str)){match=-1}else{};
    }
    return match;
  };

  var _sort = function(arr,sortProperties,direction) {
    if( arr.length > 1 ){
      var result = [],tmpVal;
      arr.sort(_orderByProperty(sortProperties,direction)).forEach(function(el){
        if(el[sortProperties[0]]==tmpVal){
          console.log("result: ",result);
          if (Array.isArray(result[result.length-1])) {result[result.length-1].push(el)}else{result.push(el); }
        }else{
          tmpVal=el[sortProperties[0]];
          if (sortProperties.length > 1) {result.push([el]);}else{result.push(el)}
        }
      });
      return result; 
    }else{
      return arr;
    }
  }; 

  var _orderByProperty = function(arr,direction) {
    var args = Array.prototype.slice.call(arr, 1);
    return function (a, b) {
      var equality;
      if (direction == true) { equality = a[arr[0]] - b[arr[0]] }else{ equality = b[arr[0]] - a[arr[0]] };
      if (equality === 0 && arr.length > 1) {
        var res = _orderByProperty(args,direction)(a, b);
        return res;
      }
      return equality;
    };
  }; 

  return {  
    csvToArr: function(csv,strDelimiter) { return _csvToArr(csv,strDelimiter) },  
    sort: function(arr,sortProperties,direction) { return _sort(arr,sortProperties,direction) }
  };

});

app.config(function ($routeProvider) {
  $routeProvider
    .when('/', {
      templateUrl: 'views/main.html',
      controller: 'MainCtrl'
    })
    .when('/report', {
      controller: 'reportCtrl',
      templateUrl: 'views/report.html'
    })
    .otherwise({
      redirectTo: '/'
    });
});


