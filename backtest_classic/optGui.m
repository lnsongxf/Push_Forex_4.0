function varargout = optGui(varargin)


% OPTGUI M-file for optGui.fig
%      OPTGUI, by itself, creates a new OPTGUI or raises the existing
%      singleton*.
%
%      H = OPTGUI returns the handle to a new OPTGUI or the handle to
%      the existing singleton*.
%
%      OPTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OPTGUI.M with the given input arguments.
%
%      OPTGUI('Property','Value',...) creates a new OPTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before optGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to optGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help optGui

% Last Modified by GUIDE v2.5 24-May-2011 20:29:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @optGui_OpeningFcn, ...
                   'gui_OutputFcn',  @optGui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT



% --- Executes just before optGui is made visible.
function optGui_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

c=0;
O=0;
Rmin=NaN;
Rmax=NaN;
Rstep=NaN;
d=NaN;


map = containers.Map;

tr = char(varargin);
s=size(tr);
l = s(1);
for i = 1 : l
    vettore(i,:) = char(tr(i,:));
    % map(vettore(i,:)) = parameter;
end

set(handles.text_paraminfo,'String',['Insert parameters of ' vettore(c+1,:)]);
set(handles.uipanel_setRange, 'Visible', 'off');
set(handles.slider_d, 'Visible', 'off');
set(handles.edit_d, 'Visible', 'off');
set(handles.text_d, 'Visible', 'off');

set(handles.edit_Rmin, 'Visible', 'off');
set(handles.edit_Rmax, 'Visible', 'off');
set(handles.edit_Rstep, 'Visible', 'off');
set(handles.text_Rmin, 'Visible', 'off');
set(handles.text_Rmax, 'Visible', 'off');
set(handles.text_Rstep, 'Visible', 'off');
set(handles.text_u, 'Visible', 'off');

handles.var_vettore=vettore;
handles.var_Rmin=Rmin;
handles.var_Rmax=Rmax;
handles.var_Rstep=Rstep;
handles.var_d=d;

handles.var_c=c;
handles.var_l=l;
handles.var_O=O;
handles.var_vettore=vettore;
handles.output = map;

% Update handles structure
guidata(hObject, handles);

%uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = optGui_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;
% uiwait(handles.figure1); 

