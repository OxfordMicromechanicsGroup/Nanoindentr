%% Nanoindentr2
% by RJS

clear % Clears all workspace variables
close all % Closes all figures
clc % Clears the command window

addpath(addpath('.\functions'));

% Set this to true to calculate stress and strain data.
CalculateStressStrain = 1;

% Set this to true to select the files based using a pop up window rather than pasting as a string array.
GUI_on_off = 1;

if GUI_on_off == false
    % Enter paths to Excel sheets here. Should be string or string array.
    filepaths = [];
else
    Filter = '*.xlsx';
    [files, path] = uigetfile(Filter, sprintf('Select nanoindentation %s files...', Filter), "MultiSelect","on");
    filepaths = string(fullfile(path, files));
end

% These are the tests which will be ignored. Each row is a file.
IgnoreSheets = []; % e.g. ["Test 001", "Test 004"]

% This is what the data will be cropped to in the end and what the final
% plot's limits will be.
crop_x = [0, inf];
% crop_y = [0, max(MidPoints)];

% The order in which variables will be dealt with in this code, and what
% their displayed labels on the plot will be.
var_index = ["Displacement [nm]", "Load [mN]", "Time [s]", "HCS [N/m]", "Hardness [GPa]", "Young's Modulus [GPa]", "Strain [%]", "Stress [GPa]"];

if GUI_on_off == false
    x_var = var_index(1); % x_var is your x-axis variable
    y_var = var_index(6); % y_var is your y-axis variable
else
    [indx_xvar,tf_x] = listdlg('ListString',var_index,'PromptString', 'Select the x-axis variable', 'SelectionMode','single');
    [indx_yvar,tf_y] = listdlg('ListString',var_index,'PromptString', 'Select the y-axis variable', 'SelectionMode','single');
    if and(tf_y, tf_y) == false
        return
    end
    x_var = var_index(indx_xvar); % x_var is your x-axis variable
    y_var = var_index(indx_yvar); % y_var is your y-axis variable
end

% Cleaning out un-needed variables for after this section
clear files Filter indx_xvar indx_yvar tf_x tf_y

%% File Loop

close all

NumFiles = length(filepaths);

