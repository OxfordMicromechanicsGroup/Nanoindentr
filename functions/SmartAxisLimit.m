function Lim = SmartAxisLimit(y_var, y)
    disp('Running SmartAxisLimit')
    
    BinWidth = [];
    minValue = [];
    maxValue = [];
    

    if sum(contains(y_var, 'Modulus')) >= 1
        minValue = 0;
        maxValue = 1300;
        BinWidth = 100;
    end

    if sum(contains(y_var, 'Hardness')) >= 1
        minValue = 0;
        maxValue = 100;
        BinWidth = 1;
    end

    if sum(contains(y_var, 'HCS')) >= 1
        minValue = 0;
        maxValue = [];
        BinWidth = 10000;
    end
    
    if sum(contains(y_var, 'Stress')) >= 1
        minValue = 0;
        maxValue = 10;
        BinWidth = 0.1;
    end
    
    if sum(contains(y_var, 'Strain')) >= 1
        minValue = 0;
        maxValue = 50;
        BinWidth = 0.1;
    end

    if isempty(BinWidth) == true
        Lim = [0, inf];
        return
    end
    
    if and(isempty(minValue) == false, isempty(maxValue) == false)
        InRange = and(y>=minValue, y<=maxValue);
        y = y(InRange);
    end
    
    disp(BinWidth);
    
    opts = {'Normalization', 'countdensity', 'BinWidth', BinWidth};
    
    [N,edges] = histcounts(y, opts{:});
%     Bins = edges(1:end-1)+((edges(2)-edges(1))/2);
    Idx = find(N > 0, 1, 'last');
%     disp(N);
    Lim = [0, edges(Idx+1)];
    
    figure;
    histogram(y, 'EdgeAlpha', 0, opts{:});
    
    
    disp('Running SmartAxisLimit done')

end