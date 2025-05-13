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

        indent_var_list = ["depth", "load", "time", "E", "H", "HCS", "strain", "stress"] % "displacement", 
        % displacement % Indent displacement [nm]
        depth % Indent depth [nm]
        load % Indent load [mN]
        time % Time during indentation [s]
        HCS % Harmonic Contact Stiffness [N/m]
        H % Hardness [GPa]
        E % Young's modulus [GPa]
        strain % Indentation strain [1]
        stress % Indentation stress [GPa]

        temperature (1,1) % Sample temperature [K]
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
            fprintf('IndentSummary: %s has %d indents\n', name2show, length(indents));
            obj.material_name = material_name;
            obj.indents = indents;
            obj.material_condition = options.condition;
            obj.material_details = options.details;
        end
        % 
        % function obj = remove_indents(obj, indent_numbers)
        %     arguments
        %         obj IndentSummary
        %         indent_numbers (1,:) double
        %     end
        % 
        %     in = obj.indents;
        %     in(indent_numbers) = [];
        %     obj.indents = in;
        % 
        % end


        function obj = bin(obj, NumBins, binVar, options)
            arguments
                obj IndentSummary
                NumBins (1,1) double
                binVar (1,1) string = "depth"
                options.avg_method (1,1) string = "mean"
                options.err_method (1,1) string = "std"
            end

            list = obj.indent_var_list;
            for i = 1:length(list)
                for id = 1:length(obj.indents)
                    % fprintf("Prop %s id %d\n", list(i), id)
                    data = obj.indents(id).(list(i));
                    if id == 1
                        all_variables.(list(i)) = data;
                    else
                        all_variables.(list(i)) = vertcat( all_variables.(list(i)), data );
                    end
                end
            end

            % list = obj.indent_var_list;
            idx0 = ismember(list, binVar);
            list(idx0) = [];

            [all_variables.(binVar), idx] = sort(all_variables.(binVar), 'ascend');
            x = all_variables.(binVar);
            user_edges = linspace(0, max(x), NumBins);
            [Y, edges] = discretize(x, user_edges);
            BinWidth = edges(2)-edges(1);
            MidPoints = (edges(1:end)+(BinWidth/2))';

            for propNum = 1:length(list)
                % disp(list(propNum))
                y = all_variables.(list(propNum));
                if isempty(y) == false
                    all_variables.(list(propNum)) = y(idx);
                end
            end


            % obj.(binVar) = [];
            % % obj.("bin_"+binVar) = MidPoints;
            % % disp(idx)

            % LineMethod = 'mean';
            % BoundaryMethod = 'std';

            for propNum = 1:length(list)
                y = all_variables.(list(propNum));
                if isempty(y) == true
                    continue
                end

                y_binVal = nan(NumBins, 1);
                y_BinError_pos = nan(NumBins, 1);
                y_BinError_neg = nan(NumBins, 1);

                %     list = obj.indent_var_list;
                %
                for i = 1:NumBins
                    TF_bin = (Y==i);
                    bin_y = y(TF_bin);
                    switch lower(options.avg_method)
                        case 'mean'
                            y_binVal(i) = mean(bin_y, 'omitnan');
                        case 'median'
                            y_binVal(i) = median(bin_y, 'omitnan');
                    end

                    switch lower(options.err_method)
                        case 'std'
                            y_BinError_pos(i) = std(bin_y, 0, 'omitnan');
                            y_BinError_neg(i) = std(bin_y, 0, 'omitnan');
                        case 'minmax'
                            if isfinite(y_binVal(i)) == true
                                y_plus = abs(y_binVal(i) - max(bin_y) );
                                y_minus = abs(y_binVal(i) - min(bin_y) );
                                y_BinError_pos(i) = y_plus;
                                y_BinError_neg(i) = y_minus;
                            else
                                continue
                            end
                    end
                end

                obj.(list(propNum)) = BinnedData(MidPoints, y_binVal, y_BinError_pos, y_BinError_neg, options.avg_method, options.err_method, binVar, list(propNum));
            end
        end
        
        function plot_all_indents(obj,xVar,yVar)
            arguments
                obj IndentSummary
                xVar (1,1) string = "depth"
                yVar (1,1) string = "load"
            end
            for i = 1:length(obj.indents)
                scatter(obj.indents(i).(xVar), obj.indents(i).(yVar), '.', 'DisplayName', sprintf('Indent %d', i));
                hold on
            end
            xlabel(sprintf("%s [%s]",xVar, Indent.get_unit(xVar)))
            ylabel(sprintf("%s [%s]",yVar, Indent.get_unit(yVar)))
        end

    end

end