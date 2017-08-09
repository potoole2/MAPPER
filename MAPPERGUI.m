function varargout = MAPPERGUI(varargin)
% MAPPERGUI MATLAB code for MAPPERGUI.fig
%      MAPPERGUI, by itself, creates a new MAPPERGUI or raises the existing
%      singleton*.
%
%      H = MAPPERGUI returns the handle to a new MAPPERGUI or the handle to
%      the existing singleton*.
%
%      MAPPERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAPPERGUI.M with the given input arguments.
%
%      MAPPERGUI('Property','Value',...) creates a new MAPPERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MAPPERGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MAPPERGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MAPPERGUI

% Last Modified by GUIDE v2.5 18-Jul-2017 15:00:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @MAPPERGUI_OpeningFcn, ...
    'gui_OutputFcn',  @MAPPERGUI_OutputFcn, ...
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



% --- Executes just before MAPPERGUI is made visible.
function MAPPERGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MAPPERGUI (see VARARGIN)

% Choose default command line output for MAPPERGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MAPPERGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MAPPERGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in uploadButton.
function uploadButton_Callback(hObject, eventdata, handles)
% hObject    handle to uploadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename,directory] = uigetfile
if directory ~= 0
    handles.var{1} = {directory,filename};
    handles.var{2} = importdata([directory,filename]);
    guidata(hObject,handles);
    handles.uploadName.String = filename;
end


% --- Executes on button press in runBotton.
function runBotton_Callback(hObject, eventdata, handles)
% hObject    handle to runBotton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
directory = handles.var{1}(1);
filename = handles.var{1}(2);
file = handles.var{2};

if handles.stitchButton.Value == 1
    doStitch = 1;
    M = str2double(handles.MBox.String);
    N = str2double(handles.NBox.String);
    overlap = handles.overlapBox.String;
    fileName = [handles.filenameBox.String,' '];
    numembs = str2num(handles.numembsBox.String);
    channels = {handles.channelsBox1.String,handles.channelsBox2.String,handles.channelsBox3.String,handles.channelsBox4.String};
    channels = channels(~cellfun('isempty',channels));
    numChars = str2num(handles.numCharsBox.String);
    fijiDir = handles.var{3}(1:length(handles.var{3})-1);
    
    gaussSigma = str2num(handles.gaussSigmaBox.String);
    filterchoice = 3;
    
elseif handles.stitchButton.Value == 0
    doStitch = 0;
end

if handles.segmentCellsCheck.Value == 1
    doSegmentCells = 1;
    sigmaX = 5/str2num(handles.SigmaXBox.String);
    sigmaY = 5/str2num(handles.SigmaYBox.String);
    threshold = str2num(handles.thresholdBox.String);
    filterDiameter = str2num(handles.filterDiameterBox.String);
elseif handles.segmentCellsCheck.Value == 0
    if handles.loadCheck.Value == 1
        doSegmentCells = 1;
    elseif handles.loadCheck.Value == 0
        doSegmentCells = 0;
    end
end



MAPPER


% --- Executes on button press in stitchButton.
function stitchButton_Callback(hObject, eventdata, handles)
% hObject    handle to stitchButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stitchButton




function MBox_Callback(hObject, eventdata, handles)
% hObject    handle to MBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MBox as text
%        str2double(get(hObject,'String')) returns contents of MBox as a double


% --- Executes during object creation, after setting all properties.
function MBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NBox_Callback(hObject, eventdata, handles)
% hObject    handle to NBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NBox as text
%        str2double(get(hObject,'String')) returns contents of NBox as a double


% --- Executes during object creation, after setting all properties.
function NBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function overlapBox_Callback(hObject, eventdata, handles)
% hObject    handle to overlapBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of overlapBox as text
%        str2double(get(hObject,'String')) returns contents of overlapBox as a double


% --- Executes during object creation, after setting all properties.
function overlapBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to overlapBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox13.
function checkbox13_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox13


% --- Executes on button press in checkbox14.
function checkbox14_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox14


% --- Executes on button press in checkbox15.
function checkbox15_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox15


% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox9


% --- Executes on button press in checkbox10.
function checkbox10_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox10


% --- Executes on button press in checkbox11.
function checkbox11_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox11


% --- Executes on button press in checkbox12.
function checkbox12_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox12


% --- Executes on button press in gaussButton.
function gaussButton_Callback(hObject, eventdata, handles)
% hObject    handle to gaussButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of gaussButton



function gaussSigmaBox_Callback(hObject, eventdata, handles)
% hObject    handle to gaussSigmaBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gaussSigmaBox as text
%        str2double(get(hObject,'String')) returns contents of gaussSigmaBox as a double


% --- Executes during object creation, after setting all properties.
function gaussSigmaBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gaussSigmaBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in doVignettingCorrectionButton.
function doVignettingCorrectionButton_Callback(hObject, eventdata, handles)
% hObject    handle to doVignettingCorrectionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of doVignettingCorrectionButton



function YBox_Callback(hObject, eventdata, handles)
% hObject    handle to YBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YBox as text
%        str2double(get(hObject,'String')) returns contents of YBox as a double


% --- Executes during object creation, after setting all properties.
function YBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ZBox_Callback(hObject, eventdata, handles)
% hObject    handle to ZBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ZBox as text
%        str2double(get(hObject,'String')) returns contents of ZBox as a double


% --- Executes during object creation, after setting all properties.
function ZBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ZBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cropBox_Callback(hObject, eventdata, handles)
% hObject    handle to cropBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cropBox as text
%        str2double(get(hObject,'String')) returns contents of cropBox as a double


