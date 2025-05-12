classdef IndentSummary
    % IndentSummary Class representing the summary of multiple indents.
    %   Represents a single indent, containing its information.
    %
    % Type the following to open up the documentation for this class:
    % >>> doc indent
    % >>> help indent
    %
    % Robin Scales 2025
    %

    properties
        material_name (1,1) string % The material name associated with the sample
        material_condition string % The specific material condition
        material_details (1,1) string % Other details of the sample
        indents (:,1) Indent % The indents

        indent_var_list = ["displacement", "depth", "load", "time", "E", "H", "HCS", "strain", "stress"]
        displacement (:,1) double % Indent displacement [nm]
        depth (:,1) double % Indent depth [nm]
        load (:,1) double % Indent load [mN]
        time (:,1) double % Time during indentation [s]
        HCS (:,1) double % Harmonic Contact Stiffness [N/m]
        H (:,1) double % Hardness [GPa]
        E (:,1) double % Young's modulus [GPa]
        strain (:,1) double % Indentation strain [1]
        stress (:,1) double % Indentation stress [GPa]
        temperature (1,1) double % Indentation stress [K]
    end

    methods
        function obj = IndentSummary(material_name, indents, options)
            % Constructor method to perform the calculations needed to produce the essential properties i.e. initialisation
            arguments
                material_name (1,1) string % The material name associated with the sample
                indents (:,1) Indent % The indents
                options.condition string = "" % The specific material condition
                options.details (1,1) string = "" % Other details of the sample
                % options.interp (1,1) struct = struct('method', 'invdist', 'radius', 5, 'power', 2);
            end
            if isempty(options.condition) == true
                name2show = sprintf('%s (%s)', material_name, options.condition);
            else
                name2show = material_name;
            end
            fprintf('IndentSummary for %s has %d indents\n', name2show, length(indents));
            obj.material_name = material_name;
            obj.indents = indents;
            obj.material_condition = options.condition;
            obj.material_details = options.details;
        end

        function obj = stack_data(obj)
            list = obj.indent_var_list;
            for i = 1:length(list)
                for id = 1:length(obj.indents)
                    % fprintf("Prop %s id %d\n", list(i), id)
                    obj.(list(i)) = vertcat( obj.(list(i)), obj.indents(id).(list(i)) );
                end
            end
        end

        function obj = bin(obj, NumBins, binVar)
            obj = stack_data(obj);

            list = obj.indent_var_list;
            idx0 = ismember(list, binVar);
            list(idx0) = [];

            [obj.(binVar), idx] = sort(obj.(binVar), 'ascend');
            for propNum = 1:length(list)
                % disp(list(propNum))
                y = obj.(list(propNum));
                if isempty(y) == false
                    obj.(list(propNum)) = y(idx);
                end
            end

            x = obj.(binVar);
            user_edges = linspace(0, max(x), NumBins);
            [Y, edges] = discretize(x, user_edges);
            BinWidth = edges(2)-edges(1);
            MidPoints = (edges(1:end)+(BinWidth/2))';
            obj.(binVar) = [];
            obj.(binVar) = MidPoints;
            % disp(idx)

            LineMethod = 'mean';

            for propNum = 1:length(list)
                y = obj.(list(propNum));
                if isempty(y) == true
                    continue
                end

                y_binVal = nan(NumBins, 1);
                % y_BinError_pos = nan(NumBins, 1);
                % y_BinError_neg = nan(NumBins, 1);

                %     list = obj.indent_var_list;
                %
                for i = 1:NumBins
                    TF_bin = (Y==i);
                    bin_y = y(TF_bin);
                    switch lower(LineMethod)
                        case 'mean'
                            y_binVal(i) = mean(bin_y, 'omitnan');
                        case 'median'
                            y_binVal(i) = median(bin_y, 'omitnan');
                    end

                    % switch lower(BoundaryMethod)
                    % case 'std'
                    % y_BinError_pos(i) = std(bin_y, 0, 'omitnan');
                    % y_BinError_neg(i) = std(bin_y, 0, 'omitnan');
                    %             case 'minmax'
                    %                 if isfinite(y_binVal(i)) == true
                    %                     y_plus = abs(y_binVal(i) - max(bin_y) );
                    %                     y_minus = abs(y_binVal(i) - min(bin_y) );
                    %                     y_BinError_pos(i) = y_plus;
                    %                     y_BinError_neg(i) = y_minus;
                    %                 else
                    %                     continue
                    %                 end
                end

                obj.(list(propNum)) = [];
                obj.(list(propNum)) = y_binVal;
            end
        end

    end

end