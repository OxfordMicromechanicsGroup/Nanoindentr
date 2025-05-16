%% Nanoindentr_oo
% by RJS

clear % Clears all workspace variables
close all % Closes all figures
clc % Clears the command window

% addpath(addpath('.\functions'));
addpath(addpath('.\import_plugins'));
addpath(addpath('.\data'));

% Set this to true to select the files based using a pop up window rather than pasting as a string array.
GUI_on_off = false;

x_variable = "depth";
y_variable = "E";

if GUI_on_off == false
    % Enter path to Mat files here. Should be string or string array.
    filepaths = [".\data\Steel.mat", ".\data\Brass.mat"]; 
else
    Filter = '*.mat';
    [files, path] = uigetfile(Filter, sprintf('Select nanoindentation %s files...', Filter), "MultiSelect","on");
    filepaths = string(fullfile(path, files));
end
[path, ~, ~] = fileparts(filepaths(1));

% Colours = {'#e6194b', '#3cb44b', '#ffe119', '#4363d8', '#f58231', '#911eb4', '#46f0f0', '#f032e6', '#bcf60c', '#fabebe', '#008080', '#e6beff', '#9a6324', '#fffac8', '#800000', '#aaffc3', '#808000', '#ffd8b1', '#000075', '#808080', '#ffffff', '#000000'};
Colours = {'#e6194b', '#3cb44b', '#f032e6', '#4363d8', '#f58231', '#911eb4', '#46f0f0', '#f032e6', '#bcf60c', '#fabebe', '#008080', '#e6beff', '#9a6324', '#fffac8', '#800000', '#aaffc3', '#808000', '#ffd8b1', '#000075', '#808080', '#ffffff', '#000000'};


fig = figure;
ax = gca;

num_skipped = 0;

for i = 1:length(filepaths)
    filepath = filepaths(i);
    s = load(filepath).s;
    
    [~, filename, ~] = fileparts(filepath);
    


    binnedData = s.(y_variable);

    if binnedData.x_variable ~= x_variable
        num_skipped = num_skipped+1;
        continue
    end

    C = Colours{i-num_skipped};

    binnedData.plot(filename, "color",C)
    drawnow
end

% grid on
% grid minor
NumColumns = max(floor(((length(filepaths)-num_skipped)*2)/15), 1);

legendMode = "inside"; % "outside"
switch lower(legendMode)
    case "inside"
        legend('Location', 'best', 'NumColumns', NumColumns, 'Interpreter', 'none','Color','white','EdgeColor','none','BackgroundAlpha',0.5);
    case "outside"
        legend('Location', 'Northeastoutside', 'NumColumns', NumColumns, 'Interpreter', 'none');
end