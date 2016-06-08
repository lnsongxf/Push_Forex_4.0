console.log("started worker");

if (!Array.prototype.last){
    Array.prototype.last = function(){
        return this[this.length - 1];
    };
};
Array.prototype.max = function() {
  return Math.max.apply(null, this);
};
Array.prototype.min = function() {
  return Math.min.apply(null, this);
};

var QuotesModule = (function(){

	var _timeFrameQuotes = function(providerName){
		this.provider = providerName, 
		this.description = "This obj store all the time-frame quotes from this specific Provider and for each cross"
	};

	var _createTimeFrameQuotesObj = function(quotes_list,providerName){
		if (quotes_list == null || quotes_list == undefined || providerName == null || providerName == undefined) {
			console.log('quotes_list %s or providerName '+quotes_list,providerName+' null or not defined into _createTimeFrameQuotesObj');
			return null;
		};
		var _quotesObj = new _timeFrameQuotes(providerName);

		var arr = quotes_list.quotes;
		for(var i=0; i<arr.length; i++){
		    for(var key in arr[i]){
		        var attrName = key;
		        var attrValue = arr[i][key];
		        _quotesObj[attrValue]=[{"m1":[]},{"m5":[]},{"m15":[]},{"m30":[]},{"h1":[]},{"h4":[]},{"d1":[]},{"w1":[]}];
				for(var j=0; j<_quotesObj[attrValue].length; j++){
					_quotesObj[attrValue][j][Object.keys(_quotesObj[attrValue][j])[0]]=[{"v1":[]},{"v5":[]},{"v10":[]},{"v20":[]},{"v40":[]},{"v100":[]}];
		        }
		    }
		}
		console.log("created new TimeFrameQuotesObj: "+JSON.stringify(_quotesObj)+ " providerName: "+providerName);  
		return _quotesObj
	};


	var _realTimeQuotes = function(providerName){
		this.provider = providerName, 
		this.description = "This obj store all the last current quotes from this specific provider and for each cross"
	};

	var _createRealTimeQuotesObj = function(quotes_list,providerName){
		if (quotes_list == null || quotes_list == undefined || providerName == null || providerName == undefined) {
			console.log('quotes_list '+quotes_list+' or providerName '+providerName+' null or not defined into _createRealTimeQuotesObj');
			return null;
		};
		var _realTimeQuotesObj = new _realTimeQuotes(providerName);

		var arr = quotes_list.quotes;
		for(var i=0; i<arr.length; i++){
		    for(var key in arr[i]){
		        var attrName = key;
		        var attrValue = arr[i][key];
		        //_realTimeQuotesObj[attrValue]="";  17/03 changed
		        _realTimeQuotesObj[attrValue]={
		        	"m1":{open:null,max:null,min:null,close:null,volume:0,dateTime:null},
		        	"m5":{open:null,max:null,min:null,close:null,volume:0,dateTime:null},
		        	"m15":{open:null,max:null,min:null,close:null,volume:0,dateTime:null},
		        	"m30":{open:null,max:null,min:null,close:null,volume:0,dateTime:null},
		        	"h1":{open:null,max:null,min:null,close:null,volume:0,dateTime:null},
		        	"h4":{open:null,max:null,min:null,close:null,volume:0,dateTime:null},
		        	"d1":{open:null,max:null,min:null,close:null,volume:0,dateTime:null},
		        	"w1":{open:null,max:null,min:null,close:null,volume:0,dateTime:null}
		        }
		    }
		}

		//console.log("created new realTimeQuotesObj: "+JSON.stringify( _realTimeQuotesObj)+ " providerName: "+providerName);
		return _realTimeQuotesObj
	};

	var _updateRealTimeQuotesObj = function(platform,messageArr){
		if (platform == null || platform == undefined || messageArr == null || messageArr == undefined) {
			console.log('searchObjRealTimeQuote '+searchObjRealTimeQuote+' or messageArr '+messageArr+' null or not defined into _updateRealTimeQuotesObj');
			return null;
		};

		//messageArr: [event.data.d[j].cross,open,high,low,close,volume];
		
		var realOpen = messageArr[1];
		var realMax = messageArr[2];
		var realMin = messageArr[3];
		var realClose = messageArr[4];
		var realVolume = messageArr[5];
		var cross = messageArr[0];
		var dateTime = messageArr[6];

		if (runningProviderRealTimeObjs[platform] == null || runningProviderRealTimeObjs[platform] == undefined) {
			console.log("Unable to find platform " + platform);
			return null;
		}
		
		if (runningProviderRealTimeObjs[platform][cross] == null || runningProviderRealTimeObjs[platform][cross] == undefined) {
			console.log("Unable to find cross " + cross + " in platform " + platform);
			return null;
		}		
			  				
		for( timeFrame in runningProviderRealTimeObjs[platform][cross] ){
		    if (realMax > runningProviderRealTimeObjs[platform][cross][timeFrame]['max'] || runningProviderRealTimeObjs[platform][cross][timeFrame]['max'] == null){
			    runningProviderRealTimeObjs[platform][cross][timeFrame]['max'] = realMax;
			}
			if (realMin < runningProviderRealTimeObjs[platform][cross][timeFrame]['min'] || runningProviderRealTimeObjs[platform][cross][timeFrame]['min'] == null){
			    runningProviderRealTimeObjs[platform][cross][timeFrame]['min'] = realMin;
			}
			if( runningProviderRealTimeObjs[platform][cross][timeFrame]['open']  == null){
				runningProviderRealTimeObjs[platform][cross][timeFrame]['open'] = realOpen;
			}
			runningProviderRealTimeObjs[platform][cross][timeFrame]['close'] = realClose;
			runningProviderRealTimeObjs[platform][cross][timeFrame]['dateTime'] = dateTime;
			if (timeFrame == 'm1') {
				runningProviderRealTimeObjs[platform][cross][timeFrame]['volume'] = parseInt(realVolume);
			}
							
			if (cross == 'EURUSD' && timeFrame == 'm1') {
				//console.log("messageArr: "+JSON.stringify(messageArr) );
				//console.log("runningProviderRealTimeObjs[platform][cross][timeFrame]: "+JSON.stringify(runningProviderRealTimeObjs[platform]['EURUSD']['m1']) );
			};
		}
		return true;
	};

	var _createNewQuote = function(tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty,cross,timeFrame){
			
		//tmpRealTimeQuoteProperty is the first "search key" used in the global runningProviderRealTimeObjs (es: REALTIMEQUOTE$MT4$ACTIVTRADES)
		//timeframe is the value used to specify the type of timeframe (ex: m1,m5,m15,..). Its used also like 

		//ex: single quote == 11313,11315,11313,11316,30,03/18/2016 01:24  -->   apertura,massimo,minimo,chiusura,volume,time

		var open = runningProviderRealTimeObjs[tmpRealTimeQuoteProperty][cross][timeFrame]['open'];
		var max = runningProviderRealTimeObjs[tmpRealTimeQuoteProperty][cross][timeFrame]['max'];
		var min = runningProviderRealTimeObjs[tmpRealTimeQuoteProperty][cross][timeFrame]['min'];
		var close = runningProviderRealTimeObjs[tmpRealTimeQuoteProperty][cross][timeFrame]['close'] ;
		var volume = runningProviderRealTimeObjs[tmpRealTimeQuoteProperty][cross][timeFrame]['volume'];  //needed only for m1
		//var currentdate = new Date(); 
		//var datetime = currentdate.getDate()+"/"+(currentdate.getMonth()+1)+"/"+currentdate.getFullYear()+" "+currentdate.getHours()+":"+currentdate.getMinutes(); 
		var datetime = runningProviderRealTimeObjs[tmpRealTimeQuoteProperty][cross][timeFrame]['dateTime']; 

		if (timeFrame != 'm1') {

			var prevTimeFrame = "";  // this variable is used to store the previous timeframe (es: i want to update m5 array i have to consider m1 array. In this case prevTimeFrame = m1 )
			var index = "";
			numValues = "";
			switch (timeFrame){
	    		case "m5":
	    			prevTimeFrame = 'm1';
	    			index = 0;
	    			numValues = 5;  // m1 x 5 = m5
	    			break;
	    		case "m15":
	    			prevTimeFrame = 'm5';
	    			index = 1;
	    			numValues = 3;   // m5 x 3 = m15
	    			break;
	    		case "m30":
	    			prevTimeFrame = 'm15';
	    			index = 2;
	    			numValues = 2;   // m15 x 2 = m30
	    			break;
	    		case "h1":
	    			prevTimeFrame = 'm30';
	    			index = 3;
	    			numValues = 2;  // m30 x 2 = h1
	    			break;
	    		case "h4":
	    			prevTimeFrame = 'h1';
	    			index = 4;
	    			numValues = 4;  // h1 x 4 = h4
	    			break;
				case "d1":
	    			prevTimeFrame = 'h4';
	    			index = 5;
	    			numValues = 6;  // h4 x 6 = d1
	    			break;
				case "w1":
	    			prevTimeFrame = 'd1';
	    			index = 6;
	    			numValues = 5;  // d1 x 7 = w1
	    			break;
			}

			var tmpArrPreviousTimeFrameQuotesV10 = runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty][cross][index][prevTimeFrame][2]['v10']; //we are going to get the previous timeframe array(es: if timeframe is m5 we get m1)
			if( tmpArrPreviousTimeFrameQuotesV10.length >= numValues ){
				volume = 0;
				
				for(var i = numValues-1; i >= 0; i--){  //We iterate on each value of the previuos timeframe array (es: id m5, previous array is m1. In this case we iterate on the previous 5 values)
					var tmpArrSingleQuote = tmpArrPreviousTimeFrameQuotesV10[tmpArrPreviousTimeFrameQuotesV10.length-1-i].split(',');
					volume = volume + parseInt(tmpArrSingleQuote[4]);
				}
			}else{
				if (cross == 'EURUSD') {
					console.log('Error on timeframe '+timeFrame+', cross '+ cross+' tmpArrPreviousTimeFrameQuotesV10 :'+JSON.stringify(tmpArrPreviousTimeFrameQuotesV10) );
				}
			}

		}

		//11313,11315,11313,11316,30,03/18/2016 01:24  -->   apertura,massimo,minimo,chiusura,volume,time
		var newQuote =  open+','+max+','+min+','+close+','+volume+','+datetime;

		if (timeFrame == 'm1' || timeFrame == 'm30' || timeFrame == 'm15'){ 
			if( cross == 'EURUSD' ) {
				console.log('Creating new quote - Cross:'+cross+' timeframe:'+timeFrame+' newQuote:'+newQuote);
				console.log('Resetting values for cross '+cross+' timeframe '+timeFrame+' : '+JSON.stringify(runningProviderRealTimeObjs[tmpRealTimeQuoteProperty][cross][timeFrame]) );
			}
		};

		//Resetting runningProviderRealTimeObjs[tmpRealTimeQuoteProperty] for the this specific cross
		runningProviderRealTimeObjs[tmpRealTimeQuoteProperty][cross][timeFrame]['open'] = null
		runningProviderRealTimeObjs[tmpRealTimeQuoteProperty][cross][timeFrame]['max'] = null;
		runningProviderRealTimeObjs[tmpRealTimeQuoteProperty][cross][timeFrame]['min'] = null;
		runningProviderRealTimeObjs[tmpRealTimeQuoteProperty][cross][timeFrame]['close'] = null;
		runningProviderRealTimeObjs[tmpRealTimeQuoteProperty][cross][timeFrame]['volume'] = 0;

		return newQuote;
	};

	

	var _updateTimeFrameQuotesObj = function(timeFrame,timeFrameQuotesObj,realTimeQuotesObj,tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty){
                                   //(timeFrameToUpdate,runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty],runningProviderRealTimeObjs[tmpRealTimeQuoteProperty],tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty);
		if (timeFrame == null || timeFrame == undefined || timeFrameQuotesObj == null || timeFrameQuotesObj == undefined || realTimeQuotesObj == null || realTimeQuotesObj == undefined ) {
			console.log('In _updateTimeFrameQuotesObj timeframe or timeFrameQuotesObj or realTimeQuotesObj is notDefined/null');
			return null;
		};

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
			if (realTimeQuotesObj[key0] != ""){
		  		if (realTimeQuotesObj.hasOwnProperty(key0)) {
		  			for (var key1 in timeFrameQuotesObj) {
		  				if (realTimeQuotesObj.hasOwnProperty(key1)) {
		  					if (key0 == key1 && key0 != "provider" && key0 != "description") {

		  						console.log("TIMEFRAME TO UPDATE: "+timeFrame);
								
	  							//AND WE CLEAN THE REAL TIME ARRAY OBJ. THIS RRAY STORE THE LAST REALTIME VALUES INTO ON1 MINUTE
			  						var newQuote = _createNewQuote(tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty,key0,timeFrame);

			  						var tmpNewQuote = newQuote.split(',');
			  						if ( tmpNewQuote[0] != null && tmpNewQuote[1] != null && tmpNewQuote[2] != null && tmpNewQuote[3] != null && tmpNewQuote[0] != 'null' && tmpNewQuote[1] != 'null' && tmpNewQuote[2] != 'null' && tmpNewQuote[3] != 'null') {
				  						for (var j = 0; j <= timeFrameQuotesObj[key1][index][timeFrame].length - 1; j++) {
				  							tempObj = timeFrameQuotesObj[key1][index][timeFrame][j];

					  						if (tempObj[Object.keys(tempObj)[0]].length < Object.keys(tempObj)[0].split("v")[1] ){
		
					  							if (realTimeQuotesObj[key0] != "" && realTimeQuotesObj[key0] != null && realTimeQuotesObj[key0] != undefined ) {
					  								//key0 is the cross (es: EURUSD) and its used like second "search key" in the global runningProviderRealTimeObjs
					  								//realTimeQuotesObj[key0] is the array with the last 60 seconds realtime quotes
					  								//tmpRealTimeQuoteProperty is the first "search key" used in the global runningProviderRealTimeObjs (es: REALTIMEQUOTE$MT4$ACTIVTRADES)
					  								//tmpTimeFrameQuoteProperty is the first "search key" used in the global runningProviderTimeFrameObjs (es: TIMEFRAMEQUOTE$MT4$ACTIVTRADES)
					  								//timeframe is the value used to specify the type of timeframe (ex: m1,m5,m15,..). Its used also like 
					  								
					  								//Example of research in runningProviderTimeFrameObjs: runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty][key0][index0][timeFrame][index1]	--> return one array of values
					  								//Example of research in runningProviderRealTimeObjs: runningProviderRealTimeObjs[tmpRealTimeQuoteProperty][key0] --> return one array of values	
					  								
					  								tempObj[Object.keys(tempObj)[0]].push( newQuote );	

					  								/*
					  								//console.log.trace('Updated timeFrameQuotesObj(operation:adding) : ' + tempObj[Object.keys(tempObj)[0]].toString() + ' for TimeFrame: '+timeFrame+ ' for number of values: '+Object.keys(tempObj)[0]+' on Cross: '+key1 );
					  								var topic = key1;
					  								//"TIMEFRAMEQUOTE@MT4@ACTIVTRADES   +     @EURUSD     +     @m1     +    @v1 
					  								var topicToSignalProvider = timeFrameQuotesObj.provider+"@"+key1+"@"+timeFrame+"@"+Object.keys(tempObj)[0];
					  								if (topicToSignalProvider == null || topicToSignalProvider == undefined ) {
														console.log.error('timeFrameQuotesObjProvider: ' +JSON.stringify(timeFrameQuotesObj.provider) + ' key1: ' + key1 + ' timeFrame: ' +timeFrame + ' totValues: ' + JSON.stringify( Object.keys(tempObj)[0] ) + ' In _updateTimeFrameQuotesObj topicToSignalProvider is notDefined/null');
													}else if (tempObj[Object.keys(tempObj)[0]].toString() == null || tempObj[Object.keys(tempObj)[0]].toString() == undefined ) {
														console.log.error('objWithMessageToSend: '+ JSON.stringify(tempObj) + ' _updateTimeFrameQuotesObj is sending a message (Quotes) notDefined/null');
													}else{
					  									sockPub.send([topicToSignalProvider, tempObj[Object.keys(tempObj)[0]].join(";")]);
					  									testSockPub.send([topicToSignalProvider, tempObj[Object.keys(tempObj)[0]].join(";")]);
					  									if (timeFrame == 'm5' && Object.keys(tempObj)[0].split("v")[1] == '1') {
															console.log.info('Sent new timeFrame value message (ex: logs only for m5 and v1): '+tempObj[Object.keys(tempObj)[0]].join(";")+ 'for TimeFrame: '+timeFrame+ 'for Cross: '+key1+' on topic: '+topicToSignalProvider);
					  									}else if (timeFrame == 'm30' && Object.keys(tempObj)[0].split("v")[1] == '5') {
															console.log.info('Sent new timeFrame value message (ex: logs only for m30 and v5): '+tempObj[Object.keys(tempObj)[0]].join(";")+ 'for TimeFrame: '+timeFrame+ 'for Cross: '+key1+' on topic: '+topicToSignalProvider);
					  									}
					  								}*/
					  							}else{
					  								//if (topicToSignalProvider == null || topicToSignalProvider == undefined ) {
													//	console.log.error('In _updateTimeFrameQuotesObj, realTimeQuotesObj[key0] is null');
													//};
					  							}
					  						}else{
		
				  								if (realTimeQuotesObj[key0] != "" && realTimeQuotesObj[key0] != null && realTimeQuotesObj[key0] != undefined) {
		
					  								tempObj[Object.keys(tempObj)[0]].shift();
					  								
					  								tempObj[Object.keys(tempObj)[0]].push(newQuote);

					  								/*
					  								//console.log.trace('Updated timeFrameQuotesObj(operation:shifting) : ' + tempObj[Object.keys(tempObj)[0]].toString() + 'for TimeFrame: '+timeFrame+ ' for number of values: '+Object.keys(tempObj)[0]+' for Cross: '+key1 );
					  								//"TIMEFRAMEQUOTE@MT4@ACTIVTRADES   +     @EURUSD     +     @m1     +    @v10 
					  								var topicToSignalProvider = timeFrameQuotesObj.provider+"@"+key1+"@"+timeFrame+"@"+Object.keys(tempObj)[0];
					  								if (topicToSignalProvider == null || topicToSignalProvider == undefined ) {
														console.log.error('timeFrameQuotesObjProvider: '+ JSON.stringify(timeFrameQuotesObj.provider) + ' key1: ' + key1 + ' timeFrame: '+ timeFrame + 'totValues: ' + JSON.stringify(Object.keys(tempObj)[0]) +' In _updateTimeFrameQuotesObj topicToSignalProvider is notDefined/null');
													}else if (tempObj[Object.keys(tempObj)[0]].toString() == null || tempObj[Object.keys(tempObj)[0]].toString() == undefined ) {
														console.log.error('objWithMessageToSend: ' + JSON.stringify(tempObj) + ' _updateTimeFrameQuotesObj is sending a message (Quotes) notDefined/null');
													}else{
					  									sockPub.send([topicToSignalProvider, tempObj[Object.keys(tempObj)[0]].join(";")]);
					  									testSockPub.send([topicToSignalProvider, tempObj[Object.keys(tempObj)[0]].join(";")]);
					  									if (timeFrame == 'm5' && Object.keys(tempObj)[0].split("v")[1] == '1') {
					  										console.log.info('Sent new timeFrame value message (logs only for m5 and v1): '+tempObj[Object.keys(tempObj)[0]].join(";")+ 'for TimeFrame: '+timeFrame+ 'for Cross: '+key1+' on topic: '+topicToSignalProvider);
					  									}else if (timeFrame == 'm30' && Object.keys(tempObj)[0].split("v")[1] == '5') {
															console.log.info('Sent new timeFrame value message (ex: logs only for m30 and v5): '+tempObj[Object.keys(tempObj)[0]].join(";")+ 'for TimeFrame: '+timeFrame+ 'for Cross: '+key1+' on topic: '+topicToSignalProvider);
					  									}
					  								}*/
					  							}else{
					  								//if (topicToSignalProvider == null || topicToSignalProvider == undefined ) {
													//	console.log.error('In _updateTimeFrameQuotesObj, realTimeQuotesObj[key0] is null');
													//};
					  							}
					  						}
					  						timeFrameQuotesObj[key1][index][timeFrame][j] = tempObj;
				  						}
				  					}
			  					
		  						//uncomment this file if you want to check how are stored the quotes values
		  						//console.log.trace('Updated timeFrameQuotesObj[key1][index][timeFrame]: ' + JSON.stringify(timeFrameQuotesObj[key1][index][timeFrame] ) +  ' TimeFrame Obj Updated');
		  						//console.log("timeFrameQuotesObj[key1][index][timeFrame]: ",timeFrameQuotesObj[key1][index][timeFrame]);
		  					}	
						}
					}
		  		}
		  	}
		};

		return timeFrameQuotesObj;
	};


	return{
    	createTimeFrameQuotesObj: function(quotes_list,providerName){ 
      		return _createTimeFrameQuotesObj(quotes_list,providerName);  
    	},
    	createOneMinuteOpenObj: function(quotes_list,providerName){ 
    		return _createOneMinuteOpenObj(quotes_list,providerName)
    	},
    	createRealTimeQuotesObj:  function(quotes_list,providerName){ 
      		return _createRealTimeQuotesObj(quotes_list,providerName);  
    	},
    	updateTimeFrameQuotesObj: function(timeFrame,timeFrameQuotesObj,realTimeQuotesObj,tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty){
    		return _updateTimeFrameQuotesObj(timeFrame,timeFrameQuotesObj,realTimeQuotesObj,tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty);
    	},
    	updateRealTimeQuotesObj: function(searchObjRealTimeQuote,messageArr){
    		return _updateRealTimeQuotesObj(searchObjRealTimeQuote,messageArr);
    	},
    	importHistoryTimeFrameQuotesObj: function(searchObjTimeFrameQuote,messageArr){
    		return _importHistoryTimeFrameQuotesObj(searchObjTimeFrameQuote,messageArr);
    	}
    }
    
})();

