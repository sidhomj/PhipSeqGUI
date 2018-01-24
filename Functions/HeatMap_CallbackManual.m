function handles=HeatMap_CallbackManual(hObject, eventdata, handles)
% hObject    handle to HeatMapClusters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    ChannelsOut=handles.channels_out;
    idx=handles.idx;
    ClusterIter=[1:max(idx)];
    y=handles.y;
    
    for j=ClusterIter
            clusterselect=idx==j;
            SizeCluster(j)=sum(clusterselect);
            clusterselect2=y(clusterselect,:);
            clusterselect2=log10(clusterselect2);
            HeatMapData(j,:)=real(median(clusterselect2)); 
            RowLabels{j}=strcat('Cluster ',num2str(j),' = ',num2str(100*(SizeCluster(j)/size(y,1))),'%');
    end
    
    handles.HeatMapData=HeatMapData;
    handles.RowLabels=RowLabels;
    ClusterContrib=tabulate(idx);
    if ClusterContrib(1,1)==0
        ClusterContrib=ClusterContrib(2:end,:);
    end
    handles.SizeCluster=SizeCluster;
    handles.ClusterContrib=ClusterContrib;
    handles.I=ClusterIter;
    handles.num_clusters=max(idx);