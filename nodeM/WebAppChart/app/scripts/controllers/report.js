'use strict';

angular.module('webApp')
  .controller('reportCtrl', ['$scope', '$routeParams', 'Help', 'AjaxService',
    function($scope,$routeParams, Help, AjaxService) {
      $scope.msg = 'Algo Report Page';
      $scope.arrOpSort = "";
      $scope.algoId = "";
      $scope.chart = "";
      $scope.server = "production";
     

      /*$('.serverButtons button').on('click', function(){
        var $this = $(this);  
        if(!$this.hasClass('server_button_active')){
            $this.parent().find('button.server_button_active').removeClass("server_button_active");
            $this.addClass("server_button_active");
            //localStorage.setItem("socialStatsUrlTimespan", $this.attr("data-timespan"));
            $scope.query_json.timeFrame = $this.attr("data-timespan");
        }
      });*/

      $scope.createCSV = function(){

        $scope.arrOpSortForCsv = Help.sort($scope.arrOp,['magic']);
        console.log("$scope.arrOpSortForCsv: ",$scope.arrOpSortForCsv);
        var csvContent = "data:text/csv;charset=utf-8,";
        $scope.arrOpSortForCsv.forEach(function(elFirst,i){
          elFirst.forEach(function(elSecond,k){
            var objLength = Object.keys(elSecond).length;
            var j=0;
            for (var key in elSecond) {
              if ( j < objLength-1 ) { 
                csvContent = csvContent + elSecond[key]+",";
              }else if ( j == objLength-1) {
                csvContent = csvContent + elSecond[key];
              }
              j++;
            }
            csvContent = csvContent +"\n";
          });
        });

        console.log("csvContent: ",csvContent);
        var encodedUri = encodeURI(csvContent);
        var link = document.createElement("a");
        link.className = "csv_generator_button";
        link.textContent = "Download CSV";
        link.setAttribute("href", encodedUri);
        link.setAttribute("download", "my_data.csv");
        document.getElementById("viewWebApp").appendChild(link);

        /*var data = [["name1", "city1", "some other info"], ["name2", "city2", "more info"]];
        var csvContent = "data:text/csv;charset=utf-8,";
        data.forEach(function(infoArray, index){

           dataString = infoArray.join(",");
           csvContent += index < data.length ? dataString+ "\n" : dataString;

        });*/

      }





      AjaxService.getCSV()
  		.success(function(data, status, headers) {            
    		
        console.log("data: ",data);
        // CSV PARSER
        $scope.arrOp = Help.csvToArr(data.data.data,"↵");
        $scope.createCSV();
        $scope.showProfitChart();


    	})
    	.error(function(data, status, headers, config) {
    		console.log("data error: ",data);
        console.log("data error: ",status);
        console.log("data error: ",headers);
    	});


      $scope.showProfitChart = function(){
        //SORT by: openDate,open,closeDate,close,profit,opType,cross,high,low,magic,opId
        $scope.arrOpSort = Help.sort($scope.arrOp,['magic'])

        var xs = {};
        var columns = [];
        $scope.arrOpSort.forEach(function(elFirst,index){
          xs[elFirst[0]['magic'].toString()] = 'x'+index;
          columns.push(['x'+index]);
          columns.push([elFirst[0]['magic'].toString()]);
          elFirst.forEach(function(elSecond){
            columns[columns.length-2].push(elSecond['closeDate']);
            columns[columns.length-1].push(elSecond['profit']);
          })
        });

        $scope.chart_title = "Profit timeSeries Chart";

        $scope.chart = c3.generate({
            padding: {
                right: 50,
                left: 50,
                top:10
            },
            zoom: {
              enabled: true
            },
            bindto: '#chart_operations',
            data: {
                xFormat: '%m/%d/%Y %H:%M',  // 05/2016/27 12:20
                xs: xs,
                columns: columns
            },
            axis: {
              x: {
                  type: 'timeseries',
                  tick: {
                      format: '%m/%d/%Y %H:%M',
                      culling: {
                        max: 5
                      }
                  }
              }
            },
            color: {
              pattern: ['#6C6767','#B0BDBE','#F5FFFF','#A8A5A5']
            }
        });

      }



      $scope.showComulativeProfitChart = function(){

        $scope.arrOpSort = Help.sort($scope.arrOp,['magic']);

        var xs = {};
        var columns = [];
        $scope.arrOpSort.forEach(function(elFirst,index){
          xs[elFirst[0]['magic'].toString()] = 'x'+index;
          columns.push(['x'+index]);
          columns.push([elFirst[0]['magic'].toString()]);
          var comulativeProfit = 0;
          elFirst.forEach(function(elSecond){
            columns[columns.length-2].push(elSecond['closeDate']);
            comulativeProfit = comulativeProfit + elSecond['profit'];
            columns[columns.length-1].push( comulativeProfit  );
          })
        });

        $scope.chart_title = "Comulative Profit timeSeries Chart";

        $scope.chart = c3.generate({
            padding: {
                right: 50,
                left: 50,
                top:10
            },
            zoom: {
              enabled: true
            },
            bindto: '#chart_operations',
            data: {
                xFormat: '%m/%d/%Y %H:%M',  // 05/2016/27 12:20
                xs: xs,
                columns: columns
            },
            axis: {
              x: {
                  type: 'timeseries',
                  tick: {
                      format: '%m/%d/%Y %H:%M',
                      culling: {
                        max: 5
                      }
                  }
              }
            },
            color: {
              pattern: ['#6C6767','#B0BDBE','#F5FFFF','#A8A5A5']
            }
        });

      }
        
}]);
