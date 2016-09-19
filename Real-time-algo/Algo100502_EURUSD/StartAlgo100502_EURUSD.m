function StartAlgo100502_EURUSD(IP,password)

if(nargin == 0)
    IP='52.33.13.29';
    password = 'pushit2015';
elseif(nargin > 2)
    error('StartAlgo only accepts IP and password as parameters input');
end

% tcp://127.0.0.1:50026
context = zmq.core.ctx_new();
socket = zmq.core.socket(context, 'ZMQ_SUB');
contextPub = zmq.core.ctx_new();
socket_pub = zmq.core.socket(contextPub, 'ZMQ_PUB');

% SET LISTENERS
port = 50027;
add = strcat('tcp://',IP,':%d');
address = sprintf(add, port);
zmq.core.connect(socket, address);
portPub = 50026;
addressPub = sprintf(add, portPub);
zmq.core.connect(socket_pub, addressPub);

% SETTING TOPICS PUB
fileIdPub = fopen('configPublishers100502_EURUSD.txt');
ListP = textscan(fileIdPub,'%s');
fclose(fileIdPub);
[k,~] = size(ListP{1});
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

fileIdSub = fopen('configListeners100502_EURUSD.txt');
ListS = textscan(fileIdSub,'%s');
fclose(fileIdSub);
[m,~] = size(ListS{1});
for j = 1:m
    zmq.core.setsockopt(socket, 'ZMQ_SUBSCRIBE', ListS{1}{j});
end
zmq.core.setsockopt(socket_pub, 'ZMQ_RCVBUF', 102400);
zmq.core.setsockopt(socket, 'ZMQ_RCVBUF', 102400);
zmq.core.setsockopt(socket, 'ZMQ_RCVTIMEO', 185000);

while 1
    try
        message = char(zmq.core.recv(socket, 102400));
    catch ME
        display(ME.identifier);
        zmq.core.disconnect(socket, address);
        zmq.core.disconnect(socket_pub, addressPub);
        
        zmq.core.connect(socket, address);
        zmq.core.connect(socket_pub, addressPub);
        display('Reconnecting...')
        continue;
    end
    isMember = any(ismember(ListS{1},message));
    if isMember == 1
        topicName = message;
        messageBody = char(zmq.core.recv(socket, 102400));
        
        [topicPub, messagePub]=onlineAlgo100502_EURUSD_client03(topicName,messageBody,password);
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
