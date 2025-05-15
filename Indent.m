classdef Indent
    % indent Class representing the data from a single indent.
    %   Represents a single indent, containing its information.
    %
    % Type the following to open up the documentation for this class:
    % >>> doc indent
    % >>> help indent
    %
    % Robin Scales 2025
    %

    properties
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
    % end
    % 
    % properties (Access = private)
        % private – The property can be accessed only by members of the defining class.
        tip Tip % The indenter tip used
        indent_number (1,1) double % The number associated with the indent
    end

    methods
        function obj = clean_data(obj)
            % Cleans the data of the indent by selecting data with
            % modulus less than 1000 GPa
            % fprintf('Cleaning indent %d\n', obj.indent_number);
            TF = obj.E > 0 & obj.E < 1E3;
            obj = remove_rows(obj, ~TF);
        end

        function obj = remove_rows(obj, rows2remove)
            list = ["displacement", "depth", "load", "time", "E", "H", "HCS", "strain", "stress"];
            for i = 1:length(list)
                if isempty(obj.(list(i))) == false
                    % fprintf('Looking at %s\n', list(i))
                    obj.(list(i))(rows2remove) = [];
                end
            end
        end
    end

    methods(Static)
        function unit = get_unit(var)
            arguments
                var (1,1) string
            end
            switch var
                case "displacement"
                    unit = "nm";
                case "depth"
                    unit = "nm";
                case "load"
                    unit = "mN";
                case "time"
                    unit = "s";
                case "HCS"
                    unit = "N/m";
                case "H"
                    unit = "GPa";
                case "E"
                    unit = "GPa";
                case "strain"
                    unit = "1";
                case "stress"
                    unit = "GPa";
                case "temperature"
                    unit = "K";
                otherwise
                    warning('get_unit with unknown variable of %s !\n', var)
            end
        end
    end

end