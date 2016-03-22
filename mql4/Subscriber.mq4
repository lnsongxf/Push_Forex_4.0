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
   string topic = "OPERATIONS@ACTIVTRADES@" + Symbol();
   listener = conn_and_sub("tcp://localhost:50027", topic);
   Alert("Listening to " + topic);
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
      msg = receive(listener); //topic
      if (StringLen(msg) > 0)
      {

        
        string sep="@";                // A separator as a character
        ushort u_sep;                  // The code of the separator character
        string result[];               // An array to get strings
        //--- Get the separator code
        u_sep=StringGetCharacter(sep,0);
        //--- Split the string to substrings
        int k=StringSplit(msg,u_sep,result);
        //--- Show a comment 
        PrintFormat("Strings obtained: %d. Used separator '%s' with the code %d",k,sep,u_sep);
        //--- Now output all obtained strings
        if (k > 0) {
          int magic = StrToInteger(result[k-1]);
          msg = receive(listener); //message
          Alert("Message received: " + msg);
          processInput(msg, magic);
        }
      }
   }while (StringLen(msg) != 0);
         
  }
  
  void processInput(string msg, int magic)
{
   buffer = "";
   int op=-999;
   int ticket=123456789;
   double stoploss = 0;
   double takeprofit = 0;
   string sep=",";                // A separator as a character
   ushort u_sep;                  // The code of the separator character
   string result[];               // An array to get strings
   //--- Get the separator code
   u_sep=StringGetCharacter(sep,0);
   //--- Split the string to substrings
   int k=StringSplit(msg,u_sep,result);
   //--- Show a comment 
   PrintFormat("Strings obtained: %d. Used separator '%s' with the code %d",k,sep,u_sep);
   //--- Now output all obtained strings
   if(k>0)
     {
      for(int i=0;i<k;i++)
        {
         PrintFormat("result[%d]=%s",i,result[i]);
         string token = result[i];
         string substrings[];
         string subsep = "=";
         ushort u_subsep = StringGetCharacter(subsep,0);
         StringSplit(token,u_subsep,substrings);
         string id = substrings[0];
         int number = StringToDouble(substrings[1]);
         //Alert(id);
         //Alert(number);
         if(id == "sl")
         {
            stoploss = number;
            Alert("sl = " + stoploss);
         }
         else if(id == "tp")
         {
            takeprofit = number;
            Alert("tp = " + takeprofit);
         } 
         else if(id == "magic")
         {
            magic = number;
            Alert("magic = " + magic);
         }   
         else if(id == "price") {}
         else if(id == "slippage") {}
         else if(id == "lots") {}
         else if(id == "ticket")
         {
            ticket = number;
         }
         else if(id == "op")
         {
            op = number;
         }
         else
         {
            Alert("WTF??? is a " + id);
         }
      }
   }
   // Viene gestita la posizione letta dal file      
   int lastTicket;
   if(op == 1) {
       lastTicket = ApriPosizioneEuro("what",stoploss,takeprofit,magic);
   } else if(op == -1) {  
       lastTicket = ApriPosizioneDollaro("what",stoploss,takeprofit,magic); 
   } else if(op == 0){
       //Alert("Richiesta di chiusura del ticket: "+id);
       int currentPosition;
       int total=OrdersTotal();    
       if(!OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
       {
           Alert("Ticket da chiudere non trovato");
           writeResponse(magic+"="+GetLastError(), magic);
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
           ChiudiPosizioneEuro(ticket,magic);
       } else if(currentPosition == -1) {
           ChiudiPosizioneDollaro(ticket,magic);
       }
   }
   else
   {
       Alert("WTF???");
   }
    
   if(StringLen(buffer) > 0){
      //string output = StringSubstr(buffer,0,StringLen(buffer)-1);
      //writeResponse(output);
      writeResponse(buffer, magic);
   }
   else {
      Alert("Buffer is empty, what the hell ??");
   }
   return;
}

  int ApriPosizioneEuro(string id, double sl, double tp, int magic) {
      RefreshRates();

      if(tp > 0)
      {
         tp = Ask+tp*Point;
      }
      if(sl > 0)
      {
         sl = Ask-sl*Point;
      }

      int ticket = OrderSend(Symbol(),OP_BUY,1,Ask,50,sl,tp,"commento",magic,0,CLR_NONE);      
      string type = "open";
      int status = 1;
      int price = -1;
      
      Alert("Posizione Euro aperta: ticket ",ticket);
      if(ticket < 0) {
         Alert("Errore! posizione non aperta per errore ",GetLastError()); 
         ticket = -1;
         status = -1;
      } 
      else
      {
         OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES); 
         price = OrderOpenPrice()*10000;
         Alert("Stop loss  : " + OrderStopLoss());
         Alert("Take profit: " + OrderTakeProfit());
      }
      buffer = status + "," + type + "," + price + "," + ticket;
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
      string type = "open";
      int status = 1;
      int ticket = OrderSend(Symbol(),OP_SELL,1,Bid,50,sl,tp,"commento",magic,0,CLR_NONE);
      int price = -1;
      Alert("Posizione Dollaro aperta: ticket ",ticket);
      if(ticket < 0){
         Alert("Errore! posizione non aperta per errore ",GetLastError());
         ticket = -1;
         status = -1;
      }
      else
      {
         OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES); 
         price = OrderOpenPrice()*10000;
         Alert("Stop loss  : " + OrderStopLoss());
         Alert("Take profit: " + OrderTakeProfit());
      }
      buffer = status + "," + type + "," + price + "," + ticket;
      return (ticket);
   } 


   void ChiudiPosizioneEuro(int ticket, int magic) {
      string type = "close";
      int status = 1;
      int price = -1;
      Alert("Attempting to close the ticket " + ticket);
      RefreshRates();
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) {
         if(OrderClose(ticket,1, OrderClosePrice(),50,CLR_NONE)) {
            OrderSelect(ticket,SELECT_BY_TICKET,MODE_HISTORY);
            price = OrderClosePrice()*10000;
            status = 1;
        }
        else{
           Alert("Errore! posizione non chiusa per errore ",GetLastError());
           buffer = buffer+(magic+"="+GetLastError()+",");
        }
      }
      else if (OrderSelect(ticket,SELECT_BY_TICKET,MODE_HISTORY)) {
            price = OrderClosePrice()*10000;
            status = 1;
      }
      buffer = status + "," + type + "," + price + "," + ticket;
   }


   void ChiudiPosizioneDollaro(int ticket, int magic){
      string type = "close";
      int status = -1;
      int price = -1;
      Alert("Attempting to close the ticket " + ticket);
      RefreshRates();
      if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)) {
         if(OrderClose(ticket,1, OrderClosePrice(),50,CLR_NONE)) {
            OrderSelect(ticket,SELECT_BY_TICKET,MODE_HISTORY);
            price = OrderClosePrice()*10000;
            status = 1;
         }
         else{
            Alert("Errore! posizione non chiusa per errore ",GetLastError());
         }
      }
      else if (OrderSelect(ticket,SELECT_BY_TICKET,MODE_HISTORY)) {
            price = OrderClosePrice()*10000;
            status = 1;
      }
      buffer = status + "," + type + "," + price + "," + ticket;
   }
   
   void writeResponse(string output, int magic){
      string topic = "STATUS@"+ Symbol() +"@" + IntegerToString(magic);
      Alert("Message to send: " + output + " on topic: " + topic);
      int result = send_with_topic(speaker, output+"\n", topic);
      Alert("Sending result = " + IntegerToString(result));
      Alert("Message sent: " + output + " on topic: " + topic);
   }

