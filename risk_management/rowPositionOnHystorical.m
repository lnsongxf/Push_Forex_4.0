function [rowPositionOpen,rowPositionClose]=rowPositionOnHystorical(outputHyst,inputResultsMatrix)

%
% DESCRIPTION:
% -------------------------------------------------------------------------
% This function calculates the row position into the hystorical matrix of
% all the opearation done during a test
%
% INPUT parameters:
% -------------------------------------------------------------------------
% outputHyst           ... hystorical data correspondent to the period of  
%                          test
% inputResultsMatrix   ... matrix of results coming from the test
%
% OUTPUT parameters:
% -------------------------------------------------------------------------
% rowPosition          ... row position of the operation into the hytorical
%                          matrix
%
% EXAMPLE of use:
% -------------------------------------------------------------------------
% [rowPositionOpen,rowPositionClose]=rowPositionOnHystorical(outputHyst,inputResultsMatrix);
%

s=size(inputResultsMatrix);
rowPositionOpen=zeros(s(1),1);
rowPositionClose=zeros(s(1),1);

for i = 1:s(1)
    
    date=inputResultsMatrix(i,7);
    [ro,~,~] = find(outputHyst(:,6)<=date);
    rowPositionOpen(i)=ro(end);
    
    date=inputResultsMatrix(i,8);
    [rc,~,~] = find(outputHyst(:,6)<=date);
    rowPositionClose(i)=rc(end);
    
end


end