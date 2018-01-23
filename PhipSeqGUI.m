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

% Last Modified by GUIDE v2.5 23-Jan-2018 18:14:55

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
handles.cluster_alg_list.String={'Hard KMEANS (on t-SNE)','Hard KMEANS (on HD Data)',...
    'DBSCAN','Hierarchical Clustering','Network Graph-Based','Self Organized Map',...
    'GMM - Expectation Minimization','Variational Bayesian Inference for GMM'};
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
hbox=msgbox('t-SNE...')

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
handles.HeatMap_TSNE.String=handles.channels_out;
handles.Sort_By_Menu.String=handles.channels_out;
handles.Threshold_By_Menu.String=handles.channels_out;


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

if log10(max(FC_Master)) == Inf;
    max_new=max(FC_Master(FC_Master~=Inf));
    FC_Master(FC_Master==Inf)=max_new;
end
    
handles.FC_Plot = (log10(FC_Master)/log10(max(FC_Master)))*400;

scatter(handles.axes1,Y(:,1),Y(:,2),handles.FC_Plot,colorscheme,'filled','MarkerFaceAlpha',0.75,'MarkerEdgeColor',[0 0 0],'MarkerEdgeAlpha',0.6);

handles.axes1.XTickLabel={};
handles.axes1.YTickLabel={};
handles.tsne_xlim=handles.axes1.XLim;
handles.tsne_ylim=handles.axes1.YLim;

PlotClusterView(handles,Y);
guidata(hObject,handles);
close(hbox);


% --- Executes on selection change in HeatMap_TSNE.
function HeatMap_TSNE_Callback(hObject, eventdata, handles)
% hObject    handle to HeatMap_TSNE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns HeatMap_TSNE contents as cell array
%        contents{get(hObject,'Value')} returns selected item from HeatMap_TSNE

contents=cellstr(get(hObject,'String'));
sel=get(hObject,'Value');
Y=handles.Y;
channel=handles.X_Master(:,sel);

cutofftop=prctile(channel,100);
cutoffbottom=prctile(channel,0);
replace=(channel>cutofftop);
channel(replace)=cutofftop;
replace=channel<cutoffbottom;
channel(replace)=cutoffbottom;


figure('Name',contents{sel},'NumberTitle','off');
scatter(Y(:,1),Y(:,2),handles.FC_Plot,channel,'filled');
colormap('jet');
title(contents(sel),'FontSize',10,'Interpreter','none')


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


% --- Executes on button press in save_axes_1.
function save_axes_1_Callback(hObject, eventdata, handles)
% hObject    handle to save_axes_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path,filetype]=uiputfile({'*.bmp','BMP';'*.jpeg','JPEG';'*.png','PNG'},'Save Image As');
F=getframe(handles.axes1);
Image=frame2im(F);
imwrite(Image,strcat(path,file));


% --- Executes on button press in save_axes_2.
function save_axes_2_Callback(hObject, eventdata, handles)
% hObject    handle to save_axes_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path,filetype]=uiputfile({'*.bmp','BMP';'*.jpeg','JPEG';'*.png','PNG'},'Save Image As');
F=getframe(handles.axes2);
Image=frame2im(F);
imwrite(Image,strcat(path,file));


% --- Executes on button press in Load_Workspace.
function Load_Workspace_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Workspace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path,filetype]=uigetfile({'*.mat','MAT'});
load(strcat(path,file),'handles');
currentobjects=findall(0);

n=1;
for i=1:size(currentobjects,1);
    try
    nametemp=currentobjects(i).Name;
    indx(n)=i;
    n=n+1;
    catch
        continue
    end
end

close(currentobjects(indx(end)));


% --- Executes on button press in Save_Workspace.
function Save_Workspace_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Workspace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path,filetype]=uiputfile({'*.mat','MAT'});
hbox=msgbox('Saving Workspace...');
save(strcat(path,file),'handles');
close(hbox);

