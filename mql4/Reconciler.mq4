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

string speaker;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   speaker = connect("tcp://localhost:51025");
   Print("Connecting: " + speaker);
   
   return(INIT_SUCCEEDED);
  }
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
  
      
      return(rates_total);
  }

int deinit()
{
   //close the socket
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