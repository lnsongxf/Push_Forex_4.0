var http = require('http');
var zmq = require('zmq'); 
var schedule = require('node-schedule');
var bunyan = require('bunyan');
var BunyanSlack = require('bunyan-slack');
var later = require('later');

/*
"fatal" (60): The service/app is going to stop or become unusable now. An operator should definitely look into this soon.
"error" (50): Fatal for a particular request, but the service/app continues servicing other requests. An operator should look at this soon(ish).
"info" (30):  Detail on topics and message exchanged
"trace" (10): Detail on regular operation. 
*/
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
			logger.error('quotes_list %s or providerName '+quotes_list,providerName+' null or not defined into _createTimeFrameQuotesObj');
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
		logger.trace("created new TimeFrameQuotesObj: "+JSON.stringify(_quotesObj)+ " providerName: "+providerName);  
		return _quotesObj
	};

	var _realTimeQuotes = function(providerName){
		this.provider = providerName, 
		this.description = "This obj store all the last current quotes from this specific provider and for each cross"
	};

	var _createRealTimeQuotesObj = function(quotes_list,providerName){
		if (quotes_list == null || quotes_list == undefined || providerName == null || providerName == undefined) {
			logger.error('quotes_list '+quotes_list+' or providerName '+providerName+' null or not defined into _createRealTimeQuotesObj');
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
		        	"m1":{open:null,max:null,min:null,close:null,volume:0},
		        	"m5":{open:null,max:null,min:null,close:null,volume:0},
		        	"m15":{open:null,max:null,min:null,close:null,volume:0},
		        	"m30":{open:null,max:null,min:null,close:null,volume:0},
		        	"h1":{open:null,max:null,min:null,close:null,volume:0},
		        	"h4":{open:null,max:null,min:null,close:null,volume:0},
		        	"d1":{open:null,max:null,min:null,close:null,volume:0},
		        	"w1":{open:null,max:null,min:null,close:null,volume:0}
		        }
		    }
		}

		//console.log("created new realTimeQuotesObj: "+JSON.stringify( _realTimeQuotesObj)+ " providerName: "+providerName);
		return _realTimeQuotesObj
	};

	var _updateRealTimeQuotesObj = function(platform,messageArr){
		if (platform == null || platform == undefined || messageArr == null || messageArr == undefined) {
			logger.error('searchObjRealTimeQuote '+searchObjRealTimeQuote+' or messageArr '+messageArr+' null or not defined into _updateRealTimeQuotesObj');
			return null;
		};


		//ex: searchObjRealTimeQuote == "REALTIMEQUOTE$MT4$ACTIVTRADES"
		//runningProviderRealTimeObjs['REALTIMEQUOTE$MT4@ACTIVTRADES']={'EURUSD':'','EURGBP':''}
		//11313,11315,11313,11316,30,03/18/2016 01:24  -->   apertura,massimo,minimo,chiusura,volume,time
		
		
		var realOpen = messageArr[1].split(',')[0]
		var realMax = messageArr[1].split(',')[1]
		var realMin = messageArr[1].split(',')[2]
		var realClose = messageArr[1].split(',')[3]
		var realVolume = messageArr[1].split(',')[4]

		if (runningProviderRealTimeObjs[platform] == null || runningProviderRealTimeObjs[platform] == undefined) {
			logger.error("Unable to find platform " + platform);
			return null;
		}

		var cross = messageArr[0];
		if (runningProviderRealTimeObjs[platform][cross] == null || runningProviderRealTimeObjs[platform][cross] == undefined) {
			logger.error("Unable to find cross " + cross + " in platform " + platform);
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
			if (timeFrame == 'm1') {
				runningProviderRealTimeObjs[platform][cross][timeFrame]['volume'] = parseInt(realVolume);
			}
			else {

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
		var currentdate = new Date(); 
		var datetime = currentdate.getDate()+"/"+(currentdate.getMonth()+1)+"/"+currentdate.getFullYear()+" "+currentdate.getHours()+":"+currentdate.getMinutes(); 

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
					logger.error('Error on timeframe '+timeFrame+', cross '+ cross+' tmpArrPreviousTimeFrameQuotesV10 :'+JSON.stringify(tmpArrPreviousTimeFrameQuotesV10) );
				}
			}

		}

		//11313,11315,11313,11316,30,03/18/2016 01:24  -->   apertura,massimo,minimo,chiusura,volume,time
		var newQuote =  open+','+max+','+min+','+close+','+volume+','+datetime;

		if (timeFrame == 'm1' || timeFrame == 'm30' || timeFrame == 'm15'){ 
			if( cross == 'EURUSD' ) {
				logger.info('Creating new quote - Cross:'+cross+' timeframe:'+timeFrame+' newQuote:'+newQuote);
				logger.info('Resetting values for cross '+cross+' timeframe '+timeFrame+' : '+JSON.stringify(runningProviderRealTimeObjs[tmpRealTimeQuoteProperty][cross][timeFrame]) );
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

		if (timeFrame == null || timeFrame == undefined || timeFrameQuotesObj == null || timeFrameQuotesObj == undefined || realTimeQuotesObj == null || realTimeQuotesObj == undefined ) {
			logger.error('In _updateTimeFrameQuotesObj timeframe or timeFrameQuotesObj or realTimeQuotesObj is notDefined/null');
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

		  						logger.trace("TIMEFRAME TO UPDATE: "+timeFrame);

		  						if (timeFrame == 'm15') {
	  								var paramMarketStatus =  tmpTimeFrameQuoteProperty.split('$')[1]+'$'+tmpTimeFrameQuoteProperty.split('$')[2]+'$TRADEALLOWED';
	  								logger.info('MARKET STATUS FROM METATRADER: '+marketStatus[paramMarketStatus] );
	  							}
								//TO FIX - WE HAVE TO USE ONE MESSAGE FORM MT4 TO UNDERSTAND WHEN THE MARKET IS CLOSED
	  							//TEMPORARY FIX FOR THE WEEKEND
	  							//HERE WE CLEAN THE 1minuteObjs. This objs store the last 1minute values.
	  							//AND WE CLEANTHE REAL TIME ARRAY OBJ. THIS RRAY STORE THE LAST REALTIME VALUES INTO ON1 MINUTE
	  							var paramMarketStatus =  tmpTimeFrameQuoteProperty.split('$')[1]+'$'+tmpTimeFrameQuoteProperty.split('$')[2]+'$TRADEALLOWED';
	  							if ( marketStatus[paramMarketStatus] == 0 ) {			  								
	  								runningProviderRealTimeObjs[tmpRealTimeQuoteProperty] = _createRealTimeQuotesObj(configQuotesList, tmpRealTimeQuoteProperty.replace("$", "@").replace("$", "@") );
	  								logger.info('MARKET IS CLOSED, RESETTING runningProviderRealTimeObjs[tmpRealTimeQuoteProperty]: '+JSON.stringify(runningProviderRealTimeObjs[tmpRealTimeQuoteProperty]) );
	  							}else{

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

					  								//logger.trace('Updated timeFrameQuotesObj(operation:adding) : ' + tempObj[Object.keys(tempObj)[0]].toString() + ' for TimeFrame: '+timeFrame+ ' for number of values: '+Object.keys(tempObj)[0]+' on Cross: '+key1 );
					  								var topic = key1;
					  								//"TIMEFRAMEQUOTE@MT4@ACTIVTRADES   +     @EURUSD     +     @m1     +    @v1 
					  								var topicToSignalProvider = timeFrameQuotesObj.provider+"@"+key1+"@"+timeFrame+"@"+Object.keys(tempObj)[0];
					  								if (topicToSignalProvider == null || topicToSignalProvider == undefined ) {
														logger.error('timeFrameQuotesObjProvider: ' +JSON.stringify(timeFrameQuotesObj.provider) + ' key1: ' + key1 + ' timeFrame: ' +timeFrame + ' totValues: ' + JSON.stringify( Object.keys(tempObj)[0] ) + ' In _updateTimeFrameQuotesObj topicToSignalProvider is notDefined/null');
													}else if (tempObj[Object.keys(tempObj)[0]].toString() == null || tempObj[Object.keys(tempObj)[0]].toString() == undefined ) {
														logger.error('objWithMessageToSend: '+ JSON.stringify(tempObj) + ' _updateTimeFrameQuotesObj is sending a message (Quotes) notDefined/null');
													}else{
					  									sockPub.send([topicToSignalProvider, tempObj[Object.keys(tempObj)[0]].join(";")]);
					  									if (timeFrame == 'm5' && Object.keys(tempObj)[0].split("v")[1] == '1') {
															logger.info('Sent new timeFrame value message (ex: logs only for m5 and v1): '+tempObj[Object.keys(tempObj)[0]].join(";")+ 'for TimeFrame: '+timeFrame+ 'for Cross: '+key1+' on topic: '+topicToSignalProvider);
					  									}else if (timeFrame == 'm30' && Object.keys(tempObj)[0].split("v")[1] == '5') {
															logger.info('Sent new timeFrame value message (ex: logs only for m30 and v5): '+tempObj[Object.keys(tempObj)[0]].join(";")+ 'for TimeFrame: '+timeFrame+ 'for Cross: '+key1+' on topic: '+topicToSignalProvider);
					  									}
					  								}
					  							}else{
					  								//if (topicToSignalProvider == null || topicToSignalProvider == undefined ) {
													//	logger.error('In _updateTimeFrameQuotesObj, realTimeQuotesObj[key0] is null');
													//};
					  							}
					  						}else{
		
				  								if (realTimeQuotesObj[key0] != "" && realTimeQuotesObj[key0] != null && realTimeQuotesObj[key0] != undefined) {
		
					  								tempObj[Object.keys(tempObj)[0]].shift();
					  								
					  								tempObj[Object.keys(tempObj)[0]].push(newQuote);

					  								//logger.trace('Updated timeFrameQuotesObj(operation:shifting) : ' + tempObj[Object.keys(tempObj)[0]].toString() + 'for TimeFrame: '+timeFrame+ ' for number of values: '+Object.keys(tempObj)[0]+' for Cross: '+key1 );
					  								//"TIMEFRAMEQUOTE@MT4@ACTIVTRADES   +     @EURUSD     +     @m1     +    @v10 
					  								var topicToSignalProvider = timeFrameQuotesObj.provider+"@"+key1+"@"+timeFrame+"@"+Object.keys(tempObj)[0];
					  								if (topicToSignalProvider == null || topicToSignalProvider == undefined ) {
														logger.error('timeFrameQuotesObjProvider: '+ JSON.stringify(timeFrameQuotesObj.provider) + ' key1: ' + key1 + ' timeFrame: '+ timeFrame + 'totValues: ' + JSON.stringify(Object.keys(tempObj)[0]) +' In _updateTimeFrameQuotesObj topicToSignalProvider is notDefined/null');
													}else if (tempObj[Object.keys(tempObj)[0]].toString() == null || tempObj[Object.keys(tempObj)[0]].toString() == undefined ) {
														logger.error('objWithMessageToSend: ' + JSON.stringify(tempObj) + ' _updateTimeFrameQuotesObj is sending a message (Quotes) notDefined/null');
													}else{
					  									sockPub.send([topicToSignalProvider, tempObj[Object.keys(tempObj)[0]].join(";")]);
					  									if (timeFrame == 'm5' && Object.keys(tempObj)[0].split("v")[1] == '1') {
					  										logger.info('Sent new timeFrame value message (logs only for m5 and v1): '+tempObj[Object.keys(tempObj)[0]].join(";")+ 'for TimeFrame: '+timeFrame+ 'for Cross: '+key1+' on topic: '+topicToSignalProvider);
					  									}else if (timeFrame == 'm30' && Object.keys(tempObj)[0].split("v")[1] == '5') {
															logger.info('Sent new timeFrame value message (ex: logs only for m30 and v5): '+tempObj[Object.keys(tempObj)[0]].join(";")+ 'for TimeFrame: '+timeFrame+ 'for Cross: '+key1+' on topic: '+topicToSignalProvider);
					  									}
					  								}
					  							}else{
					  								//if (topicToSignalProvider == null || topicToSignalProvider == undefined ) {
													//	logger.error('In _updateTimeFrameQuotesObj, realTimeQuotesObj[key0] is null');
													//};
					  							}
					  						}
					  						timeFrameQuotesObj[key1][index][timeFrame][j] = tempObj;
				  						}
				  					}
			  					}
		  						//uncomment this file if you want to check how are stored the quotes values
		  						//logger.trace('Updated timeFrameQuotesObj[key1][index][timeFrame]: ' + JSON.stringify(timeFrameQuotesObj[key1][index][timeFrame] ) +  ' TimeFrame Obj Updated');
		  						//console.log("timeFrameQuotesObj[key1][index][timeFrame]: ",timeFrameQuotesObj[key1][index][timeFrame]);
		  					}	
						}
					}
		  		}
		  	}
		};

		return timeFrameQuotesObj;
	};

	var _importHistoryTimeFrameQuotesObj = function(searchObjTimeFrameQuote,messageArr){
		// EX: REALTIMEQUOTES@MT4@ACTIVTRADES
		if (searchObjTimeFrameQuote == null || searchObjTimeFrameQuote == undefined || messageArr == null || messageArr == undefined ) {
			logger.error('In _updateTimeFrameQuotesObj timeframe or timeFrameQuotesObj or realTimeQuotesObj is notDefined/null');
		};
		for (var key0 in runningProviderTimeFrameObjs) {
			if (key0 == searchObjTimeFrameQuote) {
				for (var key in runningProviderTimeFrameObjs[key0]) {
					if (runningProviderTimeFrameObjs[key0].hasOwnProperty(key)) {
						// EX message:"EURUSD@m1@" + Bid + ";" + Ask + ";" + Time[0] + "$...
						//Check for 'EURUSD'...
			  			if (key == messageArr[0]) {
			  				for(var i=0;i<runningProviderTimeFrameObjs[key0][key].length;i++){
			  					for (var key1 in runningProviderTimeFrameObjs[key0][key][i]) {
			  						var tmpObjTimeFrameQuote = runningProviderTimeFrameObjs[key0][key][i];
			  						//Check for 'm1'...
			  						if ( Object.keys(tmpObjTimeFrameQuote)[0] == messageArr[1] ) {
			  							var arrfirstQuotesValues = messageArr[2].split("$");
			  							for(var k=0;k<arrfirstQuotesValues.length;k++){
			  								for(var j=0;j<tmpObjTimeFrameQuote[Object.keys(tmpObjTimeFrameQuote)[0]].length;j++){
			  									var tmpObjSetValuesQuote = tmpObjTimeFrameQuote[Object.keys(tmpObjTimeFrameQuote)[0]][j];
			  									if (tmpObjSetValuesQuote[Object.keys(tmpObjSetValuesQuote)].length < Object.keys(tmpObjSetValuesQuote)[0].split("v")[1] ){
			  										tmpObjSetValuesQuote[Object.keys(tmpObjSetValuesQuote)].push(arrfirstQuotesValues[k]);
			  										tmpObjTimeFrameQuote[Object.keys(tmpObjTimeFrameQuote)[0]][j] = tmpObjSetValuesQuote;
			  										runningProviderTimeFrameObjs[key0][key][i] = tmpObjTimeFrameQuote;
			  										
			  									}else if (tmpObjSetValuesQuote[Object.keys(tmpObjSetValuesQuote)].length >= Object.keys(tmpObjSetValuesQuote)[0].split("v")[1]) {
			  										tmpObjSetValuesQuote[Object.keys(tmpObjSetValuesQuote)].shift();
													tmpObjSetValuesQuote[Object.keys(tmpObjSetValuesQuote)].push(arrfirstQuotesValues[k]);
													tmpObjTimeFrameQuote[Object.keys(tmpObjTimeFrameQuote)[0]][j] = tmpObjSetValuesQuote;
			  										runningProviderTimeFrameObjs[key0][key][i] = tmpObjTimeFrameQuote;

			  									}
			  								}
			  							}
			  							if (messageArr[0] == 'EURUSD' && messageArr[1] == 'm1' ) {
			  								logger.info('Updated history timeframe m1 (v10) for cross EURUSD: '+JSON.stringify( runningProviderTimeFrameObjs[key0][key][i]) );
			  							};
			  							logger.trace("Updated TimeFrameObj with History Quotes. Key0(Quote Provider Name): "+key0+" ,Cross: "+key+" ,Values: "+JSON.stringify( runningProviderTimeFrameObjs[key0][key][i] ) );
			  							return true;	
			  						}			
			  					}
			  				}
						}
					}
				}
			}
		}
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

var logger = (function(){

	var topicLogFatal="LOGS@FATAL";
	var topicLogError="LOGS@ERROR";
	var topicLogInfo="LOGS@INFO";
	var topicLogTrace="LOGS@TRACE";

	var fatal = function(message){ sockLog.send([topicLogFatal, message]); }
	var error = function(message){ sockLog.send([topicLogError, message]); }
	var info = function(message){ sockLog.send([topicLogInfo, message]); }
	var trace = function(message){ 
		//console.log("sending logs..");
		sockLog.send([topicLogTrace, message]);
    }

	return{
		fatal: function(message){ fatal(message) },
		error: function(message){ error(message) },
		info: function(message){ info(message) },
		trace: function(message){ trace(message) }
	}

})();

var sockPub = zmq.socket('pub');
var sockSubFromQuotesProvider = zmq.socket('sub');
var sockSubFromSignalProvider = zmq.socket('sub');

//var hwm = 1000;
//var verbose = 0;
var sockLog = zmq.socket('pub');
//sockLog.identity = 'publisher' + process.pid;
//sockLog.setsockopt(zmq.ZMQ_SNDHWM, hwm);
//sockLog.setsockopt(zmq.ZMQ_XPUB_VERBOSE, verbose);

sockSubFromQuotesProvider.bindSync('tcp://*:50025');
sockSubFromSignalProvider.bindSync('tcp://*:50026');    
sockPub.bindSync('tcp://*:50027');  
sockLog.bindSync('tcp://*:50028');


/*sockLog.on('message', function(data, bla) {
  var type = data[0]===0 ? 'unsubscribe' : 'subscribe';
  var channel = data.slice(1).toString();
  console.log(type + ':' + channel);
});*/

setInterval(function(){
	logger.trace("running logger...");
},60000);

//-------------------------------------------------------------------------------------------------------------------------------
// QUOTES PROVIDER PUB TO NODEJS TO SIGNAL PROVIDER

var configQuotesList = require('./config_quotes');
if (configQuotesList == null || configQuotesList == undefined){
	logger.fatal('The file confing_quotes.json is not in the path or is empty ');
}
if (configQuotesList.quotes.length < 0){
	logger.fatal('The quotes list in the file config_quotes.json is empty');	
}
//REMEMBER THAT THE MONTH IN THE SERVER SETTING JSON START FROM 0 TO 11
//Month: Integer value representing the month, beginning with 0 for January to 11 for December
var serverSetting = require('./server_setting');
var runningProviderTopicList = [];
var runningProviderTimeFrameObjs = {};
var runningProviderRealTimeObjs = {};
var open1mObjs = {};
var marketStatus = {};


// THE CODE BELOW SET THE SUBTASK TO UPDATED THE TIMEFRAME DATA EACH 1M,5M,15M ETC.. 
var startSchedule = serverSetting.serverSettingList[0].startScheduleTime.split(",");
if (startSchedule == null || startSchedule == undefined){
	logger.fatal('The start date in the Server is not defined or is null, check the server_setting.json file');
}else if ( startSchedule != null || startSchedule != undefined ) {
	logger.info('Server Start Date'+serverSetting.serverSettingList[0].startScheduleTime);
};
var date_start_schedule = new Date(startSchedule[0],startSchedule[1],startSchedule[2],startSchedule[3],startSchedule[4],startSchedule[5]);
//var minutesList=[{'m1':60000},{'m5':300000},{'m15':900000},{'m30':1800000},{'h1':3600000},{'h4':14400000},{'d1':86400000},{'w1':604800000}];


var updatingTimeFrameTaskFunction = function(timeFrameToUpdate){

	if (runningProviderTopicList.length > 0) {

		logger.info( '//////////////////////////////////////////////////////////////////////Start Task , updating TimeFrame: '+timeFrameToUpdate +' ////////////////////////////////////////////////////////////////////////////////////////////////');//+minutesList[i][Object.keys(minutesList[i])[0]] );
		for (var i = 0; i < runningProviderTopicList.length; i++) {
	    	var tmpTopicArr = runningProviderTopicList[i].toString().split("@");
	    	//TOPIC EXAMPLE: "MT4@ACTIVTRADES@REALTIMEQUOTES";
	    	var tmpTimeFrameQuoteProperty = "TIMEFRAMEQUOTE$"+tmpTopicArr[0]+"$"+tmpTopicArr[1];
	    	var tmpRealTimeQuoteProperty = "REALTIMEQUOTE$"+tmpTopicArr[0]+"$"+tmpTopicArr[1];
	    	//EX Time Frame Obj Property: runningProviderTimeFrameObjs["TIMEFRAMEQUOTE$MT4$ACTIVTRADES"];
	   		var new_timeFrameQuotesObj = QuotesModule.updateTimeFrameQuotesObj(timeFrameToUpdate,runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty],runningProviderRealTimeObjs[tmpRealTimeQuoteProperty],tmpRealTimeQuoteProperty,tmpTimeFrameQuoteProperty);
	   		if ( new_timeFrameQuotesObj == null || new_timeFrameQuotesObj == undefined) {
	   			logger.error('timeFrameObjToUpdate: '+JSON.stringify(runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty])+ ' CurrentRealTimeObj: '+JSON.stringify(runningProviderRealTimeObjs[tmpRealTimeQuoteProperty] )   );
	   		};
	   		runningProviderTimeFrameObjs[tmpTimeFrameQuoteProperty] = new_timeFrameQuotesObj;
		}
	}
}

