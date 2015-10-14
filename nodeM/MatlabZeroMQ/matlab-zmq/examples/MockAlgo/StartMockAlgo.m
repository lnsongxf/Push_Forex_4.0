function StartMockAlgo()
    % tcp://127.0.0.1:50026
    context = zmq.core.ctx_new();
    socket = zmq.core.socket(context, 'ZMQ_SUB');
    contextPub = zmq.core.ctx_new();
    socket_pub = zmq.core.socket(contextPub, 'ZMQ_PUB');

    % SET LISTENERS
    port = 50027;
    address = sprintf('tcp://2.125.222.249:%d', port);
    zmq.core.connect(socket, address);
    portPub = 50026;
    addressPub = sprintf('tcp://2.125.222.249:%d', portPub);
    zmq.core.connect(socket_pub, addressPub);
    
    % SETTING TOPICS PUB
    fileIdPub = fopen('configPublishers.txt');
    ListP = textscan(fileIdPub,'%s');
    fclose(fileIdPub);
    [k,z] = size(ListP{1});
    pause(5);
    for w = 1:k
        newTopicPub = 'NEWTOPICFROMSIGNALPROVIDER';
        %messagePubOperation = sprintf('%s %s', newTopicPub, ListP{1}{w});
        %zmq.core.send(socket_pub, uint8(messagePubOperation));
        messageBody = ListP{1}{w};
        zmq.core.send(socket_pub, uint8(newTopicPub), 'ZMQ_SNDMORE');
        zmq.core.send(socket_pub, uint8(messageBody));
    end
    
    % SETTING TOPICS SUB - 
    % EX: TIMEFRAMEQUOTE@MT4@ACTIVTRADES@EURUSD@m1@v1
    % EX: MATLAB@111@EURUSD@STATUS
    
    fileIdSub = fopen('configListeners.txt');
    ListS = textscan(fileIdSub,'%s');
    fclose(fileIdSub);
    [m,n] = size(ListS{1});
    for j = 1:m
        zmq.core.setsockopt(socket, 'ZMQ_SUBSCRIBE', ListS{1}{j});
    end
    zmq.core.setsockopt(socket_pub, 'ZMQ_RCVBUF', 102400);
    zmq.core.setsockopt(socket, 'ZMQ_RCVBUF', 102400);

    while 1
            message = char(zmq.core.recv(socket, 102400));
            isMember = any(ismember(ListS{1},message));
            if isMember == 1
                topicName = message;
                messageBody = char(zmq.core.recv(socket, 102400));
                [topicPub, messagePub]=onlineAlgo002(topicName,messageBody);
                if (~isempty( messagePub) && strcmp(messagePub,'') ==0)
                    display(strcat('Topic: ', topicPub));
                    display(strcat('Message: ', messagePub));
                    %messagePub1 = sprintf('%s %s', topicPub, messagePub);
                    %zmq.core.send(socket_pub, uint8(messagePub1));
                    zmq.core.send(socket_pub, uint8(topicPub), 'ZMQ_SNDMORE');
                    zmq.core.send(socket_pub, uint8(messagePub));
                    
                end
                
            end
    end
    zmq.core.disconnect(socket, address);
    zmq.core.close(socket);
    zmq.core.ctx_shutdown(context);
    zmq.core.ctx_term(context);
end
