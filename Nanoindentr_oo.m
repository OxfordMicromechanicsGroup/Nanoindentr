%% Nanoindentr_oo
% by RJS

clear % Clears all workspace variables
close all % Closes all figures
clc % Clears the command window

addpath(addpath('.\functions'));
addpath(addpath('.\import_plugins'));

% Set this to true to calculate stress and strain data.
CalculateStressStrain = 1;

% Set this to true to select the files based using a pop up window rather than pasting as a string array.
GUI_on_off = false;

if GUI_on_off == false
    % Enter paths to Excel sheets here. Should be string or string array.
    filepaths = ["C:\Users\mans3428\OneDrive - Nexus365\DPhil\group folder\Lewis Sutton\Matlab Work\Green scrap 50x50 1500 to 2000nm.xlsx"];
else
    Filter = '*.xlsx';
    [files, path] = uigetfile(Filter, sprintf('Select nanoindentation %s files...', Filter), "MultiSelect","on");
    filepaths = string(fullfile(path, files));
end


x_variable = "depth";
y_variable = "E";

indents = import_agilent_csm(filepaths);
indents([4,7]) = [];

s = IndentSummary("Aged Cantor", indents);
s = s.bin(50, x_variable);

figure;
% s.plot_all_indents(x_variable, y_variable)
s.(y_variable).plot;