var sched_m1 = later.parse.recur().every(1).minute();
var sched_m5 = later.parse.recur().every(5).minute();
var sched_m15 = later.parse.recur().every(15).minute();
var sched_m30 = later.parse.recur().every(30).minute();
var sched_h1 = later.parse.recur().every(1).hour();
var sched_h4 = later.parse.recur().every(4).hour();
var sched_d1 = later.parse.recur().every(24).hour();
var sched_w1 = later.parse.recur().every(1).dayOfWeek(); 
 
later.setInterval(function() { updatingTimeFrameTaskFunction('m1') }, sched_m1);
later.setInterval(function() { updatingTimeFrameTaskFunction('m5') }, sched_m5);
later.setInterval(function() { updatingTimeFrameTaskFunction('m15') }, sched_m15);
later.setInterval(function() { updatingTimeFrameTaskFunction('m30') }, sched_m30);
later.setInterval(function() { updatingTimeFrameTaskFunction('h1') }, sched_h1);
later.setInterval(function() { updatingTimeFrameTaskFunction('h4') }, sched_h4);
later.setInterval(function() { updatingTimeFrameTaskFunction('d1') }, sched_d1);
later.setInterval(function() { updatingTimeFrameTaskFunction('w1') }, sched_w1);

sockSubFromQuotesProvider.subscribe('NEWTOPICQUOTES');
sockSubFromQuotesProvider.subscribe('DELETETOPICQUOTES');
//sockSubFromQuotesProvider.subscribe('');
sockSubFromQuotesProvider.on('message', function(topic, message) {
	//console.log("mess: ",message.toString());
	//console.log("topic: ",topic.toString());
	//logger.trace('Received message from Quotes Provider: '+message+ 'on topic: '+topic);
	var topicArr = topic.toString().split("@");
  	var messageArr = message.toString().split("@");

  	switch (topicArr[0]) {
  		case "NEWTOPICQUOTES":
  			//TOPIC MESSAGE EXAMPLE: "MT4@ACTIVTRADES@REALTIMEQUOTES";
  			if ( runningProviderTopicList.indexOf( message.toString() ) == "-1" ) {
  				//CREATE MARKET STATUS TOPIC
  				var newTopicMarketStatus = messageArr[0]+'@'+messageArr[1]+'@TRADEALLOWED';
  				sockSubFromQuotesProvider.subscribe(newTopicMarketStatus);

				//CREATE AND ADD NEW TOPICS (EX: MT4@ACTIVTRADES@REALTIMEQUOTES) IN THE ARRAY LIST
				if ( messageArr[2] == "REALTIMEQUOTES" ||  messageArr[2] == "LISTQUOTES"){
					runningProviderTopicList.push(message.toString());
					sockSubFromQuotesProvider.subscribe(message.toString());
					logger.info('created new topic: '+message.toString() );
					var newObjTimeFrameQuote = "TIMEFRAMEQUOTE$"+messageArr[0]+"$"+messageArr[1];
					var newObjRealTimeQuote = "REALTIMEQUOTE$"+messageArr[0]+"$"+messageArr[1];
					var newValuePropertyTimeFrameQuote = "TIMEFRAMEQUOTE@"+messageArr[0]+"@"+messageArr[1];
					var newValuePropertyRealTimeQuote = "REALTIMEQUOTE@"+messageArr[0]+"@"+messageArr[1];  
					runningProviderTimeFrameObjs[newObjTimeFrameQuote] = QuotesModule.createTimeFrameQuotesObj(configQuotesList,newValuePropertyTimeFrameQuote);
					if (runningProviderTimeFrameObjs[newObjTimeFrameQuote] == null || runningProviderTimeFrameObjs[newObjTimeFrameQuote] == undefined) {
						logger.error( 'topic: '+ JSON.stringify(topicArr[0]) + ' message: ' +JSON.stringify(message.toString()) + ' runningProviderTimeFrameObjs[newObjTimeFrameQuote]: ' + JSON.stringify(runningProviderTimeFrameObjs[newObjTimeFrameQuote] ) + 'TimeFrame Obj is not created for topic: '+message.toString() );
					};
					runningProviderRealTimeObjs[newObjRealTimeQuote] = QuotesModule.createRealTimeQuotesObj(configQuotesList,newValuePropertyRealTimeQuote);
					if (runningProviderRealTimeObjs[newObjRealTimeQuote] == null || runningProviderRealTimeObjs[newObjRealTimeQuote] == undefined) {
						logger.error( 'topic: '+ JSON.stringify(topicArr[0]) + 'message:' + JSON.stringify(message.toString()) +'runningProviderTimeFrameObjs[newObjTimeFrameQuote]: ' +JSON.stringify(runningProviderRealTimeObjs[newObjRealTimeQuote]) + 'RealTime Obj is not created for topic: '+message.toString() );
					};
				}else{
					logger.error('topic: ' + JSON.stringify(topicArr[0]) + ' New topic: '+message.toString()+' wrong format. The new Topic form Quotes Provider should ending with LISTQUOTES or REALTIMEQUOTES' );
				}
			}else{
				logger.error('topic: '+ JSON.stringify(topicArr[0]) + ' Its not possible to add this topic name '+ message.toString() + ' because the topic already exist');
			}
  			break;

		case "DELETETOPICQUOTES":
			//TOPIC EXAMPLE: "MT4@ACTIVTRADES@REALTIMEQUOTES";
			if ( runningProviderTopicList.indexOf( message.toString() ) > -1 ){
				//REMOVE TOPICS (EX: MT4@ACTIVTRADES@REALTIMEQUOTES) IN THE ARRAY LIST
				var index = runningProviderTopicList.indexOf( message.toString() );
				runningProviderTopicList.splice(index, 1);
				sockSubFromQuotesProvider.unsubscribe(message.toString());
				logger.info('Deleted topic: '+message.toString() );
  				var searchObjTimeFrameQuote = "TIMEFRAMEQUOTE$"+messageArr[0]+"$"+messageArr[1];
				var searchObjRealTimeQuote = "REALTIMEQUOTE$"+messageArr[0]+"$"+messageArr[1];
				if (runningProviderTimeFrameObjs[searchObjTimeFrameQuote] != null && runningProviderTimeFrameObjs[searchObjTimeFrameQuote] != undefined && runningProviderRealTimeObjs[searchObjRealTimeQuote] != null && runningProviderRealTimeObjs[searchObjRealTimeQuote] != undefined) {
					delete runningProviderTimeFrameObjs[searchObjTimeFrameQuote];
					delete runningProviderRealTimeObjs[searchObjRealTimeQuote];
				}else{
					logger.error('topic: ' + JSON.stringify(topicArr[0]) + ' TimeFrameObj: ' + JSON.stringify(runningProviderTimeFrameObjs[searchObjTimeFrameQuote]) +' RealTimeObj: ' +JSON.stringify(runningProviderRealTimeObjs[searchObjRealTimeQuote]) + ' Its not possible to delete the TimeFrameObj and RealTimeObj for the topic '+message.toString() );
				}
				
			}else{
				logger.error('topic: ' + JSON.stringify(topicArr[0]) + ' Its not possible to delete this topic '+message.toString()+' because this topic doesnt exist' );
			}
			break;

		default:

			//EX: MT4@ACTIVTRADES@REALTIMEQUOTES, STATUS@EURUSD@111
			if (topicArr.length <= 3) {
  				//EX: MT4@ACTIVTRADES@REALTIMEQUOTES
				if (topicArr[2] == 'REALTIMEQUOTES'){
					if ( runningProviderTopicList.indexOf( topic.toString() ) > -1 ){
						//TOPIC EXAMPLE: MT4@ACTIVTRADES@REALTIMEQUOTES;
						var searchObjRealTimeQuote = "REALTIMEQUOTE$"+topicArr[0]+"$"+topicArr[1];
						var searchObjTimeFrameQuote = "TIMEFRAMEQUOTE$"+topicArr[0]+"$"+topicArr[1];



							//TODO  check if message e' solo 1 valore altrimenti dai errore


						if (messageArr.length == 2) {
							var result = QuotesModule.updateRealTimeQuotesObj(searchObjRealTimeQuote,messageArr);
							if (result == null || result == undefined) {
								logger.error('topic: ' + JSON.stringify(topicArr[0]) + ' message: ' + JSON.stringify(message.toString()) + ' the realTimeQuoteObj is not update' );
							}else{
								//logger.trace('topic: ' + JSON.stringify(topicArr[0]) + ' message: ' + JSON.stringify(message.toString()) + ' the realTimeQuoteObj is updated with the last Value' +message.toString() );
							}
						}
						else if (messageArr.length > 2) {
							var result = QuotesModule.importHistoryTimeFrameQuotesObj(searchObjTimeFrameQuote,messageArr);
							if (result == null || result == undefined) {
								logger.error('topic: ' + JSON.stringify(topicArr[0]) + ' message: ' + JSON.stringify(message.toString()) + ' Error to import HistoryData for message '+message.toString() );
							}else{
								//logger.trace('topic: ' +JSON.stringify(topicArr[0]) + ' message: ' + JSON.stringify(message.toString()) + ' updatedHistoryQuotes: '+result );
							}
						}else{
							logger.error('topic: ' + JSON.stringify(topicArr[0]) + ' message: ' + JSON.stringify(message.toString()) + ' Error in message received from Quotes provider. Message '+message.toString()+' length is not right' );
						}
					}else{
						logger.error('topic: ' + JSON.stringify(topic.toString()) + ' message: ' + JSON.stringify(message.toString()) + 'Error in message received from Quotes provider. The Quotes Provider wants to publish a new message quote '+message.toString()+' on topic '+topic.toString()+', but the topic doesnt exist ' );
					}
				}else if (topicArr[2] == 'TRADEALLOWED') {
					//EX: MT4@ACTIVTRADES@TRADEALLOWED
					var platform_broker = topicArr[0]+'$'+topicArr[1]; 
					if (marketStatus.hasOwnProperty( platform_broker )) { 
						marketStatus[ platform_broker ] = messageArr[0];
					}else{
						logger.info('create topic TRADEALLOWED: '+ JSON.stringify(topicArr) );
						marketStatus[ platform_broker ] = messageArr[0];
					}
				}else if (topicArr[0] == 'STATUS'){
					//EX: STATUS@EURUSD@111		
	  				sockPub.send([topic.toString(), message]);	
	  			}else{
					logger.error('topic: ' + JSON.stringify(topic.toString()) + ' message: ' + JSON.stringify(message.toString()) + 'Error in message received from Quotes Provider. The Quotes Provider wants to publish a new message quote '+message.toString()+',but the topic '+topic.toString()+' is not valid' );
				}
	  		}else{
	  			logger.error('topic: ' + JSON.stringify(topic.toString()) + ' message: ' + JSON.stringify(message.toString()) + ' Error in message received from Quotes Provider. The topic '+topic.toString()+' format/length is not valid.' );
	  		}
	  		break;
	}
});

