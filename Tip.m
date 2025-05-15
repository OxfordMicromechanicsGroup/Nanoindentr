classdef Tip
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
        name (1,1) string % Tip name on box
        owner (1,1) string % Owner of tip
        type (1,1) string % Berkovich, spherical, etc.
        calibration_date (1,1) datetime % The date that the tip was calibrated
    end


    % tip = Tip;
    % tip.name = tipName;
    % tip.owner = "Bo-Shiuan Li";
    % tip.type = "Berkovich";
    % tip.calibration_date = datetime("01/01/2020", "Format","dd/MM/uuuu");
end