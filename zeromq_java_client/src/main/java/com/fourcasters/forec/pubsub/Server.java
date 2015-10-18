package com.fourcasters.forec.pubsub;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.InetSocketAddress;
import java.net.ServerSocket;
import java.net.Socket;

public class Server {

	public static void main(String[] args) throws IOException {
		try(ServerSocket server = new ServerSocket();) {
			server.bind(new InetSocketAddress(50123));
			while (true) {
				Socket client = server.accept();
				System.out.println(new BufferedReader(new InputStreamReader(client.getInputStream())).readLine());
				client.close();
			}
		}
	}

}