//----------------------------------------------------------------------------------------------------------------------------
// SIGNAL PROVIDE PUB TO NODEJS TO QUOTES PROVIDER

//var runningSignalProviderTopicOperationList = [];
//var runningSignalProviderTopicStatusList = [];
//var TopicAlgosOperationListLabel = 'ALGOSOPERATIONLIST'; 
//var TopicAlgosStatusListLabel = 'ALGOSSTATUSLIST'; 

/*var updatingSignalProviderTopicOperationListAndTopicStatusList = function(){
	if ( runningSignalProviderTopicOperationList.length > 0 ){
		var runningSignalProviderTopicOperationListString = JSON.stringify(runningSignalProviderTopicOperationList);
		sockPub.send([TopicAlgosOperationListLabel, runningSignalProviderTopicOperationListString]);
		logger.info('New Topic Operation List, Sent message: '+runningSignalProviderTopicOperationListString+ 'on topic: '+runningSignalProviderTopicOperationListString);
	}else{
		//log arr empty
	}

	if ( runningSignalProviderTopicStatusList.length > 0 ) {
		var runningSignalProviderTopicStatusListString = JSON.stringify(runningSignalProviderTopicStatusList);
		sockPub.send([TopicAlgosStatusListLabel, runningSignalProviderTopicStatusListString]);
		logger.info('New Topic Status List, Sent message: '+runningSignalProviderTopicStatusListString+ 'on topic: '+TopicAlgosStatusListLabel);
	}else{
		//log arr empty
	}
}

//Permit to update (every 5 sec) and sending on topic the updated list for TopicStatus and TopicOperations
setInterval(function(){ updatingSignalProviderTopicOperationListAndTopicStatusList.bind(this)  },5000);*/
sockSubFromSignalProvider.subscribe('NEWTOPICFROMSIGNALPROVIDER');
sockSubFromSignalProvider.on('message', function() {
  
  	//console.log('Message from signal provider: ' + arguments);
	var data = [];//messageSub.toString().split(" ");
	Array.prototype.slice.call(arguments).forEach(function(arg) {
        data.push(arg.toString());
    });
  	var topic = data[0];
  	var message = data[1];
  	//console.log('received a message related to:', data[0], ' containing message: ', data[1]);
  	logger.info('Received message from Signal Provider: '+message+ 'on topic: '+topic);

  	switch (topic) {
  		case "NEWTOPICFROMSIGNALPROVIDER":

  			var newTopic = message.split('@');
  			if (newTopic[0] == 'OPERATIONS') {
  				//EX: OPERATIONS@ACTIVTRADES@EURUSD
				sockSubFromSignalProvider.subscribe(message);
				logger.info('New Topic OPERATION From Signal Provider: '+message);
  			}else if (newTopic[0] == 'STATUS'){
  				//EX: STATUS@EURUSD@111		
				sockSubFromQuotesProvider.subscribe(message);
				logger.info('New Topic STATUS from Signal Provider: '+message);
  			}else{
  				logger.error('topic: ' + JSON.stringify(topic) + ' message: ' + JSON.stringify(message) + ' message format from Signal Provider is not valid. Signal provider wants to create the new topic '+message+' but the format is not valid');
  			}
			break;

		case "DELETETOPICQUOTES":
			//EX: OPERATIONS@ACTIVTRADES@EURUSD STATUS@EURUSD@111	
			var deleteTopic = message.split('@');
  			if (deleteTopic[0] == 'OPERATIONS') {
				sockSubFromSignalProvider.unsubscribe( message );
				logger.info('Unsubscribe Topic Operation: '+message);
			}else if (deleteTopic[0] == 'STATUS'){
				sockSubFromQuotesProvider.unsubscribe( message );
				logger.info('Unsubscribe Topic Status: '+message);
  			}else{
  				logger.error('topic: ' + JSON.stringify(topic) + ' message: ' + JSON.stringify(message) + ' Signal provider wants to delete one TOPIC '+message+' but this topic format is not valid. Accepted only OPERATIONS/STATUS TOPICS');
  			}
			break;

		default:

		 	//EX: MATLAB@111@EURUSD@OPERATIONS
			var topicType = topic.split('@');
  			if (topicType[0] == 'OPERATIONS') {
  				//if ( runningSignalProviderTopicOperationList.indexOf( topic ) > -1 ) {
					sockPub.send([topic, message]);
					logger.info('New Operation: '+message+ 'from (on topic): '+topic);
				//}else{
				//	logger.error('topic: ' + JSON.stringify(topic) + ' message: ' + JSON.stringify(message) + ' Signal provider wants to publish a new operation on Topic '+topic+' but the topic doesnt exist. Create the topic before to push data on it');
				//}
			}else{
				logger.error('topic: ' + JSON.stringify(topic) + ' message: ' + JSON.stringify(message) + ' Signal provider wants to publish a new data on TOPIC '+message+', but this topic format is not valid');
			}
			break;
	}

});




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////        LOG SERVER         /////////////////////////////

