classdef DecisionMaker_Pegasus < handle
    
   properties
        AVG_25_0
        AVG_25_1
        AVG_25_2
        AVG_50_0
        AVG_50_1
        AVG_50_2
    end
    
    
    methods
    
        function [matrix] = AvgClose(obj,matrix)
            AVG_25_0 = mean(matrix(1:25,4));
            AVG_25_1 = mean(matrix(2:26,4));
            AVG_25_2 = mean(matrix(3:27,4));

            AVG_50_0 = mean(matrix(1:50,4));
            AVG_50_1 = mean(matrix(2:51,4));
            AVG_50_2 = mean(matrix(3:52,4));
        end

        % Long entry
        function [matrix,upperBand,value2,intialRiskLimit] = longOpen(obj,matrix,upperBand,value2,intialRiskLimit)

            AVGClose(matrix);

            if ( AVG_25 > AVG_25_1 )
                if ( AVG_50 > AVG_50_1 )
                    if ( AVG_25_1 > AVG_25_2 )
                        if ( AVG_50_1 > AVG_50_2 )
                            if (matrix(1:1,4) > upperBand )
                                if (value2 < intialRiskLimit )
                                    return true;
                                else
                                    return false;
                                end
                            else
                                return false;
                            end
                        else
                            return false;
                        end
                    else
                        return false;
                    end
                else
                    return false;
                end
            else
                return false;
            end
        end

        %short entry
        function [matrix,lowerBand,value3,intialRiskLimit] = shortOpen(obj,matrix,lowerBand,value3,intialRiskLimit)

            AVGClose(matrix);

            if (AVG_25_0 < AVG_25_1)
                if (AVG_50_0 < AVG_50_1)
                    if(AVG_25_1 < AVG_25_2)
                        if (AVG_50_1 < AVG_50_2)
                            if (matrix(1:1,4) < lowerBand)
                                if (value3 < intialRiskLimit )
                                    return true;
                                else
                                    return false;
                                end
                            else
                                return false;
                            end
                        else
                            return false;
                        end
                    else
                        return false;
                    end
                else
                    return false;
                end
            else
                return false;
            end
        end

        %long exit
        function [matrix,value1,trueRange,Large_ATR] = longExit(obj,matrix,value1,trueRange,Large_ATR)

            AVGClose(matrix);
            
            if (matrix(1:1,4) < value1)
                return true;
            else
                return false;
            end 

            if (AVG_25_0 < AVG_25_1)
                if (AVG_25_1 < AVG_25_2)
                    return true;
                else
                    return false;
                end
            else
                return false;
            end

            if(trueRange > Large_ATR)
                if(matrix(1:1,4) < matrix(2:2,4) )
                    return true
                else
                    return false
                end
            else
                return false
            end

        end


        %short exit
        function [matrix,value1,trueRange,Large_ATR] = shortExit(obj,matrix,value1,trueRange,Large_ATR)

            AVGClose(matrix);
            
            if (matrix(1:1,4) > value1)
                return true;
            else
                return false
            end

            if(AVG_25_0 > AVG_25_1)
                if(AVG_25_1 > AVG_25_2)
                    return true;
                else
                    return false;
                end
            else
                return false;
            end

            if(trueRange > Large_ATR)
                if(matrix(1:1,4) > matrix(2:2,4) )
                    return true;
                else
                    return false;
                end
            else
                return false;
            end       
        end
    end
end