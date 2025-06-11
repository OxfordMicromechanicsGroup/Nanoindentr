classdef Tip_berkovich < Tip
    % tip Class representing a Berkovich nanoindenter tip.
    %   Represents a single indent, containing its information.
    %
    % Type the following to open up the documentation for this class:
    % >>> doc Tip_berkovich
    % >>> help Tip_berkovich
    %
    % Robin Scales 2025
    %6

    properties
        spherical_tip_radius (1,1) double = 2*10^-6; % In um
        % coeff_Ac_1 (1,1) double = 2.*(2*10^-6)./10^-9; % Diameter in nm

        % Jamal, M and Morgan, MN (2017) Materials characterization part I: contact
        % area of the Berkovich indenter for nanoindentation tests. International
        % Journal of Advanced Manufacturing Technology. ISSN 0268-3768
        % "𝐶_0 = 24.5 for a perfect Berkovich indenter"
        % and https://en.wikipedia.org/wiki/Nanoindentation 21/05/2025
        A_coeffs (1,:) double = 24.5; % Equ 4 of the above paper.
    end

    methods
        % Functions which rely on the object
        function stress = get_A(obj, A_coeffs)
            num_coeffs = length(A_coeffs);
            powers = 2^
        end

    end

end