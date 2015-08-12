var http = require('http');
var zmq = require('zmq'); 

var QuotesModule = (function(){

	var _timeFrameQuotes = function(providerName){
		this.provider = providerName, 
		this.description = "This obj store all the time-frame quotes from this specific Provider and for each cross"
	}

	var _createTimeFrameQuotesObj = function(quotes_list,providerName){

		var _quotesObj = new _timeFrameQuotes(providerName);

		var arr = quotes_list.quotes;
		//console.log("arr: ",arr);
		for(var i=0; i<arr.length; i++){
		    for(var key in arr[i]){
		        var attrName = key;
		        var attrValue = arr[i][key];
		        //console.log("attrName: "+attrName+" attrValue: "+attrValue);
		        _quotesObj[attrValue]=[{"m1":[]},{"m5":[]},{"m15":[]},{"m30":[]},{"h1":[]},{"h4":[]},{"d1":[]},{"w1":[]}];
				for(var j=0; j<_quotesObj[attrValue].length; j++){
					_quotesObj[attrValue][j][Object.keys(_quotesObj[attrValue][j])[0]]=[{"v1":[]},{"v5":[]},{"v10":[]},{"v20":[]},{"v40":[]},{"v80":[]}];
		        }
		    }
		}
		return _quotesObj
	};

	var _realTimeQuotes = function(providerName){
		this.provider = providerName, 
		this.description = "This obj store all the last current quotes from this specific provider and for each cross"
	}

	var _createRealTimeQuotesObj = function(quotes_list,providerName){
		var _realTimeQuotesObj = new _realTimeQuotes(providerName);

		var arr = quotes_list.quotes;
		//console.log("arr: ",arr);
		for(var i=0; i<arr.length; i++){
		    for(var key in arr[i]){
		        var attrName = key;
		        var attrValue = arr[i][key];
		        _realTimeQuotesObj[attrValue]="";
		    }
		}
		return _realTimeQuotesObj
	};

	var _updateTimeFrameQuotesObj = function(timeFrame,timeFrameQuotesObj,realTimeQuotesObj){

		var index = "";
		switch (timeFrame){
			case "m1":
        		index = 0;
        		break;
    		case "m5":
    			index = 1;
    			break;
    		case "m15":
    			index = 2;
    			break;
    		case "m30":
    			index = 3;
    			break;
    		case "h1":
    			index = 4;
    			break;
    		case "h4":
    			index = 5;
    			break;
			case "d1":
    			index = 6;
    			break;
			case "w1":
    			index = 7;
    			break;
		}

		var tempObj = "";
		for (var key0 in realTimeQuotesObj) {
	  		if (realTimeQuotesObj.hasOwnProperty(key0)) {
	  			for (var key1 in timeFrameQuotesObj) {
	  				if (realTimeQuotesObj.hasOwnProperty(key1)) {
	  					if (key0 == key1 && key0 != "provider" && key0 != "description") {
	  						for (var j = timeFrameQuotesObj[key1][index][timeFrame].length - 1; j >= 0; j--) {
	  							tempObj = timeFrameQuotesObj[key1][index][timeFrame][j];
	  							//console.log(tempObj);
	  							//console.log("tempObj[Object.keys(tempObj)[0]]: ",tempObj[Object.keys(tempObj)[0]] );
	  							//console.log("Object.keys(tempObj)[0].split('v')[1]: ",Object.keys(tempObj)[0].split("v")[1] );
		  						if (tempObj[Object.keys(tempObj)[0]].length < Object.keys(tempObj)[0].split("v")[1] ){
		  							if (realTimeQuotesObj[key0] == null || realTimeQuotesObj[key0] == undefined) {
		  								tempObj[Object.keys(tempObj)[0]].push(realTimeQuotesObj[key0]);	
		  							};
		  						}else{
	  								if (realTimeQuotesObj[key0] == null || realTimeQuotesObj[key0] == undefined) {
		  								tempObj[Object.keys(tempObj)[0]].shift();
		  								tempObj[Object.keys(tempObj)[0]].push(realTimeQuotesObj[key0]);
		  							}
		  						}
	  						};
	  						//uncomment this file if you want to check how are stored the quotes values
	  						//console.log("timeFrameQuotesObj[key1][index][timeFrame]: ",timeFrameQuotesObj[key1][index][timeFrame]);
	  					}	
					}
				}
	  		}
		};

		return true;
	};

	return{
    	createTimeFrameQuotesObj: function(quotes_list,providerName){ 
      		return _createTimeFrameQuotesObj(quotes_list,providerName);  
    	},
    	createRealTimeQuotesObj:  function(quotes_list,providerName){ 
      		return _createRealTimeQuotesObj(quotes_list,providerName);  
    	},
    	updateTimeFrameQuotesObj: function(timeFrame,timeFrameQuotesObj,realTimeQuotesObj){
    		return _updateTimeFrameQuotesObj(timeFrame,timeFrameQuotesObj,realTimeQuotesObj);
    	}
    }

})();

