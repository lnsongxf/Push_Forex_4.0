classdef Parameters < handle
    
    properties
        map;
        mapIterator;
        optimized;
        working = 0;
        % {
        alfa;
        newAlfa;
        stopLoss;
        smoothVal1;
        smoothVal2;
        previous_signal;
        smoothingCoef;
        startValue;
        lastDer;
        maxDelta;
        maxValue;
        valueTp;
        percTp;
        maxPercTp;
        initPercTp;
        noLoose;
        deltaOpt;
        maxIterOpt;
        operClosingValue;
        operOpeningValue;
        real;
        %}
    end
    
    methods
        function mapKeys = getMapKeys (obj)
            mapKeys = keys (obj.map);
        end
        function p = getVar (obj, key)
            p = obj.map(key);
        end
        function p = get (obj,s)
               p = obj.map(s).startValue;
        end
        function obj = set (obj,key,value)
               obj.map(key).setValue(value);
        end
        function obj = setOldValue (obj,ov)
           obj.map(key).setOldValue(ov); 
        end
        function obj = updateValues (obj)
            it = MapIterator (obj.map);
            while it.hasNext
               key = it.next;
               p = obj.map(key);
               if p.optimize
                  p.startValue = p.oldValue; 
               end
            end
        end
        function obj = updateOnClosingOper (obj)
            obj.set('openValue_',-1);
            obj.set('closeValue',-1);
            obj.set('percTp____',0);
            obj.set('maxValue__',0);
            % obj.set('alfa______',obj.get('newAlfa___'));
            it = MapIterator (obj.map);
            while it.hasNext
               key = it.next;
               p = obj.map(key);
               if p.optimize
                  p.startValue = p.oldValue; 
               end
            end
        end
		function operStates = closeOnTakeProfit (obj,operStates)
            obj.set('closeValue',obj.get('openValue_') + obj.get('noLoose___')*operStates.actualOperation);
            operStates.lastOperation    = operStates.actualOperation;
            operStates.actualOperation  = 0;
            operStates.lock             = 0;
            operStates.phase            = 0;
                        
        end
        function operStates = updatePh0To1 (obj,operStates,value)
            obj.set('maxValue__',value);
            obj.set('percTp____',min (obj.get('maxPercTp_'),obj.get('initPercTp') + abs (obj.get('maxValue__') - obj.get('openValue_'))/...
                    obj.get('maxDelta__')*(obj.get('maxPercTp_')-(obj.get('initPercTp')*sign (obj.get('initPercTp'))))));
            if (obj.get('percTp____') > 0)
                % obj.valueTp      = obj.get('openValue_') + (obj.maxValue - obj.get('openValue_'))*obj.percTp;
                obj.set('valueTp___',obj.get('openValue_') + (obj.get( 'maxValue__') - obj.get('openValue_'))*obj.get('percTp____'));
                operStates.phase = 1;
            end
        end
        function operStates = closeOnStopLoss (obj, operStates)
            % display ('Ho chiuso per stop loss');
            obj.set('closeValue',obj.get('openValue_') +obj.get('stopLoss__')*(-operStates.actualOperation));
            operStates.lastOperation    = operStates.actualOperation;
            operStates.actualOperation  = 0;
            operStates.lock             = 0;
            operStates.phase            = 0;
            % obj.set('alfa______',obj.get('newAlfa___'));
            % display (strcat ('Guadagno netto: ',mat2str (-1*abs (obj.get('closeValue') - obj.get('openValue_')))));
        end
        
        function operStates = closeOnCall (obj, operStates, currValue)
            % display ('Ho chiuso per stop loss');
            obj.set('closeValue',currValue);
            operStates.lastOperation    = operStates.actualOperation;
            operStates.actualOperation  = 0;
            operStates.lock             = 0;
            operStates.phase            = 0;
        end
                    
        function operStates = updateParamsMaxIncrease (obj, operStates,value)
            updateParamsOnMaxIncrease (obj,operStates,value);
        end
        function operStates = updateParamsOnTakeProfit (obj,operStates)
            % display ('Ho chiuso per take profit');
            obj.set('closeValue',obj.get('valueTp___'));
            operStates.lastOperation    = operStates.actualOperation;
            operStates.actualOperation  = 0;
            operStates.lock             = 0;
            operStates.phase            = 0;
            % obj.set('alfa___ ___',obj.get('newAlfa___'));
            % display (strcat ('Guadagno netto: ',mat2str (abs (obj.get('closeValue') - obj.get('openValue_')))));
        end
        
        function operStates = resetStatusOnFailureOpening (obj,operStates)      
            obj.set('openValue_',-1);
            obj.set('closeValue',-1);
            obj.set('percTp____',0);
            obj.set('maxValue__',0);
            operStates.lastOperation    = 0;
            operStates.actualOperation  = 0;
            operStates.lock             = 0;
            operStates.phase            = 0;
        end

        function operStates = updateParamsCounterIncrease (obj,operStates)
            operStates.counter  = operStates.counter + 1;
            obj.set('percTp____',min (obj.get('maxPercTp_'),obj.get('percTp____') + 0.01/60*operStates.counter));
            obj.set('valueTp___',obj.get('openValue_') + (obj.get( 'maxValue__') - obj.get('openValue_'))*obj.get('percTp____'));
        end
        function obj = Parameters
            obj.optimized = 0;
            obj.map = containers.Map;
            obj.map('openValue_')=parameter;
            obj.set('openValue_',-1);
            obj.map('closeValue')=parameter;
            obj.set('closeValue',-1);
            obj.map('stopLoss__')=parameter;
            obj.set('stopLoss__',-1);
            obj.map('noLoose___')=parameter;
            obj.set('noLoose___',-1);
            obj.map('maxPercTp_')=parameter;
            obj.set('maxPercTp_',-1);
            obj.map('initPercTp')=parameter;
            obj.set('initPercTp',-1);
            obj.map('maxDelta__')=parameter;
            obj.set('maxDelta__',-1);
            obj.map('maxValue__') =parameter;
            obj.set('maxValue__',-1);
            obj.map('percTp____') =parameter;
            obj.set('percTp____',-1);
            obj.map('valueTp___') =parameter;
            obj.set('valueTp___',-1);
            obj.map('real______') =parameter;
            obj.set('real______',-1);
            obj.map('smoothVal1') =parameter;
            obj.set('smoothVal1',-1);
            obj.map('smoothVal2') =parameter;
            obj.set('smoothVal2',-1);
            obj.map('previous_signal') =parameter;
            obj.set('previous_signal',0);
            
            
        end
        function obj = setMap (obj,inMap)
            obj.map = inMap;    
            obj.mapIterator = MapIterator (obj.map);
            while obj.mapIterator.hasNext
                obj.map(obj.mapIterator.next) = -1;
            end
            obj.mapIterator.reset;
        end
    end
    
end

