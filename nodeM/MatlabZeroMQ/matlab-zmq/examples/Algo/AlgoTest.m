function [ topicPub, messagePub ] = AlgoTest(topicSub,messageSub)

    % TOPICSUB EX1: TIMEFRAMEQUOTE@MT4@ACTIVTRADES@EURUSD@m1@v1
    % TOPICSUB EX2: MATLAB@111@EURUSD@STATUS
    fprintf('topic: %s, message: %s\n', topicSub, messageSub);
    pause(5)
    % REMEMBER THE VAR 'TOPICPUB' SHOULD BE ONE STRING VALUE AS THE VALUES
    % CONFIGURATED INTO THE FILE CONFIGPUBLISHERS.TXT
    topicPub = 'MATLAB@111@EURUSD@OPERATIONS';
    messagePub = '12';  

end

