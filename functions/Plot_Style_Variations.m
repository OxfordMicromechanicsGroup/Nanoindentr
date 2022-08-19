function [D, NumOfUniquePlots] = Plot_Style_Variations(LineStyles, Colours)
    B = LineStyles;
    C = Colours;
    [Cx,Bx] = ndgrid(1:numel(C),1:numel(B));
    D = vertcat(C(Cx(:)),B(Bx(:)));
    NumOfUniquePlots = max(size(D));
end