//+------------------------------------------------------------------+
//|                                                HistorySender.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#include <zmq_sub.mqh>

string cross_array[] = {"EURUSD", "GBPUSD", "AUDCAD", "GBPJPY", "USDCHF"};

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(60*60*24); //One day
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
//---
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
      string terminalPath = TerminalInfoString(TERMINAL_DATA_PATH);
      for (int i = 0; i < ArraySize(cross_array); i++) {
         string cross = cross_array[i];
         string fileName = terminalPath + "\\MQL4\\Files\\" + cross + ".csv";
         int fileHandle = FileOpen(fileName, FILE_WRITE|FILE_CSV);
         if (fileHandle == INVALID_HANDLE) {
            int error = GetLastError();
            Print(IntegerToString(error) + " error on creating file " + fileName); 
         }
         dump_history(cross, fileHandle);
         FileClose(fileHandle);
      }
  }
//+------------------------------------------------------------------+

void dump_history(string cross, int handle)
{
      int cnt = 0;
      datetime now = TimeCurrent();
      int number_bars = 60*24*250*4;//Minutes in 4 years;
      int period = 1;
      string period_string = "1";
      string message = "";
      for (cnt = number_bars; cnt >= 0; cnt--) {
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
               s_day = "0" + IntegerToString(day);
            } else {
               s_day = "" + IntegerToString(day);
            }
            
            int month = TimeMonth(iTime  (Symbol(), period, cnt));
            string s_month;
            if (month < 10) {
               s_month = "0" + IntegerToString(month);
            } else {
               s_month = "" + IntegerToString(month);
            }
            string year = IntegerToString(TimeYear(iTime  (Symbol(), period, cnt)));
            string date = s_month+"/"+s_day+"/"+year;

            double strline_intero=StrToDouble(strline);
            double strline_intero2=StrToDouble(strline2);
            double strline_intero3=StrToDouble(strline3);
            double strline_intero4=StrToDouble(strline4);
            double strline_intero5=StrToDouble(strline5);
            double strline_intero6=StrToDouble(strline6);
            
            int history_data_close  = (int)(strline_intero*10000);
            int history_data_open   = (int)(strline_intero2*10000);
            int history_data_high   = (int)(strline_intero3*10000);
            int history_data_low    = (int)(strline_intero4*10000);
            int history_data_volume = (int)strline_intero5;

            message += IntegerToString(history_data_open)+","+IntegerToString(history_data_high)+","+IntegerToString(history_data_low)+","+IntegerToString(history_data_close)+","+IntegerToString(history_data_volume)+","+date +" "+strline6+"\n";
            if (cnt % 10 == 0) {
               FileWrite(handle, message);
               message = "";   
            }
            
      } // end for
      FileWrite(handle, message);
}