for FileNum = 1:NumFiles
    %% Sheet Name Obtainment

    filepath = filepaths(FileNum);
    [path, filename, ext] = fileparts(filepath);
    fprintf('\nWorking on file %s: ', filename);

    PlotCount = 1; % This is the count of how many plots there are on one figure;

    % Initialising final data store
    disp = nan(1, 1);
    load = nan(1, 1);
    time = nan(1, 1);
    HCS = nan(1, 1);
    H = nan(1, 1);
    E = nan(1, 1);
    strain = nan(1, 1);
    stress = nan(1, 1);
    
    % Gets the sheet names from the Excel
    sheets = sheetnames(filepath);

    TF = contains(sheets, 'Test');
    SheetNames = sheets(TF);
    TF_tagged = ~contains(SheetNames, ["Tagged", "Inputs"]);
    SheetNames = SheetNames(TF_tagged);

    %% Generation of Plot Styles For Each Test

    Colours = {'#e6194b', '#3cb44b', '#ffe119', '#4363d8', '#f58231', '#911eb4', '#46f0f0', '#f032e6', '#bcf60c', '#fabebe', '#008080', '#e6beff', '#9a6324', '#fffac8', '#800000', '#aaffc3', '#808000', '#ffd8b1', '#000075', '#808080', '#ffffff', '#000000'};
    LineStyles = {'-', ':', '--', '-.'};
    [D, NumOfUniquePlots] = Plot_Style_Variations(LineStyles, Colours);

    %% Test Loop

    fig = figure;
    ax = gca;

    NumSheets = length(SheetNames);

    for i = 1:NumSheets
        sheetName = SheetNames(i);
        if isempty(IgnoreSheets) == false
            if ismember(sheetName, IgnoreSheets) == true
                warning('Sheet is %s and is ignored!', sheetName);
                continue
            end
        end

        % Importing data
        fprintf('.'); % fprintf('Working on %s\n', sheetName);
        
        %% Important
        % This section is what does the main importing of the data. If you
        % want to import another data type, write your own script that
        % outputs the data in the same way.
        output = importfileData(filepath, sheetName);
        %%

        % Getting the desired variables
        test_disp = output(:, 1);
        finite_disp = isfinite(test_disp);
        test_disp = output(finite_disp, 1);
        test_load = output(finite_disp, 2);
        test_time = output(finite_disp, 3);
        test_HCS = output(finite_disp, 4);
        test_H = output(finite_disp, 5);
        test_E = output(finite_disp, 6);


        % Calculating stress and strain
        if CalculateStressStrain == true
            [test_strain, test_stress] = calc_stress_strain(test_disp, test_load, test_HCS);
        else
            test_strain = nan(size(test_disp));
            test_stress = test_strain;
        end


    %     test_disp = smoothdata(test_disp);

        % Plotting current test
        var_values = [test_disp, test_load, test_time, test_HCS, test_H, test_E, test_strain, test_stress];
        [x, ~, y, ~] = switch_x_y_vars(x_var, y_var, var_values, var_index);
        plot(ax, x, y, 'Color', D{1,PlotCount}, 'LineStyle', D{2,PlotCount}, 'DisplayName', sprintf('%s', sheetName));
        hold on
        drawnow;

        % Storing current tests data
        disp = vertcat(disp, test_disp);
        load = vertcat(load, test_load);
        time = vertcat(time, test_time);
        HCS = vertcat(HCS, test_HCS);
        H = vertcat(H, test_H);
        E = vertcat(E, test_E);
        strain = vertcat(strain, test_strain);
        stress = vertcat(stress, test_stress);

        PlotCount = PlotCount + 1;
        if PlotCount > NumOfUniquePlots
            PlotCount = 1;
        end
    end
    title(sprintf('File: %s', filename), 'Interpreter', 'none')
    xlabel(x_var);
    ylabel(y_var);
    fprintf('\n');
% end

    %% Binning
    clc
    NumBins = 100;
    
    var_values_validtests = [disp, load, time, HCS, H, E, strain, stress];
    LineMethod = 'mean';
    BoundaryMethod = 'std';

    [x, x_label, y, y_label, BinWidth, MidPoints, y_binVal, y_BinError_pos, y_BinError_neg] = f_BinData(NumBins, var_values_validtests, x_var, y_var, var_index, LineMethod, BoundaryMethod);
    
    if length(filename) > 1
        ID = string(inputdlg('Enter the name to ID this data with:'));
    else
        ID = filename;
    end
    
    %% Plotting
    clc
    plot(ax, MidPoints, y_binVal, 'r-', 'LineWidth', 2, 'DisplayName', 'Average');
    
    withincrop = and(MidPoints >= crop_x(1), MidPoints <= crop_x(2));
    
    new_x = MidPoints(withincrop);
    new_y = y_binVal(withincrop);
    new_err_pos = y_BinError_pos(withincrop);
    new_err_neg = y_BinError_neg(withincrop);
    
    
    % errorbar(ax, new_x, new_y, new_err_neg, new_err_pos, 'r-', 'LineWidth', 2);
    
    NiceNumbers = and(isfinite(new_x), isfinite(new_y));
    new_x = new_x(NiceNumbers);
    new_y = new_y(NiceNumbers);
    new_err_pos = new_err_pos(NiceNumbers);
    new_err_neg = new_err_neg(NiceNumbers);
    
    
    Boundary_y_top = new_y + new_err_pos;
    Boundary_y_bot = flipud(new_y - new_err_neg);
    Boundary_x_top = new_x;
    Boundary_x_bot = flipud(new_x);
    Boundary_y = vertcat(Boundary_y_top, Boundary_y_bot);
    Boundary_x = vertcat(Boundary_x_top, Boundary_x_bot);

    Poly = polyshape(Boundary_x, Boundary_y);
    hold on
    patch(ax, 'XData', Boundary_x, 'YData', Boundary_y, 'FaceColor', 'r', 'EdgeColor', 'none', 'FaceAlpha', 0.4, 'DisplayName', 'Uncertainty');
    
    xlim(crop_x);
    Lim = SmartAxisLimit(y_var, y);
    figure(fig);
    ylim(Lim);
    xlabel(x_label);
    ylabel(y_label);
    title(sprintf('%s - Num Bins = %d - X BinWidth = %.3g', ID, NumBins, BinWidth));
    grid on; grid minor;
    legend('Location', 'Northeastoutside', 'NumColumns', max(floor(NumSheets/15), 1));
    
    %% Saving Data
    
    out.type = 'Average Of Indents';
    out.originalFile = sprintf('%s.%s', ID, ext);
    out.x = new_x;
    out.y = new_y;
    out.err_neg = new_err_neg;
    out.err_pos = new_err_pos;
    out.Boundary_x = Boundary_x;
    out.Boundary_y = Boundary_y;
    Settings = sprintf('LineMethod  = %s\nBoundaryMethod = %s', LineMethod, BoundaryMethod);
    out.Settings = Settings;
    out.XLabel = x_label;
    out.YLabel = y_label;
    
    savenamebase = fullfile(path, matlab.lang.makeValidName(sprintf('%s_vs_%s  %s', lower(x_var), lower(y_var), ID)) );
    save(sprintf('%s.%s', savenamebase, 'mat'), 'out');
    
    saveas(gcf, sprintf('%s.%s', savenamebase, 'png'));
