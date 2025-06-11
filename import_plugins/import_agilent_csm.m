function indents = import_agilent_csm(workbookFile)
%IMPORT_AGILENT_CSM Summary of this function goes here
%   Detailed explanation goes here

%% Input handling
warning('off','MATLAB:table:ModifiedAndSavedVarnames')

% Reads the results sheet and translates it into MATLAB format
opts = spreadsheetImportOptions("NumVariables", 7);
opts.VariableNames = ["Test", "AvgModulus", "AvgHardness", "DriftCorrection", "Time", "TipName", "Temperature"];
opts.VariableTypes = ["double","double", "double", "double", "datetime", "string", "double"];
results_sheet = readtable(workbookFile, opts, "UseExcel", false, "Sheet","Results"); % ,"NumHeaderLines",1, "VariableNamingRule","modify"
results_sheet(isnan(results_sheet.Test),:) = [];
results_sheet.Time = datetime(results_sheet.Time, "Format", "HH:mm:ss");
results_sheet.Temperature(isnan(results_sheet.Temperature)) = 20;

% Gets the sheet names from the Excel
sheets = sheetnames(workbookFile);

TF = contains(sheets, 'Test');
SheetNames = sheets(TF);
TF_tagged = ~contains(SheetNames, ["Tagged", "Inputs"]);
SheetNames = SheetNames(TF_tagged);

% If row start and end points
% dataLines = [3, inf];

indent_template = Indent;
indent_template.temperature = NaN;
indents = repelem(indent_template,length(SheetNames),1);

for i = 1:length(SheetNames)
    %% Set up the Import Options and import the data
    % Import the data
    SheetName = SheetNames(i);
    output = readtable(workbookFile, "UseExcel", false, "Sheet",SheetName, "VariableNamingRule","modify"); % , opts

    % for idx = 2:size(dataLines, 1)
    %     opts.DataRange = "B" + dataLines(idx, 1) + ":G" + dataLines(idx, 2);
    %     tb = readtable(workbookFile, opts, "UseExcel", false);
    %     output = [output; tb];
    % end
    % if sum(ismember(output.Properties.VariableNames, {'Segment','Var1'})) > 0
        % output = removevars(output, ["Segment" , "Var1"]);
    vars2remove = ismember(output.Properties.VariableNames, {'Segment','Var1'});
    output(:,vars2remove) = [];
    % end

    TF = sum(isfinite(table2array(output)),2)~=0;
    output = output(TF,:);

    % output = table2array(output);
    IN = str2double(extractAfter(SheetName, 'Test '));
    indents(IN).indent_number = IN;
    indents(IN).displacement = output.DisplacementIntoSurface;
    indents(IN).depth = output.DisplacementIntoSurface;
    indents(IN).load = output.LoadOnSample;
    indents(IN).time = output.TimeOnSample;
    indents(IN).HCS = output.HarmonicContactStiffness;
    indents(IN).H = output.Hardness;
    indents(IN).E = output.Modulus;
    indents(IN).temperature = results_sheet.Temperature(IN)+273; % K
    
    tipName = results_sheet.TipName(IN);
    tipLoc = fullfile('.\tips',tipName+".mat");
    if isfile(tipLoc) == false
        tip = Tip;
        tip.name = tipName;
        save(tipLoc, "tip");
        warning('Tip not found in tips folder, it has been created but please enter in all of the information for it');
    else
        tip = load(tipLoc).tip;
        % fprintf('Loaded tip "%s"\n', tip.name);
    end
    indents(IN).tip = tip;

    if (class(tip) == "Tip_spherical") == true
        if isfinite(tip.coeff_Ac_1) == true
            indents(IN).strain = tip.get_strain(indents(IN).depth, indents(IN).load, indents(IN).HCS)/100;
            indents(IN).stress = tip.get_stress(indents(IN).depth, indents(IN).load);
        end
    end

    indents(IN) = indents(IN).clean_data;
    
    % disp(indents(IN).H(1))

end

end

