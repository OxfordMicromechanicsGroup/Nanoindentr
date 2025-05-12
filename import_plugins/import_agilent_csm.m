function indents = import_agilent_csm(workbookFile)
%IMPORT_AGILENT_CSM Summary of this function goes here
%   Detailed explanation goes here

%% Input handling
warning('off','MATLAB:table:ModifiedAndSavedVarnames')

% Gets the sheet names from the Excel
sheets = sheetnames(workbookFile);

TF = contains(sheets, 'Test');
SheetNames = sheets(TF);
TF_tagged = ~contains(SheetNames, ["Tagged", "Inputs"]);
SheetNames = SheetNames(TF_tagged);

% If row start and end points
% dataLines = [3, inf];
% opts = spreadsheetImportOptions("NumVariables", 7);
% opts.DataRange = "A" + dataLines(1, 1) + ":G" + dataLines(1, 2);
% opts.VariableNames = ["Segment", "DisplacementIntoSurface", "LoadOnSample", "TimeOnSample", "HarmonicContactStiffness", "Hardness", "Modulus"];
% opts.VariableTypes = ["double","double", "double", "double", "double", "double", "double"];

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
    if sum(ismember(output.Properties.VariableNames, 'Segment')) > 0
        output = removevars(output, "Segment");
    end

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

    indents(IN) = indents(IN).clean_data;
    % disp(indents(IN).H(1))

end

end

