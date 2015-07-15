function sub_client()
    % Temperature informant
    %
    % Example borrowed from
    % http://learning-0mq-with-pyzmq.readthedocs.org/en/latest/pyzmq/patterns/pubsub.html
    %
    % This informant will collect 5 temperature updates from a weather server and
    % calculate the average

    port = 50026;
    % tcp://127.0.0.1:50026
    % Socket to talk to server
    context = zmq.core.ctx_new();
    socket = zmq.core.socket(context, 'ZMQ_SUB');

    % Subscribe 
    fprintf('Collecting updates from weather server...\n');
    address = sprintf('tcp://127.0.0.1:%d', port);
    zmq.core.connect(socket, address);

   
    topicfilter = 'kitty';
    zmq.core.setsockopt(socket, 'ZMQ_SUBSCRIBE', topicfilter);

    % Process 5 updates
   
    for update = 1:5
        message = char(zmq.core.recv(socket));
        fprintf('%s \n', message);
        parts = strsplit(message);
        [topic, data] = parts{:};
  
        fprintf('%s %s\n', topic, data);
    end

    zmq.core.disconnect(socket, address);

    zmq.core.close(socket);

    zmq.core.ctx_shutdown(context);
    zmq.core.ctx_term(context);
end
