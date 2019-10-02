function varargout = ui(varargin)
% UI MATLAB code for ui.fig
%      UI, by itself, creates a new UI or raises the existing
%      singleton*.
%
%      H = UI returns the handle to a new UI or the handle to
%      the existing singleton*.
%
%      UI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UI.M with the given input arguments.
%
%      UI('Property','Value',...) creates a new UI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ui

% Last Modified by GUIDE v2.5 10-Apr-2019 00:26:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ui_OpeningFcn, ...
                   'gui_OutputFcn',  @ui_OutputFcn, ...
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


% --- Executes just before ui is made visible.
function ui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ui (see VARARGIN)

% Choose default command line output for ui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in browse.
function browse_Callback(hObject, eventdata, handles)
global signal  
global fs
[filename,~] =uigetfile ( {'*.wav','*.mp3'} , 'Select File' ) ; 
[signal,fs] = audioread ( filename ) ;
axes(handles.signalGraph)
signal = signal(:,1);
plot(signal)


% --- Executes on button press in play.
function play_Callback(hObject, eventdata, handles)
global signal
global fs
global player
player = audioplayer(signal,fs)
play(player)

% --- Executes on button press in stop.
function stop_Callback(hObject, eventdata, handles)
global player
stop(player)


% --- Executes on button press in pause.
function pause_Callback(hObject, eventdata, handles)
global player
pause(player)


% --- Executes on button press in resume.
function resume_Callback(hObject, eventdata, handles)
global player
resume (player)


% --- Executes on button press in spectrogrambtn.
function spectrogrambtn_Callback(hObject, eventdata, handles)
global signal
global fs
axes(handles.spectrogram)
spec = spectrogram(signal, 1024, 3/4*1024, [], fs, 'yaxis');
spectrogram(signal, 1024, 3/4*1024, [], fs, 'yaxis');
box on
xlabel('Time')
ylabel('Frequency, Hz')
title('Spectrogram of the signal')
h = colorbar;
ylabel(h, 'Magnitude, dB')

A0 = 27.5; %lowest piano note frequency A0 = 27.5 Hz
keys = 0:87; % 88 keys of a piano
center = A0*2.^((keys)/12); % set filter center frequencies
left = A0*2.^((keys-1)/12); % left frequency
left = (left+center)/2.0;
right = A0*2.^((keys+1)/12); % right frequency
right = (right+center)/2;

% Construct a filter bank
filter = zeros(numel(center),1024/2+1); % place holder
freqs = linspace(0,fs/2,1024/2+1); % array of frequencies in spectrogram
for i = 1:numel(center)
    xTemp = [0,left(i),center(i),right(i),fs/2]; % create points for filter bounds
    yTemp = [0,0,1,0,0]; % set magnitudes at each filter point
    filter(i,:) = interp1(xTemp,yTemp,freqs); % use interpolation to get values for   frequencies
end

% multiply filter by spectrogram to get chroma values.
chroma = filter*abs(spec);

%Put into 12 bin chroma to reflect our 12 chords
chroma12 = zeros(12,size(chroma,2));
for i = 1:size(chroma,1)
    bin = mod(i,12)+1; % get modded index
    chroma12(bin,:) = chroma12(bin,:) + chroma(i,:); % add octaves together
end

t = [1:size(chroma12,2)]*1024/4/fs;
axes(handles.chromagram)
imagesc(t,[1:12],20*log10(chroma12)); %image scale color
axis xy
caxis(max(caxis)+[-60 0]) %color map limits
yticks([1 2 3 4 5 6 7 8 9 10 11 12])
yticklabels({'C','C#','D','D#','E','F','F#','G','G#','A','A#','B'})
title('Chromagram')