% --- Executes on button press in Cluster.
function Cluster_Callback(hObject, eventdata, handles)
% hObject    handle to Cluster (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Y=handles.Y;
ClusterMethod=handles.cluster_alg_list.Value;
clusterparameter=str2num(handles.cluster_parameter.String);

switch ClusterMethod

    case 1
        
        hbox=msgbox('Clustering Events...');
        num_clusters=clusterparameter;
        idx=kmeans(Y,num_clusters,'Start','uniform');
    case 2
        
        hbox=msgbox('Clustering Events...');
        num_clusters=clusterparameter;
        idx=kmeans(handles.X_Master,num_clusters,'Start','uniform');
    
    case 3
        hbox=msgbox('Clustering Events...');
        epsilonf=clusterparameter/100;
        D=pdist(Y);
        epsilon=(epsilonf)*median(D); %.02 default
        MinPoints=1;%(0.0001)*size(Y,1); %.0001 default
        [idx,isnoise]=DBSCAN(Y,epsilon,MinPoints);
        num_clusters=max(idx);
    case 4
        hbox=msgbox('Clustering Events...');
        dm=pdist(handles.X_Master);
        z=linkage(dm);
        idx=cluster(z,'cutoff',clusterparameter);
        num_clusters=max(idx);
    case 5
        NetworkGui(handles);
        waitfor(findobj('Tag','networkgui'));
        
        hbox=msgbox('Creating Graph...');
        [G,GGraph]=CreateGraph(handles.X_Master,clusterparameter);
        close(hbox);
        
        handles=guidata(findobj('Tag','clusterbutton'));
     
        switch handles.graphclustermethod  
            case 1      
                hbox=msgbox('Clustering Events...');
                N=length(G);
                W=PermMat(N);                     % permute the graph node labels
                A=W*G*W';
                
                [COMTY ending] = cluster_jl_cppJW(A,1);
                J=size(COMTY.COM,2);
                VV=COMTY.COM{J}';
                idx=W'*VV;      
                              
            case 2
                hbox=msgbox('Clustering Events...');
                idx=GCModulMax2(G); 
            case 3
                hbox=msgbox('Clustering Events...');
                idx=GCModulMax3(G);
            case 4
                hbox=msgbox('Clustering Events...');
                idx=GCDanon(G);
            case 5
                clusterparameter2=inputdlg('Enter # of Clusters');
                hbox=msgbox('Clustering Events...');
                clusterparameter2=str2num(clusterparameter2{1});
                idx=GCSpectralClust1(G,clusterparameter2);
                idx=idx(:,clusterparameter2);
                
        end
        num_clusters=max(idx);
    case 6
        hbox=msgbox('Clustering Events...');
        net=selforgmap([round(sqrt(clusterparameter)),round(sqrt(clusterparameter))]);
        net.trainParam.showWindow = false;
        net=train(net,transpose(handles.X_Master));
        idx=transpose(vec2ind(net(transpose(handles.X_Master))));
        num_clusters=max(idx);
    case 7
        hbox=msgbox('Clustering Events...');
        try 
         idx=transpose(mixGaussEm(transpose(handles.X_Master),clusterparameter));
        num_clusters=max(idx); 
        catch
            msgbox('Enter smaller # of Clusters');
        end
        
    case 8
        hbox=msgbox('Clustering Events...');
        try
        idx=transpose(mixGaussVb(transpose(handles.X_Master),clusterparameter));
        num_clusters=max(idx);
        catch
            msgbox('Enter smaller # of Clusters');
        end
        
        end
    close(hbox);
    
    [colorspec1,colorspec2]=CreateColorTemplate(num_clusters);
    handles.colorspec1=colorspec1;
    
    clear colorscheme
    for i=1:size(idx,1);
        colorscheme(i,:)=colorspec1(idx(i)).spec;
    end
    PlotClusterView(handles,Y,colorscheme);
 
    y=handles.X_Master;
    ClusterContrib=tabulate(idx);
    
    for i=1:num_clusters
        ClusterNames(i)=strcat('Cluster ',num2str(i),{' - '},num2str(ClusterContrib(i,3)),{'%'});
    end

    [HeatMapData,RowLabels,SizeCluster]=GetHeatMapData(num_clusters,idx,y,ClusterMethod,ClusterContrib);
    
    handles.Cluster_Selection_Listbox.String=ClusterNames;
    handles.idx=idx; 
    handles.ClusterContrib=ClusterContrib;
    handles.num_clusters=num_clusters;
    handles.HeatMapData=HeatMapData;
    handles.RowLabels=RowLabels;
    handles.SizeCluster=SizeCluster;
    handles.I=[1:num_clusters];
    handles.Imod=handles.I;
    guidata(hObject,handles);
    datacursormode on
    dcm_obj=datacursormode(handles.axes2.Parent);
    set(dcm_obj,'UpdateFcn',{@myupdatefcn,idx,Y})


% --- Executes on button press in Clear_Clusters.
function Clear_Clusters_Callback(hObject, eventdata, handles)
% hObject    handle to Clear_Clusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in Threshold_Listbox.
function Threshold_Listbox_Callback(hObject, eventdata, handles)
% hObject    handle to Threshold_Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Threshold_Listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Threshold_Listbox


% --- Executes during object creation, after setting all properties.
function Threshold_Listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Threshold_Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in HeatMap_Events.
function HeatMap_Events_Callback(hObject, eventdata, handles)
% hObject    handle to HeatMap_Events (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in HeatMap_Clusters.
function HeatMap_Clusters_Callback(hObject, eventdata, handles)
% hObject    handle to HeatMap_Clusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in Cluster_Selection_Listbox.
function Cluster_Selection_Listbox_Callback(hObject, eventdata, handles)
% hObject    handle to Cluster_Selection_Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Cluster_Selection_Listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Cluster_Selection_Listbox


% --- Executes during object creation, after setting all properties.
function Cluster_Selection_Listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cluster_Selection_Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Cluster_Analyze_Listbox.
function Cluster_Analyze_Listbox_Callback(hObject, eventdata, handles)
% hObject    handle to Cluster_Analyze_Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Cluster_Analyze_Listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Cluster_Analyze_Listbox


% --- Executes during object creation, after setting all properties.
function Cluster_Analyze_Listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cluster_Analyze_Listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Select_Cluster_Button.
function Select_Cluster_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Select_Cluster_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Remove_Cluster_Button.
function Remove_Cluster_Button_Callback(hObject, eventdata, handles)
% hObject    handle to Remove_Cluster_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in Sort_By_Menu.
function Sort_By_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Sort_By_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Sort_By_Menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Sort_By_Menu

handles=SortClusters(handles);
handles=ApplyCurrentThresh(handles);
handles=ClusterCut(handles);
PlotSelectClusters(handles);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function Sort_By_Menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sort_By_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Threshold_By_Menu.
function Threshold_By_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Threshold_By_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Threshold_By_Menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Threshold_By_Menu


% --- Executes during object creation, after setting all properties.
function Threshold_By_Menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Threshold_By_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

contents=cellstr(get(hObject,'String'));
Value=contents{get(hObject,'Value')};
Threshold_GUI(handles,Value);


function Frequency_Cut_Callback(hObject, eventdata, handles)
% hObject    handle to Frequency_Cut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Frequency_Cut as text
%        str2double(get(hObject,'String')) returns contents of Frequency_Cut as a double

handles=SortClusters(handles);
handles=ApplyCurrentThresh(handles);
handles=ClusterCut(handles);
PlotSelectClusters(handles)
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function Frequency_Cut_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Frequency_Cut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Sort_Toggle.
function Sort_Toggle_Callback(hObject, eventdata, handles)
% hObject    handle to Sort_Toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Sort_Toggle
if get(hObject,'Value')
    handles.Sort_Toggle.String='Ascending';
else
    handles.Sort_Toggle.String='Descending';
end

Sort_By_Menu_Callback(hObject, eventdata, handles);


% --- Executes on button press in Clear_Thresholds.
function Clear_Thresholds_Callback(hObject, eventdata, handles)
% hObject    handle to Clear_Thresholds (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Select_Clusters.
function Select_Clusters_Callback(hObject, eventdata, handles)
% hObject    handle to Select_Clusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dcm_obj=datacursormode(handles.axes2.Parent);
set(dcm_obj,'Enable','off');

if ~isfield(handles,'ManualClusterCount')
    if isfield(handles,'idx')
        handles=rmfield(handles,'idx');
        handles=rmfield(handles,'colorspec1');
    end
    [colorspec1,colorspec2]=CreateColorTemplate(100);
    handles.colorspec1=colorspec1;
    handles.Cluster_Selection_Listbox.String={};
    Y=handles.Y;
    scatter(handles.axes2,Y(:,1),Y(:,2),'filled');
    handles.axes2.XTickLabel={};
    handles.axes2.YTickLabel={};
    hold(handles.axes2)
    handles.ManualClusterCount=1;
    I=1;
else
    Y=handles.Y;
    handles.ManualClusterCount=handles.ManualClusterCount+1;
    colorspec1=handles.colorspec1;
    idx=handles.idx;
    I=handles.I;
    I=[I,I(end)+1];
    handles.I=I;
    handles.Imod=I;
    ClusterContrib=handles.ClusterContrib;
end

sel=selectdata('SelectionMode','Lasso','Verify','on');
if handles.ManualClusterCount~=1
    sel=sel{handles.ManualClusterCount};
end
in=zeros(size(handles.Y,1),1);
in(sel)=1;
in=logical(in);
Yplot=handles.Y(in,:);
%hold(handles.cluster_view);
scatter(handles.axes2,Yplot(:,1),Yplot(:,2),[],colorspec1(handles.ManualClusterCount).spec,'filled');
handles.axes2.XLim=handles.tsne_xlim;
handles.axes2.YLim=handles.tsne_ylim;
hold(handles.axes2);

ClusterContrib(handles.ManualClusterCount,1)=handles.ManualClusterCount;
ClusterContrib(handles.ManualClusterCount,2)=sum(in);
ClusterContrib(handles.ManualClusterCount,3)=100*(sum(in)/size(in,1));
handles.ClusterContrib=ClusterContrib;

sortedlist=cell(1,size(I,2));
for i=1:size(I,2);
    sortedlist(i)=strcat({'Cluster '},num2str(I(i)),{' - '},num2str(ClusterContrib(I(i),3)),{'%'});
end


if handles.ManualClusterCount==1;
    handles.Cluster_Selection_Listbox.Value=[];
    handles.Cluster_Selection_Listbox.String=sortedlist;
    handles.idx=double(in);
    handles.I=I;
    handles.Imod=I;
else
    p=handles.ManualClusterCount;
    idx=handles.idx+p*double(in);
    handles.idx=double(idx);
    handles.Cluster_Selection_Listbox.Value=[];
    handles.Cluster_Selection_Listbox.String=sortedlist;
    handles=HeatMap_CallbackManual(hObject, eventdata, handles);
end

guidata(hObject,handles);


% --- Executes on selection change in cluster_alg_list.
function cluster_alg_list_Callback(hObject, eventdata, handles)
% hObject    handle to cluster_alg_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns cluster_alg_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from cluster_alg_list
%        contents{get(hObject,'Value')} returns selected item from clustermethods

sel=handles.cluster_alg_list.Value;
if ismember(sel,[1 2 6 7 8])
    set(handles.cluster_parameter,'String','# of Clusters');
elseif ismember(sel,[3 4])
    set(handles.cluster_parameter,'String','Distance Factor');
elseif ismember(sel,[5])
    set(handles.cluster_parameter,'String','k-nearest neighbors');
end
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function cluster_alg_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cluster_alg_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cluster_parameter_Callback(hObject, eventdata, handles)
% hObject    handle to cluster_parameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cluster_parameter as text
%        str2double(get(hObject,'String')) returns contents of cluster_parameter as a double


% --- Executes during object creation, after setting all properties.
function cluster_parameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cluster_parameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
