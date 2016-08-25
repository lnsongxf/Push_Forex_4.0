function StartAlgoTest_2_0(varargin)



ListS = {{}};
password = 'pushit2015';
init = 1;
%(nargin > 2)
%    error('StartAlgo only accepts IP and password as parameters input');
%end

% tcp://127.0.0.1:50026
context = zmq.core.ctx_new();
socket = zmq.core.socket(context, 'ZMQ_SUB');
contextPub = zmq.core.ctx_new();
socket_pub = zmq.core.socket(contextPub, 'ZMQ_PUB');

% SET SUBSCRIBE SOCKET
port = str2num(varargin{2});
add = strcat('tcp://',varargin{1},':%d');
address = sprintf(add, port);
zmq.core.connect(socket, address);
%SET PUBLISHER SOCKET
portPub = str2num(varargin{3});
addressPub = sprintf(add, portPub);
zmq.core.connect(socket_pub, addressPub);

pause(5);
% SETTING TOPICS PUB AND SUB
% EX: OPERATIONS@ACTIVTRADES@AUDCAD@9999  -->  PUB TOPIC
% EX: TIMEFRAMEQUOTE@MT4@ACTIVTRADES@EURUSD@m1@v1  -->  SUB TOPIC
% EX: MATLAB@111@EURUSD@STATUS  -->  PUB AND SUB TOPIC
nVarargs = length(varargin);
newTopicPub = 'NEWTOPICFROMSIGNALPROVIDER';
for k = 1:nVarargs
  %fprintf('   %s\n', varargin{k});
  C = strsplit(varargin{k},'@');
  if ( strcmp(C{1},'OPERATIONS')==1 )
    %display(strcat('setting topic pub: ', varargin{k}));
    messageBody = varargin{k};
    zmq.core.send(socket_pub, uint8(newTopicPub), 'ZMQ_SNDMORE');
    zmq.core.send(socket_pub, uint8(messageBody));
  elseif ( strcmp(C{1},'SKIP')==1 )
    %display(strcat('setting topic pub: ', varargin{k}));
    messageBody = varargin{k};
    zmq.core.send(socket_pub, uint8(newTopicPub), 'ZMQ_SNDMORE');
    zmq.core.send(socket_pub, uint8(messageBody));
  elseif ( strcmp(C{1},'TIMEFRAMEQUOTE')==1 )
      %display(strcat('setting topic sub: ', varargin{k}));
      ListS{1}{end+1} = varargin{k};
      zmq.core.setsockopt(socket, 'ZMQ_SUBSCRIBE', varargin{k});
  elseif ( strcmp(C{1},'STATUS')==1 )
      %display(strcat('setting topic pub & sub: ', varargin{k}));
      messageBody = varargin{k};
      zmq.core.send(socket_pub, uint8(newTopicPub), 'ZMQ_SNDMORE');
      zmq.core.send(socket_pub, uint8(messageBody));
      ListS{1}{end+1} = varargin{k};
      zmq.core.setsockopt(socket, 'ZMQ_SUBSCRIBE', varargin{k});
  end
end

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
        [topicPub, messagePub]=onlineAlgoTest_client_backtest(topicName,messageBody,init);
        init = 0;
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
zmq.core.disconnect(socket_pub, address);
zmq.core.close(socket_pub);
zmq.core.ctx_shutdown(contextPub);
zmq.core.ctx_term(contextPub);
end
