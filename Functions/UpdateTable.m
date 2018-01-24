function handles=UpdateTable(handles)
    I=handles.Ifinal;
    maxconditions=max(handles.ID_Master);
    if ~isempty(I)
        for i=1:size(I,2)
            incluster=handles.idx==I(i);
            sample=handles.ID_Master(incluster);
            table_sample=tabulate(sample);
            for j=1:maxconditions
                try
                    table_out(j,i)=100*(table_sample(j,2)/sum(handles.ID_Master==j));
                catch
                    table_out(j,i)=0;
                end
            end
        end

        sampleid=transpose(handles.ID);
        datawrite=[sampleid,num2cell(table_out)];

        rownames=['Sample',num2cell(I)];
        datawrite=[rownames;datawrite];
        handles.Cluster_Breakdown.Data=datawrite;
        handles.Cluster_Breakdown.RowName='';
    else
        handles.clusterbreakdown2.Data={};
    end