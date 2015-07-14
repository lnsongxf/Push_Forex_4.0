package com.fourcasters.forec.pubsub;

import java.nio.charset.Charset;
import java.util.Arrays;
import java.util.List;

import org.zeromq.ZMQ;
import org.zeromq.ZMQ.Context;
import org.zeromq.ZMQ.Socket;

public class Subscriber {

	private static final Charset CHARSET = Charset.defaultCharset();
	private static final String SERVER_ADDRESS = "address";
	private static final String SERVER_PORT = "port";
	private static final String TOPICS = "topics";
	private static String serverAddress;
	private static Integer port;
	private static List<String> topics;
	private static Context context;
	private static Socket subscriber;
	private static String connectionString;
	
	public static void main(String[] args) {
		
		config();
		
        connect();
        
        subscribe(topics, subscriber);
        
        while (!Thread.currentThread ().isInterrupted ()) {
            read(subscriber);
        }
        
        close();
	}

	private static void connect() {
		subscriber.connect(connectionString);
	}

	private static void close() {
		subscriber.close ();
        context.term ();
	}

	private static void config() {
		serverAddress = System.getProperty(SERVER_ADDRESS, "localhost");
		port = Integer.getInteger(SERVER_PORT, 5563);
		topics = Arrays.asList(System.getProperty(TOPICS,"eurusd").split(","));
		// Prepare our context and subscriber
        context = ZMQ.context(1);
        subscriber = context.socket(ZMQ.SUB);
        connectionString = "tcp://" + serverAddress + ":" + port;
	}

	private static void subscribe(List<String> topics, Socket subscriber) {
		for (String topic : topics) {
			subscriber.subscribe(topic.getBytes());
		}
	}

	private static void read(Socket subscriber) {
		
        // Read envelope with address
        String address = subscriber.recvStr (CHARSET);
        // Read message contents
        String contents = subscriber.recvStr (CHARSET);
        System.out.println(address + " : " + contents);
	}
	
}
