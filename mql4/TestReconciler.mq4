//+------------------------------------------------------------------+
//|                                               TestReconciler.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

int MAX_NUM_OF_TRADES_PER_MESSAGE = 25;

void OnStart()
  {

      string buffer = "";
      string topic = "HISTORY@ACTIVTRADES@EURUSD";
      // retrieving info from trade history
      int i,hstTotal=OrdersHistoryTotal();
      for(i=0;i<hstTotal;i++)
      {
         //---- check selection result
         if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false)
         {
            Print("Access to history failed with error (",GetLastError(),")");
            break;
         }
         // some work with order
         buffer += ";";
         buffer += nextOrderToString();
         if (i >= MAX_NUM_OF_TRADES_PER_MESSAGE) {
            buffer += ";";
            buffer += "more";
            
            Print(StringConcatenate(topic, ":" ,buffer));
         }
      }
      Print(StringConcatenate(topic, ":" ,buffer));
  }

string nextOrderToString()
{
   //ticket number; open time; trade operation; amount of lots; symbol; open price; Stop Loss; Take Profit; close time; close price; commission; swap; profit;
   //comment; magic number; pending order expiration date.
   string buffer = "";
   StringConcatenate(OrderTicket(),";",
   OrderOpenTime(),";",
   OrderType(),";",
   OrderLots(),";",
   OrderSymbol(),";",
   OrderOpenPrice(),";",
   OrderStopLoss(),";",
   OrderTakeProfit(),";",
   OrderCloseTime(),";",
   OrderClosePrice(),";",
   OrderCommission(),";",
   OrderSwap(),";",
   OrderProfit(),";",
   OrderComment(),";",
   OrderMagicNumber());

   return buffer;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
//---
  }