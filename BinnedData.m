classdef BinnedData
    %BinnedData Describes binned data
    %   Detailed explanation goes here

    properties
        binMidPoints (:,1) double
        val (:,1) double
        pos (:,1) double
        neg (:,1) double
        avg_method (1,1) string
        err_method (1,1) string
        x_variable (1,1) string
        y_variable (1,1) string
    end

    methods
        function obj = BinnedData(binMidPoints,val,pos,neg,avg_method,err_method, x_variable, y_variable)
            %BinnedData Construct an instance of this class
            obj.binMidPoints = binMidPoints;
            obj.val = val;
            obj.pos = pos;
            obj.neg = neg;
            obj.avg_method = avg_method;
            obj.err_method = err_method;
            obj.x_variable = x_variable;
            obj.y_variable = y_variable;
        end

        function [Boundary_x, Boundary_y, Poly] = gen_ShadedRegion(obj)
            obj.pos = obj.pos;
            Boundary_y_top = obj.val + obj.pos;
            Boundary_y_bot = flipud(obj.val - obj.neg);
            Boundary_x_top = obj.binMidPoints;
            Boundary_x_bot = flipud(obj.binMidPoints);
            Boundary_y = vertcat(Boundary_y_top, Boundary_y_bot);
            Boundary_x = vertcat(Boundary_x_top, Boundary_x_bot);
            
            TF = isfinite(Boundary_x) & isfinite(Boundary_y);
            Boundary_x(~TF) = [];
            Boundary_y(~TF) = [];
            Poly = polyshape(Boundary_x, Boundary_y);
            % hold on
            % patch(ax, 'XData', Boundary_x, 'YData', Boundary_y, 'FaceColor', 'r', 'EdgeColor', 'none', 'FaceAlpha', 0.4, 'DisplayName', 'Uncertainty');
        end

        function plot(obj, DisplayName, options)
            arguments
                obj BinnedData
                DisplayName (1,1) string;
                options.color (1,1) string = "#808080";
            end
            plot(obj.binMidPoints, obj.val, Color=options.color, DisplayName=DisplayName);
            hold on;
            [Boundary_x, Boundary_y, ~] = gen_ShadedRegion(obj); % 
            patch('XData', Boundary_x, 'YData', Boundary_y, 'FaceColor', options.color, 'EdgeColor', 'none', 'FaceAlpha', 0.4, 'HandleVisibility', 'off');
            % errorbar(obj.binMidPoints, obj.val, obj.neg, obj.neg)
            % plot(Poly)
            % patch('XData', Boundary_x, 'YData', Boundary_y, 'FaceColor', 'red', 'FaceAlpha', 0);
            xlabel(sprintf("%s [%s]",obj.x_variable, Indent.get_unit(obj.x_variable)))
            ylabel(sprintf("%s [%s]",obj.y_variable, Indent.get_unit(obj.y_variable)))
        end

    end
end