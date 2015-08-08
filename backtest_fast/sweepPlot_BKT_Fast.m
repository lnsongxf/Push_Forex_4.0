function sweepPlotMA(xdata, ydata, zdata)
%SWEEPPLOTMA(XDATA, YDATA, ZDATA)
%  XDATA: surface xdata
%  YDATA: surface ydata
%  ZDATA: surface zdata
%
%  If only one input is provided, it is assumed to be ZDATA, and XDATA and
%  YDATA are automatically filled from 1 to whatever integer is needed to
%  fit the size of ZDATA.

% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1);
view(axes1,[80 35]);
grid(axes1,'on');
hold(axes1,'all');

if nargin == 1
    % Create surfc
    surfc(xdata','Parent',axes1,'FaceLighting','phong',...
        'FaceColor','interp',...
        'EdgeColor','none');
else
    % Create surfc
    surfc(xdata, ydata, zdata,'Parent',axes1,'FaceLighting','phong',...
        'FaceColor','interp',...
        'EdgeColor','none');
end

% Create light
light('Parent',axes1,'Position',[0.5 -0.9 0.05]);

% Create xlabel
xlabel('n','HorizontalAlignment','right');

% Create ylabel
ylabel('m','HorizontalAlignment','left');

% Create zlabel
zlabel('R_over_maxDD');

% Create colorbar
colorbar('peer',axes1);

% Create title
title('R_over_maxDD as a function of the optimized parameters')

