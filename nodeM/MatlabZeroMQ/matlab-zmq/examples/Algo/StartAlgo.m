function StartAlgo()
    % tcp://127.0.0.1:50026
    context = zmq.core.ctx_new();
    socket = zmq.core.socket(context, 'ZMQ_SUB');
    contextPub = zmq.core.ctx_new();
    socket_pub = zmq.core.socket(contextPub, 'ZMQ_PUB');
    % Listner
    port = 50026;
    address = sprintf('tcp://127.0.0.1:%d', port);
    zmq.core.connect(socket, address);
    portPub = 50028;
    addressPub = sprintf('tcp://127.0.0.1:%d', portPub);
    zmq.core.connect(socket_pub, addressPub);
    fileID = fopen('configListeners.txt');
    C = textscan(fileID,'%s');
    fclose(fileID);
    [m,n] = size(C{1});
    for j = 1:m
        zmq.core.setsockopt(socket, 'ZMQ_SUBSCRIBE', C{1}{j});
    end
    topicName = 'null';
    while 1
            message = char(zmq.core.recv(socket));
            isMember = any(ismember(C{1},message));
            if isMember == 1
                topicName = message;
            else
                [topicPub, messagePub]=AlgoTest(topicName,message);
                messagePub1 = sprintf('%s %s', topicPub, messagePub);
                zmq.core.send(socket_pub, uint8(messagePub1));
                topicName = 0;
            end
    end
    zmq.core.disconnect(socket, address);
    zmq.core.close(socket);
    zmq.core.ctx_shutdown(context);
    zmq.core.ctx_term(context);
end