// TO CHANGE

var configQuotesList = {
    "quotes":[
    	{"value":"AUDNZD"},{"value":"AUDCAD"},{"value":"AUDCHF"},{"value":"AUDJPY"},{"value":"AUDUSD"},{"value":"CADJPY"},{"value":"CADCHF"},{"value":"CHFJPY"},{"value":"EURUSD"},{"value":"EURGBP"},{"value":"EURAUD"},{"value":"EURCHF"},{"value":"EURJPY"},{"value":"EURNZD"},{"value":"EURCAD"},{"value":"GBPUSD"},{"value":"GBPCHF"},{"value":"GBPJPY"},{"value":"GBPAUD"},{"value":"GBPCAD"},{"value":"NZDJPY"},{"value":"NZDUSD"},{"value":"USDCHF"},{"value":"USDCAD"},{"value":"USDJPY"},{"value":"USDCHF"}
    ]
}


var runningProviderTimeFrameObjs = {};
var runningProviderRealTimeObjs = {};

var newObjTimeFrameQuote = "TIMEFRAMEQUOTE$BACKTEST$BACKTEST";
var newObjRealTimeQuote = "REALTIMEQUOTE$BACKTEST$BACKTEST";
var newValuePropertyTimeFrameQuote = "TIMEFRAMEQUOTE@BACKTEST@BACKTEST";
var newValuePropertyRealTimeQuote = "REALTIMEQUOTE@BACKTEST@BACKTEST";  
runningProviderTimeFrameObjs[newObjTimeFrameQuote] = QuotesModule.createTimeFrameQuotesObj(configQuotesList,newValuePropertyTimeFrameQuote);
runningProviderRealTimeObjs[newObjRealTimeQuote] = QuotesModule.createRealTimeQuotesObj(configQuotesList,newValuePropertyRealTimeQuote);

