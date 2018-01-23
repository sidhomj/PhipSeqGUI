function PlotClusterView(handles,Y,colorscheme);

if ~exist('colorscheme')
    colorscheme=[0,0.447000000000000,0.741000000000000];
end
scatter(handles.axes2,Y(:,1),Y(:,2),handles.FC_Plot,colorscheme,'filled');
handles.axes2.XTickLabel={};
handles.axes2.YTickLabel={};


end