//+------------------------------------------------------------------+
//|                                                    Reconciler.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#include <zmq_sub.mqh>

#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

string listener;
string speaker;

int MAX_NUM_OF_TRADES_PER_MESSAGE = 25;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   listener = conn_and_sub("tcp://localhost:51127", "RECONCILER@ACTIVTRADES@EURUSD");
   speaker = connect("tcp://localhost:51125");
   Print("Connecting: " + listener);
   
   return(INIT_SUCCEEDED);
  }
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int deinit()
{
   //close(listener);
   //close(speaker);
   return 0;
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
  
   string msg;
   
   //Alert("Tick!");
   msg = receive(listener);
   //Alert("Msg: " + msg);
   if (StringLen(msg) > 0)
   {
      //Alert("Msg: " + msg);
      if (StringCompare("FULL", msg) == 0)
      {
         Alert("Message received: " + msg);
         processInput(msg);
      }   
   }
   return 0;
}

void processInput(string msg)
{
   if (StringCompare("FULL", msg) == 0)
   {
      string buffer = "";
      string topic = "HISTORY@ACTIVTRADES@EURUSD";
      // retrieving info from trade history
      int i,j=0,hstTotal=OrdersHistoryTotal();
      for(i=0;i<hstTotal;i++)
      {
         //---- check selection result
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false)
         {
            Print("Access to history failed with error (",GetLastError(),")");
            break;
         }
         // some work with order
         buffer += nextOrderToString();
         j = j + 1;
         if (j >= MAX_NUM_OF_TRADES_PER_MESSAGE && i != hstTotal - 1) {
            buffer += "|";
            buffer += "more";
            
            send(topic, buffer);
            
            j = 0;
            buffer = "";
            
         }
         if (j != 0 && i < hstTotal - 1) 
         {
            buffer += "|";
         }
      }
      send(topic, buffer);
   }
   else {
   	Print("Invalid command " + msg);
   }
   
}

string nextOrderToString()
{
   //ticket number; open time; trade operation; amount of lots; symbol; open price; Stop Loss; Take Profit; close time; close price; commission; swap; profit;
   //comment; magic number; pending order expiration date.
   // Open Date,Close Date,Symbol,Action,
   // Lots,SL,TP,Open Price,Close Price,Commission,Swap,Pips,Profit,
   // Comment,Magic Number,Duration (DD:HH:MM:SS),Profitable(%),Profitable(time duration),
   // Drawdown,Risk:Reward,Max(pips),Max(EUR),Min(pips),Min(EUR),Entry Accuracy(%),Exit Accuracy(%),ProfitMissed(pips),ProfitMissed(EUR)%

   //% 10/31/2013 12:48,10/31/2013 13:44,EURUSD,Buy,
   //% 1.00,1.36414,1.36644,1.36622,1.36409,0.0000,0.0000,-21.3,-156.15,
   //% "commento",1943642475,00:00:56:26,0.0,0s,
   //% 29.8,29.85,0.0,0.0,-29.8,-218.434,0.0,28.5,-21.30,-156.13

   string buffer =
   StringConcatenate(
   OrderOpenTime(),";",
   OrderCloseTime(),";",
   OrderSymbol(),";",
   OrderType(),";",
   OrderLots(),";",
   OrderStopLoss(),";",
   OrderTakeProfit(),";",
   OrderOpenPrice(),";",
   OrderClosePrice(),";",
   OrderCommission(),";",
   OrderSwap(),";",
   OrderProfit(),";",
   OrderComment(),";",
   OrderMagicNumber(),";",

   "-1;", //Duration
   "-1;", //Profitable
   "-1;", //Profitable
   "-1;", //Drawdown
   "-1;", //Risk:Reward
   "-1;", //Max
   "-1;", //Max
   "-1;", //Min
   "-1;", //Min
   "-1;", //Entry Accuracy
   "-1;", //Exit Accuracy
   "-1;", //ProfitMissed
   "-1;", //ProfitMissed

   OrderTicket());

   return buffer;
}

void send(string topic, string message){
   Print("Message to send: " + message + " on topic: " + topic);
   int result = send_with_topic(speaker, message+"\n", topic);
   Print("Sending result = " + IntegerToString(result));
   Print("Message sent: " + message + " on topic: " + topic);
}

int sleepXIndicators(int milli_seconds)
  {
   uint cont=0;
   uint startTime;
   int sleepTime=0;
   startTime = GetTickCount();
   while (cont<1000000000)
     {
      cont++;
      sleepTime = (int)(GetTickCount()-startTime);
      if ( sleepTime >= milli_seconds ) break;
     }   
   return(sleepTime);
  }