var tmpTimeFrameQuoteProperty = "TIMEFRAMEQUOTE$BACKTEST$BACKTEST";
var tmpRealTimeQuoteProperty = "REALTIMEQUOTE$BACKTEST$BACKTEST";
var searchObjRealTimeQuote = "REALTIMEQUOTE$BACKTEST$BACKTEST";

/*   EURGBP_2016-01-21_2016-05-17
52.33.13.29   trader abc123
2016.01.21,13:47,0.77152,0.77166,0.77142,0.77166,254
time open high lowclose volume
*/

var CSVToArray = function( strData, strDelimiter ){
	// This will parse a delimited string into an array of
    // arrays. The default delimiter is the comma, but this
    // can be overriden in the second argument.

    // Check to see if the delimiter is defined. If not,
    // then default to comma.
    strDelimiter = (strDelimiter || ",");
    // Create a regular expression to parse the CSV values.
    var objPattern = new RegExp(
        (
            // Delimiters.
            "(\\" + strDelimiter + "|\\r?\\n|\\r|^)" +
            // Quoted fields.
            "(?:\"([^\"]*(?:\"\"[^\"]*)*)\"|" +
            // Standard fields.
            "([^\"\\" + strDelimiter + "\\r\\n]*))"
        ),
        "gi"
        );
    // Create an array to hold our data. Give the array
    // a default empty first row.
    var arrData = [[]];
    // Create an array to hold our individual pattern
    // matching groups.
    var arrMatches = null;
    // Keep looping over the regular expression matches
    // until we can no longer find a match.
    while (arrMatches = objPattern.exec( strData )){
        // Get the delimiter that was found.
        var strMatchedDelimiter = arrMatches[ 1 ];
        // Check to see if the given delimiter has a length
        // (is not the start of string) and if it matches
        // field delimiter. If id does not, then we know
        // that this delimiter is a row delimiter.
        if (
            strMatchedDelimiter.length &&
            (strMatchedDelimiter != strDelimiter)
            ){
            // Since we have reached a new row of data,
            // add an empty row to our data array.
            arrData.push( [] );
        }
        // Now that we have our delimiter out of the way,
        // let's check to see which kind of value we
        // captured (quoted or unquoted).
        if (arrMatches[ 2 ]){
            // We found a quoted value. When we capture
            // this value, unescape any double quotes.
            var strMatchedValue = arrMatches[ 2 ].replace(
                new RegExp( "\"\"", "g" ),
                "\""
                );
        } else {
            // We found a non-quoted value.
            var strMatchedValue = arrMatches[ 3 ];
        }
        // Now that we have our value string, let's add
        // it to the data array.
        arrData[ arrData.length - 1 ].push( strMatchedValue );
    }
    // Return the parsed data.
    return( arrData );
}



