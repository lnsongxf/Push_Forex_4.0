function [ topicPub, messagePub ] = AlgoTest(topicSub,messageSub)

    fprintf('topic: %s, message: %s\n', topicSub, messageSub);
    pause(5)
    topicPub = 'OPEN$EURUSD';
    messagePub = '12'; 
    %topic = 'CLOSE$EURUSD';
    %message = 12; 

end

