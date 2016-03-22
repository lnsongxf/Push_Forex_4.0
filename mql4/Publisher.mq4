//+------------------------------------------------------------------+
//|                                                    Publisher.mq4 |
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

bool first_time = true;

   //FREQUENZA DI AGGIORNAMENTO E ESTENSIONE DEL FILE
   int    frequency_update = 1;
   string file_extension   = ".csv";

   //SETTAGGI NUMERO DI RECORD E ANNO
   int  number_bars   = 1000;
   int  from_year     = 2009;
   
   //VISUALIZZA SUL GRAFICO LE BARRE
   bool completed_bar = false;
   bool enable_debug  = false;

   //PERIODO
   bool period_weekly = false;
   bool period_daily  = false;
   bool period_4hour  = false;
   bool period_1hour  = false;
   bool period_30min  = true;
   bool period_15min  = false;
   bool period_5min   = false;
   bool period_1min   = false;
   
   //PERMESSI DI SCRITTURA
   bool writedata = true;

   //FILE HANDLE
   int handle, cnt, shift;
   int current_time = 0;
   int history_data_close;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   speaker = connect("tcp://localhost:50025");
   Print("Connecting: " + speaker);

      string new_quotes_topic_message = "MT4@ACTIVTRADES@REALTIMEQUOTES";
      
      string topic0 = "NEWTOPICQUOTES";
      sleepXIndicators(5000);
      if(send_with_topic(speaker, new_quotes_topic_message, topic0) == -1)
         Print("Error sending message: " + new_quotes_topic_message);
      else
         Print("Published message new topic: " + new_quotes_topic_message);
      
      write_history(30);
      write_history(1);
      
      first_time = false;
   
   EventSetTimer(60);
   
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
  
      //SWITCH IL PERIODO DEL FILE DELLA STRINGA   
      string period_string_file;

      period_string_file = "1";

      string strline2 = DoubleToStr(iOpen  (Symbol(), PERIOD_M1, 0), 5);
      string strline3 = DoubleToStr(iHigh  (Symbol(), PERIOD_M1, 0), 5);
      string strline4 = DoubleToStr(iLow   (Symbol(), PERIOD_M1, 0), 5);
      string strline  = DoubleToStr(iClose (Symbol(), PERIOD_M1, 0), 5);
      string strline5 = DoubleToStr(iVolume(Symbol(), PERIOD_M1, 0), 5);
      string strline6 = DoubleToStr(Bid, 5);
            int day = Day();
            string s_day;
            if (day < 10) {
               s_day = "0" + day;
            } else {
               s_day = "" + day;
            }
            
            int month = Month();
            string s_month;
            if (month < 10) {
               s_month = "0" + month;
            } else {
               s_month = "" + month;
            }
            string year = Year();
            string date = s_month+"/"+s_day+"/"+year;
      string strline7 = TimeToStr  (TimeCurrent(),TIME_MINUTES);

      double strline_intero=StrToDouble(strline);
      double strline_intero2=StrToDouble(strline2);
      double strline_intero3=StrToDouble(strline3);
      double strline_intero4=StrToDouble(strline4);
      double strline_intero5=StrToDouble(strline5);
      double strline_intero6=StrToDouble(strline6);

      int history_data_close  = strline_intero*10000;
      int history_data_open   = strline_intero2*10000;
      int history_data_high   = strline_intero3*10000;
      int history_data_low    = strline_intero4*10000;
      int history_data_volume = strline_intero5;
      int history_data_bid    = strline_intero6*10000;
      string current_tick = Symbol()+"@"+history_data_open+","+history_data_high+","+history_data_low+","+history_data_bid+","+history_data_volume+","+date + " " + strline7;

      string topic2 = "MT4@ACTIVTRADES@REALTIMEQUOTES";
      int result = send_with_topic(speaker, current_tick, topic2);
      if(result == -1)
         Print("Error sending message: " + current_tick);
      //else
         //Print("Published message: " + current_tick);  
  
      return(rates_total);
  }

//+------------------------------------------------------------------+


