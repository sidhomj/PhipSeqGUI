function Threshold_GUI(handles,Value)
positiongui=handles.figure1.Parent.PointerLocation;

fh = figure('units','pixels',...
              'units','normalized',...
              'position',[0.25 0.25 .3 .6],...
              'menubar','none',...
              'name','Define Threshold',...
              'numbertitle','off',...
              'resize','off');

guidata(fh,handles);

handles.Value=Value;

h=axes('Parent',fh,'Position',[0.05 0.1 0.55 0.8]);
h.XTickLabel={};
h.YTickLabel={};
handles.h=h;

sld = uicontrol('Parent',fh,'Style','slider',...
        'Min',0,'Max',1,'Value',0.5,...
        'units','normalized',...
        'Position', [0.65 0.1 0.05 0.8],...
        'Callback', @slider,...
        'Tag','slider1'); 

handles.sld=sld;

thresholdval=uicontrol('Parent',fh,'Style','edit',...
    'String','Threshold Value',...
    'units','normalized',...
    'Position',[.1,.03,0.2,0.05],...
    'Callback',@thresholdvaluetag,...
    'Tag','thresholdvalue');

handles.thresholdval=thresholdval;

addabovevar=uicontrol('Style','push',...
    'String','Add Above Threshold',...
    'units','normalized',...
    'Position',[0.75,.65,.2,.1],...
    'Tag','addabove',...
    'Callback',@addabove);

handles.addabove=addabovevar;

addbelowvar=uicontrol('Style','push',...
'String','Add Below Threshold',...
'units','normalized',...
'Position',[.75,.45,0.2,0.1],...
'Tag','addbelow',...
'Callback',@addbelow);

handles.addbelow=addbelowvar;

title=uicontrol('Style','text',...
    'String',handles.Threshold_By_Menu.String{handles.Threshold_By_Menu.Value},...
    'units','normalized',...
    'Position',[.225,.925,0.2,0.05],...
    'FontSize',16);

y=handles.X_Master;
clusterselect2=y;
r=normrnd(1,0.15,size(clusterselect2,1),1);
index=strmatch(Value,handles.channels_out,'exact');
axes(h);
dscatter(r,clusterselect2(:,index));
h.XTickLabel={};
h.XLim=[0,2];
dataquery=clusterselect2(:,index);
h.YLim=[prctile(dataquery,0),prctile(dataquery,100)];
guidata(fh,handles);
end

    
function thresholdvaluetag(hObject, eventdata)
    % hObject    handle to thresholdvaluetag (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of thresholdvaluetag as text
    %        str2double(get(hObject,'String')) returns contents of thresholdvaluetag as a double
    handles=guidata(hObject);
    if isfield(handles,'line')
        delete(handles.line);
    end
    linepos=str2num(get(hObject,'String'));
    h=imline(handles.h,[-10 10],[linepos linepos]);
    handles.line=h;
    handles.sld.Value=linepos/5;
    guidata(hObject,handles);
end

function slider(hObject, eventdata)
    % hObject    handle to slider3 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'Value') returns position of slider
    %        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    handles=guidata(hObject);
    if isfield(handles,'line')
        delete(handles.line);
    end
    index=strmatch(handles.Value,handles.channels_out,'exact');
    
    dataquery=handles.X_Master(:,index);
    up=prctile(dataquery,100);
    down=prctile(dataquery,0);
    factor=(up-down);
    linepos=get(hObject,'Value')*factor+down;
   
    h=imline(handles.h,[-10 10],[linepos linepos]);
    handles.line=h;
    hpos=getPosition(h);
    handles.thresholdcurrent=hpos(1,2);
    handles.thresholdval.String=num2str(handles.thresholdcurrent);
    guidata(hObject,handles);
end

        
function addabove(hObject,eventdata)
    handles=guidata(hObject);
    handles=SortClusters(handles);
    thresholdvalue=str2num(handles.thresholdval.String);
    channelselstring=handles.Value;

    if ~isfield(handles,'threshold_count')
        handles.thresholdbook(1).Channel=channelselstring;
        handles.thresholdbook(1).threshold=thresholdvalue;
        handles.thresholdbook(1).direction='>';
        handles.Threshold_Listbox.String=strcat(channelselstring,{' , '},num2str(thresholdvalue),{' , '},'>');
        handles.threshold_count=1;
    else
        currentlist=handles.Threshold_Listbox.String;
        count=handles.threshold_count;
        handles.thresholdbook(count+1).Channel=channelselstring;
        handles.thresholdbook(count+1).threshold=thresholdvalue;
        handles.thresholdbook(count+1).direction='>';
        currentlist=[currentlist;strcat(channelselstring,{' , '},num2str(thresholdvalue),{' , '},'>')];
        handles.Threshold_Listbox.String=currentlist;
        handles.threshold_count=count+1;
    end
    handles=ApplyCurrentThresh(handles);
    handles=ClusterCut(handles);
    guidata(findobj('Tag','Threshold_By_Menu'),handles);
    closereq
end
        
function addbelow(hObject,eventdata)
    handles=guidata(hObject);
    handles=SortClusters(handles);
    thresholdvalue=str2num(handles.thresholdval.String);
    channelselstring=handles.Value;

    if ~isfield(handles,'threshold_count')
        handles.thresholdbook(1).Channel=channelselstring;
        handles.thresholdbook(1).threshold=thresholdvalue;
        handles.thresholdbook(1).direction='<';
        handles.Threshold_Listbox.String=strcat(channelselstring,{' , '},num2str(thresholdvalue),{' , '},'<');
        handles.threshold_count=1;
    else
        currentlist=handles.threshlist.String;
        count=handles.threshold_count;
        handles.thresholdbook(count+1).Channel=channelselstring;
        handles.thresholdbook(count+1).threshold=thresholdvalue;
        handles.thresholdbook(count+1).direction='<';
        currentlist=[currentlist;strcat(channelselstring,{' , '},num2str(thresholdvalue),{' , '},'<')];
        handles.Threshold_Listbox.String=currentlist;
        handles.threshold_count=count+1;
    end
    handles=ApplyCurrentThresh(handles);
    handles=ClusterCut(handles);
    guidata(findobj('Tag','Threshold_By_Menu'),handles);
    closereq
end

