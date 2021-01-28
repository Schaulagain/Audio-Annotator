function varargout = Annotator(varargin)
% ANNOTATOR MATLAB code for Annotator.fig
%      ANNOTATOR, by itself, creates a new ANNOTATOR or raises the existing
%      singleton*.
%
%      H = ANNOTATOR returns the handle to a new ANNOTATOR or the handle to
%      the existing singleton*.
%
%      ANNOTATOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANNOTATOR.M with the given input arguments.
%
%      ANNOTATOR('Property','Value',...) creates a new ANNOTATOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Annotator_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Annotator_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Annotator

% Last Modified by GUIDE v2.5 07-Aug-2020 12:52:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Annotator_OpeningFcn, ...
                   'gui_OutputFcn',  @Annotator_OutputFcn, ...
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


% --- Executes just before Annotator is made visible.
function Annotator_OpeningFcn(hObject, ~, handles, varargin)

% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Annotator (see VARARGIN)

% Choose default command line output for Annotator
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Annotator wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

%Declaring Global Variables
global sr; %For the default sample rate
global changeSpeed; %for checking the speed
global play1 %For the play session in the main player
global play2 %For the play session in the background player
global track1 %Checking if the main track is loaded 
global track2 %Checking if the secondary track is loaded
global info1 %Details about main track
global info2 %Details about secondary track
global pause1
global pause2

%Default Values to the declaration at the start of program
sr = 47000;
changeSpeed = false;
play1 = false;
play2 = false;
track1 = false;
track2 = false;
info1 = 0;
info2 = 0;
pause1= false;
pause2= false;
   %Functions
function playaudio(audio2)%Function for playing audio track on both players
    if audio2 == 1
    global main;
    global play1;
    global track1;
    global pause1;
    if ~play1 && track1
        resume(main);
        play1 = true;
        pause1 = false;
    end
    elseif audio2 == 2
        global bg;
        global play2;
        global track2;
        global pause2;
        if track2 && ~play2
            resume(bg);
            play2 = true;
            pause2 = false;
        end
    end
function pauseaudio(audio2)
    if audio2 == 1
    global main;
    global play1;
    global volume1;
    
    play1 = false;
    pause1 = true;
    pause(main);
elseif audio2 == 2
    global bg;
    global play2;
    global volume2;
    
    play2 = false;
    pause2 = true;
    pause(bg);
    end
function stopaudio(handles,audio2)
    if audio2 == 1
    global track1;
    global main;
    global play1;
    global pause1;
    if audio2
        play1 = false;
        pause1 = false;
        stop(main);
        set(handles.pslider1, 'VALUE', get(handles.pslider1, 'MIN'));
        set(handles.text12, 'String', round(handles.text12.Value, 1)); 
    end
elseif audio2 == 2
    global track2;
    global bg;
    global play2;
    global pause2;  
    if audio2 %if track2 has been loaded execute code.
        play2 = false;
        pause2 = false;
        stop(bg);
        set(handles.pslider2, 'VALUE', get(handles.pslider2, 'MIN')); 
        set(handles.text13, 'String', round(handles.text13.Value, 1)); 
    end
    end
function loadFile(handles, audio2) 


global sr;
global changeSpeed;
[fileName,pathName] = uigetfile( ...
{'*.wav;*.mp3',...
'Audio Files (*.wav,*.mp3)'; ...
'*wav', 'WAV(*.wav)';...
'*mp3', 'MP3(*.mp3)';},...
'Select file'); 

