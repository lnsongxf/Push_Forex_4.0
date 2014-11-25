function varargout = opt(varargin)


% OPT M-file for opt.fig
%      OPT, by itself, creates a new OPT or raises the existing
%      singleton*.
%
%      H = OPT returns the handle to a new OPT or the handle to
%      the existing singleton*.
%
%      OPT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OPT.M with the given input arguments.
%
%      OPT('Property','Value',...) creates a new OPT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before opt_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to opt_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help opt

% Last Modified by GUIDE v2.5 08-May-2011 18:37:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @opt_OpeningFcn, ...
                   'gui_OutputFcn',  @opt_OutputFcn, ...
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



% --- Executes just before opt is made visible.
function opt_OpeningFcn(hObject, eventdata, handles, varargin)

handles.output = hObject;

c=0;
O=0;
map = containers.Map;

tr = char(varargin);
s=size(tr);
l = s(1);
for i = 1 : l
    vettore(i,:) = char(tr(i,:));
    map(vettore(i,:)) = parameter;
end

handles.var_c=c;
handles.var_l=l;
handles.var_O=O;
handles.var_vettore=vettore;
handles.output = map;

% Update handles structure
guidata(hObject, handles);

%uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = opt_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;
%uiwait(handles.figure1); 

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
    else
      O =0;
    end;    
   
    handles.var_O = O ;
    guidata(hObject,handles);


% --- Executes on button press in push_accept.
function push_accept_Callback(hObject, eventdata, handles)
c=handles.var_c;    
c = c+1;
    
    Rmin=handles.var_Rmin;
    Rmax=handles.var_Rmax;
    Rstep=handles.var_Rstep;
    startV=handles.var_startV;
    
    O=handles.var_O;
    l=handles.var_l;
    vettore=handles.var_vettore;
    map = handles.output;
    
    
  parameter.startValue = startV;
  parameter.opt = O;
  parameter.range =[Rmin : Rstep : Rmax];
  
  map(vettore(c,:)) = parameter;
  
    
if c== l
    handles.output = map;
    handles.var_c=c;
    guidata(hObject,handles);
    
    opt_OutputFcn(hObject, eventdata, handles);
    delete(gcf);
    return;

else
   set(handles.text_paraminfo,'String','Insert parameters ');
end


handles.output = map;
handles.var_c=c;
guidata(hObject,handles);


% --- Executes on button press in push_back.
function push_back_Callback(hObject, eventdata, handles)

c=handles.var_c;

if c==1
    f= msgbox('You are in the first frame','warn');
     waitfor(f);
else
        c=c-1;
        set(handles.text_paraminfo,'String','Insert Take-Profit parameters ');
    end

handles.var_c=c;
guidata(hObject,handles);


% --- Executes on button press in push_clear.
function push_clear_Callback(hObject, eventdata, handles)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
