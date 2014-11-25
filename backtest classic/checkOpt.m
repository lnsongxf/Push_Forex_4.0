
function [handles]=checkOpt(hObject, eventdata,handles,p)

    if(p.optimize)
        
        set(handles.uipanel_setRange, 'Visible', 'on');
        set(handles.slider_d, 'Visible', 'on');
        set(handles.edit_d, 'Visible', 'on');
        set(handles.edit_Rmin, 'Visible', 'on');
        set(handles.edit_Rmax, 'Visible', 'on');
        set(handles.edit_Rstep, 'Visible', 'on');
        set(handles.text_Rmin, 'Visible', 'on');
        set(handles.text_Rmax, 'Visible', 'on');
        set(handles.text_Rstep, 'Visible', 'on');
        set(handles.text_d, 'Visible', 'on');
        set(handles.text_u, 'Visible', 'on');
        
        handles.var_d=p.delta;
        set(handles.edit_d, 'String',num2str(p.delta));
        
        handles.var_Rmin=p.range(1);
        set(handles.edit_Rmin, 'String',num2str(p.range(1)));
        
        handles.var_Rmax=p.range(length(p.range));
        set(handles.edit_Rmax, 'String',num2str(p.range(length(p.range))));
        
        if(length(p.range) > 1)
            
            handles.var_Rstep=p.range(2) - p.range(1);
            set(handles.edit_Rstep, 'String',num2str(p.range(2) - p.range(1)));
            
        else
%             set(handles.uipanel_setRange, 'Visible', 'off');
%             set(handles.edit_Rmin, 'Visible', 'off');
%             set(handles.edit_Rmax, 'Visible', 'off');
%             set(handles.edit_Rstep, 'Visible', 'off');
%             set(handles.text_Rmin, 'Visible', 'off');
%             set(handles.text_Rmax, 'Visible', 'off');
%             set(handles.text_Rstep, 'Visible', 'off');
%             set(handles.text_u, 'Visible', 'off');
            
            handles.var_Rstep=1;
            set(handles.edit_Rstep, 'String',num2str(1));
            
        end
    end
end