var tmpTimeFrameQuoteProperty = "TIMEFRAMEQUOTE$BACKTEST$BACKTEST";
//EX Setting: {cross:'EURUSD','dataLenght':'v1'},{cross:'EURGBP','dataLenght':'v10'}
var setting = [];
var indexQuote = 1;

self.addEventListener('message',  function(event){
	console.log("message: ",event);
	//EX: {cross:cross_list[i].cross,history_quotes:store_history_in_memory,from:from,to:to,dataLenght:cross_list[i].dataLenght}

	if (event.data.type == 'initialHistoryQuotes') {
		console.log("initialHistoryQuotes");
		for(var j=0; j<=event.data.d.length-1; j++){
			//console.log("event.data.d[j].cross: ",event.data.d[j].cross);
			//console.log("dataLenght: ",event.data.d[j].dataLenght);
			setting.push( {'cross':event.data.d[j].cross,'dataLenght':event.data.d[j].dataLenght} );
			console.log("setting: ",setting);
		    var history_quote_arr = CSVToArray(event.data.d[j].history_quotes,';');
		    console.log("history_quote_arr: ",history_quote_arr);
		    for(var i=1; i<=history_quote_arr.length; i++){

		    	var tmpQuote = history_quote_arr[i-1].toString().split(',');
		    	var dateTime = tmpQuote[0]+" "+tmpQuote[1];
		    	var open = tmpQuote[2];
		    	var high = tmpQuote[3];
		    	var low = tmpQuote[4];
		    	var close = tmpQuote[5];
		    	var volume = tmpQuote[6];

		    	var messageArr = [event.data.d[j].cross,open,high,low,close,volume,dateTime];
		    	console.log("messageArr: ",messageArr);
				var result = QuotesModule.updateRealTimeQuotesObj(searchObjRealTimeQuote,messageArr);

				var timeFrameToUpdate = 'm1';   //m1,m5,m15,m30,h1,h4,d1,w1
				var new_timeFrameQuotesObj = QuotesModule.updateTimeFrameQuotesObj(timeFrameToUpdate,runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty],runningProviderRealTimeObjs[tmpRealTimeQuoteProperty],tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty);
				runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty] = new_timeFrameQuotesObj;

				if ( (i%5) == 0 ) {
					timeFrameToUpdate = 'm5';   //m1,m5,m15,m30,h1,h4,d1,w1
					new_timeFrameQuotesObj = QuotesModule.updateTimeFrameQuotesObj(timeFrameToUpdate,runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty],runningProviderRealTimeObjs[tmpRealTimeQuoteProperty],tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty);
					runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty] = new_timeFrameQuotesObj;
				};
				if ( (i%15) == 0 ) {
					timeFrameToUpdate = 'm15';   //m1,m5,m15,m30,h1,h4,d1,w1
					new_timeFrameQuotesObj = QuotesModule.updateTimeFrameQuotesObj(timeFrameToUpdate,runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty],runningProviderRealTimeObjs[tmpRealTimeQuoteProperty],tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty);
					runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty] = new_timeFrameQuotesObj;
				};
				if ( (i%30) == 0 ) {
					timeFrameToUpdate = 'm30';   //m1,m5,m15,m30,h1,h4,d1,w1
					var new_timeFrameQuotesObj = QuotesModule.updateTimeFrameQuotesObj(timeFrameToUpdate,runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty],runningProviderRealTimeObjs[tmpRealTimeQuoteProperty],tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty);
					runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty] = new_timeFrameQuotesObj;
				};
				if ( (i%60) == 0) { 
					timeFrameToUpdate = 'h1';   //m1,m5,m15,m30,h1,h4,d1,w1
					var new_timeFrameQuotesObj = QuotesModule.updateTimeFrameQuotesObj(timeFrameToUpdate,runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty],runningProviderRealTimeObjs[tmpRealTimeQuoteProperty],tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty);
					runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty] = new_timeFrameQuotesObj;
				};
				if ( (i%240) == 0 ) {
					timeFrameToUpdate = 'h4';   //m1,m5,m15,m30,h1,h4,d1,w1
					var new_timeFrameQuotesObj = QuotesModule.updateTimeFrameQuotesObj(timeFrameToUpdate,runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty],runningProviderRealTimeObjs[tmpRealTimeQuoteProperty],tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty);
					runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty] = new_timeFrameQuotesObj;
				};
				if ( (i%1440) == 0 ) {
					timeFrameToUpdate = 'd1';   //m1,m5,m15,m30,h1,h4,d1,w1
					var new_timeFrameQuotesObj = QuotesModule.updateTimeFrameQuotesObj(timeFrameToUpdate,runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty],runningProviderRealTimeObjs[tmpRealTimeQuoteProperty],tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty);
					runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty] = new_timeFrameQuotesObj;
				};
				if ( (i%7200) == 0 ) {
					timeFrameToUpdate = 'w1';   //m1,m5,m15,m30,h1,h4,d1,w1
					var new_timeFrameQuotesObj = QuotesModule.updateTimeFrameQuotesObj(timeFrameToUpdate,runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty],runningProviderRealTimeObjs[tmpRealTimeQuoteProperty],tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty);
					runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty] = new_timeFrameQuotesObj;
				};
			}
		}
		console.log('runningProviderTimeFrameObjs["TIMEFRAMEQUOTE$BACKTEST$BACKTEST"]: ',runningProviderTimeFrameObjs );
	}else if (event.data.type == 'messageFromSignalProvider') {

		console.log('Message from signal provider: ' + event.data.d);
		var data = [];
		Array.prototype.slice.call( event.data.d ).forEach(function(arg) {
	        data.push(arg.toString());
	    });
	  	var topic = data[0];
	  	var message = data[1];
	  	console.log('Received message from Signal Provider: '+message+ 'on topic: '+topic);

	  	switch (topic) {
	  		case "NEWTOPICFROMSIGNALPROVIDER":

	  			var newTopic = message.split('@');
	  			if (newTopic[0] == 'OPERATIONS') {
	  				//EX: OPERATIONS@ACTIVTRADES@EURUSD
	  				self.postMessage({'d':message,'type':'subscribe'});
					//sockSubFromSignalProvider.subscribe(message);
	  			}else if (newTopic[0] == 'STATUS'){
	  				//EX: STATUS@EURUSD@111		
	  				self.postMessage({'d':message,'type':'subscribe'});
					//sockSubFromSignalProvider.subscribe(message);
	  			}else{
	  				console.log("error message: ",newTopic[0])
	  			}
				break;

			case "DELETETOPICQUOTES":
				//EX: OPERATIONS@ACTIVTRADES@EURUSD STATUS@EURUSD@111	
				var deleteTopic = message.split('@');
	  			if (deleteTopic[0] == 'OPERATIONS') {
	  				self.postMessage({'d':message,'type':'unsubscribe'});
					//sockSubFromSignalProvider.unsubscribe( message );
				}else if (deleteTopic[0] == 'STATUS'){
					self.postMessage({'d':message,'type':'unsubscribe'});
					//sockSubFromSignalProvider.unsubscribe( message );
	  			}else{
	  				console.log("error message: ",newTopic[0]);
	  			}
				break;

			default:

			 	//EX: OPERATIONS@ACTIVTRADES@EURUSD@1002
				var topicType = topic.split('@');
	  			if (topicType[0] == 'OPERATIONS') {
	  				console.log('New Operation: '+message+ 'from (on topic): '+topic);
	  				//open    price=11295,lots=1,slippage=1.5,sl=1220,tp=1220,magic=1002,op=-1
	  				//close   price=11279,lots=1,slippage=0.2,ticket=103510387,op=0
	  				var operation = message.split(",");
	  				var cross = topicType[2];

	  				if ( operation[6] != undefined && operation[6] != null && operation[6].split('=')[0]=='op'   ) {
	  					console.log("in open operation");
	  					//open    price=11295,lots=1,slippage=1.5,sl=1220,tp=1220,magic=1002,op=-1

	  					var price_rv = operation[0].split('=')[1];
		  				var lots_rv = operation[1].split('=')[1];
		  				var slippage_rv = operation[2].split('=')[1];
		  				var sl_rv = operation[3].split('=')[1];
		  				var tp_rv = operation[4].split('=')[1];
		  				var magic_rv = operation[5].split('=')[1];
		  				var op_rv = operation[6].split('=')[1];

						var op_id = operation_unique_id;  //generate unique id
						operation_unique_id++;
						var price = price_rv;
						var sl = sl_rv;
						var tp = tp_rv;
						var magic = magic_rv;
						operations.push( {'open':price,'id':op_id,'op':op_rv,'close':'','sl':sl,'tp':tp,'magic':magic} );
						var status_mess = "1,open,"+price+","+op_id;
						var status_topic = "STATUS@"+cross+"@"+magic;
						
						var topic = "STATUS@"+cross+"@"+magic;
						var mesage = "1,open,"+price+","+op_id;

						//1,open,11295,103510387 on topic: STATUS@EURUSD@1002
						self.postMessage({'d':[topic, message],'type':'sendStatusToSignalProvider'});
						//sockPub.send([topic, message]);


					}else if ( operation[4].split('=')[0]=='op' ) {
						console.log("in close operation");
						//close   price=11279,lots=1,slippage=0.2,ticket=103510387,op=0

						var price_rv = operation[0].split('=')[1];
		  				var lots_rv = operation[1].split('=')[1];
		  				var slippage_rv = operation[2].split('=')[1];
		  				var ticket_rv = operation[3].split('=')[1];
		  				var op_rv = operation[4].split('=')[1];

						var price = price_rv;
						var ticket = ticket_rv;
						for(var i=0; i<=operations.length-1; i++){
							if (operations[i].id == ticket) {

								var operation_result = ((price - operations[i].open) * operations[i].op) / 10;
								var last_operation = tot_backtest_all_operations[tot_backtest_all_operations.length-1];

								tot_backtest_comulative.push( tot_backtest_comulative[tot_backtest_comulative.length-1] + operation_result );  //IF WE HAVE 5 NUMBERS, IN ORDER TO CALCULATE THE TOTAL OF PIPS WE HAVE DELETE FOR 10 
								tot_backtest_all_operations.push( operation_result );

								// TOTAL PROFIT
								total_profit = tot_backtest_comulative[tot_backtest_comulative.length-1];

								// AVERAGE PIPS TRADE
								average_pips_trade = tot_backtest_comulative[tot_backtest_comulative.length-1] / tot_backtest_comulative[tot_backtest_comulative.length];

								// PROFIT&LOSS_PIPS   and   PROFIT&LOSS_TRADES   and   CONSECUTIVE_PROFIT&LOSS_TRADES  and  BEST&WORST_TRADE
								if (operation_result > 0) {
									profit_trades++;
									profit = profit + operation_result;
									if (last_operation > 0) {
										consecutive_profit_trades_arr.push(1);
									}else if (last_operation < 0) {
										if (consecutive_profit_trades < consecutive_profit_trades_arr.length) {
											consecutive_profit_trades = consecutive_profit_trades_arr.length;
										}
										consecutive_profit_trades_arr.push(1);
									};
									if (best_trade != null) {
										if (best_trade < operation_result) {
											best_trade = operation_result;
										};
									}else{
										best_trade = operation_result;
									}
								}else if (operation_result <= 0) {
									loss_trades++;
									loss = loss + operation_result;
									if (last_operation < 0) {
										consecutive_loss_trades_arr.push(1);
									}else if (last_operation > 0) {
										if (consecutive_loss_trades < consecutive_loss_trades_arr.length) {
											consecutive_loss_trades = consecutive_loss_trades_arr.length;
										}
										consecutive_loss_trades_arr.push(1);
									};
									if (worst_trade != null) {
										if (worst_trade > operation_result) {
											worst_trade = operation_result;
										};
									}else{
										worst_trade = operation_result;
									}

								};

								// LONG(BUY) AND SHORT(SELL)
								if (operations[i].op == '1') {
									long_trades++;
								}else if (operations[i].op == '-1') {
									short_trades++;
								};

								// MAX DRAWDOWN 
								if ( max_drawdown_arr[max_drawdown_arr.length-1] != undefined && max_drawdown_arr[max_drawdown_arr.length-1] != null ){
									var first_max_drawdown_arr_value = max_drawdown_arr[0];
									
									var current_max_drawdown_arr_value = tot_backtest_comulative[tot_backtest_comulative.length-1];
									if ( first_max_drawdown_arr_value >= current_max_drawdown_arr_value) {
										max_drawdown_arr.push( current_max_drawdown_arr_value );
									}else if (first_max_drawdown_arr_value < current_max_drawdown_arr_value) {
										var new_drawdown = ( (max_drawdown_arr.min() - max_drawdown_arr[0])/max_drawdown_arr[0] )*100;
										if (new_drawdown > max_drawdown) {
											max_drawdown = ( (max_drawdown_arr.min() - max_drawdown_arr[0])/max_drawdown_arr[0] )*100;
										};
										max_drawdown_arr = [];
									};
								}else{
									max_drawdown_arr.push( tot_backtest_comulative[tot_backtest_comulative.length-1] );
								}

								operations[i].close = price;
								var status_mess = "1,close,"+price+","+operations[i].id;
								var status_topic = "STATUS@"+cross+"@"+operations[i].magic;
								
								//1,close,11280,103510387 on topic: STATUS@EURUSD@1002
								self.postMessage({'d':[status_topic, status_message],'type':'sendStatusToSignalProvider'});
								//sockPub.send([status_topic, status_mess]);
							};
						}
						
					};
					sendNewDataToSignalProvider(indexQuote);
				}else if (topicType[0] == 'SKIP') {
					//EX: SKIP@ACTIVTRADES@EURUSD@1002
					sendNewDataToSignalProvider(indexQuote);
				}
				break;
			

		};
	};
});



