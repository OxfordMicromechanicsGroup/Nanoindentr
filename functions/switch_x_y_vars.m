function [x, x_label, y, y_label] = switch_x_y_vars(x_var, y_var, var_values, var_index)
    [x, x_label] = switchVar(x_var, var_values, var_index);
    [y, y_label] = switchVar(y_var, var_values, var_index);
end