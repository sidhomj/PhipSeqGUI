function PlotSelectClusters(handles)
    Imod=handles.Imod;
    I=handles.I;
    idx=handles.idx;
    colorspec1=handles.colorspec1;
    Y=handles.Y;
    
    if isfield(handles,'ManualClusterCount');
         Ybase=Y(idx==0,:);
         scatter(handles.axes2,Ybase(:,1),Ybase(:,2),handles.FC_Plot,'filled');
         hold(handles.axes2);
         Y=Y(idx>0,:);
         idx=idx(idx>0);
         
         selidx=ismember(idx,Imod);
         
         
         clear colorscheme
         for i=1:size(idx,1);
            colorscheme(i,:)=colorspec1(idx(i)).spec;
         end
         
       
        YNL=Y(~selidx,:);
        colorschemeNL=colorscheme(~selidx,:);
        scatter(handles.axes2,YNL(:,1),YNL(:,2),handles.FC_Plot,colorschemeNL,'filled','MarkerFaceAlpha',0.05);
        YHL=Y(selidx,:);
        colorschemeHL=colorscheme(selidx,:);
        scatter(handles.axes2,YHL(:,1),YHL(:,2),handles.FC_Plot,colorschemeHL,'filled');
        handles.axes2.XLim=handles.tsne_xlim;
        handles.axes2.YLim=handles.tsne_ylim;
        handles.axes2.XTickLabel={};
        handles.axes2.YTickLabel={};
        
        hold(handles.axes2);
        
    else

        clear colorscheme
        for i=1:size(idx,1);
            colorscheme(i,:)=colorspec1(idx(i)).spec;
        end

        selclusteridx=ismember(idx,Imod);
        YHL=Y(selclusteridx,:);
        size_1=handles.FC_Plot(selclusteridx);
        colorschemeHL=colorscheme(selclusteridx,:);
        scatter(handles.axes2,YHL(:,1),YHL(:,2),size_1,colorschemeHL,'filled');
        hold(handles.axes2);
        YNL=Y(~selclusteridx,:);
        size_2=handles.FC_Plot(~selclusteridx);
        colorschemeNL=colorscheme(~selclusteridx,:);
        scatter(handles.axes2,YNL(:,1),YNL(:,2),size_2,colorschemeNL,'filled','MarkerFaceAlpha',0.05);
       
        handles.axes2.XTickLabel={};
        handles.axes2.YTickLabel={};
        handles.axes2.XLim=handles.tsne_xlim;
        handles.axes2.YLim=handles.tsne_ylim;
        hold(handles.axes2);
    
    end