end

fprintf('Nanoindentr2 Complete.\nUse Nanoindentr2_Plotter to plot a single/multiple binned data onto one plot.')
%% Function importfileData

function output = importfileData(workbookFile, sheetName, dataLines)
    %IMPORTFILE1 Import data from a spreadsheet
    %  SMREFBIGARRAYS4 = IMPORTFILE1(FILE) reads data from the first
    %  worksheet in the Microsoft Excel spreadsheet file named FILE.
    %  Returns the data as a table.
    %
    %  SMREFBIGARRAYS4 = IMPORTFILE1(FILE, SHEET) reads from the specified
    %  worksheet.
    %
    %  SMREFBIGARRAYS4 = IMPORTFILE1(FILE, SHEET, DATALINES) reads from the
    %  specified worksheet for the specified row interval(s). Specify
    %  DATALINES as a positive scalar integer or a N-by-2 array of positive
    %  scalar integers for dis-contiguous row intervals.
    %
    %  Example:
    %  SMRefBigArrayS4 = importfile1("F:\600C and Ref\2022-05-12 Batch #00001\SM_Ref_BigArray.xlsx", "Test 035", [3, 499]);
    %
    %  See also READTABLE.
    %
    % Auto-generated by MATLAB on 13-May-2022 13:30:42

    %% Input handling

    % If no sheet is specified, read first sheet
    if nargin == 1 || isempty(sheetName)
        sheetName = 1;
    end

    % If row start and end points are not specified, define defaults
    if nargin <= 2
        dataLines = [3, 499];
    end

    %% Set up the Import Options and import the data
    opts = spreadsheetImportOptions("NumVariables", 7);

    % Specify sheet and range
    opts.Sheet = sheetName;
    opts.DataRange = "A" + dataLines(1, 1) + ":G" + dataLines(1, 2);

    % Specify column names and types
    opts.VariableNames = ["Segment", "DisplacementIntoSurface", "LoadOnSample", "TimeOnSample", "HarmonicContactStiffness", "Hardness", "Modulus"];
    opts.VariableTypes = ["double","double", "double", "double", "double", "double", "double"];

    % Import the data
    output = readtable(workbookFile, opts, "UseExcel", false);

    for idx = 2:size(dataLines, 1)
        opts.DataRange = "B" + dataLines(idx, 1) + ":G" + dataLines(idx, 2);
        tb = readtable(workbookFile, opts, "UseExcel", false);
        output = [output; tb]; %#ok<AGROW>
    end
    
%     disp('arse');
    
    if all(isnan(output.Segment)) == true
        output.Segment = [];
    else
        output.Modulus = [];
    end
    
    output = table2array(output);
    
    
end