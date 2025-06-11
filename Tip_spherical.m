classdef Tip_spherical < Tip
    % tip Class representing the nanoindenter tip.
    %   Represents a single indent, containing its information.
    %
    % Type the following to open up the documentation for this class:
    % >>> doc tip
    % >>> help tip
    %
    % Robin Scales 2025
    %

    properties
        spherical_tip_radius (1,1) double = 2*10^-6; % In um
        coeff_Ac_1 (1,1) double = 2.*(2*10^-6)./10^-9; % Diameter in nm
    end

    methods
        % Functions which rely on the object
        function stress = get_stress(obj, depth, load)
            Ac = obj.get_Ac(obj.coeff_Ac_1, depth);
            stress = (load./Ac).*(10^6); % In GPa
            stress = real(stress);
        end

        function strain = get_strain(obj, depth, load, HCS)
            ac = obj.get_ac(obj.coeff_Ac_1, depth);
            hc = obj.get_hc(depth, load, HCS);
            strain = (4.*hc)./(3*pi.*ac)*100; % In %
        end

        function hc = get_hc(~, depth, load, HCS)
            hc = depth-(0.75.*(load./HCS).*10^6);
        end
            
        function Ac = get_Ac(~, coeff_Ac_1, depth)
            Ac = (coeff_Ac_1*pi.*depth) - (pi.*(depth.^2));
        end
        
        function ac = get_ac(obj, coeff_Ac_1, depth)
            Ac = obj.get_Ac(coeff_Ac_1, depth);
            % Ac = (coeff_Ac_1*pi.*depth) - (pi.*(depth.^2));
            ac = (Ac./pi).^0.5;
        end

    end

end