'use strict';

angular.module('webApp')
  .controller('performanceCtrl', ['$scope', '$routeParams', 'Help', 'AjaxService', 
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




      $scope.loadPerformance = function(){

        $scope.tableArrOpSort = [];
        AjaxService.getPerformance($scope.magic)
        .success(function(data, status, headers) {            
          
          console.log("data: ",data);
          // CSV PARSER
          $scope.arrPerformance = Help.csvToArrPerformance(data.data.data,"↵");

          console.log("$scope.arrPerformance: ",$scope.arrPerformance);
          $scope.profitChart('pips');
          $scope.drawDownChart('drawDownPips');

          //$scope.createCSV();
          //$scope.showTable();
          //$scope.showComulativeAllProfitChart();
        })
        .error(function(data, status, headers, config) {
          console.log("data error: ",data);
          console.log("data error: ",status);
          console.log("data error: ",headers);
        });

      }



      



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


      $scope.showAllProfitChart = function(){
        //SORT by: openDate,open,closeDate,close,profit,opType,cross,high,low,magic,opId
        $scope.arrOpSort = $scope.arrOp;
        $scope.arrOpSort = Help.sort($scope.arrOpSort,['closeDate'],'true');

        var columns = [];
        columns.push(['x']); 
        columns.push(['operation']);
        $scope.arrOpSort.forEach(function(elFirst,index){
            columns[0].push( elFirst['closeDate'] );
            columns[1].push( elFirst['profit'] );
        });

        $scope.chart_title = "Trades";

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
                x: 'x',
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

        $scope.chart_title = "Trades by algorithm";

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


      
      $scope.profitChart = function(type,event){
        if (event != undefined) {
          event.stopPropagation();
        };
        $scope.typeProfitChart = type;

        if ( type == 'pips') {
          $scope.arrOpSort = $scope.arrPerformance.netReturns_pips;
        }else if( type == 'currency' ){
          $scope.arrOpSort = $scope.arrPerformance.netReturns_Euro;
        }else if( type == 'percentage' ){
          $scope.arrOpSort = $scope.arrPerformance.netReturns_perc;
        }else if( type == 'dailyPips' ){
          $scope.arrOpSort = $scope.arrPerformance.dailyNetReturns_pips;
        }else if( type == 'dailyCurrency' ){
          $scope.arrOpSort = $scope.arrPerformance.dailyNetReturns_Euro;
        }else if( type == 'dailyPercentage' ){
          $scope.arrOpSort = $scope.arrPerformance.dailyNetReturns_perc;
        }

        var columns = [];
        columns[0] = type;
        var arrSpitted = $scope.arrOpSort.split(' ');
        arrSpitted.shift();
        columns = columns.concat( arrSpitted );
        console.log(columns);
            
        $scope.chart_title = "Profit";

        $scope.chart = c3.generate({
            padding: {
                right: 50,
                left: 50,
                top:10
            },
            zoom: {
              enabled: true
            },
            bindto: '#chart_profit',
            data: {
                columns: [columns]
            },
            axis: {
              x: {
                  tick: {
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



      $scope.drawDownChart = function(type,event){
        if (event != undefined) {
          event.stopPropagation();
        };
        $scope.typeDrawDownChart = type;

        if ( type == 'drawDownPips') {
          $scope.arrDrawDownOp = $scope.arrPerformance.drawDown_pips;
        }else if( type == 'drawDown_perc' ){
          $scope.arrDrawDownOp = $scope.arrPerformance.netReturns_Euro;
        }

        var columns = [];
        columns[0] = type;
        var arrSpitted = $scope.arrDrawDownOp.split(' ');
        arrSpitted.shift();
        columns = columns.concat( arrSpitted );
        console.log(columns);
            
        $scope.chart_title = "DrawDown";

        $scope.chart = c3.generate({
            padding: {
                right: 50,
                left: 50,
                top:10
            },
            zoom: {
              enabled: true
            },
            bindto: '#chart_drawdown',
            data: {
                columns: [columns]
            },
            axis: {
              x: {
                  tick: {
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



      $scope.comulative = true;
      $scope.typeChart = 'profit';
      $scope.comulativeProfitChart = function(type,event){
        console.log("$scope.comulativeProfitChart");
        event.stopPropagation();
        if (type != $scope.typeChart) {
          $scope.typeChart = type;
          if ($scope.comulative == false) {
            if ($scope.splitByAlgo == false) {
              $scope.comulative = true;
              $scope.showComulativeAllProfitChart();
            }else{
              $scope.comulative = true;
              $scope.showComulativeProfitChart();
            }
          }else{
            if ($scope.splitByAlgo == false) {
              $scope.comulative = false;
              $scope.showAllProfitChart();
            }else{
              $scope.comulative = false;
              $scope.showProfitChart();
            } 
          }
        }
      }

      $scope.splitByAlgo = false;
      $scope.splitByAlgoFx = function(event){
        event.stopPropagation();
        console.log("$scope.splitByAlgo: ",$scope.splitByAlgo);
        if ($scope.splitByAlgo == false) {
          if ($scope.comulative == true) {
            $scope.splitByAlgo = true;
            $scope.showComulativeProfitChart();
          }else{
            $scope.splitByAlgo = true;
            $scope.showProfitChart();
          }
        }else{
          if ($scope.comulative == true) {
            $scope.splitByAlgo = false;
            $scope.showComulativeAllProfitChart();
          }else{
            $scope.splitByAlgo = false;
            $scope.showAllProfitChart();
          }
        }

      }


      $scope.showComulativeAllProfitChart = function(){
        $scope.arrOpSort = $scope.arrOp;
        $scope.arrOpSort = Help.sort($scope.arrOpSort,['closeDate'],'true');

        var columns = [];
        var comulativeProfit = 0;
        columns.push(['x']); 
        columns.push(['total']);
        $scope.arrOpSort.forEach(function(elFirst,index){
         
            console.log("total chart el: ",elFirst);
            comulativeProfit = comulativeProfit + elFirst['profit'];
            columns[0].push(elFirst['closeDate']);
            columns[1].push( comulativeProfit  );

        });

        $scope.chart_title = "Profit";

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
                x: 'x',
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

        $scope.chart_title = "Profit by algorithm";

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
