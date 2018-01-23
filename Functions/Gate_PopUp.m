function Gate_PopUp(handles)

fileselect=handles.ID_List.Value;
positiongui=handles.figure1.Parent.PointerLocation;
channels=table2cell(struct2table(handles.Data_Struct(fileselect).Day));

 
fhgat = figure('units','pixels',...
                  'position',[positiongui 600 600],...
                  'menubar','none',...
                  'name','Gating',...
                  'numbertitle','off',...
                  'resize','off');
              
%guidata(fhgat,handles);
%num=handles.num(fileselect).num;
%ChannelsAll=handles.ChannelsAll;

h=axes('Parent',fhgat,'Position',[0.25 0.15 0.7 0.7]);

title=uicontrol('Parent',fhgat,'Style','text',...
    'String',strcat({'Gating of '},handles.Data_Struct(fileselect).ID),...
    'Position',[250,525,200,40],...
    'FontSize',16);

xoption=uicontrol('Parent',fhgat,'Style','pop',...
    'String',channels,...
    'Position',[325,35,100,24],...
    'Value',1,...
    'Tag','xoption',...
    'Callback',@xoptionfunc1);

yoption=uicontrol('Parent',fhgat,'Style','pop',...
    'String',channels,...
    'Position',[20,300,100,24],...
    'Value',2,...
    'Tag','yoption',...
    'Callback',@yoptionfunc1);

xscalegat=uicontrol('Parent',fhgat,'Style','pop',...
    'String',{'Linear','Log10'},...
    'Position',[325,15,100,24],...
    'Value',1,...
    'Tag','xscalegat',...
    'Callback',@xscalegatfunc);

yscalegat=uicontrol('Parent',fhgat,'Style','pop',...
    'String',{'Linear','Log10'},...
    'Position',[20,276,100,24],...
    'Value',1,...
    'Tag','yscalegat',...
    'Callback',@yscalegatfunc);

gatebutton=uicontrol('Parent',fhgat,'Style','push',...
    'String','Gate Population',...
    'Position',[20,570,150,50],...
    'Tag','gatepop',...
    'Callback',@gatepop);

donegate=uicontrol('Parent',fhgat,'Style','push',...
    'String','Apply Gates to Single File',...
    'Position',[200,570,200,50],...
    'FontUnits','normalized',...
    'Tag','donegate',...
    'Callback',@donegatefunc);

donegate2=uicontrol('Parent',fhgat,'Style','push',...
    'String','Apply Gates to All Files',...
    'Position',[400,570,200,50],...
    'FontUnits','normalized',...
    'Tag','donegate2',...
    'Callback',@donegatefunc2);

GatePlot(handles,fileselect,channels)
guidata(fhgat,handles);
        
    
    function GatePlot(handles,fileselect,channels)
        xscale=findobj('Tag','xscalegat');
        yscale=findobj('Tag','yscalegat');
        xoption=findobj('Tag','xoption');
        yoption=findobj('Tag','yoption');

        if xscale.Value==1
             plotx=handles.Data_Struct(fileselect).Counts(xoption.Value).Counts;
        elseif xscale.Value==2
            plotx=log10forflow(handles.Data_Struct(fileselect).Counts(xoption.Value).Counts);
        end

        if yscale.Value==1
            ploty=handles.Data_Struct(fileselect).Counts(yoption.Value).Counts;
        elseif yscale.Value==2
             ploty=log10forflow(handles.Data_Struct(fileselect).Counts(yoption.Value).Counts);
        end

        dscatter(plotx,ploty);

    function xscalegatfunc(hObject,eventdata)
        handles=guidata(hObject);
        fileselect=handles.ID_List.Value;
        channels=table2cell(struct2table(handles.Data_Struct(fileselect).Day));
        GatePlot(handles,fileselect,channels)

    function yscalegatfunc(hObject,eventdata)
        handles=guidata(hObject);
        fileselect=handles.ID_List.Value;
        channels=table2cell(struct2table(handles.Data_Struct(fileselect).Day));
        GatePlot(handles,fileselect,channels)

    function gatepop(hObject,eventdata)
        handles=guidata(hObject);
        fileselect=handles.ID_List.Value;
        channels=table2cell(struct2table(handles.Data_Struct(fileselect).Day));
        [sel,xsel,ysel]=selectdata('SelectionMode','Lasso','Verify','on');
        handles.Data_Struct(fileselect).Peptides=handles.Data_Struct(fileselect).Peptides(sel);
        
        for i=1:size(handles.Data_Struct(fileselect).Counts,2)
            handles.Data_Struct(fileselect).Counts(i).Counts=handles.Data_Struct(fileselect).Counts(i).Counts(sel);
        end
            