setTimeout(function(){

	var loggerSockSub = zmq.socket('sub');
	loggerSockSub.connect('tcp://localhost:50028');

	var logStore = bunyan.createLogger({
		name: '4casterLogApp',
		streams: [
	    {
	    	level: 'trace',
	      	stream: process.stdout         // log INFO and above to stdout
	    },
	    {
	    	level: 'error',
	    	path: 'C:/4Casters/NodeLogs/4casterLogApp-error.log',  // log INFO and above to a file
	    	period: '1d',   // daily rotation
	    	count: 5        // keep 3 back copies
	    },
	    {
	    	level: 'info',
	    	path: 'C:/4Casters/NodeLogs/4casterLogApp-info.log',  // log INFO and above to a file
	    	period: '1d',   // daily rotation
	    	count: 5       // keep 3 back copies
	    },
	    {
	      	level: 'fatal',
	      	path: 'C:/4Casters/NodeLogs/4casterLogApp-fatal.log',  // log INFO and above to a file
	      	period: '1d',   // daily rotation
	      	count: 5        // keep 3 back copies
	    }
	  ]
	});


	var logMessaging = bunyan.createLogger({
	  name: '4casterLogApp',
	  streams: [
	    {
	      level: 'error',
	      stream: new BunyanSlack({
	        webhook_url: "https://hooks.slack.com/services/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",
	        channel: "#logs-node-beta",
	        username: "admin",
	        customFormatter: function(record, levelName){
	            return {text: "[" + levelName + "] " + record.msg }
	        }
	      })
	    },
	    {
	      level: 'info',
	      stream: new BunyanSlack({
	        webhook_url: "https://hooks.slack.com/services/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",
	        channel: "#logs-node-beta",
	        username: "admin",
	        customFormatter: function(record, levelName){
	            return {text: "[" + levelName + "] " + record.msg }
	        }
	      })
	    },
	    {
	      level: 'fatal',
	      stream: new BunyanSlack({
	        webhook_url: "https://hooks.slack.com/services/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",
	        channel: "#logs-node-beta",
	        username: "admin",
	        customFormatter: function(record, levelName){
	            return {text: "[" + levelName + "] " + record.msg }
	        }
	      })
	    }
	  ]
	});

	loggerSockSub.subscribe('LOGS');
	loggerSockSub.on('message', function(topic, message) {

		if (topic == "LOGS@INFO") {
			logStore.info(message.toString());
	    	logMessaging.info(message.toString());
		}else if (topic == "LOGS@FATAL") {
			logStore.fatal(message.toString());
	    	logMessaging.fatal(message.toString());
		}else if( topic == "LOGS@ERROR" ){
			logStore.error(message.toString());
	    	logMessaging.error(message.toString());
		}else if (topic == "LOGS@TRACE") {
			logStore.trace(message.toString());
		};
	});

},60000);





