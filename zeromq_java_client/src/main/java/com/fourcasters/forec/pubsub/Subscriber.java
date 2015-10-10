package com.fourcasters.forec.pubsub;

import java.nio.charset.Charset;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

import org.apache.commons.mail.DefaultAuthenticator;
import org.apache.commons.mail.Email;
import org.apache.commons.mail.EmailException;
import org.apache.commons.mail.SimpleEmail;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.zeromq.ZMQ;
import org.zeromq.ZMQ.Context;
import org.zeromq.ZMQ.Socket;

public class Subscriber {

	private final static Executor executor = Executors.newSingleThreadExecutor();
	private static final Logger LOG = LogManager.getLogger(Subscriber.class);
	private static String password;
	private static String address;
	public static void main (String[] args) {
		password = args[0];
		address = args[1];
        // Prepare our context and subscriber
        Context context = ZMQ.context(1);
        Socket subscriber = context.socket(ZMQ.SUB);
        Socket mailSender = context.socket(ZMQ.SUB);
        subscriber.connect(address + ":50028");
        mailSender.connect(address + ":50027");
        subscriber.subscribe("LOGS".getBytes());
        mailSender.subscribe("STATUS".getBytes());
        LOG.info("Connected");
        while (!Thread.currentThread ().isInterrupted ()) {
            // Read envelope with address
            String address = subscriber.recvStr(Charset.defaultCharset());
            String contents = subscriber.recvStr (Charset.defaultCharset());
            LOG.info(address + " = " + contents);
            address = mailSender.recvStr(ZMQ.NOBLOCK, Charset.defaultCharset());
            if (address != null && !address.trim().equals("")) {
            	contents = mailSender.recvStr (Charset.defaultCharset());
                LOG.info(address + " = " + contents);

            	sendEmail(address, contents);
            }
        }
        subscriber.close ();
        context.term ();
    }

	private static void sendEmail(String address, String contents) {
		String algoId = parseAlgoId(address);
		executor.execute(new Runnable() {
			@Override
			public void run() {
				try {
					Email email = new SimpleEmail();
					email.setHostName("smtp.gmail.com");
					email.setSmtpPort(465);
					email.setAuthenticator(new DefaultAuthenticator("ivan.valeriani", password));
					email.setSSL(true);
					email.setFrom("ivan.valeriani@gmail.com");
					email.setSubject("Automatic trading");
					email.setMsg(new StringBuffer().append(algoId).append(": ").append(contents).toString());
					email.addTo("push_it-30@googlegroups.com");
					email.addTo("phd.alessandro.ricci@gmail.com");
					email.addTo("cwicwi2@gmail.com");
					email.addTo("simone.allemanini@gmail.com");
					email.addTo("ivan.valeriani@gmail.com");
					email.send();
				}
				catch (EmailException e) {
					LOG.error("Unable to send email.", e);
					e.printStackTrace();
				}
			}
		});
	}

	private static String parseAlgoId(String address) {
		String[] tokens = address.split("@");
		return tokens[tokens.length - 1];
	}
}