%         handles.num(fileselect).num=handles.num(fileselect).num(sel,:);
%         k=boundary(xsel,ysel);
%         boundx=xsel(k);
%         boundy=ysel(k);
%         xoption=findobj('Tag','xoption');
%         yoption=findobj('Tag','yoption');
%         xscale=findobj('Tag','xscalegat');
%         yscale=findobj('Tag','yscalegat');
% 
%         if xscale.Value==2
%             boundx=10.^boundx;
%         elseif xscale.Value==3
%             boundx=sinh(boundx);
%         end
% 
%         if yscale.Value==2
%             boundy=10.^boundy;
%         elseif yscale.Value==3
%             boundy=sinh(boundy);
%         end
% 
%         if ~isfield(handles,'ActiveGates')
%             n=1;
%         else
%             n=size(handles.ActiveGates,2)+1;
%         end
% 
%             handles.ActiveGates(n).xparam=xoption.Value;
%             handles.ActiveGates(n).yparam=yoption.Value;
%             handles.ActiveGates(n).boundx=boundx;
%             handles.ActiveGates(n).boundy=boundy;

        guidata(findobj('Tag','gatepop'),handles);
        GatePlot(handles,fileselect,channels)


    function xoptionfunc1(hObject,eventdata)
        handles=guidata(hObject);
        fileselect=handles.ID_List.Value;
        channels=table2cell(struct2table(handles.Data_Struct(fileselect).Day));
        GatePlot(handles,fileselect,channels)


    function yoptionfunc1(hObject,eventdata)
        handles=guidata(hObject);
        fileselect=handles.ID_List.Value;
        channels=table2cell(struct2table(handles.Data_Struct(fileselect).Day));
        GatePlot(handles,fileselect,channels)
        

    function donegatefunc(hObject,eventdata)
        handles=guidata(hObject);
        current_list=handles.Viral_Peptide_List.String;
        fileselect=handles.ID_List.Value;
        c=find(ismember(handles.peptides,handles.Data_Struct(fileselect).Peptides));
        values=sum(handles.ref(c,:),1);
        values=values~=0;
        add=handles.channels(values);
        if isempty(current_list)
            handles.Viral_Peptide_List.String=add;
        else
            add=setdiff(add,current_list);
            handles.Viral_Peptide_List.String=[current_list;transpose(add)];
        end
        
        guidata(findobj('Tag','Gate_Population'),handles);
        closereq

%     function donegatefunc2(hObject,eventdata)
%         hbox=msgbox('Applying Gates to All Files.. Please Wait');
%         handles=guidata(hObject);
%         ActiveGates=handles.ActiveGates;
%         for i=1:size(handles.num,2)
%             if i~=handles.fileselect
%                 numtemp=handles.num(i).num;
%                 inpass=ones(size(numtemp,1),1);
%                 for j=1:size(ActiveGates,2)
%                     in=inpolygon(numtemp(:,ActiveGates(j).xparam),numtemp(:,ActiveGates(j).yparam),ActiveGates(j).boundx,ActiveGates(j).boundy);
%                     inpass=inpass.*in;
%                 end
%                 handles.num(i).num=numtemp(find(inpass),:); 
%             end
%         end
% 
%         guidata(findobj('Tag','gate'),handles);
%         close(hbox);
%         closereq

