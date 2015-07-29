 function [operationState,values,params] = lifeCicleNew_binary(operationState,values,params)

r = rand(1,1) > .99;
if r
    tic
end

global      returns;
global      decMaker;
global      cState;                 %aggiunto
persistent  counter;

if isempty(counter)
    counter = 0;
end
if isempty(returns)
    returns = [];
end
if isempty(decMaker)
    decMaker = DecisionMaker;
end

if isempty(cState)                  %aggiunto
    cState = coreState;
end


index=length(values.matrixVal)-1;
matrix=values.matrixVal(end-index+1:end,:);

%aperture=matrix(:,1);           %aggiunto 13 Marzo
%massimi = matrix(:,2);          %aggiunto
%minimi = matrix(:,3);           %aggiunto
chiusure = matrix(:,4);         
%volumi = matrix(:,5);       %attiva se sei in decReal3 o CoreDecisionReal3     


%% Core filtro a priori         modificato dal 2_02_2012

% filtri a priori Decision Real (Algos Real 9(1), Real 10(5), ...)

% cState.CoreDecisionReal3(chiusure,volumi,20,300);
% cState.CoreDecisionReal4(chiusure);
% state=cState.state;
% % s0=state;               %solo quando hai altri filtri Core 

% anderson + dev (Algos Real 7, Real 8)
% 
% %inserire se si vuole calcolare Anderson sulle chiusure e nn sui massimi e
% %minimi
% 
%s = size(matrix);
%s(1) = s(1) - 1;
%ma=zeros(s);
%ma(:,2)=diff(chiusure);

% ma=matrix;
% cState.anderson(ma,0.6,1);
% state=cState.state;
%s1=state;
% %s1=1;
% 
%simulCore filtro Core sul dev

% cState.simulCore(chiusure,0,8);
% state=cState.state;
% s2=state;
% %s2=1;

% % filtro Core totale
% 
% if s1==1 && s2==1              %verifica che siano gli "s" corretti !!
%     state=1;
% else
%     state=0;
% end

% 
% x=chiusure-aperture;
% CWTc=cwt(x,1,'db3')';
% a=abs(CWTc(end,1));
% b=abs(CWTc(end-1,1));
% 
% if a<1 && b<1
%     state=0;
% else
%     state=1;
% end
%     


state=1;           %solo in caso di nessun filtro core
%%


if operationState.lock
    counter = counter + 1;
    if(counter > operationState.lockDuration )
        counter = 0;
        operationState.lock = 0;
    else
        return;
    end
end


try
    lo = params.get('lastOper__');
    %if (isempty(lo) || isnan(lo))
    %else
        s = size(returns);
        l = s(1);
        returns(l+1,1) = lo.type;
        returns(l+1,2) = lo.earnCalculation;
        params.set('lastOper__',[]);
    %end
catch
    
end

if abs(operationState.actualOperation) > 0
    
    if(operationState.phase == 0)
        %[operationState,~,params] = phaseZeroManager(operationState,values,params); %commenta per escludedre il no loose
        [operationState,~,params] = takeProfitManager(operationState,values,params); %commenta per includere il no loose
        %usa phaseZeroManager per il no Loose e takeProfitManager per
        %escluderlo
    elseif(operationState.phase == 1)
        [operationState,~,params] = phaseOneManager(operationState,values,params);
    end
else
    if abs(operationState.actualOperation) == 0
        if state
%             dev=cState.dev;      %scommenta quando c'è un filtro Core su dev
            [~,~,dev] = simul(chiusure(end-index+1:end),1);    %modificato
%            dev=max(dev,7);         % commentare please!!!!
            
            %decMaker.decisionReal1(returns);
            %decMaker.decisionReal3(chiusure,volumi,20,400);
            decMaker.decisionReal4(chiusure);
            %decMaker.decisionReal5(volumi,0,200);
            %decMaker.real=1;         %commenta quando usi filtri decisionMaker
            
            
            %%% aggiunto
            
%             Algo real 7
%             TP=0.4;
%             SL=30;
%             if dev<15
%                 TakeP=4;
%             else
%                 TakeP=TP*dev;
%             end
%             
%             StopL=SL*dev;
            
            
            
%             % Algo real 8
%             TP=0.4;
%             SL=30;
%             if dev>8 && dev<=11
%                 TakeP=3;
%             elseif dev>11 && dev<15
%                 TakeP=4;
%             else
%                 TakeP=TP*dev;
%             end
%             
%             StopL=SL*dev;
         
            
%             % Algo real 10, real 11, real 12, real 14, real 15
% %            TP=1;
%             SL=20;
% %            dev=max(dev,7);
% %            TakeP=TP*dev;
%             TakeP=5;
%             StopL=SL*dev;




%             % Algo real 13
%             TP=0.4;
%             SL=2;
%             if dev>30 && dev<=40
%                 TakeP=10;
%             else
%                 TakeP=TP*dev;
%             end
%             StopL=SL*dev;       
            
            
%             % Algo real 9.1 a priori (ex real 1)
%             %TP=0.5;
%             SL=30;
%             if volumi(1,1)>=20 && volumi(1,1)<=80
%                 TakeP=3;
%                 %StopL=70;
%             elseif volumi(1,1)>=81 && volumi(1,1)<200
%                 TakeP=3;
%                 %StopL=50;
%             else
%                 TakeP=3;
%                 %TakeP=TP*dev;
%                 %StopL=3;
%             end
%             
%             StopL=SL*dev;
%             StopL=(-77/266)*volumi(1,1)+90;
% %                         
% %             %%%

% 
%                 cState.simulCore2(massimi,minimi);
%                 TakeP=0.3*cState.dev;
%                 StopL=1.1*cState.dev;

            
            % Algo LCN_16_0
            %SL=20;
            TakeP=3;
            StopL=20;
            %StopL=SL*dev;
            
                        
            % Algo LCN_15_0
%             TP=1;
%             SL=1.1;
%             TakeP=TP*dev;
%             StopL=SL*dev;



%                 TakeP=max(TakeP,3);
%                 StopL=max(StopL,3);


            [params, operationState,counter] = decMaker.decisionDirection1(chiusure,params,operationState,TakeP,StopL);
            %[params, operationState,counter] = decMaker.decisionDirection3(aperture,chiusure,params,operationState,TakeP,StopL);
            %[params,operationState,counter] = decMaker.decisionDirection4 (chiusure,@linear1,params,operationState,TakeP,StopL,dev);
            operationState = decMaker.calcLock(operationState);
        end
    end
end

end

