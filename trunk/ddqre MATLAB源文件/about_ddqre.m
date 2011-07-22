function varargout = about_ddqre(varargin)
% ABOUT_DDQRE M-file for about_ddqre.fig
%      ABOUT_DDQRE, by itself, creates a new ABOUT_DDQRE or raises the existing
%      singleton*.
%
%      H = ABOUT_DDQRE returns the handle to a new ABOUT_DDQRE or the handle to
%      the existing singleton*.
%
%      ABOUT_DDQRE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ABOUT_DDQRE.M with the given input arguments.
%
%      ABOUT_DDQRE('Property','Value',...) creates a new ABOUT_DDQRE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before about_ddqre_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to about_ddqre_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help about_ddqre

% Last Modified by GUIDE v2.5 26-Jul-2008 23:04:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @about_ddqre_OpeningFcn, ...
                   'gui_OutputFcn',  @about_ddqre_OutputFcn, ...
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


% --- Executes just before about_ddqre is made visible.
function about_ddqre_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to about_ddqre (see VARARGIN)

% Choose default command line output for about_ddqre
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes about_ddqre wait for user response (see UIRESUME)
% uiwait(handles.about_ddqre);


% --- Outputs from this function are returned to the command line.
function varargout = about_ddqre_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
