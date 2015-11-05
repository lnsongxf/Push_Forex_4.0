package com.fourcasters.forec.pubsub;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.Socket;
import java.net.UnknownHostException;

public class Client {

	public static void main(String[] args) throws InterruptedException, UnknownHostException, IOException {
		try(Socket client = new Socket("2.125.222.249", 50123);) {
			PrintWriter pw = new PrintWriter(client.getOutputStream());
			pw.println("Hello World\n");
			pw.flush();
			Thread.sleep(2000L);
			client.close();
		}
		
	}
	
}
