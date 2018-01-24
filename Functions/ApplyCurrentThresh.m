function handles=ApplyCurrentThresh(handles)

if isfield(handles,'thresholdbook')
    thresholdbook=handles.thresholdbook;
    HeatMapData=handles.HeatMapData;

    for i=1:size(thresholdbook,2);
        threshold_indx(i)=strmatch(thresholdbook(i).Channel,handles.channels_out,'exact');
        threshold_dir{i}=thresholdbook(i).direction;
        threshold_val(i)=thresholdbook(i).threshold;
    end

    ListC=[1:size(HeatMapData,1)];
    clear HeatMapData
    thresh_cut_ind=ListC;
    
    for j=ListC;
            clusterselect=handles.idx==j;
            SizeCluster(j)=sum(clusterselect);
            clusterselect2=handles.X_Master(clusterselect,:);
            if size(clusterselect2,1)==1
                HeatMapData(j,:)=clusterselect2;
            else
                HeatMapData(j,:)=median(clusterselect2); 
            end
    end
    
    for i=1:size(threshold_indx,2);
            thresh_cut=HeatMapData(:,threshold_indx(i));
            eval(['thresh_cut=thresh_cut' threshold_dir{i} 'threshold_val(i);'])
            thresh_cut_ind=intersect(ListC(thresh_cut),thresh_cut_ind);
    end

    I=handles.Imod;
    I=intersect(I,thresh_cut_ind,'stable');
    sortedlist=cell(1,size(I,2));
    for i=1:size(I,2);
        sortedlist(i)=strcat({'Cluster '},num2str(I(i)),{' - '},num2str(handles.ClusterContrib(I(i),3)),{'%'});
    end

    handles.Cluster_Selection_Listbox.Value=1;
    handles.Cluster_Selection_Listbox.String=sortedlist;
    handles.Imod=I;
end