% --- Executes during object creation, after setting all properties.
function cropBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cropBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function XBox_Callback(hObject, eventdata, handles)
% hObject    handle to XBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XBox as text
%        str2double(get(hObject,'String')) returns contents of XBox as a double


% --- Executes during object creation, after setting all properties.
function XBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filenameBox_Callback(hObject, eventdata, handles)
% hObject    handle to filenameBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filenameBox as text
%        str2double(get(hObject,'String')) returns contents of filenameBox as a double


% --- Executes during object creation, after setting all properties.
function filenameBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filenameBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numCharsBox_Callback(hObject, eventdata, handles)
% hObject    handle to numCharsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numCharsBox as text
%        str2double(get(hObject,'String')) returns contents of numCharsBox as a double


% --- Executes during object creation, after setting all properties.
function numCharsBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numCharsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function colorsBox1_Callback(hObject, eventdata, handles)
% hObject    handle to colorsBox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of colorsBox1 as text
%        str2double(get(hObject,'String')) returns contents of colorsBox1 as a double


% --- Executes during object creation, after setting all properties.
function colorsBox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colorsBox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function channelsBox1_Callback(hObject, eventdata, handles)
% hObject    handle to channelsBox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channelsBox1 as text
%        str2double(get(hObject,'String')) returns contents of channelsBox1 as a double


% --- Executes during object creation, after setting all properties.
function channelsBox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channelsBox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function colorsBox2_Callback(hObject, eventdata, handles)
% hObject    handle to colorsBox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of colorsBox2 as text
%        str2double(get(hObject,'String')) returns contents of colorsBox2 as a double


% --- Executes during object creation, after setting all properties.
function colorsBox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colorsBox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function colorsBox3_Callback(hObject, eventdata, handles)
% hObject    handle to colorsBox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of colorsBox3 as text
%        str2double(get(hObject,'String')) returns contents of colorsBox3 as a double


% --- Executes during object creation, after setting all properties.
function colorsBox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colorsBox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function colorsBox4_Callback(hObject, eventdata, handles)
% hObject    handle to colorsBox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of colorsBox4 as text
%        str2double(get(hObject,'String')) returns contents of colorsBox4 as a double


% --- Executes during object creation, after setting all properties.
function colorsBox4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colorsBox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function channelsBox2_Callback(hObject, eventdata, handles)
% hObject    handle to channelsBox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channelsBox2 as text
%        str2double(get(hObject,'String')) returns contents of channelsBox2 as a double


% --- Executes during object creation, after setting all properties.
function channelsBox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channelsBox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function channelsBox3_Callback(hObject, eventdata, handles)
% hObject    handle to channelsBox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channelsBox3 as text
%        str2double(get(hObject,'String')) returns contents of channelsBox3 as a double


% --- Executes during object creation, after setting all properties.
function channelsBox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channelsBox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function channelsBox4_Callback(hObject, eventdata, handles)
% hObject    handle to channelsBox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channelsBox4 as text
%        str2double(get(hObject,'String')) returns contents of channelsBox4 as a double


% --- Executes during object creation, after setting all properties.
function channelsBox4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channelsBox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numembsBox_Callback(hObject, eventdata, handles)
% hObject    handle to numembsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numembsBox as text
%        str2double(get(hObject,'String')) returns contents of numembsBox as a double


% --- Executes during object creation, after setting all properties.
function numembsBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numembsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SigmaXBox_Callback(hObject, eventdata, handles)
% hObject    handle to SigmaXBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SigmaXBox as text
%        str2double(get(hObject,'String')) returns contents of SigmaXBox as a double


% --- Executes during object creation, after setting all properties.
function SigmaXBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SigmaXBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SigmaYBox_Callback(hObject, eventdata, handles)
% hObject    handle to SigmaYBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SigmaYBox as text
%        str2double(get(hObject,'String')) returns contents of SigmaYBox as a double


% --- Executes during object creation, after setting all properties.
function SigmaYBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SigmaYBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function thresholdBox_Callback(hObject, eventdata, handles)
% hObject    handle to thresholdBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thresholdBox as text
%        str2double(get(hObject,'String')) returns contents of thresholdBox as a double


% --- Executes during object creation, after setting all properties.
function thresholdBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thresholdBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filterDiameterBox_Callback(hObject, eventdata, handles)
% hObject    handle to filterDiameterBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filterDiameterBox as text
%        str2double(get(hObject,'String')) returns contents of filterDiameterBox as a double


% --- Executes during object creation, after setting all properties.
function filterDiameterBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filterDiameterBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in segmentCellsCheck.
function segmentCellsCheck_Callback(hObject, eventdata, handles)
% hObject    handle to segmentCellsCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of segmentCellsCheck


% --- Executes on button press in loadCheck.
function loadCheck_Callback(hObject, eventdata, handles)
% hObject    handle to loadCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of loadCheck



function fijiBox_Callback(hObject, eventdata, handles)
% hObject    handle to fijiBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fijiBox as text
%        str2double(get(hObject,'String')) returns contents of fijiBox as a double



% --- Executes during object creation, after setting all properties.
function fijiBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fijiBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in fijiButton.
function fijiButton_Callback(hObject, eventdata, handles)
% hObject    handle to fijiButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[~,fijiDir] = uigetfile;
if fijiDir ~= 0
    handles.var{3} = fijiDir;
    guidata(hObject,handles);
    handles.fijiBox.String = fijiDir;
end



function edit34_Callback(hObject, eventdata, handles)
% hObject    handle to gaussSigmaBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gaussSigmaBox as text
%        str2double(get(hObject,'String')) returns contents of gaussSigmaBox as a double


% --- Executes during object creation, after setting all properties.
function edit34_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gaussSigmaBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
