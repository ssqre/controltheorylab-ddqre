function varargout = ddqre(varargin)
% DDQRE M-file for ddqre.fig
%      DDQRE, by itself, creates a tool_new DDQRE or raises the existing
%      singleton*.
%
%      H = DDQRE returns the handle to a tool_new DDQRE or the handle to
%      the existing singleton*.
%
%      DDQRE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DDQRE.M with the given input arguments.
%
%      DDQRE('Property','Value',...) creates a tool_new DDQRE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ddqre_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ddqre_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ddqre

% Last Modified by GUIDE v2.5 27-Jul-2008 19:00:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ddqre_OpeningFcn, ...
                   'gui_OutputFcn',  @ddqre_OutputFcn, ...
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


% --- Executes just before ddqre is made visible.
function ddqre_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ddqre (see VARARGIN)
handles.flag_model_in=0;%模型输入标志
handles.flag_model_change=0;%设置模型更改标志
handles.flag_save=0;%存储标志
handles.PID=[1,inf,0];%输入原始数据
handles.exp=[0,3];
handles.Gc_num=[1];
handles.Gc_den=[1,1];
handles.G_num=[1];
handles.G_den=[1,1];
handles.H_num=[1];
handles.H_den=[1];
if (handles.PID(2)~=inf)
    PID_num=[handles.PID(1)*handles.PID(2)*handles.PID(3),handles.PID(1)*handles.PID(2),handles.PID(1)];%PID原始模型
    PID_den=[handles.PID(2),0];
else
    PID_num=[handles.PID(1)*handles.PID(3),handles.PID(1)];
    PID_den=[1];
end
handles.PID_sys=tf(PID_num,PID_den);
[exp_num,exp_den]=pade(handles.exp(1),handles.exp(2));%e^-Ts原始模型
handles.exp_sys=tf(exp_num,exp_den);
handles.G_sys=tf(handles.G_num,handles.G_den);%G(s)原始模型
handles.Gc_sys=tf(handles.Gc_num,handles.Gc_den);%Gc(s)原始模型
handles.H_sys=tf(handles.H_num,handles.H_den);%H(s)原始模型
handles.sysk_Gc=handles.Gc_sys*handles.G_sys*handles.exp_sys*handles.H_sys;%建立系统模型
sys1=handles.Gc_sys*handles.G_sys*handles.exp_sys;
handles.sysb_Gc=feedback(sys1,handles.H_sys);
handles.sysk_PID=handles.PID_sys*handles.G_sys*handles.exp_sys*handles.H_sys;
sys2=handles.PID_sys*handles.G_sys*handles.exp_sys;
handles.sysb_PID=feedback(sys2,handles.H_sys);
ddqre_jiemian
% Choose default command line output for ddqre
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ddqre wait for user response (see UIRESUME)
% uiwait(handles.ddqre_figure);


% --- Outputs from this function are returned to the command line.
function varargout = ddqre_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Gc.
function Gc_Callback(hObject, eventdata, handles)
% hObject    handle to Gc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt={'Gc(s) Num Input','Gc(s) Den Input'};
defans={num2str(handles.Gc_num),num2str(handles.Gc_den)};
answer=inputdlg(prompt,'Gc(s) Coefficient Input',1,defans,'on');
if (~isempty(answer))
    if (~isempty(answer{1}))&(~isempty(answer{2}))
        handles.Gc_num=str2num(answer{1});
        handles.Gc_den=str2num(answer{2});
        guidata(hObject,handles);
        handles.Gc_sys=tf(handles.Gc_num,handles.Gc_den);%重构Gc_sys
        handles.sysk_Gc=handles.Gc_sys*handles.G_sys*handles.exp_sys*handles.H_sys;%重构Gc系统模型
        sys1=handles.Gc_sys*handles.G_sys*handles.exp_sys;
        handles.sysb_Gc=feedback(sys1,handles.H_sys);
        handles.flag_model_change=1;%设置模型已改
        if (handles.flag_model_in==1)
            set(handles.tool_save,'enable','on');%激活存储
            set(handles.menu_save,'enable','on');
        end
        guidata(hObject,handles);
    end
