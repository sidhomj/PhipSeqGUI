function varargout = PhipSeqGUI(varargin)
% PHIPSEQGUI MATLAB code for PhipSeqGUI.fig
%      PHIPSEQGUI, by itself, creates a new PHIPSEQGUI or raises the existing
%      singleton*.
%
%      H = PHIPSEQGUI returns the handle to a new PHIPSEQGUI or the handle to
%      the existing singleton*.
%
%      PHIPSEQGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PHIPSEQGUI.M with the given input arguments.
%
%      PHIPSEQGUI('Property','Value',...) creates a new PHIPSEQGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PhipSeqGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PhipSeqGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PhipSeqGUI

% Last Modified by GUIDE v2.5 23-Jan-2018 14:13:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PhipSeqGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PhipSeqGUI_OutputFcn, ...
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


% --- Executes just before PhipSeqGUI is made visible.
function PhipSeqGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PhipSeqGUI (see VARARGIN)

% Choose default command line output for PhipSeqGUI
handles.output = hObject;
addpath('Functions/');
addpath('tSNE_matlab/');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PhipSeqGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PhipSeqGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in Load_Ref_File.
function Load_Ref_File_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Ref_File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hbox=msgbox('Loading Reference Matrix...');
[filename,folder]=uigetfile({'*.mat'},'Select file');
fileread=strcat(folder,filename);
load(fileread);
details=whos(matfile(fileread));
ref_name=details.name;
eval(['channels=' ref_name '.Properties.VariableNames;'])
for i=1:size(channels,2)
        temp=channels{i};
        temp=strsplit(temp,'s__');
        channels(i)=temp(end);
end
handles.channels=channels(2:end);
eval(['ref = table2array(' ref_name ');']);
handles.peptides=ref(:,1);
handles.ref=ref(:,2:end);
close(hbox)
guidata(hObject,handles);
msgbox('Reference Imported');  


% --- Executes on button press in Load_Samples.
function Load_Samples_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename,folder]=uigetfile({'*.csv'},'Select file','MultiSelect','on');
hbox=msgbox('Loading Data...');
handles.filesoriginal=filename;
n=1;
for i = 1:size(handles.filesoriginal,2)
    file=handles.filesoriginal{i};
    file=strsplit(file,'_');
    ID(n)=file(1);
    n=n+1;
end

ID=unique(ID);
handles.ID_List.String=ID;

for i = 1:size(ID,2)
    Data_Struct(i).ID=ID{i};
    loc=strmatch(ID{i},handles.filesoriginal);
    for j = 1:size(loc,1)
        fileread=strcat(folder,handles.filesoriginal{loc(j)});
        file_check=strsplit(fileread,'/');
        file_check=strsplit(file_check{end},'_');
        file_check=strsplit(file_check{end},'.');
        fid=fopen(fileread);
        data=textscan(fid,repmat('%s',1,2),'delimiter',',');
        fclose(fid);
        Data_Struct(i).Peptides=cellfun(@str2num,data{1,1}(2:end));
        Data_Struct(i).Counts(j).Counts=cellfun(@str2num,data{1,2}(2:end));
        Data_Struct(i).Day(j).Day=file_check{1};
    end
end

handles.Data_Struct=Data_Struct;
handles.ID=ID;
close(hbox);
msgbox('Data Imported!');
guidata(hObject,handles);


% --- Executes on selection change in ID_List.
function ID_List_Callback(hObject, eventdata, handles)
% hObject    handle to ID_List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ID_List contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ID_List


% --- Executes during object creation, after setting all properties.
function ID_List_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ID_List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Gate_Population.
function Gate_Population_Callback(hObject, eventdata, handles)
% hObject    handle to Gate_Population (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fileselect=handles.ID_List.Value;
if isempty(fileselect)
    msgbox('No files selected','Error','error');
    return
end

Gate_PopUp(handles)



% --- Executes on button press in Assign_Samples.
function Assign_Samples_Callback(hObject, eventdata, handles)
% hObject    handle to Assign_Samples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Clear_Assignments.
function Clear_Assignments_Callback(hObject, eventdata, handles)
% hObject    handle to Clear_Assignments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Update_Assignments.
function Update_Assignments_Callback(hObject, eventdata, handles)
% hObject    handle to Update_Assignments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in Viral_Peptide_List.
function Viral_Peptide_List_Callback(hObject, eventdata, handles)
% hObject    handle to Viral_Peptide_List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Viral_Peptide_List contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Viral_Peptide_List


% --- Executes during object creation, after setting all properties.
function Viral_Peptide_List_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Viral_Peptide_List (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in TSNE.
function TSNE_Callback(hObject, eventdata, handles)
% hObject    handle to TSNE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hbox=msgbox('Computing Distance Matrix...')

Peptides_Master=[];
FC_Master=[];
ID_Master=[];
X_Master=[];
n=1;
for i = 1:size(handles.Data_Struct,2)
    peptides=handles.Data_Struct(i).Peptides;
    Peptides_Master=[Peptides_Master;peptides];
    FC=handles.Data_Struct(i).Counts(end).Counts./handles.Data_Struct(i).Counts(1).Counts;
    FC_Master=[FC_Master;FC];
    id=repmat(n,size(peptides,1),1);
    ID_Master=[ID_Master;id];
    c=find(ismember(handles.peptides,peptides));
    values=handles.ref(c,:);
    X_Master=[X_Master;values];
    n=n+1;
end
handles.Peptides_Master=Peptides_Master;
handles.FC_Master=FC_Master;
handles.ID_Master=ID_Master;

%%%Remove channels with all 0's
sel=find(sum(X_Master,1)~=0);
handles.X_Master=X_Master(:,sel);
handles.channels_out = handles.channels(sel);

%%%t-SNE Analysis on high-dimensional matrix based on bit scores

normalizetsne=1;
Y=tsne(handles.X_Master,'Standardize',normalizetsne);
handles.Y=Y;

[colorspec1,colorspec2]=CreateColorTemplate(100);
handles.colorspec1=colorspec1;

clear colorscheme
for i=1:size(ID_Master,1);
    colorscheme(i,:)=colorspec1(ID_Master(i)).spec;
end

scatter(handles.axes1,Y(:,1),Y(:,2),100,colorscheme,'filled','MarkerFaceAlpha',0.75,'MarkerEdgeColor',[0 0 0],'MarkerEdgeAlpha',0.6);

handles.axes1.XTickLabel={};
handles.axes1.YTickLabel={};
handles.tsne_xlim=handles.axes1.XLim;
handles.tsne_ylim=handles.axes1.YLim;

PlotClusterView(handles,Y);
guidata(hObject,handles);


% --- Executes on selection change in HeatMap_TSNE.
function HeatMap_TSNE_Callback(hObject, eventdata, handles)
% hObject    handle to HeatMap_TSNE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns HeatMap_TSNE contents as cell array
%        contents{get(hObject,'Value')} returns selected item from HeatMap_TSNE


% --- Executes during object creation, after setting all properties.
function HeatMap_TSNE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HeatMap_TSNE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