// SEND VALUES AT 1 MIN, 5 MIN, ETC.... 

//FOR && .shift();

//[{"v1":[]},{"v5":[]},{"v10":[]},{"v20":[]},{"v40":[]},{"v100":[]}];
var getIndexValuesNumberToSend = function(type){
	switch (type){
		case 'v1':
    		index = 0;
    		break;
		case 'v5':
			index = 1;
			break;
		case 'v10':
			index = 2;
			break;
		case 'v20':
			index = 3;
			break;
		case 'v40':
			index = 4;
			break;
		case 'v100':
			index = 5;
			break;
	}
	return index;	
}

// indexQuote start with 1
var sendNewDataToSignalProvider = function(indexQuote){
	//EX Setting: {cross:'EURUSD','dataLenght':'v1'},{cross:'EURGBP','dataLenght':'v10'}
	for(var i=0; i<=setting.length-1; i++){
		switch (indexQuote){
			case ( (indexQuote/1).toString().split('.')[1] == undefined ):
	    		var timeFrame = 'm1';
	    		var indexTimeFrame = 0;
	    		var indexDataLenght = getIndexValuesNumberToSend( setting[i].dataLenght )
	    		var quote = runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty][ setting[i].cross ][indexTimeFrame][timeFrame][indexDataLenght][setting[i].dataLenght];
				if (quote != null && quote != undefined) {
					//"TIMEFRAMEQUOTE@MT4@ACTIVTRADES   +     @EURUSD     +     @m1     +    @v1 
					//"TIMEFRAMEQUOTE@BACKTEST@BACKTEST
					var topicToSignalProvider = "TIMEFRAMEQUOTE@BACKTEST@BACKTEST@"+setting[i].cross+"@"+timeFrame+"@"+setting[i].dataLenght;
					self.postMessage({'d':[topicToSignalProvider, quote.join(";")],'type':'sendQuoteToSignalProvider'});
					//sockPub.send([topicToSignalProvider, quote.join(";")]);
				}
	    		break;
			case ( (indexQuote/5).toString().split('.')[1] == undefined ):
				var timeFrame = 'm5';
				var indexTimeFrame = 1;
	    		var indexDataLenght = getIndexValuesNumberToSend( setting[i].dataLenght )
	    		var quote = runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty][ setting[i].cross ][indexTimeFrame][timeFrame][indexDataLenght][setting[i].dataLenght];
				if (quote != null && quote != undefined) {
					//"TIMEFRAMEQUOTE@MT4@ACTIVTRADES   +     @EURUSD     +     @m1     +    @v1 
					//"TIMEFRAMEQUOTE@BACKTEST@BACKTEST
					var topicToSignalProvider = "TIMEFRAMEQUOTE@BACKTEST@BACKTEST@"+setting[i].cross+"@"+timeFrame+"@"+setting[i].dataLenght;
					self.postMessage({'d':[topicToSignalProvider, quote.join(";")],'type':'sendQuoteToSignalProvider'});
					//sockPub.send([topicToSignalProvider, quote.join(";")]);
				}
				break;
			case ( (indexQuote/15).toString().split('.')[1] == undefined ):
				var timeFrame = 'm15';
				var indexTimeFrame = 2;
	    		var indexDataLenght = getIndexValuesNumberToSend( setting[i].dataLenght )
	    		var quote = runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty][ setting[i].cross ][indexTimeFrame][timeFrame][indexDataLenght][setting[i].dataLenght];
				if (quote != null && quote != undefined) {
					//"TIMEFRAMEQUOTE@MT4@ACTIVTRADES   +     @EURUSD     +     @m1     +    @v1 
					//"TIMEFRAMEQUOTE@BACKTEST@BACKTEST
					var topicToSignalProvider = "TIMEFRAMEQUOTE@BACKTEST@BACKTEST@"+setting[i].cross+"@"+timeFrame+"@"+setting[i].dataLenght;
					self.postMessage({'d':[topicToSignalProvider, quote.join(";")],'type':'sendQuoteToSignalProvider'});
					//sockPub.send([topicToSignalProvider, quote.join(";")]);
				}
				break;
			case ( (indexQuote/30).toString().split('.')[1] == undefined ):
				var timeFrame = 'm30';
				var indexTimeFrame = 3;
	    		var indexDataLenght = getIndexValuesNumberToSend( setting[i].dataLenght )
	    		var quote = runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty][ setting[i].cross ][indexTimeFrame][timeFrame][indexDataLenght][setting[i].dataLenght];
				if (quote != null && quote != undefined) {
					//"TIMEFRAMEQUOTE@MT4@ACTIVTRADES   +     @EURUSD     +     @m1     +    @v1 
					//"TIMEFRAMEQUOTE@BACKTEST@BACKTEST
					var topicToSignalProvider = "TIMEFRAMEQUOTE@BACKTEST@BACKTEST@"+setting[i].cross+"@"+timeFrame+"@"+setting[i].dataLenght;
					self.postMessage({'d':[topicToSignalProvider, quote.join(";")],'type':'sendQuoteToSignalProvider'});
					//sockPub.send([topicToSignalProvider, quote.join(";")]);
				}
				break;
			case ( (indexQuote/60).toString().split('.')[1] == undefined ):
				var timeFrame = 'h1';
				var indexTimeFrame = 4;
	    		var indexDataLenght = getIndexValuesNumberToSend( setting[i].dataLenght )
	    		var quote = runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty][ setting[i].cross ][indexTimeFrame][timeFrame][indexDataLenght][setting[i].dataLenght];
				if (quote != null && quote != undefined) {
					//"TIMEFRAMEQUOTE@MT4@ACTIVTRADES   +     @EURUSD     +     @m1     +    @v1 
					//"TIMEFRAMEQUOTE@BACKTEST@BACKTEST
					var topicToSignalProvider = "TIMEFRAMEQUOTE@BACKTEST@BACKTEST@"+setting[i].cross+"@"+timeFrame+"@"+setting[i].dataLenght;
					self.postMessage({'d':[topicToSignalProvider, quote.join(";")],'type':'sendQuoteToSignalProvider'});
					//sockPub.send([topicToSignalProvider, quote.join(";")]);
				}
				break;
			case ( (indexQuote/240).toString().split('.')[1] == undefined ):
				var timeFrame = 'h4';
				var indexTimeFrame = 5;
	    		var indexDataLenght = getIndexValuesNumberToSend( setting[i].dataLenght )
	    		var quote = runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty][ setting[i].cross ][indexTimeFrame][timeFrame][indexDataLenght][setting[i].dataLenght];
				if (quote != null && quote != undefined) {
					//"TIMEFRAMEQUOTE@MT4@ACTIVTRADES   +     @EURUSD     +     @m1     +    @v1 
					//"TIMEFRAMEQUOTE@BACKTEST@BACKTEST
					var topicToSignalProvider = "TIMEFRAMEQUOTE@BACKTEST@BACKTEST@"+setting[i].cross+"@"+timeFrame+"@"+setting[i].dataLenght;
					self.postMessage({'d':[topicToSignalProvider, quote.join(";")],'type':'sendQuoteToSignalProvider'});
					//sockPub.send([topicToSignalProvider, quote.join(";")]);
				}
				break;
			case ( (indexQuote/1440).toString().split('.')[1] == undefined ):
				var timeFrame = 'd1';
				var indexTimeFrame = 6;
	    		var indexDataLenght = getIndexValuesNumberToSend( setting[i].dataLenght )
	    		var quote = runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty][ setting[i].cross ][indexTimeFrame][timeFrame][indexDataLenght][setting[i].dataLenght];
				if (quote != null && quote != undefined) {
					//"TIMEFRAMEQUOTE@MT4@ACTIVTRADES   +     @EURUSD     +     @m1     +    @v1 
					//"TIMEFRAMEQUOTE@BACKTEST@BACKTEST
					var topicToSignalProvider = "TIMEFRAMEQUOTE@BACKTEST@BACKTEST@"+setting[i].cross+"@"+timeFrame+"@"+setting[i].dataLenght;
					self.postMessage({'d':[topicToSignalProvider, quote.join(";")],'type':'sendQuoteToSignalProvider'});
					//sockPub.send([topicToSignalProvider, quote.join(";")]);
				}
				break;
			case ( (indexQuote/7200).toString().split('.')[1] == undefined ):
				var timeFrame = 'w1';
				var indexTimeFrame = 7;
	    		var indexDataLenght = getIndexValuesNumberToSend( setting[i].dataLenght )
	    		var quote = runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty][ setting[i].cross ][indexTimeFrame][timeFrame][indexDataLenght][setting[i].dataLenght];
				if (quote != null && quote != undefined) {
					//"TIMEFRAMEQUOTE@MT4@ACTIVTRADES   +     @EURUSD     +     @m1     +    @v1 
					//"TIMEFRAMEQUOTE@BACKTEST@BACKTEST
					var topicToSignalProvider = "TIMEFRAMEQUOTE@BACKTEST@BACKTEST@"+setting[i].cross+"@"+timeFrame+"@"+setting[i].dataLenght;
					self.postMessage({'d':[topicToSignalProvider, quote.join(";")],'type':'sendQuoteToSignalProvider'});
					//sockPub.send([topicToSignalProvider, quote.join(";")]);
				}
				break;
		};
		indexQuote++;	
	}
}






