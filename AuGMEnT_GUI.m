function varargout = AuGMEnT_GUI(varargin)
% AuGMEnT_GUI M-file for AuGMEnT_GUI.fig
%      AuGMEnT_GUI, by itself, creates a new AuGMEnT_GUI or raises the existing
%      singleton*.
%
%      H = AuGMEnT_GUI returns the handle to a new AuGMEnT_GUI or the handle to
%      the existing singleton*.
%
%      AuGMEnT_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AuGMEnT_GUI.M with the given input arguments.
%
%      AuGMEnT_GUI('Property','Value',...) creates a new AuGMEnT_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AuGMEnT_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AuGMEnT_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AuGMEnT_GUI

% Last Modified by GUIDE v2.5 10-May-2012 14:41:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AuGMEnT_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @AuGMEnT_GUI_OutputFcn, ...
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


% --- Executes just before AuGMEnT_GUI is made visible.
function AuGMEnT_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AuGMEnT_GUI (see VARARGIN)

% Choose default command line output for AuGMEnT_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AuGMEnT_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AuGMEnT_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in b_fixate.
function b_fixate_Callback(hObject, eventdata, handles)
% hObject    handle to b_fixate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in b_right.
function b_right_Callback(hObject, eventdata, handles)
% hObject    handle to b_right (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in b_left.
function b_left_Callback(hObject, eventdata, handles)
% hObject    handle to b_left (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function task_state_Callback(hObject, eventdata, handles)
% hObject    handle to task_state (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of task_state as text
%        str2double(get(hObject,'String')) returns contents of task_state as a double


% --- Executes during object creation, after setting all properties.
function task_state_CreateFcn(hObject, eventdata, handles)
% hObject    handle to task_state (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in b_step.
function b_step_Callback(hObject, eventdata, handles)
% hObject    handle to b_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in b_go.
function b_go_Callback(hObject, eventdata, handles)
% hObject    handle to b_go (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in b_pause.
function b_pause_Callback(hObject, eventdata, handles)
% hObject    handle to b_pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function s_steptime_Callback(hObject, eventdata, handles)
% hObject    handle to s_steptime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function s_steptime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to s_steptime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function t_steptime_indicator_Callback(hObject, eventdata, handles)
% hObject    handle to t_steptime_indicator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of t_steptime_indicator as text
%        str2double(get(hObject,'String')) returns contents of t_steptime_indicator as a double


% --- Executes during object creation, after setting all properties.
function t_steptime_indicator_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t_steptime_indicator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_ny_normal_Callback(hObject, eventdata, handles)
% hObject    handle to e_ny_normal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_ny_normal as text
%        str2double(get(hObject,'String')) returns contents of e_ny_normal as a double


% --- Executes during object creation, after setting all properties.
function e_ny_normal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_ny_normal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_ny_memory_Callback(hObject, eventdata, handles)
% hObject    handle to e_ny_memory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_ny_memory as text
%        str2double(get(hObject,'String')) returns contents of e_ny_memory as a double


% --- Executes during object creation, after setting all properties.
function e_ny_memory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_ny_memory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in b_apply.
function b_apply_Callback(hObject, eventdata, handles)
% hObject    handle to b_apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function s_delay_Callback(hObject, eventdata, handles)
% hObject    handle to s_delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function s_delay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to s_delay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function t_delay_indicator_Callback(hObject, eventdata, handles)
% hObject    handle to t_delay_indicator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of t_delay_indicator as text
%        str2double(get(hObject,'String')) returns contents of t_delay_indicator as a double


% --- Executes during object creation, after setting all properties.
function t_delay_indicator_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t_delay_indicator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_alpha_Callback(hObject, eventdata, handles)
% hObject    handle to e_alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_alpha as text
%        str2double(get(hObject,'String')) returns contents of e_alpha as a double


% --- Executes during object creation, after setting all properties.
function e_alpha_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_beta_Callback(hObject, eventdata, handles)
% hObject    handle to e_beta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_beta as text
%        str2double(get(hObject,'String')) returns contents of e_beta as a double


% --- Executes during object creation, after setting all properties.
function e_beta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_beta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_gamma_Callback(hObject, eventdata, handles)
% hObject    handle to e_gamma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_gamma as text
%        str2double(get(hObject,'String')) returns contents of e_gamma as a double


% --- Executes during object creation, after setting all properties.
function e_gamma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_gamma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_lambda_Callback(hObject, eventdata, handles)
% hObject    handle to e_lambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_lambda as text
%        str2double(get(hObject,'String')) returns contents of e_lambda as a double


% --- Executes during object creation, after setting all properties.
function e_lambda_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_lambda (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_lambda_mem_Callback(hObject, eventdata, handles)
% hObject    handle to e_lambda_mem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_lambda_mem as text
%        str2double(get(hObject,'String')) returns contents of e_lambda_mem as a double


% --- Executes during object creation, after setting all properties.
function e_lambda_mem_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_lambda_mem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_minfact_Callback(hObject, eventdata, handles)
% hObject    handle to e_minfact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_minfact as text
%        str2double(get(hObject,'String')) returns contents of e_minfact as a double


% --- Executes during object creation, after setting all properties.
function e_minfact_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_minfact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in p_taskselect.
function p_taskselect_Callback(hObject, eventdata, handles)
% hObject    handle to p_taskselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns p_taskselect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from p_taskselect


% --- Executes during object creation, after setting all properties.
function p_taskselect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to p_taskselect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in c_maxcritic.
function c_maxcritic_Callback(hObject, eventdata, handles)
% hObject    handle to c_maxcritic (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of c_maxcritic



function t_reward_indicator_Callback(hObject, eventdata, handles)
% hObject    handle to t_reward_indicator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of t_reward_indicator as text
%        str2double(get(hObject,'String')) returns contents of t_reward_indicator as a double


% --- Executes during object creation, after setting all properties.
function t_reward_indicator_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t_reward_indicator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function t_fixreward_indicator_Callback(hObject, eventdata, handles)
% hObject    handle to t_fixreward_indicator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of t_fixreward_indicator as text
%        str2double(get(hObject,'String')) returns contents of t_fixreward_indicator as a double


% --- Executes during object creation, after setting all properties.
function t_fixreward_indicator_CreateFcn(hObject, eventdata, handles)
% hObject    handle to t_fixreward_indicator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in b_performance_reset.
function b_performance_reset_Callback(hObject, eventdata, handles)
% hObject    handle to b_performance_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
