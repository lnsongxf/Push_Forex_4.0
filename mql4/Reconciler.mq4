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
   listener = conn_and_sub("tcp://localhost:51127", "RECONCILER@ACTIVTRADES@" + Symbol());
   speaker = connect("tcp://localhost:51125");
   Print("Connecting: " + listener);
   MathSrand(GetTickCount());
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
   if (StringLen(msg) > 0)
   {
      Alert("Msg: " + msg);
      msg = receive(listener);
   
      //Alert("Msg: " + msg);
      
      Alert("Message received: " + msg);
      processInput(msg);
         
   }
   return 0;
}

void processInput(string msg)
{
   int id = MathRand()%1024;
   string topic = "HISTORY@ACTIVTRADES@EURUSD";
   if (StringCompare("FULL", msg) == 0)
   {
      
      string buffer = IntegerToString(id) + "=FULL=";
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
            buffer = IntegerToString(id) + "=FULL=";
            
         }
         if (j != 0 && i < hstTotal - 1) 
         {
            buffer += "|";
         }
      }
      send(topic, buffer);
   }
   else if (StringCompare("OPEN", msg) == 0)
   {
      
      string buffer = IntegerToString(id) + "=OPEN=";
      // retrieving info from trade history
      int i,j=0,hstTotal=OrdersTotal();
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
            buffer = IntegerToString(id) + "=OPEN=";
            
         }
         if (j != 0 && i < hstTotal - 1) 
         {
            buffer += "|";
         }
      }
      send(topic, buffer);
   }
   else if(StringFind(msg, "SINGLE=", 0) == 0) {
      int ticket = (int)StringToInteger(StringSubstr(msg, 7));
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)==false)
      {
         Print("Access to history failed with error (",GetLastError(),")");
      }
      else if {
        if (OrderCloseTime() <= 0) {
          Print("Operation " + IntegerToString(ticket) + " is not closed yet");
        }
      }
      else 
      {
        string buffer = IntegerToString(id) + "=SINGLE=" + nextOrderToString();
        send(topic, buffer);
      }
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
   "-1,", //index of stick
   OrderOpenPrice(),",",
   OrderClosePrice(),",",
   OrderProfit(),",",
   IntegerToString(-1*(OrderType()*2-1)),",",
   "1,", //real
   TimeToStringNS(OrderOpenTime()),",",
   TimeToStringNS(OrderCloseTime()),",",
   OrderLots(),",",
   "-1,", //Duration
   "-1,", //Profitable
   OrderSymbol(),",",
   OrderStopLoss(),",",
   OrderTakeProfit(),",",
   OrderCommission(),",",
   OrderSwap(),",",
   OrderComment(),",",
   OrderMagicNumber(),",",
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

 string TimeToStringNS(datetime when){
  string withSep = TimeToStr(when),              // "yyyy.mm.dd hh:mi"
         withOut = StringSubstr(withSep,  5, 2)  // mm
         + "/"
                 + StringSubstr(withSep,  8, 2)  // dd
                 + "/"
                 + StringSubstr(withSep,  0, 4)  // yyyy
                 + " "
                 + StringSubstr(withSep,  11, 2)  // hh
                 + ":"
                 + StringSubstr(withSep, 14, 3); // mi
  return(withOut);                               // "mmddyyyy hhmi"
}
