function [x, x_label, y, y_label, BinWidth, MidPoints, y_binVal, y_BinError_pos, y_BinError_neg] = f_BinData(NumBins, var_values_validtests, x_var, y_var, var_index, LineMethod, BoundaryMethod)

    [x, x_label, y, y_label] = switch_x_y_vars(x_var, y_var, var_values_validtests, var_index);
    
%     if crop_x(2) == inf
%         crop_x(2) = max(x);
%     end
    
    user_edges = linspace(0, max(x), NumBins);
    
    [Y, edges] = discretize(x, user_edges);
    BinWidth = edges(2)-edges(1);
    MidPoints = (edges(1:end)+(BinWidth/2))';
    
    y_binVal = nan(NumBins, 1);
    y_BinError_pos = nan(NumBins, 1);
    y_BinError_neg = nan(NumBins, 1);
    
    for i = 1:NumBins
        TF_bin = (Y==i);
        bin_y = y(TF_bin);
        switch lower(LineMethod)
            case 'mean'
                y_binVal(i) = mean(bin_y, 'omitnan');
            case 'median'
                y_binVal(i) = median(bin_y, 'omitnan');
        end
        
        switch lower(BoundaryMethod)
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
end