end
string=my_disp(handles.Gc_sys.num{1},handles.Gc_sys.den{1},handles);
string=strvcat('Gc(s) Plant:',string);
set(handles.display_edit,'string',string);

   
% --- Executes on button press in G.
function G_Callback(hObject, eventdata, handles)
% hObject    handle to G (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt={'G(s) Num Input','G(s) Den Input'};
defans={num2str(handles.G_num),num2str(handles.G_den)};
answer=inputdlg(prompt,'G(s) Coefficient Input',1,defans,'on');
if (~isempty(answer))
    if (~isempty(answer{1}))&(~isempty(answer{2}))
        handles.G_num=str2num(answer{1});
        handles.G_den=str2num(answer{2});
        guidata(hObject,handles);
        handles.G_sys=tf(handles.G_num,handles.G_den);
        handles.sysk_Gc=handles.Gc_sys*handles.G_sys*handles.exp_sys*handles.H_sys;%建立系统模型
        sys1=handles.Gc_sys*handles.G_sys*handles.exp_sys;
        handles.sysb_Gc=feedback(sys1,handles.H_sys);
        handles.sysk_PID=handles.PID_sys*handles.G_sys*handles.exp_sys*handles.H_sys;
        sys2=handles.PID_sys*handles.G_sys*handles.exp_sys;
        handles.sysb_PID=feedback(sys2,handles.H_sys);
        set(handles.menu_model,'enable','on');%激活菜单
        set(handles.menu_analysis,'enable','on');
        set(handles.menu_design,'enable','on');
        set(handles.tool_save,'enable','on');
        set(handles.menu_save,'enable','on');
        set(handles.menu_save_as,'enable','on');
        set(handles.open_loop,'enable','on');
        set(handles.close_loop,'enable','on');
        set(handles.pid_map,'enable','on');
        set(handles.tool_calculate,'enable','on');
        set(handles.tool_stable,'enable','on');
        set(handles.tool_step,'enable','on');
        set(handles.tool_impulse,'enable','on');
        set(handles.tool_bode,'enable','on');
        set(handles.tool_nyquist,'enable','on');
        handles.flag_model_in=1;%设置模型已输入
        handles.flag_model_change=1;%设置模型已改
        set(handles.tool_save,'enable','on');%激活存储
        guidata(hObject,handles);
    end
end
string=my_disp(handles.G_sys.num{1},handles.G_sys.den{1},handles);
string=strvcat('G(s) Plant:',string);
set(handles.display_edit,'string',string);


% --- Executes on button press in exp.
function exp_Callback(hObject, eventdata, handles)
% hObject    handle to exp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt={'e^-Ts Num Input','e^-Ts Den Input'};
defans={num2str(handles.exp(1)),num2str(handles.exp(2))};
answer=inputdlg(prompt,'e^-Ts Coefficient Input',1,defans,'on');
if (~isempty(answer))
    if (~isempty(answer{1}))&(~isempty(answer{2}))
        x1=str2num(answer{1});
        x2=str2num(answer{2});
        handles.exp(1)=abs(x1(1));
        handles.exp(2)=x2(1);
        guidata(hObject,handles);
        [exp_num,exp_den]=pade(handles.exp(1),handles.exp(2));
        handles.exp_sys=tf(exp_num,exp_den);
        handles.sysk_Gc=handles.Gc_sys*handles.G_sys*handles.exp_sys*handles.H_sys;%建立系统模型
        sys1=handles.Gc_sys*handles.G_sys*handles.exp_sys;
        handles.sysb_Gc=feedback(sys1,handles.H_sys);
        handles.sysk_PID=handles.PID_sys*handles.G_sys*handles.exp_sys*handles.H_sys;
        sys2=handles.PID_sys*handles.G_sys*handles.exp_sys;
        handles.sysb_PID=feedback(sys2,handles.H_sys);
        handles.flag_model_change=1;%设置模型已改
        if (handles.flag_model_in==1)
            set(handles.tool_save,'enable','on');%激活存储
            set(handles.menu_save,'enable','on');
        end
        guidata(hObject,handles);
    end
end
string=my_disp(handles.exp_sys.num{1},handles.exp_sys.den{1},handles);
string=strvcat('e^-Ts Plant:',string);
set(handles.display_edit,'string',string);


% --- Executes on button press in H.
function H_Callback(hObject, eventdata, handles)
% hObject    handle to H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt={'H(s) Num Input','H(s) Den Input'};
defans={num2str(handles.H_num),num2str(handles.H_den)};
answer=inputdlg(prompt,'H(s) Coefficient Input',1,defans,'on');
if (~isempty(answer))
    if (~isempty(answer{1}))&(~isempty(answer{2}))
        handles.H_num=str2num(answer{1});
        handles.H_den=str2num(answer{2});
        guidata(hObject,handles);
        handles.H_sys=tf( handles.H_num,handles.H_den);
        handles.sysk_Gc=handles.Gc_sys*handles.G_sys*handles.exp_sys*handles.H_sys;%建立系统模型
        sys1=handles.Gc_sys*handles.G_sys*handles.exp_sys;
        handles.sysb_Gc=feedback(sys1,handles.H_sys);
        handles.sysk_PID=handles.PID_sys*handles.G_sys*handles.exp_sys*handles.H_sys;
        sys2=handles.PID_sys*handles.G_sys*handles.exp_sys;
        handles.sysb_PID=feedback(sys2,handles.H_sys);
        handles.flag_model_change=1;%设置模型已改
        if (handles.flag_model_in==1)
            set(handles.tool_save,'enable','on');%激活存储
            set(handles.menu_save,'enable','on');
        end
        guidata(hObject,handles);
    end
end
string=my_disp(handles.H_sys.num{1},handles.H_sys.den{1},handles);
string=strvcat('H(s) Plant:',string);
set(handles.display_edit,'string',string);


% --------------------------------------------------------------------
function menu_file_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_model_Callback(hObject, eventdata, handles)
% hObject    handle to menu_model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_analysis_Callback(hObject, eventdata, handles)
% hObject    handle to menu_analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_design_Callback(hObject, eventdata, handles)
% hObject    handle to menu_design (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_help_Callback(hObject, eventdata, handles)
% hObject    handle to menu_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pid.
function pid_Callback(hObject, eventdata, handles)
% hObject    handle to pid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt={'Proportional Coefficient Input','Integral Coefficient Input','Derivative Coefficient Input'};
defans={num2str(handles.PID(1)),num2str(handles.PID(2)),num2str(handles.PID(3))};
answer=inputdlg(prompt,'PID Coefficient Input',1,defans,'on');
if (~isempty(answer))
    if (~isempty(answer{1}))&(~isempty(answer{2}))&(~isempty(answer{3}))
        x1=str2num(answer{1});
        x2=str2num(answer{2});
        x3=str2num(answer{3});  
        handles.PID(1)=x1(1);
        handles.PID(2)=x2(1);
        handles.PID(3)=x3(1);
        guidata(hObject,handles);
        if (handles.PID(2)~=inf)
            PID_num=[handles.PID(1)*handles.PID(2)*handles.PID(3),handles.PID(1)*handles.PID(2),handles.PID(1)];
            PID_den=[handles.PID(2),0];
        else
            PID_num=[handles.PID(1)*handles.PID(3),handles.PID(1)];
            PID_den=[1];
        end
        handles.PID_sys=tf(PID_num,PID_den);
        handles.sysk_PID=handles.PID_sys*handles.G_sys*handles.exp_sys*handles.H_sys;
        sys2=handles.PID_sys*handles.G_sys*handles.exp_sys;
        handles.sysb_PID=feedback(sys2,handles.H_sys);
        handles.flag_model_change=1;%设置模型已改
        if (handles.flag_model_in==1)
            set(handles.tool_save,'enable','on');%激活存储
            set(handles.menu_save,'enable','on');
        end
        guidata(hObject,handles);
    end
end
string=my_disp(handles.PID_sys.num{1},handles.PID_sys.den{1},handles);
string=strvcat('PID Plant:',string);
set(handles.display_edit,'string',string);


% --- Executes on selection change in GcPID.
function GcPID_Callback(hObject, eventdata, handles)
% hObject    handle to GcPID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns GcPID contents as cell array
%        contents{get(hObject,'Value')} returns selected item from GcPID
val=get(handles.GcPID,'value');
switch val
    case 1
        set(handles.Gc,'visible','on');
        set(handles.pid,'visible','off');
    case 2
        set(handles.Gc,'visible','off');
        set(handles.pid,'visible','on');
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function GcPID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GcPID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function tool_new_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to tool_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.flag_model_in=0;%模型输入标志
handles.flag_model_change=0;%设置模型更改标志
handles.flag_save=0;%存储标志
handles.PID=[1,inf,0];%输入原始数据
handles.exp=[0,3];
handles.Gc_num=[1];
handles.Gc_den=[1,1];
handles.G_num=[1];
handles.G_den=[1,1];
handles.H_num=[1];
handles.H_den=[1];
if (handles.PID(2)~=inf)
    PID_num=[handles.PID(1)*handles.PID(2)*handles.PID(3),handles.PID(1)*handles.PID(2),handles.PID(1)];%PID原始模型
    PID_den=[handles.PID(2),0];
else
    PID_num=[handles.PID(1)*handles.PID(3),handles.PID(1)];
    PID_den=[1];
end
handles.PID_sys=tf(PID_num,PID_den);
[exp_num,exp_den]=pade(handles.exp(1),handles.exp(2));%e^-Ts原始模型
handles.exp_sys=tf(exp_num,exp_den);
handles.G_sys=tf(handles.G_num,handles.G_den);%G(s)原始模型
handles.Gc_sys=tf(handles.Gc_num,handles.Gc_den);%Gc(s)原始模型
handles.H_sys=tf(handles.H_num,handles.H_den);%H(s)原始模型
set(handles.menu_model,'enable','off');%激死菜单
set(handles.menu_analysis,'enable','off');
set(handles.menu_design,'enable','off');
set(handles.tool_save,'enable','off');
set(handles.menu_save,'enable','off');
set(handles.menu_save_as,'enable','off');
set(handles.open_loop,'enable','off');
set(handles.close_loop,'enable','off');
set(handles.pid_map,'enable','off');
set(handles.tool_calculate,'enable','off');
set(handles.tool_stable,'enable','off');
set(handles.tool_step,'enable','off');
set(handles.tool_impulse,'enable','off');
set(handles.tool_bode,'enable','off');
set(handles.tool_nyquist,'enable','off');
guidata(hObject,handles);


% --------------------------------------------------------------------
function tool_save_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to tool_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=[handles.PID,handles.exp,length(handles.Gc_num),handles.Gc_num,length(handles.Gc_den),handles.Gc_den];
data=[data,length(handles.G_num),handles.G_num,length(handles.G_den),handles.G_den];
data=[data,length(handles.H_num),handles.H_num,length(handles.H_den),handles.H_den];
if (handles.flag_save==0)
    [filename, pathname] = uiputfile('*.dqr','save','untitled');
    if (~isequal(filename,0))&(~isequal(pathname,0))
        fid=fopen(fullfile(pathname,filename), 'wb');
        fwrite(fid,data,'double');
        fclose(fid);
        handles.filename=filename;
        handles.pathname=pathname;
        handles.flag_save=1;%设置已保存
        handles.flag_model_change=0;%设置模型更改标志
        set(handles.tool_save,'enable','off');%激死存储
        set(handles.menu_save,'enable','off');
        guidata(hObject,handles);
    end
else
    handles.flag_model_change=0;%设置模型更改标志
    set(handles.tool_save,'enable','off');%激死存储
    set(handles.menu_save,'enable','off');
    guidata(hObject,handles);
    fid=fopen(fullfile(handles.pathname,handles.filename), 'wb');
    fwrite(fid,data,'double');
    fclose(fid);
end
                              

% --------------------------------------------------------------------
function tool_open_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to tool_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('*.dqr','open','');
if (~isequal(filename,0))&(~isequal(pathname,0))
    fid = fopen(fullfile(pathname,filename), 'rb');
    data=(fread(fid,'double'))';
    fclose(fid);
    handles.PID=data(1:3);%将各个数值交给相应变量
    handles.exp=data(4:5);
    handles.Gc_num=data(7:6+data(6));
    x1=6+data(6);
    handles.Gc_den=data(2+x1:1+x1+data(1+x1));
    x2=1+x1+data(1+x1);
    handles.G_num=data(2+x2:1+x2+data(1+x2));
    x3=1+x2+data(1+x2);
    handles.G_den=data(2+x3:1+x3+data(1+x3));
    x4=1+x3+data(1+x3);
    handles.H_num=data(2+x4:1+x4+data(1+x4));
    x5=1+x4+data(1+x4);
    handles.H_den=data(2+x5:1+x5+data(1+x5));
    if (handles.PID(2)~=inf)
        PID_num=[handles.PID(1)*handles.PID(2)*handles.PID(3),handles.PID(1)*handles.PID(2),handles.PID(1)];%PID模型
        PID_den=[handles.PID(2),0];
    else
        PID_num=[handles.PID(1)*handles.PID(3),handles.PID(1)];
        PID_den=[1];
    end
    handles.PID_sys=tf(PID_num,PID_den);
    [exp_num,exp_den]=pade(handles.exp(1),handles.exp(2));%读入的e^-Ts型
    handles.exp_sys=tf(exp_num,exp_den);
    handles.G_sys=tf(handles.G_num,handles.G_den);%读入的G(s)模型
    handles.Gc_sys=tf(handles.Gc_num,handles.Gc_den);%读入的Gc(s)模型
    handles.H_sys=tf(handles.H_num,handles.H_den);%读入的H(s)模型
    handles.sysk_Gc=handles.Gc_sys*handles.G_sys*handles.exp_sys*handles.H_sys;%建立读入的系统模型
    sys1=handles.Gc_sys*handles.G_sys*handles.exp_sys;
    handles.sysb_Gc=feedback(sys1,handles.H_sys);
    handles.sysk_PID=handles.PID_sys*handles.G_sys*handles.exp_sys*handles.H_sys;
    sys2=handles.PID_sys*handles.G_sys*handles.exp_sys;
    handles.sysb_PID=feedback(sys2,handles.H_sys);
    set(handles.menu_model,'enable','on');%激活菜单
    set(handles.menu_analysis,'enable','on');
    set(handles.menu_design,'enable','on');
    set(handles.tool_save,'enable','on');
    set(handles.menu_save,'enable','on');
    set(handles.menu_save_as,'enable','on');
    set(handles.open_loop,'enable','on');
    set(handles.close_loop,'enable','on');
    set(handles.pid_map,'enable','on');
    set(handles.tool_calculate,'enable','on');
    set(handles.tool_stable,'enable','on');
    set(handles.tool_step,'enable','on');
    set(handles.tool_impulse,'enable','on');
    set(handles.tool_bode,'enable','on');
    set(handles.tool_nyquist,'enable','on');
    handles.flag_model_in=1;%设置模型已输入
    handles.flag_save=0;%存储标志
    handles.flag_model_change=1;%设置模型更改标志
    guidata(hObject,handles);
end
        

% --- Executes when user attempts to close ddqre_figure.
function ddqre_figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to ddqre_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if (handles.flag_model_change==1)
    if (handles.flag_save==0)
        answer=questdlg('Save changes to the model?',...
            'Exit ddqre Confirm','Yes','No','Cancel','Cancel');
    else
        filename=fullfile(handles.pathname,handles.filename);
        diag=['Save changes to ',filename];
        answer=questdlg(diag,...
            'Exit ddqre Confirm','Yes','No','Cancel','Cancel');
    end
    switch answer
        case 'Yes'
            data=[handles.PID,handles.exp,length(handles.Gc_num),handles.Gc_num,length(handles.Gc_den),handles.Gc_den];
            data=[data,length(handles.G_num),handles.G_num,length(handles.G_den),handles.G_den];
            data=[data,length(handles.H_num),handles.H_num,length(handles.H_den),handles.H_den];
            if (handles.flag_save==0)
                [filename, pathname] = uiputfile('*.dqr','save','untitled');
                    if (~isequal(filename,0))&(~isequal(pathname,0))
                        fid=fopen(fullfile(pathname,filename), 'wb');
                        fwrite(fid,data,'double');
                        fclose(fid);
                        handles.filename=filename;
                        handles.pathname=pathname;
                        handles.flag_save=1;%设置已保存
                        handles.flag_model_change=0;%设置模型更改标志
                        guidata(hObject,handles);
                    else
                        return;
                    end
            else
                    handles.flag_model_change=0;%设置模型更改标志
                    guidata(hObject,handles);
                    fid=fopen(fullfile(handles.pathname,handles.filename), 'wb');
                    fwrite(fid,data,'double');
                    fclose(fid);
            end
            delete(hObject);% Hint: delete(hObject) closes the figure
            close all;
        case 'No'
            delete(hObject);% Hint: delete(hObject) closes the figure
            close all;
    end
else
    delete(hObject);% Hint: delete(hObject) closes the figure
    close all;
end

    
function display_edit_Callback(hObject, eventdata, handles)
% hObject    handle to display_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of display_edit as text
%        str2double(get(hObject,'String')) returns contents of display_edit as a double


% --- Executes during object creation, after setting all properties.
function display_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to display_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in tf_zpk_ss.
function tf_zpk_ss_Callback(hObject, eventdata, handles)
% hObject    handle to tf_zpk_ss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns tf_zpk_ss contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tf_zpk_ss


% --- Executes during object creation, after setting all properties.
function tf_zpk_ss_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tf_zpk_ss (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in open_loop.
function open_loop_Callback(hObject, eventdata, handles)
% hObject    handle to open_loop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(handles.GcPID,'value');%根据Gc或PID显示开环模型
switch val
    case 1
        string=my_disp(handles.sysk_Gc.num{1},handles.sysk_Gc.den{1},handles);
        string=strvcat('Open Loop:',string);
        set(handles.display_edit,'string',string);
    case 2
        string=my_disp(handles.sysk_PID.num{1},handles.sysk_PID.den{1},handles);
        string=strvcat('Open Loop:',string);
        set(handles.display_edit,'string',string);
end


% --- Executes on button press in close_loop.
function close_loop_Callback(hObject, eventdata, handles)
% hObject    handle to close_loop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(handles.GcPID,'value');%根据Gc或PID显示开环模型
switch val
    case 1
        string=my_disp(handles.sysb_Gc.num{1},handles.sysb_Gc.den{1},handles);
        string=strvcat('Closed Loop:',string);
        set(handles.display_edit,'string',string);
    case 2
        string=my_disp(handles.sysb_PID.num{1},handles.sysb_PID.den{1},handles);
        string=strvcat('Closed Loop:',string);
        set(handles.display_edit,'string',string);
end

function string=my_disp(x,y,handles)%模型显示的核心函数,x,y分别为传递函数的分子，分母系数向量
tf_zpk_ss=get(handles.tf_zpk_ss,'value');
switch tf_zpk_ss
    case 1        
        num=my_poly2str(x);
        den=my_poly2str(y);
        if (length(num)>length(den))
            u1=(length(num)-length(den))/2*16/10;%一个‘－’和一个字符的长度不一致，需要一个比例
            u1=round(u1);
            kong(1,1:u1)=' ';
            den=[kong,den];
            u2=length(num)*35/26;
            u2=round(u2);
            gang(1,1:u2)='-';
            string=strvcat(num,gang,den);
        else
            u1=(length(den)-length(num))/2*16/10;
            u1=round(u1);
            kong(1,1:u1)=' ';
            num=[kong,num];
            u2=length(den)*37/26;
            u2=round(u2);
            gang(1,1:u2)='-';
            string=strvcat(num,gang,den);
        end         
        string=strvcat('tf model',string);
    case 2     
        string=my_tf2zp(x,y);
    case 3
        string=my_tf2ss(x,y);
end


function string=my_tf2zp(x,y)%经过扩展的传递函数到零极点的转化函数，可以转换分子阶数高于分母，返回一个字符串
for k=1:length(x)%去掉分子系数前面的零
    if (x(k)~=0)
        x1=x(1,k:length(x));
        break;
    end
end
for k=1:length(y)%去掉分母系数前面的零
    if (y(k)~=0)
        y1=y(1,k:length(y));
        break;
    end
end
if (length(x1)<=length(y1))
    [z,p,k]=tf2zp(x1,y1);
else
    [p,z,k]=tf2zp(y1,x1);
    k=1/k;
end
z=num2str(z);
p=num2str(p);
k=num2str(k);
string=strvcat('zpk model','gain:',k,'z-pole:',z,'p-pole:',p);


function string=my_tf2ss(x,y)%经过扩展的传递函数到状态空间模型的转化函数，可以转换分子阶数高于分母，返回一个字符串
for k=1:length(x)%去掉分子系数前面的零
    if (x(k)~=0)
        x1=x(1,k:length(x));
        break;
    end
end
for k=1:length(y)%去掉分母系数前面的零
    if (y(k)~=0)
        y1=y(1,k:length(y));
        break;
    end
end
if (length(x1)<=length(y1))
    [a,b,c,d]=tf2ss(x,y);
    a=num2str(a);
    b=num2str(b);
    c=num2str(c);
    d=num2str(d);
    string=strvcat('ss model','a matrix:',a,'b matrix:',b,'c matrix:',c,'d matrix',d);
else
    string=strvcat('ss model','Warning:length of num>length of den!');
end
    

% --- Executes on selection change in k_Ti_Td.
function k_Ti_Td_Callback(hObject, eventdata, handles)
% hObject    handle to k_Ti_Td (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns k_Ti_Td contents as cell array
%        contents{get(hObject,'Value')} returns selected item from k_Ti_Td


% --- Executes during object creation, after setting all properties.
function k_Ti_Td_CreateFcn(hObject, eventdata, handles)
% hObject    handle to k_Ti_Td (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in twoD_threeD.
function twoD_threeD_Callback(hObject, eventdata, handles)
% hObject    handle to twoD_threeD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns twoD_threeD contents as cell array
%        contents{get(hObject,'Value')} returns selected item from twoD_threeD


% --- Executes during object creation, after setting all properties.
function twoD_threeD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to twoD_threeD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pid_input_Callback(hObject, eventdata, handles)
% hObject    handle to pid_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pid_input as text
%        str2double(get(hObject,'String')) returns contents of pid_input as a double


% --- Executes during object creation, after setting all properties.
function pid_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pid_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pid_map.
function pid_map_Callback(hObject, eventdata, handles)
% hObject    handle to pid_map (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pid_time=get(handles.pid_time,'string');
pid_time=str2num(pid_time);
val1=get(handles.k_Ti_Td,'value');
val2=get(handles.twoD_threeD,'value');
x=get(handles.pid_input,'string');
x=str2num(x);
if(~isempty(x))
    x=x(1,:);
    tag=my_figure();
    if(~isempty(pid_time))
        t=[0:0.01:pid_time(1,1)];%可以调节立体仿真时间
    else
        t=[0:0.01:10];%设置默认立体图仿真时间长
    end
    for k=1:length(x)
        switch val1
            case 1
                if (handles.PID(2)~=inf)
                    PID_num=[x(k)*handles.PID(2)*handles.PID(3),x(k)*handles.PID(2),x(k)];
                    PID_den=[handles.PID(2),0];
                else
                    PID_num=[x(k)*handles.PID(3),x(k)];
                    PID_den=[1];            
                end
                PID_sys=tf(PID_num,PID_den);
            case 2
                PID_num=[handles.PID(1)*x(k)*handles.PID(3),handles.PID(1)*x(k),handles.PID(1)];
                PID_den=[x(k),0];
                PID_sys=tf(PID_num,PID_den);
            case 3
                if (handles.PID(2)~=inf)
                    PID_num=[handles.PID(1)*handles.PID(2)*x(k),handles.PID(1)*handles.PID(2),handles.PID(1)];
                    PID_den=[handles.PID(2),0];
                else
                    PID_num=[handles.PID(1)*x(k),handles.PID(1)];
                    PID_den=[1];
                end
                PID_sys=tf(PID_num,PID_den);
        end
        sys=PID_sys*handles.G_sys*handles.exp_sys;
        sys=feedback(sys,handles.H_sys);
        n=my_isstable(sys);
        if(n==0)
            if(isempty(pid_time))
                t1=my_ts(sys);
                t1=0:0.01:t1*3/2;%设置2D图稳定时候的阶跃响应时间长
            else
                t1=0:0.01:pid_time(1,1);
            end
        else
            if(isempty(pid_time))
                t1=0:0.01:10;%设置2D图不稳定时候的阶跃响应时间长
            else
                t1=0:0.01:pid_time(1,1);
            end
        end
        switch val2
            case 1            
                step(sys,t1);
                hold on;
            case 2
                y(k,:)=step(sys,t);
            case 3
                y(k,:)=step(sys,t);
        end
    end
    switch val2
        case 1            
            set(tag,'name','PID Observer:2D Plots');
            xlabel('Time');%标注图的x,y,title
            ylabel('Step Response');
            switch val1
                case 1
                    title('Coefficient K Influence');
                case 2
                    title('Coefficient Ti Influence');
                case 3
                    title('Coefficient Td Influence');
            end           
        case 2
            if(length(x)>1)
                set(tag,'name','PID Observer:3D Plots');
                [T,X]=meshgrid(t,x);
                mesh(T,X,y);
                xlabel('Time');%标注图的x,y,z,title
                zlabel('Step Response');
                switch val1
                    case 1
                        ylabel('Coefficient K');
                        title('Coefficient K Influence');
                    case 2
                        ylabel('Coefficient Ti');
                        title('Coefficient Ti Influence');
                    case 3
                        ylabel('Coefficient Td');
                        title('Coefficient Td Influence');
                end
            else
                set(handles.display_edit,'string','Error:3D Plots need at least two numbers!');
                close(tag);
            end
        case 3
            if(length(x)>1)
                set(tag,'name','PID Observer:Interpolated 3D Plots');
                [T,X]=meshgrid(t,x);
                surf(T,X,y),shading interp;     
                xlabel('Time');%标注图的x,y,z,title
                zlabel('Step Response');
                switch val1
                    case 1
                        ylabel('Coefficient K');
                        title('Coefficient K Influence');
                    case 2
                        ylabel('Coefficient Ti');
                        title('Coefficient Ti Influence');
                    case 3
                        ylabel('Coefficient Td');
                        title('Coefficient Td Influence');
                end
            else
                set(handles.display_edit,'string','Error:Interp 3D Plots need at least two numbers!');
                close(tag);
            end
    end
end


function y=my_figure()%图形绘制的界面
tag=figure;
set(tag,'dockcontrols','off');
set(tag,'numbertitle','off');
set(tag,'menubar','none');
set(tag,'toolbar','figure');
y=tag;


function y=my_isstable(sys)%判断系统稳定性的函数，稳定返回0,不稳定返回1
n=0;
geng=roots(sys.den{1});
fen=sys.num{1};
geng1=real(geng);
for i=1:length(geng1)
    if(geng1(i)>=0)&((polyval(fen,geng(i))>0.000001)|(polyval(fen,geng(i))<-0.000001))%消除浮点误差        
        n=1;
        break;
    end
end
y=n;


% --------------------------------------------------------------------
function menu_PID_display_Callback(hObject, eventdata, handles)
% hObject    handle to menu_PID_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
string=my_disp(handles.PID_sys.num{1},handles.PID_sys.den{1},handles);
string=strvcat('PID Plant:',string);
set(handles.display_edit,'string',string);

% --------------------------------------------------------------------
function menu_Gc_display_Callback(hObject, eventdata, handles)
% hObject    handle to menu_Gc_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
string=my_disp(handles.Gc_sys.num{1},handles.Gc_sys.den{1},handles);
string=strvcat('Gc(s) Plant:',string);
set(handles.display_edit,'string',string);

% --------------------------------------------------------------------
function menu_G_display_Callback(hObject, eventdata, handles)
% hObject    handle to menu_G_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
string=my_disp(handles.G_sys.num{1},handles.G_sys.den{1},handles);
string=strvcat('G(s) Plant:',string);
set(handles.display_edit,'string',string);

% --------------------------------------------------------------------
function menu_exp_display_Callback(hObject, eventdata, handles)
% hObject    handle to menu_exp_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
string=my_disp(handles.exp_sys.num{1},handles.exp_sys.den{1},handles);
string=strvcat('e^-Ts Plant:',string);
set(handles.display_edit,'string',string);

% --------------------------------------------------------------------
function menu_H_display_Callback(hObject, eventdata, handles)
% hObject    handle to menu_H_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
string=my_disp(handles.H_sys.num{1},handles.H_sys.den{1},handles);
string=strvcat('H(s) Plant:',string);
set(handles.display_edit,'string',string);

% --------------------------------------------------------------------
function menu_openloop_display_Callback(hObject, eventdata, handles)
% hObject    handle to menu_openloop_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(handles.GcPID,'value');%根据Gc或PID显示开环模型
switch val
    case 1
        string=my_disp(handles.sysk_Gc.num{1},handles.sysk_Gc.den{1},handles);
        string=strvcat('Open Loop:',string);
        set(handles.display_edit,'string',string);
    case 2
        string=my_disp(handles.sysk_PID.num{1},handles.sysk_PID.den{1},handles);
        string=strvcat('Open Loop:',string);
        set(handles.display_edit,'string',string);
end

% --------------------------------------------------------------------
function menu_closedloop_display_Callback(hObject, eventdata, handles)
% hObject    handle to menu_closedloop_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(handles.GcPID,'value');%根据Gc或PID显示开环模型
switch val
    case 1
        string=my_disp(handles.sysb_Gc.num{1},handles.sysb_Gc.den{1},handles);
        string=strvcat('Closed Loop:',string);
        set(handles.display_edit,'string',string);
    case 2
        string=my_disp(handles.sysb_PID.num{1},handles.sysb_PID.den{1},handles);
        string=strvcat('Closed Loop:',string);
        set(handles.display_edit,'string',string);
end


function [ts,lastvalue]=my_ts(sys)   %求取调节时间ts，阶跃响应终值lastvalue,调用之前先需判断稳定性，即调用my_isstable
t=0:10^9:10^10;%计算终值，取时间很大
x=step(sys,t);
lastvalue=x(length(x));
t=0:0.01:1000;
x=step(sys,t);
u1=abs(x-lastvalue);%u1为计算调节时间ts的中间变量
u1=find(u1>0.02*lastvalue);
u1=t(u1);
ts=max(u1);%计算出了调节时间

    
% --------------------------------------------------------------------
function menu_calculate_all_Callback(hObject, eventdata, handles)
% hObject    handle to menu_calculate_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(handles.GcPID,'value');
switch val
    case 1
        sysk=handles.sysk_Gc;
        sysb=handles.sysb_Gc;
    case 2
        sysk=handles.sysk_PID;
        sysb=handles.sysb_PID;
end

[gm,pm,wg,wp]=margin(sysk);%计算频率特性
set(handles.fuzhi_yd,'string',gm);%幅值裕度
set(handles.xiangjiao_yd,'string',pm);%相角裕度
set(handles.chuanyue_pin,'string',wg);%穿越频率
set(handles.jiezhi_pin,'string',wp);%截止频率

n=my_isstable(sysb);
if(n==0)
    [ts,lastvalue]=my_ts(sysb);
    t=0:0.01:ts;
    y=step(sysb,t);
    [Mp,j]=max(y);%计算峰值时间与峰值
    peaktime=t(j);
    overshoot=100*(Mp-lastvalue)/lastvalue;%计算超调量
    overshoot=num2str(overshoot);
    for k=1:length(y)            %计算上升时间下值
        if(y(k)>0.1*lastvalue)
            t01=t(k);           
            break;
        end
    end
    for k=1:length(y)            %计算上升时间上值
        if(y(k)>0.9*lastvalue)
            t02=t(k);           
            break;
        end
    end
    tr=t02-t01;%计算上升时间
    for k=1:length(y)
        if(y(k)>0.5*lastvalue)
            td=t(k);           %计算延迟时间
            break;
        end
    end
    if(Mp<=lastvalue)
        set(handles.fengzhi,'string','None');
        set(handles.fengzhi_time,'string','None');
        set(handles.chaotiao,'string','None');
    else
        set(handles.fengzhi,'string',Mp);
        set(handles.fengzhi_time,'string',peaktime);
        set(handles.chaotiao,'string',[overshoot,'%']);
    end
    set(handles.tiaojie_time,'string',ts);
    set(handles.shangsheng_time,'string',tr);
    set(handles.yanchi_time,'string',td);
else
    set(handles.fengzhi,'string','Unstable');
    set(handles.fengzhi_time,'string','Unstable');
    set(handles.chaotiao,'string','Unstable');
    set(handles.tiaojie_time,'string','Unstable');
    set(handles.shangsheng_time,'string','Unstable');
    set(handles.yanchi_time,'string','Unstable');
end


% --------------------------------------------------------------------
function menu_stability_analysis_Callback(hObject, eventdata, handles)
% hObject    handle to menu_stability_analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(handles.GcPID,'value');
switch val
    case 1
        n=my_isstable(handles.sysb_Gc);
        if(n==0)
            msgbox('Closed-loop system is stable.');
        else
            msgbox('Closed-loop system is unstable!','','warn');
        end
    case 2
        n=my_isstable(handles.sysb_PID);
        if(n==0)
            msgbox('Closed-loop system is stable.');
        else
            msgbox('Closed-loop system is unstable!','','warn');
        end
end

% --------------------------------------------------------------------
function menu_time_domain_analysis_Callback(hObject, eventdata, handles)
% hObject    handle to menu_time_domain_analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_frequency_domain_analysis_Callback(hObject, eventdata, handles)
% hObject    handle to menu_frequency_domain_analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_bode_plot_Callback(hObject, eventdata, handles)
% hObject    handle to menu_bode_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(handles.GcPID,'value');
tag=my_figure();
set(tag,'name','Bode Diagram');
switch val
    case 1
        bode(handles.sysk_Gc),grid;
    case 2
        bode(handles.sysk_PID),grid;
end

% --------------------------------------------------------------------
function menu_step_response_Callback(hObject, eventdata, handles)
% hObject    handle to menu_step_response (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(handles.GcPID,'value');
tag=my_figure();
set(tag,'name','Step Response Plot');
switch val
    case 1
        n=my_isstable(handles.sysb_Gc);
        if(n==0)
            ts=my_ts(handles.sysb_Gc);
            t=0:0.01:ts*3/2;
        else
            t=0:0.01:30;
        end        
        step(handles.sysb_Gc,t);
    case 2
        n=my_isstable(handles.sysb_PID);
        if(n==0)
            ts=my_ts(handles.sysb_PID);
            t=0:0.01:ts*3/2;
        else
            t=0:0.01:30;
        end        
        step(handles.sysb_PID,t);
end

% --------------------------------------------------------------------
function menu_impulse_response_Callback(hObject, eventdata, handles)
% hObject    handle to menu_impulse_response (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(handles.GcPID,'value');
tag=my_figure();
set(tag,'name','Impulse Response Plot');
switch val
    case 1
        n=my_isstable(handles.sysb_Gc);
        if(n==0)
            ts=my_ts(handles.sysb_Gc);
            t=0:0.01:ts*3/2;
        else
            t=0:0.01:30;
        end        
        impulse(handles.sysb_Gc,t);
    case 2
        n=my_isstable(handles.sysb_PID);
        if(n==0)
            ts=my_ts(handles.sysb_PID);
            t=0:0.01:ts*3/2;
        else
            t=0:0.01:30;
        end        
        impulse(handles.sysb_PID,t);
end

% --------------------------------------------------------------------
function menu_ramp_response_Callback(hObject, eventdata, handles)
% hObject    handle to menu_ramp_response (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(handles.GcPID,'value');
tag=my_figure();
set(tag,'name','Ramp Response Plot');
switch val
    case 1
        n=my_isstable(handles.sysb_Gc);
        if(n==0)
            ts=my_ts(handles.sysb_Gc);
            t=0:0.01:ts*3/2;
        else
            t=0:0.01:30;
        end  
        num=handles.sysb_Gc.num{1};
        den=[handles.sysb_Gc.den{1},0];
        sys=tf(num,den);
        step(sys,t);
        title('Ramp Response');
    case 2
        n=my_isstable(handles.sysb_PID);
        if(n==0)
            ts=my_ts(handles.sysb_PID);
            t=0:0.01:ts*3/2;
        else
            t=0:0.01:30;
        end       
        num=handles.sysb_PID.num{1};
        den=[handles.sysb_PID.den{1},0];
        sys=tf(num,den);       
        step(sys,t);
        title('Ramp Response');
end

% --------------------------------------------------------------------
function menu_acceleration_response_Callback(hObject, eventdata, handles)
% hObject    handle to menu_acceleration_response (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(handles.GcPID,'value');
tag=my_figure();
set(tag,'name','Acceleration Response Plot');
switch val
    case 1
        n=my_isstable(handles.sysb_Gc);
        if(n==0)
            ts=my_ts(handles.sysb_Gc);
            t=0:0.01:ts*3/2;
        else
            t=0:0.01:30;
        end  
        num=handles.sysb_Gc.num{1};
        den=[handles.sysb_Gc.den{1},0,0];
        sys=tf(num,den);
        step(sys,t);
        title('Acceleration Response');
    case 2
        n=my_isstable(handles.sysb_PID);
        if(n==0)
            ts=my_ts(handles.sysb_PID);
            t=0:0.01:ts*3/2;
        else
            t=0:0.01:30;
        end       
        num=handles.sysb_PID.num{1};
        den=[handles.sysb_PID.den{1},0,0];
        sys=tf(num,den);       
        step(sys,t);
        title('Acceleration Response');
end

% --------------------------------------------------------------------
function menu_root_locus_analysis_Callback(hObject, eventdata, handles)
% hObject    handle to menu_root_locus_analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_zero_pole_map_Callback(hObject, eventdata, handles)
% hObject    handle to menu_zero_pole_map (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(handles.GcPID,'value');
tag=my_figure();
set(tag,'name','Zero-Pole Map');
switch val
    case 1
        pzmap(handles.sysk_Gc),grid;
    case 2
        pzmap(handles.sysk_PID),grid;
end

% --------------------------------------------------------------------
function menu_root_locus_plot_Callback(hObject, eventdata, handles)
% hObject    handle to menu_root_locus_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(handles.GcPID,'value');
tag=my_figure();
set(tag,'name','Root Locus Plot');
switch val
    case 1
        rlocus(handles.sysk_Gc),grid;
    case 2
        rlocus(handles.sysk_PID),grid;
end

% --------------------------------------------------------------------
function menu_nyquist_plot_Callback(hObject, eventdata, handles)
% hObject    handle to menu_nyquist_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(handles.GcPID,'value');
tag=my_figure();
set(tag,'name','Nyquist Diagram');
switch val
    case 1
        nyquist(handles.sysk_Gc),grid;
    case 2
        nyquist(handles.sysk_PID),grid;
end

% --------------------------------------------------------------------
function menu_nichols_plot_Callback(hObject, eventdata, handles)
% hObject    handle to menu_nichols_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(handles.GcPID,'value');
tag=my_figure();
set(tag,'name','Nichols Chart');
switch val
    case 1
        nichols(handles.sysk_Gc),grid;
    case 2
        nichols(handles.sysk_PID),grid;
end

% --------------------------------------------------------------------
function menu_new_Callback(hObject, eventdata, handles)
% hObject    handle to menu_new (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tool_new_ClickedCallback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function menu_open_Callback(hObject, eventdata, handles)
% hObject    handle to menu_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tool_open_ClickedCallback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function menu_save_Callback(hObject, eventdata, handles)
% hObject    handle to menu_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tool_save_ClickedCallback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function menu_save_as_Callback(hObject, eventdata, handles)
% hObject    handle to menu_save_as (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=[handles.PID,handles.exp,length(handles.Gc_num),handles.Gc_num,length(handles.Gc_den),handles.Gc_den];
data=[data,length(handles.G_num),handles.G_num,length(handles.G_den),handles.G_den];
data=[data,length(handles.H_num),handles.H_num,length(handles.H_den),handles.H_den];
[filename, pathname] = uiputfile('*.dqr','save','untitled');
if (~isequal(filename,0))&(~isequal(pathname,0))
    fid=fopen(fullfile(pathname,filename), 'wb');
    fwrite(fid,data,'double');
    fclose(fid);
    handles.filename=filename;
    handles.pathname=pathname;
    handles.flag_save=1;%设置已保存
    handles.flag_model_change=0;%设置模型更改标志
    set(handles.tool_save,'enable','off');%激死存储
    set(handles.menu_save,'enable','off');
    guidata(hObject,handles);
end
% --------------------------------------------------------------------
function menu_exit_Callback(hObject, eventdata, handles)
% hObject    handle to menu_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ddqre_figure_CloseRequestFcn(hObject, eventdata, handles);

% --------------------------------------------------------------------
function tool_calculate_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to tool_calculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menu_calculate_all_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function tool_stable_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to tool_stable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menu_stability_analysis_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function tool_step_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to tool_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menu_step_response_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function tool_impulse_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to tool_impulse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menu_impulse_response_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function tool_bode_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to tool_bode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menu_bode_plot_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function tool_nyquist_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to tool_nyquist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menu_nyquist_plot_Callback(hObject, eventdata, handles);


% --------------------------------------------------------------------
function menu_lead_lag_controler_Callback(hObject, eventdata, handles)
% hObject    handle to menu_lead_lag_controler (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prompt={'Target Cut-off Frequency','Target Phase Margin','Methods Choose:,Blank for auto,Positive for lead,negative for lag,zero for leadlag'};
defans={'20','45',''};
answer=inputdlg(prompt,'Lead/Lag Design Coefficient Input',1,defans,'on');
if (~isempty(answer))
    if (~isempty(answer{1}))&(~isempty(answer{2}))
        Wc=str2num(answer{1});
        Wc=Wc(1);
        Gam_c=str2num(answer{2});
        Gam_c=Gam_c(1);
        G=handles.G_sys*handles.exp_sys;
        if(isempty(answer{3}))
            Gc=my_leadlagc(G,Wc,Gam_c,1000);
        else
            key=str2num(answer{3});
            key=key(1);
            if(key>0)
                Gc=my_leadlagc(G,Wc,Gam_c,1000,1);
            elseif(key<0)
                Gc=my_leadlagc(G,Wc,Gam_c,1000,2);
            else
                Gc=my_leadlagc(G,Wc,Gam_c,1000,3);
            end
        end
        string=my_disp(Gc.num{1},Gc.den{1},handles);
        string=strvcat('Lead/Lag Controler:',string);
        set(handles.display_edit,'string',string);
        jiaoqian_sys=feedback(G,handles.H_sys);
        jiaohou_sys=feedback(G*Gc,handles.H_sys);
        n1=my_isstable(jiaoqian_sys);
        n2=my_isstable(jiaohou_sys);
        tag=my_figure();
        set(tag,'name','Lead/Lag Controler Plot');
        if(n2==0)&(n1==0)
            ts1=my_ts(jiaoqian_sys);
            ts2=my_ts(jiaohou_sys);
            if(ts1>ts2)
                t=0:0.01:ts1*3/2;
            else
                t=0:0.01:ts2*3/2;
            end
            y1=step(jiaoqian_sys,t);
            y2=step(jiaohou_sys,t);
            plot(t,y1,':b',t,y2,'r');
            legend('Original','Target');
            title('Step Response');
            ylabel('Amplitude');
            xlabel('Time(sec)');
        else
            if(n2==0)&(n1~=0)
                ts=my_ts(jiaohou_sys);
                t=0:0.01:ts*3/2;
            elseif(n2~=0)&(n1==0)
                ts=my_ts(jiaoqian_sys);
                 t=0:0.01:ts*3/2;
            else
                t=0:0.01:30;
            end
            y1=step(jiaoqian_sys,t);
            y2=step(jiaohou_sys,t);
            [u1,u2,u3]=plotyy(t,y1,t,y2);
            set(get(u1(1),'Ylabel'),'String','Amplitude');
            set(get(u1(2),'Ylabel'),'String','Amplitude');
            set(u1(1),'Ycolor','b');
            set(u1(2),'Ycolor','r');
            set(u2,'LineStyle',':');
            set(u2,'color','b');
            set(u3,'color','r');
            title('Step Response');
            xlabel('Time(sec)');
            legend(u2,'Original',2);
            legend(u3,'Target',1);
        end
    end
end
        



% --------------------------------------------------------------------
function menu_pid_controler_Callback(hObject, eventdata, handles)
% hObject    handle to menu_pid_controler (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
G=handles.G_sys*handles.exp_sys;
[K,L,T,sys]=my_getfolpd(G);
a=K*L/T;
kp1=1/a;
kp2=0.9/a;ti2=3*L;
kp3=1.2/a;ti3=2*L;td3=L/2;
P=tf(kp1,1);
PI=tf(kp2*[ti2,1],[ti2,0]);
PID=tf([kp3*ti3*td3,kp3*ti3,kp3],[ti3,0]);
string=my_disp(PID.num{1},PID.den{1},handles);
string=strvcat('PID Controler:',string);
string1=my_disp(PI.num{1},PI.den{1},handles);
string=strvcat(string1,string);
string=strvcat('PI Controler:',string);
string1=my_disp(P.num{1},P.den{1},handles);
string=strvcat(string1,string);
string=strvcat('P Controler:',string);
set(handles.display_edit,'string',string);
jiaoqian_sys=feedback(G,handles.H_sys);
jiao_P=feedback(G*P,handles.H_sys);
jiao_PI=feedback(G*PI,handles.H_sys);
jiao_PID=feedback(G*PID,handles.H_sys);
tag=my_figure();
set(tag,'name','PID Controler Plot');
n=my_isstable(jiaoqian_sys);
if(n==0)
    step(jiaoqian_sys,'b'),hold on;
    step(jiao_P,'.r');
    step(jiao_PI,'--g');
    step(jiao_PID,':y');
    legend('Original','P Controler','PI Controler','PID Controler');
else
    step(jiao_P,'.r'),hold on;
    step(jiao_PI,'--g');
    step(jiao_PID,':y');
    legend('P Controler','PI Controler','PID Controler');
end
        

function Gc=my_leadlagc(G,Wc,Gam_c,Kv,key)
G=tf(G); [Gai,Pha]=bode(G,Wc);
Phi_c=sin((Gam_c-Pha-180)*pi/180);
den=G.den{1}; a=den(length(den):-1:1);
ii=find(abs(a)<=0); num=G.num{1}; G_n=num(end);
if length(ii)>0
    a=a(ii(1)+1); 
else
    a=a(1); 
end
alpha=sqrt((1-Phi_c)/(1+Phi_c)); Zc=alpha*Wc; Pc=Wc/alpha; 
Kc=sqrt((Wc*Wc+Pc*Pc)/(Wc*Wc+Zc*Zc))/Gai; K1=G_n*Kc*alpha*alpha/a;
if (nargin==4)
    key=1;
    if (Phi_c<0)
        key=2; 
    else
        if (K1<Kv)
            key=3; 
        end
    end
end
switch key
    case 1
        Gc=tf([1 Zc]*Kc,[1 Pc]);
    case 2
        Kc=1/Gai; Zc2=Wc*0.1; Pc2=K1*Zc2/Kv;Gc=tf([1 Zc2]*Kc,[1 Pc2]); 
    case 3
        Zc2=Wc*0.1; Pc2=K1*Zc2/Kv; Gcn=Kc*conv([1 Zc],[1,Zc2]);Gcd=conv([1 Pc],[1,Pc2]); Gc=tf(Gcn,Gcd);
end


function [K,L,T,G1]=my_getfolpd(G)
[y,t]=step(G); 
fun = inline('x(1)*(1-exp(-(t-x(2))/x(3))).*(t>x(2))','x','t');
x=lsqcurvefit(fun,[1 1 1],t,y); 
K=x(1); L=x(2); T=x(3);
G=tf(K,[T 1]);
[exp_num,exp_den]=pade(L,3);
exp=tf(exp_num,exp_den);
G1=G*exp;


% --------------------------------------------------------------------
function menu_guide_Callback(hObject, eventdata, handles)
% hObject    handle to menu_guide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
help_ddqre;

% --------------------------------------------------------------------
function menu_about_Callback(hObject, eventdata, handles)
% hObject    handle to menu_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
about_ddqre


function p=my_poly2str(c)
for k=1:length(c)%去掉系数前面的零
    if (c(k)~=0)
        x1=c(1,k:length(c));
        break;
    end
end
p='';i=0;m=length(x1)-1;
for a=x1
    i=i+1;
    k=length(x1)-i;
    k1=num2str(k);
    a1=num2str(a);
    if(a~=0)
        if(k==m)
            if(k==1)
                if(a==1)
                    p=['s'];
                else
                    p=[a1,'s'];
                end
            elseif(k==0)
                p=[a1];
            else
                if(a==1)
                    p=['s','^',k1];
                else
                    p=[a1,'s','^',k1];
                end
            end
        else
            if(k==1)
                if(a==1)
                    p=[p,'+','s'];
                else
                    p=[p,'+',a1,'s'];
                end
            elseif(k==0)
                p=[p,'+',a1];
            else
                if(a==1)
                    p=[p,'+','s','^',k1];
                else
                    p=[p,'+',a1,'s','^',k1];
                end
            end
        end
    end
end


function pid_time_Callback(hObject, eventdata, handles)
% hObject    handle to pid_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pid_time as text
%        str2double(get(hObject,'String')) returns contents of pid_time as a double


% --- Executes during object creation, after setting all properties.
function pid_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pid_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


