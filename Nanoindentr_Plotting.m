%% Nanoindentr2_Plotter

clear
close all
clc
addpath(addpath('.\functions'));

% Set this to true to select the files based using a pop up window rather than pasting as a string array.
GUI_on_off = 1;

if GUI_on_off == false
    % Enter path to Mat files here. Should be string or string array.
    filepaths = [];
else
    Filter = '*.mat';
    [files, path] = uigetfile(Filter, sprintf('Select nanoindentation %s files...', Filter), "MultiSelect","on");
    filepaths = string(fullfile(path, files));
end
[path, ~, ~] = fileparts(filepaths(1));

plotNames = ["Green Scrap", "Aged Cantor", "Cantor Ref.", "Cantor Scrap - Matrix", "Cantor Scrap - Intermetallic", "Green Ref."];

Colours = {'#e6194b', '#3cb44b', '#ffe119', '#4363d8', '#f58231', '#911eb4', '#46f0f0', '#f032e6', '#bcf60c', '#fabebe', '#008080', '#e6beff', '#9a6324', '#fffac8', '#800000', '#aaffc3', '#808000', '#ffd8b1', '#000075', '#808080', '#ffffff', '#000000'};

fig = figure;
ax = gca;

PlotNum = 1;
for i = 1:length(filepaths)
    filepath = filepaths(i);
    out = load(filepath);
    data = out.out;
    
    [~, filename, ~] = fileparts(filepath);
    
    C = Colours{PlotNum};
    PlotName = sprintf('%s', plotNames(i));
    plot(ax, data.x, data.y, '-', 'LineWidth', 2, 'DisplayName', PlotName, 'Color', C);

    Boundary_y = data.Boundary_y;
    Boundary_x = data.Boundary_x;
    
    Poly = polyshape(Boundary_x, Boundary_y);
    hold on
    PatchName = sprintf('%s - Uncertainty', plotNames(i));
    patch(ax, 'XData', Boundary_x, 'YData', Boundary_y, 'FaceColor', C, 'EdgeColor', 'none', 'FaceAlpha', 0.4, 'DisplayName', PatchName);
    PlotNum = PlotNum + 1;
    ylabel(data.YLabel);
    xlabel(data.XLabel);
    drawnow
end

grid on
grid minor
legend('Location', 'Northeastoutside', 'NumColumns', max(floor((PlotNum*2)/15), 1), 'Interpreter', 'none');

% ylabel(data.YLabel);
% xlabel(data.XLabel);

ID = string(inputdlg('Enter the name to ID this data with:'));
saveas(gcf, fullfile(path, sprintf('%s.%s', ID, 'png')));
saveas(gcf, fullfile(path, sprintf('%s.%s', ID, 'fig')));


