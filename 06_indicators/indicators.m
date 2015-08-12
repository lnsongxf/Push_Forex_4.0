classdef indicators < handle
    
    %
    % DESCRIPTION:
    % -------------------------------------------------------------
    % This class collect many functions for the calculation of
    % specific trading indicators useful for bulding up the coreState of
    % the Algos. Ideed all the indicators useful for bulding up an entry/exit
    % strategy have to be included as method of this class.
    %
    
    properties
        
    end
    
    
    methods
        
        function [obj,varargout] = rsi(obj,price,M,thresh,scaling,cost)
            % RSI
            %
            % Copyright 2010, The MathWorks, Inc.
            % All rights reserved.
            if ~exist('scaling','var')
                scaling = 1;
            end
            if ~exist('M','var')
                M = 0; % no detrending
            else
                if numel(M) > 1
                    N = M(2);
                    M = M(1);
                else
                    N = M;
                    M = 15*M;
                end
            end
            if ~exist('thresh','var')
                thresh = [30 70]; % default threshold
            else
                if numel(thresh) == 1 % scalar value
                    thresh = [100-thresh, thresh];
                else
                    if thresh(1) > thresh(2)
                        thresh= thresh(2:-1:1);
                    end
                end
            end
            
            if ~exist('cost','var')
                cost = 0; % default cost
            end
            
            % Detrend with a moving average
            if M == 0
                ma = zeros(size(price));
            else
                ma = movavg(price,M,M,'e');
            end
            ri = rsindex(price - ma, N);
            
            % Position signal
            s = zeros(size(price));
            % Crossing the lower threshold
            indx    = ri < thresh(1);
            indx    = [false; indx(1:end-1) & ~indx(2:end)];
            s(indx) = 1;
            % Crossing the upper threshold
            indx    = ri > thresh(2);
            indx    = [false; indx(1:end-1) & ~indx(2:end)];
            s(indx) = -1;
            % Fill in zero values with prior position
            for i = 2:length(s)
                if  s(i) == 0
                    s(i) = s(i-1);
                end
            end
            
            % PNL Caclulation
            r  = [0; s(1:end-1).*diff(price)-abs(diff(s))*cost/2];
            sh = scaling*sharpe(r,0);
            
            % Plot if requested
            if nargout == 0
                ax(1) = subplot(3,1,1);
                plot([price,ma]), grid on
                legend('Price',['Moving Average ',num2str(M)])
                title(['RSI Results, Sharpe Ratio = ',num2str(sh,3)])
                ax(2) = subplot(3,1,2);
                plot([ri,thresh(1)*ones(size(ri)),thresh(2)*ones(size(ri))])
                grid on
                legend(['RSI ',num2str(N)],'Lower Threshold','Upper Threshold')
                title('RSI')
                ax(3) = subplot(3,1,3);
                plot([s,cumsum(r)]), grid on
                legend('Position','Cumulative Return')
                title(['Final Return = ',num2str(sum(r),3),' (',num2str(sum(r)/price(1)*100,3),'%)'])
                linkaxes(ax,'x')
            else
                % Return values
                for i = 1:nargout
                    switch i
                        case 1
                            varargout{1} = s; % signal
                        case 2
                            varargout{2} = r; % return (pnl)
                        case 3
                            varargout{3} = sh; % sharpe ratio
                        case 4
                            varargout{4} = ri; % rsi signal
                        case 5
                            varargout{5} = ma; % moving average
                        case 6
                            varargout{6} = thresh; % threshold
                        otherwise
                            warning('RSI:OutputArg',...
                                'Too many output arguments requested, ignoring last ones');
                    end %switch
                end %for
            end %if
        end
        
        % Examples
        
        
        % Supporting Functions
        % Faster implementation of rsindex found in Financial Toolbox
        function r=rsindex(x,N)
            L = length(x);
            dx = diff([0;x]);
            up=dx;
            down=abs(dx);
            % up and down moves
            I=dx<=0;
            up(I) = 0;
            down(~I)=0;
            % calculate exponential moving averages
            m1 = movavg(up,N,N,'e'); m2 = movavg(down,N,N,'e');
            warning off
            r = 100*m1./(m1+m2);
            %r(isnan(r))=50;
            I2=~((up+down)>0);
            r(I2)=50;
            
            warning on
        end
        
        function [obj,varargout] = leadlag(obj,P,N,M,scaling,cost)
            %LEADLAG returns a trading signal for a simple lead/lag ema indicator
            %   LEADLAG returns a trading signal for a simple lead/lag exponential
            %   moving-average technical indicator.
            %
            %   S = LEADLAG(PRICE) returns a trading signal based upon a 12-period
            %   lead and a 26-period lag.  This is the default value used in a MACD
            %   indicator.  S is the trading signal of values -1, 0, 1 where -1 denotes
            %   a sell (short), 0 is neutral, and 1 is buy (long).
            %
            %   S = LEADLAG(PRICE,N,M) returns a trading signal for a N-period lead and
            %   a M-period lag.
            %
            %   [S,R,SH,LEAD,LAG] = LEADLAG(...) returns the trading signal S, the
            %   absolute return in R, the Sharpe Ratio in SH calculated using R, and
            %   the LEAD or LAG series.
            %
            %   EXAMPLE:
            %   % IBM
            %     load ibm.dat
            %     [s,~,~,lead,lag] = leadlag(ibm(:,4));
            %     ax(1) = subplot(2,1,1);
            %     plot([ibm(:,4),lead,lag]);
            %     title('IBM Price Series')
            %     legend('Close','Lead','Lag','Location','Best')
            %     ax(2) = subplot(2,1,2);
            %     plot(s)
            %     title('Trading Signal')
            %     set(gca,'YLim',[-1.2 1.2])
            %     linkaxes(ax,'x')
            %
            %   % Disney
            %     load disney
            %     dis_CLOSE(isnan(dis_CLOSE)) = [];
            %     [s,~,~,lead,lag] = leadlag(dis_CLOSE);
            %     ax(1) = subplot(2,1,1);
            %     plot([dis_CLOSE,lead,lag]);
            %     title('Disney Price Series')
            %     legend('Close','Lead','Lag','Location','Best')
            %     ax(2) = subplot(2,1,2);
            %     plot(s)
            %     title('Trading Signal')
            %     set(gca,'YLim',[-1.2 1.2])
            %     linkaxes(ax,'x')
            %
            %   See also movavg, sharpe, macd
            
            %%
            % Copyright 2010-2012, The MathWorks, Inc.
            
            
            %% Process input args
            if ~exist('scaling','var')
                scaling = 1;
            end
            
            if ~exist('cost','var')
                cost = 0;
            end
            
            if nargin < 2
                % default values
                M = 26;
                N = 12;
            elseif nargin < 3
                error('LEADLAG:NoLagWindowDefined',...
                    'When defining a leading window, the lag must be defined too')
            end
            
            % Simple lead/lag ema calculation
            if nargin > 0
                s = zeros(size(P));
                [lead,lag] = movavg(P,N,M,'e');
                s(lead>lag) = 1;
                s(lag>lead) = -1;
                
                trades  = [0; 0; diff(s(1:end-1))]; % shift trading by 1 period
                cash    = cumsum(-trades.*P-abs(trades)*cost/2);
                pandl   = [0; s(1:end-1)].*P + cash;
                r = diff(pandl);
                sh = scaling*sharpe(r,0);
                
                if nargout == 0 % Plot
                    %% Plot results
                    ax(1) = subplot(2,1,1);
                    plot([P,lead,lag]); grid on
                    legend('Close',['Lead ',num2str(N)],['Lag ',num2str(M)],'Location','Best')
                    title(['Lead/Lag EMA Results, Annual Sharpe Ratio = ',num2str(sh,3)])
                    ax(2) = subplot(2,1,2);
                    plot([s,pandl]); grid on
                    legend('Position','Cumulative Return','Location','Best')
                    title(['Final Return = ',num2str(sum(r),3),' (',num2str(sum(r)/P(1)*100,3),'%)'])
                    xlabel(ax(1), 'Serial day number');
                    xlabel(ax(2), 'Serial day number');
                    ylabel(ax(1), 'Price ($)');
                    ylabel(ax(2), 'Returns ($)');
                    linkaxes(ax,'x')
                else
                    for i = 1:nargout
                        switch i
                            case 1
                                varargout{1} = s;
                            case 2
                                varargout{2} = r;
                            case 3
                                varargout{3} = sh;
                            case 4
                                varargout{4} = lead;
                            case 5
                                varargout{5} = lag;
                            otherwise
                                warning('LEADLAG:OutputArg',...
                                    'Too many output arguments requested, ignoring last ones');
                        end %switch
                    end %for
                end %if
            else
                %% Run Example
                example(1:2)
            end %if
            
            %% Examples
            function example(ex)
                for e = 1:length(ex)
                    for e = 1:length(ex)
                        switch ex(e)
                            case 1
                                figure(1), clf
                                load ibm.dat
                                [s,~,~,lead,lag] = leadlag(ibm(:,4));
                                ax(1) = subplot(2,1,1);
                                plot([ibm(:,4),lead,lag]);
                                title('IBM Price Series')
                                legend('Close','Lead','Lag','Location','Best')
                                ax(2) = subplot(2,1,2);
                                plot(s)
                                title('Trading Signal')
                                set(gca,'YLim',[-1.2 1.2])
                                xlabel(ax(1), 'Serial day number');
                                xlabel(ax(2), 'Serial day number');
                                ylabel(ax(1), 'Price ($)');
                                ylabel(ax(2), 'Returns ($)');
                                linkaxes(ax,'x')
                            case 2
                                figure(2),clf
                                load disney
                                dis_CLOSE(isnan(dis_CLOSE)) = [];
                                [s,~,~,lead,lag] = leadlag(dis_CLOSE);
                                ax(1) = subplot(2,1,1);
                                plot([dis_CLOSE,lead,lag]);
                                title('Disney Price Series')
                                legend('Close','Lead','Lag','Location','Best')
                                ax(2) = subplot(2,1,2);
                                plot(s)
                                title('Trading Signal')
                                set(gca,'YLim',[-1.2 1.2])
                                xlabel(ax(1), 'Serial day number');
                                xlabel(ax(2), 'Serial day number');
                                ylabel(ax(1), 'Price ($)');
                                ylabel(ax(2), 'Returns ($)');
                                linkaxes(ax,'x')
                        end %switch
                    end %for
                end %for
            end
        end
        
        function [obj,varargout] = macd(obj,data,p1,p2,p3)
            % [mavg1,mavg2] = macd(data,p1,p2,p3)
            % Function to calculate the moving average convergence/divergence of a data set
            % 'data' is the vector to operate on.  The first element is assumed to be
            % the oldest data.
            %
            % p1 and p2 are the number of periods over which to calculate the moving
            % averages that are subtracted from each other.
            % p3 is the period of the indicator moving average
            %
            % If called with one output then it will be a two column matrix containing
            % both calculated series.
            % If called with two outputs then the first will contain the macd series
            % and the second will contain the indicator series.
            %
            % Example:
            % mavg1 = macd(data,p1,p2,p3);
            % [mavg1,mavg2] = macd(data,p1,p2,p3);
            
            % Error check
            if (nargin < 1) || (nargin >4)
                error([mfilename,' requires between 1 and 4 inputs.']);
            end
            [m,n]=size(data);
            if ~(m==1 || n==1)
                error(['The data input to ',mfilename,' must be a vector.']);
            end
            
            % set some defaults
            switch nargin
                case 1
                    p1 = 26;
                    p2 = 12;
                    p3 = 9;
                case 2
                    p2 = 12;
                    p3 = 9;
                case 3
                    p3 = 9;
            end
            
            if (numel(p1) ~= 1) || (numel(p2) ~= 1) || (numel(p3) ~= 1)
                error('The period must be a scalar.');
            end
            
            % calculate the MACD
            mavg1 = ema(data,p2)-ema(data,p1);
            % Need to be careful with handling NaN's in the second calculation
            idx = isnan(mavg1);
            mavg2 = [mavg1(idx); ema(mavg1(~idx),p3)];
            switch nargout
                case {0,1}
                    varargout{1} = [mavg1 mavg2];
                case 2
                    varargout{1} = mavg1;
                    varargout{2} = mavg2;
                otherwise
                    error('Too many outputs have been requested.');
            end
            
        end
        
        
        function [obj,varargout] = wpr(obj,price,N,scaling,cost)
            %WPR returns a trading signal for a simple Williams %R indicator
            %   WPR returns a trading signal for a simple Williams %R indicator.
            %
            %   S = WPR(PRICE) returns a trading signal based upon a 14-period Williams
            %   %R model. S is the trading signal of values -1, 0, 1 where -1 denotes a
            %   sell (short), 0 is neutral, and 1 is buy (long).
            %
            %   S = WPR(PRICE,N) returns a trading signal for a N-period model.
            %
            %   S = WPR(PRICE,N,scaling,cost) incorporates an annual scaling (used when
            %   computing the Shapre ratio) and a bid/ask spread transaction cost
            %   (assumed constant)
            %
            %   [S,R,SH,W] = WPR(...) returns the trading signal S, the absolute return
            %   in R, the Sharpe Ratio in SH calculated using R, and the indicator W.
            %
            % Copyright 2010-2012, The MathWorks, Inc.
            
            if ~exist('scaling','var'), scaling = 1; end
            if ~exist('N','var'), N = 14; end
            if ~exist('cost','var'), cost = 0; end
            
            % williams %r
            w = willpctr(price,N);
            
            % Position signal
            s = zeros(size(w));
            % Crossing the lower threshold on the reversion
            indx    = w < -80;
            indx    = [false; indx(1:end-1) & ~indx(2:end)];
            s(indx) = 1;
            % Crossing the upper threshold on the reversion
            indx    = w > -20;
            indx    = [false; indx(1:end-1) & ~indx(2:end)];
            s(indx) = -1;
            % Fill in zero values with prior position
            for i = 2:length(s)
                if  s(i) == 0
                    s(i) = s(i-1);
                end
            end
            
            % PNL calculation
            trades  = [0; 0; diff(s(1:end-1))]; % shift trading by 1 period
            cash    = cumsum(-trades.*price(:,end)-abs(trades)*cost/2);
            pandl   = [0; s(1:end-1)].*price(:,end) + cash;
            r = diff(pandl);
            sh = scaling*sharpe(r,0);
            % Plot if requested
            if nargout == 0
                ax(1) = subplot(3,1,1);
                plot(price), grid on
                legend('High','Low','Close')
                title(['W%R Results, Sharpe Ratio = ',num2str(sh,3)])
                ylabel('Price (USD)')
                ax(2) = subplot(3,1,2);
                plot([w,-80*ones(size(w)),-20*ones(size(w))])
                grid on
                legend(['Williams %R ',num2str(N)],'Over sold','Over bought')
                title('W%R')
                ylabel('W%R')
                ax(3) = subplot(3,1,3);
                plot([s,pandl]), grid on
                legend('Position','Cumulative Return')
                title(['Final Return = ',num2str(sum(r),3),' (',num2str(sum(r)/price(1)*100,3),'%)'])
                ylabel('Return (USD)')
                xlabel('Serial time number')
                linkaxes(ax,'x')
            else
                % Return values
                for i = 1:nargout
                    switch i
                        case 1
                            varargout{1} = s; % signal
                        case 2
                            varargout{2} = r; % return (pnl)
                        case 3
                            varargout{3} = sh; % sharpe ratio
                        case 4
                            varargout{4} = w; % w%r signal
                        otherwise
                            warning('WPR:OutputArg',...
                                'Too many output arguments requested, ignoring last ones');
                    end %switch
                end %for
            end %if
        end
        
    end
    
    
end
