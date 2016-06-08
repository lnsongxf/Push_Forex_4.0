
function abc = Client(path)

import java.io.*;
import java.net.*;
import com.forecserver.messages.*;
import com.google.protobuf.*;


persistent first_call;


%# connect to server
try
    fid = fopen(path,'r');  % Open text file
    port = textscan(fid,'%d',1,'delimiter',',');
    javapath = textscan(fid,'%s',1,'delimiter',',');
    display('listening on port');
    port = cell2mat(port);
    display(port);
    javaaddpath(javapath{1});
    display('javapath:');
    display(javapath{1});
    fclose(fid);
    global log;
    global map;
    log = log4m.getLogger('logfile.txt');
    log.setLogLevel(log.DEBUG);
    log.info('Init','Init logging');
    server = ServerSocket(port);
    sock = server.accept();
    %lancia server java -jar JavaTest.jar da shell
    display('Socket accepted');
    out = CodedOutputStream.newInstance(sock.getOutputStream());
    input = BufferedInputStream(sock.getInputStream());
    display('Getting into the while loop');
    while 1
        dv =  javaMethod('parseDelimitedFrom', 'com.forecserver.messages.DataValues$data_values_message',input);
        
%         %Questa parte del first call puoi anche cancellarla se non ti serve
%         if isempty(first_call)
%             first_call = 1;
%             if(isempty(map))
%                 map = containers.Map;
%             end
%             if(~isKey(map,'LCNB_5m_real17'))
%                 operationState = OperationState;
%                 params         = Parameters;
%                 ram = RealAlgo(operationState,params);
%                 map('LCNB_5m_real17') = ram;
%             end
%         end
        
        result = do_something(dv);
        
        [resp] = generateResponse(result);
        out.writeRawVarint32(resp.getSerializedSize());
        resp.writeTo(out);
        out.flush();
        clear dv;
        clear resp;
    end
    
catch ME
    %if isempty(sock)
    %    return
    %end
    %sock.close();
    clear out;
    clear in;
    clear sock;
    error(ME.identifier, 'Error: %s', ME.message)
end
out.close();
sock.close();
clear out;
clear in;
clear sock;
end

function [resp] = generateResponse(result)
builder =  javaMethod('newBuilder', 'com.forecserver.messages.AlgoResponseMessage$algo_response_message');
if isempty(result)
    builder.setDirection(0);
else
    builder.setDirection(result(1,1));
    builder.setOpenValue(result(2));
    builder.setCloseValue(result(3));
    builder.setStopLoss(result(4));
    builder.setNoLoose(result(5));
    builder.setValueTp(result(6));
    builder.setProbability(result(7));
end
resp = builder.build();
clear builder;
end

function [matrix] = parse_dv(dv)
matrix = dv.getDataList().toArray();
carray = cell(matrix);
matrix = cell2mat(carray);
columns = matrix(1,1);
matrix = reshape(matrix(2:end),columns,(length(matrix)-1)/columns)';
display(matrix(1,:));
display(matrix(2,:));
clear carray;
end

function do_setup(params)
clear params;
end


function [result] = do_something(dv)
matrix = parse_dv(dv);
matrix = flipud(matrix);
[dir,ov,cv,sl,nl,vtp,real] = LCNB_5m_real_test(matrix);
result = [dir,ov,cv,sl,nl,vtp,real];
clear matrix;
end