if fileName
    [snd,FS]=audioread(fullfile(pathName, fileName));
    if audio2 == 1
        global info1;
        global main;
        global play1;
        play1 = false;
        global pause1;
        pause1 = false;
        global track1;
        track1 = true;
        set(handles.filelink1,'String',[pathName fileName]); 
         if FS ~= sr 
             [A,B] = rat(sr/FS); 
             info1 = resample(snd,A,B); 
         else
             info1 = snd;
         end 
        main = audioplayer(info1,sr); 
        set(main,'TimerFcn',{@timerUpdate,audio2, handles}, 'TimerPeriod', 0.1, 'StopFcn',{@songfinish, audio2, handles}); 
        
        updateUI(info1,sr,handles,audio2); 
    elseif audio2 == 2
        global info2;
        global bg;
        global play2;
        play2 = false;
        global pause2;
        pause2 = false;
        global track2;
        track2 = true;
        set(handles.filelink2,'String',[pathName fileName]);  
        if FS ~= sr 
            [A,B] = rat(sr/FS); 
            info2 = resample(snd,A,B); 
        else
             info2 = snd;
        end  
        bg = audioplayer(info2,sr);
        set(bg,'TimerFcn',{@timerUpdate,audio2, handles}, 'TimerPeriod', 0.1, 'StopFcn',{@songfinish, audio2, handles});      
        updateUI(info2,sr,handles,audio2); 
    end
    if(changeSpeed) 
        resetSpeed(handles);
    end
end
function songfinish(~,~,audio2, handles) 
global play1;
global play2;

if audio2 == 1
    if play1 == true 
        play1 = false;
        set(handles.pslider1, 'VALUE', get(handles.pslider1, 'MIN')); 
        if get(handles.loop1, 'Value') == true 
            playaudio(1);
        end
    end
elseif audio2 == 2
    if play2 == true 
        play2 = false;
        set(handles.pslider2, 'VALUE', get(handles.pslider2, 'MIN')); 
        if get(handles.loop2, 'value') == true 
            playaudio(2);
        end
    end
end
function updateUI(snd, FS, handles, audio2)
time=round((1/FS)*length(snd),1); 
if audio2 == 1
    axes = handles.plot1;
    slider = handles.pslider1;
    set(handles.islider, 'MAX', time); 
    set(handles.islider, 'VALUE', 0);
    set(handles.islider, 'MIN', 0);
elseif audio2 == 2
    axes = handles.plot2;
    slider = handles.pslider2;
end
t=linspace(0,time,length(snd)); 
plot(axes,t,snd); 
axesLabels(axes); 
set(slider, 'MAX', time);
set(slider, 'VALUE', 0);
set(slider, 'MIN', 0);
function timerUpdate(~,~,audio2, handles)
global sr;
if audio2 == 1
    global main;
    global info1;
    
    slider = handles.pslider1;
    text = handles.text12;
    time = round(main.CurrentSample / sr,1); 
    snd = info1;   
elseif audio2 == 2
    global bg;
    global info2; 
    slider = handles.pslider2;
    text = handles.text13;
    time = round(bg.CurrentSample / sr,1); 
    snd = info2;
end
finalTime = get(slider, 'MAX');
if time < finalTime
    set(slider, 'VALUE', time); 
    set(text, 'String', time);
else 
   set(slider, 'VALUE', finalTime); 
   set(text, 'String', finalTime);
   updateUI(snd,sr,handles,audio2);
end
function axesLabels(hObject)

axes = hObject;
axes.YLabel.String = 'Strength';
axes.XLabel.String = 'Sec';
function changeRate(handles, sampleMultiplier)
global info2;
global sr;
global main;
global bg;
global play1;
global play2;
global track1;
global track2;
global changeSpeed;
changeSpeed = true;
continue1 = play1; 
continue2 = play2;
nr = sr * sampleMultiplier; 
if(track1) 
    main = audioplayer(info1, nr);
    set(main,'TimerFcn',{@timerUpdate,1, handles}, 'TimerPeriod', 0.1, 'StopFcn',{@songfinish, 1, handles});
    stopaudio(handles,1); 
    if(continue1)
        playaudio(1);
    end
end
if(track2)
    bg = audioplayer(info2, nr); 
    set(bg,'TimerFcn',{@timerUpdate,2, handles}, 'TimerPeriod', 0.1, 'StopFcn',{@songfinish, 2, handles});
    stopaudio(handles,2); 
    if(continue2) 
        playaudio(2);
    end
end
function resetSpeed(handles)

global changeSpeed;
if(changeSpeed)
    changeRate(handles, 1); 
    set(handles.sslider, 'Value', 1);
end
changeSpeed = false;
function combineTracks(handles)
global track1;
global track2;
global main;
global bg;
global info1;
global info2;

