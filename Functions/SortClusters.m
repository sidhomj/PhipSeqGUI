function handles=SortClusters(handles)
    
    HeatMapData=handles.HeatMapData;
    ListC=[1:size(HeatMapData,1)];
    clear HeatMapData
    
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
    
    channelsel=handles.Sort_By_Menu.Value;
    ClusterContrib=handles.ClusterContrib;
    channelselstring=handles.channels_out{channelsel};
    valsort=strmatch(channelselstring,handles.channels_out,'exact');
    I=handles.I;


    if handles.Sort_Toggle.Value==0
        [B,I2]=sortrows(HeatMapData,-valsort);
    else
        [B,I2]=sortrows(HeatMapData,valsort);
    end

    I2=transpose(intersect(I2,I,'stable'));
    I=I2;

    sortedlist=cell(1,size(I,2));
    for i=1:size(I,2);
        sortedlist(i)=strcat({'Cluster '},num2str(I(i)),{' - '},num2str(ClusterContrib(I(i),3)),{'%'});
    end

    handles.Cluster_Selection_Listbox.Value=1;    
    handles.Cluster_Selection_Listbox.String=sortedlist;
    handles.Imod=I;