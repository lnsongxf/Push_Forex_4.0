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
   listener = zmq_socket(context, ZMQ_PULL);
   
   /*if (zmq_bind(listener,"tcp://127.0.0.1:50005") == -1)
   {
      Print("Error binding the listener!");
      return(-1);
   }*/
   
   if (zmq_connect(listener,"tcp://127.0.0.1:50005") == -1)
   {
      Print("Error connecting to the client!");
      return(-1);
   }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
   string message2 = s_recv(listener, ZMQ_NOBLOCK);
   if (message2 != "") // Will return NULL if no message was received.
   {
      Print("Received message: " + message2);
   }
   return(0);
  }
//+------------------------------------------------------------------+