if track1 && track2 
    if get(bg, 'nc') == 1 
        
        data2temp = [info2 info2];
    else
        data2temp = info2;
    end
    if get(main, 'nc') == 1
        
        info1 = [info1 info1];
    end
    stopaudio(handles,1);
    stopaudio(handles,2);
    snd1=get(main,'ts');
    FS1=get(main,'sr');
   
    snd2=get(bg,'ts');
    
    inserttext=round(get(handles.islider,'value')) * FS1; 
    
    if (snd2+inserttext) > snd1 
        
        toBeAdded = snd2+inserttext-snd1; 
        silence = zeros(toBeAdded,2); 
        info1 = [info1 ; silence];  
    end
    
    toBeAddedPre = inserttext; 
    silencePre = zeros(toBeAddedPre,2); 
        
    if (snd2+inserttext) < snd1 
        
        toBeAddedPost = snd1 - inserttext - snd2; 
        silencePost = zeros(toBeAddedPost,2); 
        data2Manip = [silencePre ; data2temp ; silencePost]; 
    else 
        data2Manip = [silencePre ; data2temp];
    end
    
    info1 = info1 + data2Manip; 
    main = audioplayer(info1,FS1);
    set(main,'TimerFcn',{@timerUpdate,1, handles}, 'TimerPeriod', 0.1, 'StopFcn',{@songfinish, 1, handles}); 
    updateUI(info1,FS1,handles,1); 
function saveTrack()

global info1;
global track1;
global sr;

if track1 %if track 1 is loaded
    folderName = uigetdir('','Select a folder to save into'); 
    if folderName
        fileName = inputdlg('Enter a file name:',... 
                     'choose file name', [1 50]);
        if length(fileName) == 1 
            path = strcat(folderName,'\',fileName,'.wav'); 
            if exist(path{1}, 'file') == 2 
                cn = questdlg('That file exists. Overwrite?','File exists','Yes','No','No');
                 if strcmp(cn,'Yes') 
                    audiowrite(path{1},info1,sr);
                 end
            else
                audiowrite(path{1},info1,sr); 
            end
        end
    end
end

function varargout = Annotator_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;
function Play1_Callback(~, eventdata, handles)
playaudio(1);
function play2_Callback(hObject, eventdata, handles)
playaudio(2);
function pause1_Callback(hObject, eventdata, handles)
pauseaudio(1);
function pause2_Callback(hObject, eventdata, handles)
pauseaudio(2);
function stop1_Callback(~, eventdata, handles)
stopaudio(handles,1);
function stop2_Callback(hObject, eventdata, handles)
stopaudio(handles,2);
function volumes1_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function volumes1_Callback(~, eventdata, handles)
volume(handles,1);
function volumes2_Callback(~, eventdata, handles)
volume(handles,2);
function volumes2_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function pslider1_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function pslider2_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function islider_Callback(hObject, eventdata, handles)
addlistener(handles.islider,'Value','PostSet',@(s,e) set(handles.inserttext, 'String', round(handles.islider.Value, 1)));
function islider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function mergeb_Callback(hObject, eventdata, handles)
combineTracks(handles);
function exportb_Callback(hObject, eventdata, ~)
saveTrack();
function sslider_Callback(hObject, eventdata, handles)
addlistener(handles.sslider,'Value','PostSet',@(s,e) set(handles.slabel, 'String', round(handles.sslider.Value, 1)));
changeRate(handles,get(handles.sslider, 'Value')); %Call changeRate function to change the track's speed.
function sslider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function restorebutton_Callback(hObject, eventdata, handles)
resetSpeed(handles);
function plot1_CreateFcn(hObject, eventdata, handles)
axesLabels(hObject);
function plot2_CreateFcn(hObject, eventdata, handles)
axesLabels(hObject);
function loop2_Callback(hObject, eventdata, handles)
function loop1_Callback(hObject, eventdata, handles)
function Browse2_Callback(hObject, eventdata, handles)
loadFile(handles,2);
function Browse1_Callback(hObject, eventdata, handles)
loadFile(handles,1);


% --- Executes during object creation, after setting all properties.
function Browse1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Browse2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function Browse2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Browse2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
