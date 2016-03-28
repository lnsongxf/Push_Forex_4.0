package com.fourcasters.forec.pubsub;

import org.zeromq.ZMQ;
import org.zeromq.ZMQ.Context;
import org.zeromq.ZMQ.Socket;

public class Publisher {

    public static void main (String[] args) throws Exception {
        // Prepare our context and publisher
        Context context = ZMQ.context(1);
        Socket publisher = context.socket(ZMQ.PUB);

        publisher.bind("tcp://*:5563");
        //publisher.connect("tcp://localhost:5563");
        while (!Thread.currentThread ().isInterrupted ()) {
            // Write two messages, each with an envelope and content
            publisher.sendMore ("A");
            publisher.send ("We don't want to see this");
            publisher.sendMore ("OPERATIONS@ACTIVTRADES@EURUSD@1024");
            publisher.send("price=11214,lots=1,slippage=0.2,ticket=100358333,op=0");
            Thread.sleep(10000L);
        }
        publisher.close ();
        context.term ();
    }

}
