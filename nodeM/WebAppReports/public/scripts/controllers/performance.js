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


      $scope.leverage = 1;
      $scope.stack = 10000;
      $scope.lots = 1;


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


      $scope.dataLoad = false;
      $scope.magic = '';
      $scope.loadPerformance = function(){

        if ($scope.magic != '' && $scope.magic != undefined) {
          $scope.tableArrOpSort = [];
          AjaxService.getPerformance($scope.magic)
          .success(function(data, status, headers) {            
            
            console.log("data: ",data);
            // CSV PARSER
            $scope.arrPerformance = Help.csvToArrPerformance(data.data.data,"↵");

            console.log("$scope.arrPerformance: ",$scope.arrPerformance);
            $scope.dataLoad = true;
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
        };

        

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
        arrSpitted.pop();

        console.log("arrSpitted: ",arrSpitted);
        var sum = arrSpitted.reduce(function(a, b) { 
          console.log("parseInt(a): ",parseInt(a));
          console.log("parseInt(b): ",parseInt(b));
          var tot = parseInt(a) + parseInt(b); 
          return tot;
        });
        var avg = sum / arrSpitted.length;
        console.log("sum: "+sum);
        console.log("avg: "+avg);
        var avgMsg = 'Average '+avg.toFixed(1);

        columns = columns.concat( arrSpitted );
        console.log(columns);
            
        $scope.chart_title = "Profit";

        setTimeout(function(){

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
              grid: {
                  y: {
                      lines: [
                          {value: avg, text: avgMsg, position: 'middle', class: 'label_avg'},
                      ]
                  }
              },
              color: {
                pattern: ['#6C6767','#B0BDBE','#F5FFFF','#A8A5A5']
              }
          });

        },0);

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
        arrSpitted.pop();

        console.log("arrSpitted: ",arrSpitted);
        var sum = arrSpitted.reduce(function(a, b) { 
          console.log("parseInt(a): ",parseInt(a));
          console.log("parseInt(b): ",parseInt(b));
          var tot = parseInt(a) + parseInt(b); 
          return tot;
        });
        var avg = sum / arrSpitted.length;
        console.log("sum: "+sum);
        console.log("avg: "+avg);
        var avgMsg = 'Average '+avg.toFixed(1);

        columns = columns.concat( arrSpitted );
        console.log(columns);
            
        $scope.chart_title = "DrawDown";

        setTimeout(function(){

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
              grid: {
                  y: {
                      lines: [
                          {value: avg, text: avgMsg, position: 'middle', class: 'label_avg'},
                      ]
                  }
              },
              color: {
                pattern: ['#6C6767','#B0BDBE','#F5FFFF','#A8A5A5']
              }
          });

        },0);

      }

        
}]);
