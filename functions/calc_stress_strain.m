function [var_strain, var_stress] = calc_stress_strain(var_disp, var_load, var_HCS)
    % Taken from the function Robert Kerr used for his work.
    % The values were for his spherical tip data.
    
    spherical_tip_radius = 2*10^-6; % In um
    coeff_Ac_1 = 2.*spherical_tip_radius./10^-9; % Diameter in nm

    hc = var_disp-(0.75.*(var_load./var_HCS).*10^6);
    Ac = (coeff_Ac_1*pi.*var_disp) - (pi.*(var_disp.^2));
    ac = (Ac./pi).^0.5;

    var_stress = (var_load./Ac).*(10^6); % In GPa
    var_strain = (4.*hc)./(3*pi.*ac)*100; % In %
    
    var_stress = real(var_stress);
    var_strain = real(var_strain);
    
end