function handles=ClusterCut(handles)
    SizeCluster=handles.SizeCluster;
    ClusterContrib=handles.ClusterContrib;
    I=handles.Imod;
    cut=str2num(handles.Frequency_Cut.String)/100;
    if isempty(cut);
        cut=0;
    end
    FreqCluster=SizeCluster./size(handles.X_Master,1);
    Keep=(FreqCluster>cut).*[1:size(FreqCluster,2)];
    Keep(Keep==0)=[];
    I=intersect(I,Keep,'stable');
    handles.Imod=I;

    if ~isempty(I)
        for i=1:size(I,2);
        sortedlist(i)=strcat({'Cluster '},num2str(I(i)),{' - '},num2str(ClusterContrib(I(i),3)),{'%'});
        end
    end

    if ~exist('sortedlist')
        sortedlist={};
    end

    handles.Cluster_Selection_Listbox.Value=1;
    handles.Cluster_Selection_Listbox.String=sortedlist;
    PlotSelectClusters(handles);