'use strict';

angular.module('webApp')
  .controller('reportCtrl', ['$scope', '$routeParams', 'Help', 'AjaxService', 
    function($scope,$routeParams, Help, AjaxService) {
      $scope.msg = 'Algo Report Page';
      $scope.arrOpSort = "";
      $scope.algoId = "";
      $scope.chart = "";
      $scope.server = "production";
     

      $('.funcButtons button').on('click', function(){
        var $this = $(this);  
        if(!$this.hasClass('func_button_active')){
            $this.parent().find('button.func_button_active').removeClass("func_button_active");
            $this.addClass("func_button_active");
        }
      });


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

        $scope.arrOpSortForCsv = $scope.arrOp;
        $scope.arrOpSortForCsv = Help.sort($scope.arrOpSortForCsv,['magic','closeDate'],'true');
        
        var csvContent = "data:text/csv;charset=utf-8,";
        $scope.arrOpSortForCsv.forEach(function(elFirst,i){
          for(var i=elFirst.length-1;i>=0;i--){
            var objLength = Object.keys(elFirst[i]).length;
            var j=0;
            for (var key in elFirst[i]) {
              if ( j < objLength-1 ) { 
                if ( key == 'closeDate' || key == 'openDate') {
                  csvContent = csvContent + new Date(elFirst[i][key]).toString() +",";
                }else{
                  csvContent = csvContent + elFirst[i][key]+",";
                }
              }else if ( j == objLength-1) {
                if ( key == 'closeDate' || key == 'openDate') {
                  csvContent = csvContent + new Date(elFirst[i][key]).toString();
                }else{
                  csvContent = csvContent + elFirst[i][key];
                }
              }
              j++;
            }
            csvContent = csvContent +"\n";
          }  
        });

        console.log("csvContent: ",csvContent);
        var encodedUri = encodeURI(csvContent);
        var link = document.createElement("a");
        link.className = "csv_generator_button";
        link.textContent = "Download CSV";
        link.setAttribute("href", encodedUri);
        link.setAttribute("download", "my_data.csv");
        document.getElementById("download_csv").appendChild(link);

      }



      $scope.tableArrOpSort = [];
      AjaxService.getHistoryCSV()
      .success(function(data, status, headers) {            
        
        console.log("data: ",data);
        // CSV PARSER
        $scope.arrOp = Help.csvToArr(data.data.data,"↵");
        $scope.createCSV();
        $scope.showTable();
        $scope.showProfitChart();
      })
      .error(function(data, status, headers, config) {
        console.log("data error: ",data);
        console.log("data error: ",status);
        console.log("data error: ",headers);
      });



      $scope.getOpenProfit = function(openPrice,currentPrice,opType){
        if (opType == -1) {
          return Math.round( ((openPrice - currentPrice)*100000) );   // *10000 beacuse we use 5 digits pips
        }else{
          return Math.round( ((currentPrice - openPrice)*100000) );   // *10000 beacuse we use 5 digits pips
        }
      }

      $scope.tableArrOpOpenSort = [];
      AjaxService.getOpenCSV()
  		.success(function(data1, status, headers) {            
    		
        console.log("data1: ",data1);
        // CSV PARSER
        $scope.arrOpOpen = Help.csvToArrOpenPosition(data1.data.data,"↵");
        console.log("arrOpOpen: ",$scope.arrOpOpen);
        $scope.openOperations = $scope.arrOpOpen;
        //$scope.createCSVOpen();
        //$scope.showTableOpen();
        //$scope.showProfitChartOpen();
    	})
    	.error(function(data, status, headers, config) {
    		console.log("data error: ",data);
        console.log("data error: ",status);
        console.log("data error: ",headers);
    	});


      $scope.showProfitChart = function(){
        //SORT by: openDate,open,closeDate,close,profit,opType,cross,high,low,magic,opId
        $scope.arrOpSort = $scope.arrOp;
        $scope.arrOpSort = Help.sort($scope.arrOpSort,['magic','closeDate'],'true');

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
        $scope.arrOpSort = $scope.arrOp;
        $scope.arrOpSort = Help.sort($scope.arrOpSort,['magic','closeDate'],'true');

        var xs = {};
        var columns = [];
        $scope.arrOpSort.forEach(function(elFirst,index){
          xs[elFirst[0]['magic'].toString()] = 'x'+index;
          columns.push(['x'+index]);
          columns.push([elFirst[0]['magic'].toString()]);
          var comulativeProfit = 0;
          for(var i=elFirst.length-1;i>=0;i--){
            columns[columns.length-2].push(elFirst[i]['closeDate']);
            comulativeProfit = comulativeProfit + elFirst[i]['profit'];
            columns[columns.length-1].push( comulativeProfit  );
          }

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


      $scope.showTable = function(){

        $scope.$watch('magic',function(newValue, oldValue){
          if (newValue !== oldValue) {
            console.log("in");
            if ($scope.magic == null || $scope.magic == undefined || $scope.magic == "") {
                $scope.tableArrOpSort = $scope.arrOp;
                $scope.totalItems = $scope.tableArrOpSort.length;
                $scope.updateItems();
            }else{
              $scope.tableArrOpSort = $scope.arrOp.filter(function(value){
                if (value.magic == $scope.magic) {
                  return true;
                }else{
                  return false;
                }
              });
              $scope.totalItems = $scope.tableArrOpSort.length;
              $scope.updateItems(); 
            }
          }
        });

        $scope['sortFlagCloseDate']=false;
        $scope.prevClass='sortFlagCloseDate';
        $scope.sortTable = function(sortField,sortFlag,flagName){
          $scope[$scope.prevClass]=undefined;
          $scope[flagName]=sortFlag;
          $scope.prevClass=flagName
          console.log("$scope[flagName]: ",$scope[flagName]);
          $scope.tableArrOpSort = Help.sort($scope.tableArrOpSort,[sortField],sortFlag);
          $scope.updateItems();
        };

        $scope.updateItems = function() {
          console.log("in2");
          $scope.pagedItems = $scope.tableArrOpSort.slice($scope.itemsPerPage * ($scope.currentPage - 1), $scope.itemsPerPage * $scope.currentPage);
          console.log("$scope.pagedItems: ",$scope.pagedItems);
        };

        $scope.selectItemsPerPage = function(itemNo) {
            $scope.itemsPerPage = itemNo;
            $scope.updateItems();
        };

        $scope.setPage = function(pageNo) {
            $scope.currentPage = (pageNo === -1) ? $scope.numPages : pageNo;
            $scope.updateItems();
        };

        $scope.$watch('currentPage', function() {
            $scope.updateItems();
        });

        $scope.tableArrOpSort = $scope.arrOp;
        $scope.tableArrOpSort = Help.sort($scope.tableArrOpSort,['closeDate'],'true');
        console.log("$scope.tableArrOpSort: ",$scope.tableArrOpSort);
        $scope.currentPage = 1;
        $scope.totalItems = $scope.tableArrOpSort.length;
        $scope.itemsPerPage = 10;
        $scope.numPages = 0;

      }

      




        
}]);
