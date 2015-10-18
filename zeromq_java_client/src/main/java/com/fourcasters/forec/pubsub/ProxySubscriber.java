package com.fourcasters.forec.pubsub;

import java.nio.charset.Charset;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.zeromq.ZMQ;
import org.zeromq.ZMQ.Context;
import org.zeromq.ZMQ.Socket;

public class ProxySubscriber {

	private static final Logger LOG = LogManager.getLogger(ProxySubscriber.class);

	public static void main (String[] args) {
		
        // Prepare our context and subscriber
        Context context = ZMQ.context(1);
        Socket subscriber = context.socket(ZMQ.SUB);
        Socket publisher = context.socket(ZMQ.PUB);
        subscriber.bind("tcp://*:50026");
        subscriber.subscribe("OPERATIONS".getBytes());
        publisher.connect("tcp://2.125.222.249:50026");
        LOG.info("Connected");
        while (!Thread.currentThread ().isInterrupted ()) {
            // Read envelope with address
            String address = subscriber.recvStr(Charset.defaultCharset());
            String contents = subscriber.recvStr (Charset.defaultCharset());
            LOG.info(address + " = " + contents);
            publisher.sendMore(address);
            publisher.send(contents);
        }
        subscriber.close ();
        context.term ();
    }

}

