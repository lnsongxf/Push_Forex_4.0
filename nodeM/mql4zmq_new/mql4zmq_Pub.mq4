#property copyright ""
#property link      "http://www.mql4zmq.org"

#include <mql4zmq.mqh>

int speaker,listener,context;

int init()
  {
//----
   int major[1];int minor[1];int patch[1];
   zmq_version(major,minor,patch);
   //Print("Using zeromq version " + major[0] + "." + minor[0] + "." + patch[0]);
   //Print("NOTE: to use the precompiled libraries you will need to have the Microsoft Visual C++ 2010 Redistributable Package installed. To Download: http://www.microsoft.com/download/en/details.aspx?id=5555");
   
   context = zmq_init(1);
   speaker = zmq_socket(context, ZMQ_PUB);
  
   /*if (zmq_bind(speaker,"tcp://127.0.0.1:50025") == -1) 
   {
      Print("Error binding the speaker!");
      return(-1);  
   }*/
   
   if (zmq_connect(speaker,"tcp://127.0.0.1:50025") == -1)
   {
      Print("Error connecting to the client!");
      return(-1);
   }
   
   
   
   return(0);
  }

int deinit()
  {
//----

   // Protect against memory leaks on shutdown.
   zmq_close(speaker);
   zmq_close(listener);
   zmq_term(context);

//----
   return(0);
  }

int start()
  {

   // Publish current tick value.
   string current_tick = "tick " + Bid + " " + Ask + " " + Time[0];
   
   string topic = "EURUSD@30m@40";
   s_sendmore(speaker, topic);
   if(s_send(speaker, current_tick) == -1)
      Print("Error sending message: " + current_tick);
   else
      Print("Published message: " + current_tick);
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