var sockPub = zmq.socket('pub');
var sockSubFromQuotesProvider = zmq.socket('sub');
var sockSubFromSignalProvider = zmq.socket('sub');

sockSubFromQuotesProvider.bindSync('tcp://127.0.0.1:50025');
sockSubFromSignalProvider.bindSync('tcp://127.0.0.1:50026');    
sockPub.bindSync('tcp://127.0.0.1:50027');  

//-------------------------------------------------------------------------------------------------------------------------------
// METATRADER PUB TO NODEJS TO MATLAB

var Mt4configQuotes = require('./mt4_config_quotes');
var quotesObj_provider_Mt4 = QuotesModule.createTimeFrameQuotesObj(Mt4configQuotes,"MT4");
var realTimeQuotesObj_provider_Mt4 = QuotesModule.createRealTimeQuotesObj(Mt4configQuotes,"MT4");

/*setInterval(function() {    

	var isUpdated = QuotesModule.updateTimeFrameQuotesObj("m1",quotesObj_provider_Mt4,realTimeQuotesObj_provider_Mt4);

	//SEND LAST 80 values at 30m
  	//.................
  	//SEND LAST 40 values at 30m
  	//sockPub.send(['EURUSD@30m@40', message.toString()]);
  	//SEND LAST 20 values at 30m
  	//...............
  	//SEND LAST 10 values at 30m
  	//...............
  	//SEND LAST 5 values at 30m
  	//.................
  	//SEND LAST 1 values at 30m


},3000);  // 1M
setInterval(function() {         },300000);  // 5M
setInterval(function() {         },900000);  // 15M
setInterval(function() {         },1800000);  // 30M
setInterval(function() {         },3600000);  // 60M - 1H
setInterval(function() {         },14400000);  // 240M - 4H
setInterval(function() {         },86400000);  // 1440M - 24H
setInterval(function() {         },604800000);  // 10080M - 1W*/

sockSubFromSignalProvider.subscribe('MT4');
sockSubFromQuotesProvider.on('message', function(topic, message) {
  console.log('received a message related to:', topic.toString(), 'containing message:', message.toString());
  
  	//EX TOPIC: MT4@REALQUOTES@EURUSD
  	//EX MESSAGE: EURUSD@12.5
  	console.log("message.toString(): ",message.toString());
  	var topicArr = topic.toString().split("@");
  	var messageArr = message.toString().split("@");
  	switch (topicArr[0]) {
	    case "MT4":
	    	if (topicArr[1] == "REALQUOTES") {
	    		for (var key in realTimeQuotesObj_provider_Mt4) {
			  		if (realTimeQuotesObj_provider_Mt4.hasOwnProperty(key)) {
			  			if (key == messageArr[0]) {
			  				realTimeQuotesObj_provider_Mt4[key] = messageArr[1];
			  				console.log("realTimeQuotesObj_provider_Mt4[key]: ",realTimeQuotesObj_provider_Mt4[key]);
			  			};	
			  		}
				}
	    	}
	        break;
	    case "PROVIDER1":
	    	break;
	    case "PROVIDER2":
	    	break;
	}
});

//----------------------------------------------------------------------------------------------------------------------------
// MATLAB PUB TO NODEJS TO METATRADER

sockSubFromSignalProvider.subscribe('OPEN$EURUSD');
sockSubFromSignalProvider.subscribe('CLOSE$EURUSD');

sockSubFromSignalProvider.on('message', function(messageSub) {
  var message = messageSub.toString().split(" ");
  console.log('received a message related to:', message[0], 'containing message:', message[1]);

  if (message[0] == "OPEN@EURUSD") {
    console.log("Sending Open trade msg for topic: "+message[0]+ "to Metatrader");
    sockPub.send(message[0] + ";" +message[1]);
  };
  
  if (message[0] == "CLOSE@EURUSD") {
    console.log("Sending Open trade msg for topic: "+message[0]+ "to Metatrader");
    sockPub.send(message[0] + ";" +message[1]);
  };

});




