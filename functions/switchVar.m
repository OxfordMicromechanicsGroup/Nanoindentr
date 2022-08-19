function [out, out_label] = switchVar(var, var_values, var_index)
    matching = matches(var_index, var);
    out = var_values(:, matching);
    out_label = var;
end