%delete(handles.figure1);
%close(gcf);
%figure1_CloseRequestFcn(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function text_paraminfo_CreateFcn(hObject, eventdata, handles)




function edit_startvalue_Callback(hObject, eventdata, handles)

   
   Strsel = get(hObject,'String');
   startV = str2double(Strsel);
   
   handles.var_startV = startV;
   guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_startvalue_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Rmin_Callback(hObject, eventdata, handles)

     
   Strsel = get(hObject,'String');
   Rmin = str2double(Strsel);
   
   handles.var_Rmin = Rmin;
   guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_Rmin_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Rmax_Callback(hObject, eventdata, handles)


   Strsel = get(hObject,'String');
   Rmax = str2double(Strsel);
   
   handles.var_Rmax = Rmax;
   guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function edit_Rmax_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Rstep_Callback(hObject, eventdata, handles)

   Strsel = get(hObject,'String');
   Rstep = str2double(Strsel);
   
%    f= msgbox('You are in the first frame','warn');
%    waitfor(f);
   
   handles.var_Rstep = Rstep;
   guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit_Rstep_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check_O.
function check_O_Callback(hObject, eventdata, handles)

      
    if (get(hObject,'Value') == get(hObject,'Max'))
      O =1;
       
    set(handles.uipanel_setRange, 'Visible', 'on');
    set(handles.slider_d, 'Visible', 'on');
    
    set(handles.edit_Rmin, 'Visible', 'on');
    set(handles.edit_Rmax, 'Visible', 'on');
    set(handles.edit_Rstep, 'Visible', 'on');
    set(handles.text_Rmin, 'Visible', 'on');
    set(handles.text_Rmax, 'Visible', 'on');
    set(handles.text_Rstep, 'Visible', 'on');
    set(handles.edit_d, 'Visible', 'on');
    
    set(handles.text_d, 'Visible', 'on');
    set(handles.text_u, 'Visible', 'on');
    
    else
      O =0;
         
    set(handles.uipanel_setRange, 'Visible', 'off');
    set(handles.slider_d, 'Visible', 'off');
    
    set(handles.edit_Rmin, 'Visible', 'off');
    handles.var_Rmin=NaN;
    set(handles.edit_Rmax, 'Visible', 'off');
    handles.var_Rmax=NaN;
    set(handles.edit_Rstep, 'Visible', 'off');
    handles.var_Rstep=NaN;
    set(handles.edit_d, 'Visible', 'off');
    handles.var_d=NaN;
      
    set(handles.text_Rmin, 'Visible', 'off');
    set(handles.text_Rmax, 'Visible', 'off');
    set(handles.text_Rstep, 'Visible', 'off');
    set(handles.text_d, 'Visible', 'off');
    set(handles.text_u, 'Visible', 'off');
    end;    
   
    handles.var_O = O ;
    guidata(hObject,handles);


% --- Executes on button press in push_accept.
function push_accept_Callback(hObject, eventdata, handles)

vettore=handles.var_vettore;
c=handles.var_c;    
c = c+1;
   
    Rmin=handles.var_Rmin;
    Rmax=handles.var_Rmax;
    Rstep=handles.var_Rstep;
    d=handles.var_d;
    startV=handles.var_startV;
    
    O=handles.var_O;
    l=handles.var_l;
    vettore=handles.var_vettore;
    map = handles.output;
    
  param=parameter;  
  param.startValue = startV;
  param.optimize = O;
  param.range =(Rmin : (Rmax-Rmin)/Rstep : Rmax);
  param.delta=(Rmax-Rmin)/Rstep*d;
  
  map(vettore(c,:)) = param;
  
  
    
if c==l
    handles.output = map;
    handles.var_c=c;
    guidata(hObject,handles);
    
    optGui_OutputFcn(hObject, eventdata, handles);
    delete(gcf);
    return;

else
   set(handles.text_paraminfo,'String',['Insert parameters of ' vettore(c+1,:)]);
end

if isKey(map,vettore(c+1,:))
    p=map(vettore(c+1,:));
    [handles]=checkOpt(hObject, eventdata,handles,p);
    
else
    set(handles.uipanel_setRange, 'Visible', 'off');
    set(handles.slider_d, 'Visible', 'off');
    set(handles.edit_Rmin, 'Visible', 'off');
    set(handles.edit_Rmax, 'Visible', 'off');
    set(handles.edit_Rstep, 'Visible', 'off');
    set(handles.edit_d, 'Visible', 'off');
    set(handles.text_Rmin, 'Visible', 'off');
    set(handles.text_Rmax, 'Visible', 'off');
    set(handles.text_Rstep, 'Visible', 'off');
    set(handles.text_d, 'Visible', 'off');
    set(handles.text_u, 'Visible', 'off');
    
set(handles.edit_startvalue, 'String',' ');
handles.var_startV=NaN;
set(handles.edit_Rmin, 'String',' ');
handles.var_Rmin=NaN;
set(handles.edit_Rmax, 'String',' ');
handles.var_Rmax=NaN;
set(handles.edit_Rstep, 'String',' ');
handles.var_Rstep=NaN;
set(handles.edit_d, 'String',' ');
handles.var_d=NaN;

set(handles.check_O, 'Value', 0);
handles.var_O=0;
end

set(handles.slider_d, 'Value',0);

handles.output = map;
handles.var_c=c;
guidata(hObject,handles);


% --- Executes on button press in push_back.
function push_back_Callback(hObject, eventdata, handles)

vettore=handles.var_vettore;
c=handles.var_c;
O=handles.var_O;
map = handles.output;

if c==0
    f= msgbox('You are in the first frame','warn');
    waitfor(f);
else
    c=c-1;
    set(handles.text_paraminfo,'String',['Insert parameters of ' vettore(c+1,:)]);
    
    p=map(vettore(c+1,:));
    
    handles.var_startV=p.startValue;
    set(handles.edit_startvalue, 'String',num2str(p.startValue));
    
    set(handles.check_O, 'Value', p.optimize);
    handles.var_O=p.optimize;
    
    [handles]=checkOpt(hObject, eventdata,handles,p);
    
end

handles.var_O;
handles.var_c=c;
guidata(hObject,handles);


% --- Executes on button press in push_clear.
function push_clear_Callback(hObject, eventdata, handles)


set(handles.uipanel_setRange, 'Visible', 'off');
set(handles.slider_d, 'Visible', 'off');

set(handles.edit_Rmin, 'Visible', 'off');
set(handles.edit_Rmax, 'Visible', 'off');
set(handles.edit_Rstep, 'Visible', 'off');
set(handles.edit_d, 'Visible', 'off');

set(handles.text_Rmin, 'Visible', 'off');
set(handles.text_Rmax, 'Visible', 'off');
set(handles.text_Rstep, 'Visible', 'off');
set(handles.text_d, 'Visible', 'off');
set(handles.text_u, 'Visible', 'off');

set(handles.edit_startvalue, 'String',' ');
handles.var_startV=NaN;
set(handles.edit_Rmin, 'String',' ');
handles.var_Rmin=NaN;
set(handles.edit_Rmax, 'String',' ');
handles.var_Rmax=NaN;
set(handles.edit_Rstep, 'String',' ');
handles.var_Rstep=NaN;
set(handles.edit_d, 'String',' ');
handles.var_d=NaN;

set(handles.slider_d, 'Value',0);
set(handles.check_O, 'Value', 0);
handles.var_O=0;

guidata(hObject,handles);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)

delete(hObject);


% --- Executes during object creation, after setting all properties.
function uipanel_setRange_CreateFcn(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function text_u_CreateFcn(hObject, eventdata, handles)



% --- Executes on slider movement.
function slider_d_Callback(hObject, eventdata, handles)

    d = get(handles.slider_d, 'Value');
    set(handles.edit_d, 'String', num2str(d));
    set(handles.slider_d, 'Value',d);
    
    handles.var_d=d;
    guidata(hObject,handles);
    

% --- Executes during object creation, after setting all properties.
function slider_d_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit_d_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_d_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function text_d_CreateFcn(hObject, eventdata, handles)
