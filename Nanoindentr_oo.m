%% Nanoindentr_oo
% by RJS

clear % Clears all workspace variables
close all % Closes all figures
clc % Clears the command window

addpath(addpath('.\import_plugins'));
addpath(addpath('.\data'));

sample_name = "Green Reference";
material_name = "Green Reference";
sample_condition = "";
sample_details = "";
x_variable = "depth";
y_variable = "E";

% Set this to true to calculate stress and strain data.
CalculateStressStrain = 1;

% Enter paths to Excel sheets here. Should be string or string array.
filepaths = [];


indents = import_agilent_csm(filepaths);
indents([4,7]) = [];

s = IndentSummary(material_name, indents, "condition",sample_condition,"details",sample_details);
s = s.bin(50, x_variable);

figure;
s.plot_all_indents(x_variable, y_variable)
s.(y_variable).plot(sample_name);

save(fullfile('.\data\',sprintf("%s.mat",sample_name)), "s");