void write_history(int period) {    
      //SWITCH IL PERIODO DELLA STRINGA   
      string period_string;

      //SWITCH IL PERIODO DEL FILE DELLA STRINGA   
      string period_string_file;

      switch(period) {
         case 10080 :
         period_string = "w1";
         period_string_file = "10080";
         break;

         case 1440 :
         period_string = "d1";
         period_string_file = "1440";
         break;

         case 240 :
         period_string = "h4";
         period_string_file = "240";
         break;

         case 60 :
         period_string = "h1";
         period_string_file = "60";
         break;

         case 30 :
         period_string = "m30";
         period_string_file = "30";
         break;

         case 15 :
         period_string = "m15";
         period_string_file = "15";
         break;

         case 5 :
         period_string = "m5";
         period_string_file = "5";
         break;
      
         case 1 :
         period_string = "m1";
         period_string_file = "1";
         break;
      }  // end swith

      //RESETTO STRINGA
      string message = Symbol() + "@" + period_string + "@";
      //LEGGO L ESISTENZA DEI RECORDO SUL FILE
      for (cnt = number_bars; cnt >= shift; cnt--) {
         //VERIFICO L ANNO
         if (from_year < TimeYear(iTime(Symbol(), period, cnt))) {
            //ASSEGNO I CONTENUTI
          
            string strline2 = DoubleToStr(iOpen  (Symbol(), period, cnt), 4);
            string strline3 = DoubleToStr(iHigh  (Symbol(), period, cnt), 4);
            string strline4 = DoubleToStr(iLow   (Symbol(), period, cnt), 4);
            string strline  = DoubleToStr(iClose (Symbol(), period, cnt), 4);
            string strline5 = DoubleToStr(iVolume(Symbol(), period, cnt), 4);
            string strline6 = TimeToStr  (iTime  (Symbol(), period, cnt),TIME_MINUTES);
            int day = TimeDay(iTime  (Symbol(), period, cnt));
            string s_day;
            if (day < 10) {
               s_day = "0" + day;
            } else {
               s_day = "" + day;
            }
            
            int month = TimeMonth(iTime  (Symbol(), period, cnt));
            string s_month;
            if (month < 10) {
               s_month = "0" + month;
            } else {
               s_month = "" + month;
            }
            string year = TimeYear(iTime  (Symbol(), period, cnt));
            string date = s_month+"/"+s_day+"/"+year;
            //Alert(strline6);
            double strline_intero=StrToDouble(strline);
            double strline_intero2=StrToDouble(strline2);
            double strline_intero3=StrToDouble(strline3);
            double strline_intero4=StrToDouble(strline4);
            double strline_intero5=StrToDouble(strline5);
            double strline_intero6=StrToDouble(strline6);
            
            int history_data_close  = strline_intero*10000;
            int history_data_open   = strline_intero2*10000;
            int history_data_high   = strline_intero3*10000;
            int history_data_low    = strline_intero4*10000;
            int history_data_volume = strline_intero5;
            //Alert("1 minuto: " ,history_data_close);  
         
            //SCRIVO I CONTENUTI
            
            message += history_data_open+","+history_data_high+","+history_data_low+","+history_data_close+","+history_data_volume+","+date +" "+strline6;
            if(cnt != shift) message += "$";
            //FileWrite(handle, history_data_open+","+history_data_high+","+history_data_low+","+history_data_close+","+history_data_volume);
            
          } // end if
      } // end for
      message += "\n";
      // Publish current tick value.
      //string current_tick = Symbol()+"@" + Bid + ";" + Ask + ";" + Time[0];
      string topic2 = "MT4@ACTIVTRADES@REALTIMEQUOTES";
      string topic3 = "MT4@ACTIVTRADES@HISTORYQUOTES";
      if(send_with_topic(speaker, message, topic2) == -1)
         Print("Error sending message: " + message);
      else
         Print("Published message: " + message);
      if(send_with_topic(speaker, message, topic3) == -1)
         Print("Error sending message: " + message);
      else
         Print("Published message: " + message);
          
      Alert("Finito davvero...");
      
   } // end method write_history(int)
//+------------------------------------------------------------------+

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

  void OnTimer() {
   string topic = "MT4@ACTIVTRADES@TRADEALLOWED";
   string isMarketOpen = IntegerToString(MarketInfo(Symbol(), MODE_TRADEALLOWED));
   send_with_topic(speaker, isMarketOpen, topic);
  }
  