//STATUS  2016.04.22 07:54:00.246	Subscriber EURUSD,M30: Alert: Message sent: 1,close,11280,103510387 on topic: STATUS@EURUSD@1002
//CLOSE   2016.04.22 07:54:00.051	Subscriber EURUSD,M30: Alert: Message received: price=11279,lots=1,slippage=0.2,ticket=103510387,op=0

//STATUS  2016.04.22 00:30:03.105	Subscriber EURUSD,M30: Alert: Message sent: 1,open,11295,103510387 on topic: STATUS@EURUSD@1002
//OPEN    2016.04.22 00:30:02.894	Subscriber EURUSD,M30: Alert: Message received: price=11295,lots=1,slippage=1.5,sl=1220,tp=1220,magic=1002,op=-1
//Topic: STATUS@EURUSD@1002message: "1,open,11403,105634693\n"

var operations = [];
var tot_backtest_comulative = [0];
var tot_backtest_all_operations = [];
var profit = 0;
var loss = 0;
var profit_trades = 0;
var loss_trades = 0;
var total_profit = 0;
var average_pips_trade = null;
var consecutive_profit_trades_arr = [];
var consecutive_loss_trades_arr = [];
var consecutive_profit_trades = 0;
var consecutive_loss_trades = 0;
var worst_trade = null;
var best_trade = null;
var long_trades = 0;
var short_trades = 0;
var max_drawdown_arr = [];
var max_drawdown = 0;
var min_drawdown = 0;
var operation_unique_id = 1;



sendNewDataToSignalProvider(indexQuote);






//from 53200 to 53300







