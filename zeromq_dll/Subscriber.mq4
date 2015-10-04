//+------------------------------------------------------------------+
//|                                                   Subscriber.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#include <zmq_sub.mqh>

#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

string listener;
string buffer;
string speaker;
int OnInit()
  {
//---
     Alert("Initialising sub indicator");
//--- indicator buffers mapping
   //listener = conn_and_sub(1, "tcp://192.168.53.68:5563", "eurusd");
   listener = conn_and_sub("tcp://localhost:50027", "eurusd");
   speaker = connect("tcp://localhost:50025");
   Alert("Conn and sub ing: " + listener);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   string msg;
   do {
      msg = receive(listener);
      if (StringLen(msg) > 0)
      {
         if (StringCompare("empty", msg) != 0)
         {
            //Print("msg: " + msg);
            processInput(msg);
         }
         
      }
   }while (StringCompare("empty", msg) != 0);
         
  }
  
  void processInput(string msg)
{
   int index = 0;
   int newindex = 0;
   int k = 0;
      
   buffer = "";
      
   while( index < StringLen(msg) && newindex >= 0){
         //Alert(msg);
      double stoploss = 0;
      double takeprofit = 0;
      int magic = 0;
                  
      newindex = StringFind(msg,",",index);
      string s = StringSubstr(msg,index,newindex-index);
      index = newindex+1;
            
      int detailIndex = 0;
      int newDetailIndex = 0;
      int kDetail = 0;
               
      string detailmsg = s;
      int counter = 0;      
         
      string origmsg = detailmsg;
      while(detailIndex < StringLen(origmsg) && newDetailIndex >= 0){
         //Alert(s);   
         newDetailIndex = StringFind(origmsg,";",detailIndex );
         detailmsg = StringSubstr(origmsg,detailIndex,newDetailIndex);
         detailIndex = newDetailIndex+1;
         
         counter = counter+1;
         int subindex      =  StringFind(detailmsg, "=", 0);
         string id      =  StringSubstr(detailmsg,0,subindex);
         string sNumber =  StringSubstr(detailmsg,subindex+1,StringLen(s));
         int number     =  StrToInteger(sNumber);
         //Alert(id);
         //Alert(number);
         if(id == "sl")
         {
            stoploss = number;
         }
         else if(id == "tp")
         {
            takeprofit = number;
         } 
         else if(id == "key")
         {
            magic = number;    
         }     
         else
         {
            // Viene gestita la posizione letta dal file      
            int lastTicket;
            if(number >= 1) {
               lastTicket = ApriPosizioneEuro(id,stoploss,takeprofit,magic);
            } else if(number <= -1) {  
               lastTicket = ApriPosizioneDollaro(id,stoploss,takeprofit,magic); 
            } else if(number == 0){
               //Alert("Richiesta di chiusura del ticket: "+id);
               int currentPosition;
               int total=OrdersTotal();    
               if(!OrderSelect(StrToInteger(id), SELECT_BY_TICKET, MODE_TRADES))
               {
                  Alert("Ticket da chiudere non trovato");
                  writeResponse(magic+"="+GetLastError());
               }
               else
               {      
                  if(OrderType() == OP_BUY) {
                     currentPosition = 1;        
                  } else {
                     currentPosition = -1;        
                  }
               }
               if(currentPosition == 1) {
                  ChiudiPosizioneEuro(StrToInteger(id),magic);
               } else if(currentPosition == -1) {
                  ChiudiPosizioneDollaro(StrToInteger(id),magic);
               }
            }
         }
      }
   }    

      
   if(StringLen(buffer) > 0){
      string output = StringSubstr(buffer,0,StringLen(buffer)-1);
      writeResponse(output);
   }
   return ;
}

  int ApriPosizioneEuro(string id, double sl, double tp, int magic) {
      RefreshRates();
      Alert("tp = " + tp);
      Alert("sl = " + sl);
      Alert("magic = " + magic);

      if(tp > 0)
      {
         tp = Ask+tp*Point;
      }
      if(sl > 0)
      {
         sl = Ask-sl*Point;
      }

      int ticket = OrderSend(Symbol(),OP_BUY,1,Ask,25,sl,tp,"commento",magic,0,CLR_NONE);      


      Alert("Posizione Euro aperta: ticket ",ticket);
      if(ticket < 0) {
         Alert("Errore! posizione non aperta per errore ",GetLastError()); 
      } 
      else
      {
         OrderSelect(StrToInteger(id), SELECT_BY_TICKET, MODE_TRADES); 
         Alert("Stop loss  : " + OrderStopLoss());
         Alert("Take profit: " + OrderTakeProfit());
      }
      buffer = buffer+(magic+"="+ticket+",");
      return (ticket);
   }


   int ApriPosizioneDollaro(string id,double sl, double tp, int magic) {
      RefreshRates();
      Alert("tp = " + tp);
      Alert("sl = " + sl);
      Alert("magic = " + magic);

      if(tp > 0)
      {
         tp = Bid-tp*Point;
      }
      if(sl > 0)
      {
         sl = Bid+sl*Point;
      }

      int ticket = OrderSend(Symbol(),OP_SELL,1,Bid,5,sl,tp,"commento",magic,0,CLR_NONE);
      Alert("Posizione Dollaro aperta: ticket ",ticket);
      if(ticket < 0){
         Alert("Errore! posizione non aperta per errore ",GetLastError());
      }
      else
      {
         OrderSelect(StrToInteger(id), SELECT_BY_TICKET, MODE_TRADES); 
         Alert("Stop loss  : " + OrderStopLoss());
         Alert("Take profit: " + OrderTakeProfit());
      }
      buffer = buffer+(magic+"="+ticket+",");
      return (ticket);
   } 


   void ChiudiPosizioneEuro(int ticket, int magic) {
      
      Alert("Attempting to close the ticket " + ticket);
      RefreshRates();
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) {
         if(OrderClose(ticket,1,Bid,4,CLR_NONE))
           buffer = buffer+(magic+"="+"1"+",");
        else{
           Alert("Errore! posizione non chiusa per errore ",GetLastError());
           buffer = buffer+(magic+"="+GetLastError()+",");
        }
      }
   }


   void ChiudiPosizioneDollaro(int ticket, int magic){
      Alert("Attempting to close the ticket " + ticket);
      RefreshRates();
       if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) {
         if(OrderClose(ticket,1,Ask,4,CLR_NONE))
            buffer = buffer+(magic+"="+"1"+",");
         else{
            Alert("Errore! posizione non chiusa per errore ",GetLastError());
            buffer = buffer+(magic+"="+GetLastError()+",");
         }
      }
   }
   
   void writeResponse(string output){
      output = output + ",cross="+Symbol();
      send_with_topic(speaker, output+"\n", "MT4@status");
   }

