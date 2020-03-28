rng('default')  % For reproducibility
allData = {};
dists = {};
aapl = readtable('AAPL.csv');
axp = readtable('AXP.csv');
ba = readtable('BA.csv');
cat = readtable('CAT.csv');
csco = readtable('CSCO.csv');
cvx = readtable('CVX.csv');
dis = readtable('DIS.csv');
gs = readtable('GS.csv');
hd = readtable('HD.csv');
ibm = readtable('IBM.csv');
intc = readtable('INTC.csv');
jnj = readtable('JNJ.csv');
jpm = readtable('JPM.csv');
ko = readtable('KO.csv');
mcd = readtable('MCD.csv');
mmm = readtable('MMM.csv');
mrk = readtable('MRK.csv');
msft = readtable('MSFT.csv');
nke = readtable('NKE.csv');
pfe = readtable('PFE.csv');
pg = readtable('PG.csv');
trv = readtable('TRV.csv');
utx = readtable('UTX.csv');
v = readtable('V.csv');
vz = readtable('CVX.csv');
wba = readtable('WBA.csv');
wmnt = readtable('WMT.csv');
xom =readtable('XOM.csv');
dow = readtable('DJI.csv');


%this is the line to change to run the code with different assets.
%keep dow where it is, and just enter whatevern you call the data for each
%asset. See ReadMe on Github. 
allData = {dow aapl axp utx wmnt};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

weights = zeros(1, numel(allData) - 1);

%for loop taken from Jon's code.
for i = 1:numel(allData)
    datax = table2array(allData{i}(:,6));

    %datax = randn(6*252,5);
    %Sturge's Rule
    %nbins = 1 + 3.322 * log(length(data)); 
    %Rice's Rule
    nbins = ceil((length(datax)^(1/3)) * 2);
    bins = (1:nbins)';
    datax = tick2ret(datax);
    minimum = min(datax); 
    maximum = max(datax); 
    step_size = (maximum-minimum)/nbins;  %get bin width
    sorted = sort(datax);
    nrow = size(sorted,1);
    ncol = size(sorted,2);


    binned = [];
    %binned = zeros(6*252,30);
    for j = 1:nrow
        for k = 1:ncol
            for b = 1:nbins
                if sorted(j,k) >= minimum+(step_size*(b-1)) && sorted(j,k) <= minimum+(step_size*(b))
                    binned(j,k) = bins(b,:);
                end
                if sorted(j,k) >= minimum+(step_size*(23))
                    binned(j,k) = 24;
                end
            end
        end
    end


    counted = zeros(24,1);
    for l = 1:size(binned, 1)
        for j = 1:ncol
            for u = 1:length(unique(binned))
                if floor(binned(l,j)) == floor(u)
                    counted(u,j) = counted(u,j) + 1; 
                end
            end
        end
    end

    freq = counted ./ length(datax); 

    %smoothing method
    epsilon = 0.0000001; 
    for q = 1:size(freq, 1)
        y = nnz(~freq(:,j));
        if freq(q,1) == 0
           %make each zero value have some small epsilon
           freq(q,1) = freq(q,j) + epsilon;
        end
        if freq(q,j) ~= 0
           %probability must add to one, so each time we add one epsilon
           %we subtract a fraction of epsilon from all nonzero values
           freq(q,1) = freq(q,1) - (epsilon/(length(freq)-y)); 
        end
    end
    dists{i} = freq;
    
    
    figure(2)
    hold on
    plot((1:size(dists{i}, 1))', dists{i}(:,1))
end
legend;
hold off


minDivergences = [];  %will hold the result of each call to hillClimb
minWeights = [];  %will hold weight combos found by hillClimb
target = combineDist(dists, updateWeights(weights));  %Dow 
startingDivergence = getKL(dists{1}(:, 1), target)  %starting givergence
startingWeights = weights;  %startiung weights
jumps = 0; %starting value of jumps. Parameter for hillClimb() will be icremented


%indexes = zeros([1 20]);  
% %for i= 1:20
    %[minDivergences, minWeights] = hillClimb(dists, target, weights, jumps, minDivergences, minWeights);
    %[minDivergence, index] = min(abs(minDivergences(:, 1:end-1)));
    %minDivergence
    %minWeight = minWeights(index, :)
    %indexes(i) = index;
%end

%tuple that holds the results of hill climbing
[minDivergences, minWeights] = hillClimb(dists, target, weights, jumps, minDivergences, minWeights);

%minDivergence is the smallest divergence found, index is the index where 
%minDivergence was found. 
[minDivergence, index] = min(abs(minDivergences(:, 1:end-1)));

%output minDivergence
minDivergence

%output minWeight
minWeight = minWeights(index, :)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                            %FUNCTIONS%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [minDivergences, minWeights] = hillClimb(dists, dow, weights,jumps, minDivergences, minWeights)
    while(jumps <= 300000)
        weights = updateWeights(weights);
        divergence = getKL(combineDist(dists, weights), dow);
        startingDivergence = 9999999999;
    
        %move down the curve
        while(abs(divergence) < abs(startingDivergence))
            weights = climbWeights(weights);
            startingDivergence = divergence;
            divergence = getKL(dow, combineDist(dists, weights));
        end
    
        %record the min divergence and weights we found
        minDivergences = [minDivergences startingDivergence];
        minWeights =[minWeights ; weights(:,:)];
    
        %once we cant move down the curve anymore, 
        %jump to another place in the curve
        jumps = jumps + 1;
    end
end

%calculate KL divergence
function divergence = getKL(dist1, dist2)
    logDiff1 = log2(dist1) - log2(dist2);
    mult1 = dist1 .* logDiff1;
    logDiff2 = log2(dist2) - log2(dist1);
    mult2 = dist2 .* logDiff2;
    isNan = isnan(mult1);
    mult1 = mult1(~isNan);
    isNan = isnan(mult2);
    mult2 = mult2(~isNan);
    divergence = (sum(mult1) + sum(mult2))/2;
end

%combine the distributions of the assets into a single distribution
function distribution = combineDist(dists, weights)
    distribution = zeros(size(dists{1}, 1), 1);
    j = 1;
    for i = 2:size(dists, 2)
        distribution = distribution + (dists{i}(:, 1) * weights(j));
        j = j + 1;
    end
end

%jump to another possible weight setting
function weights = updateWeights(weights)
    weights = randfixedsum(numel(weights),1,100,1,100)';
end

%trying to move 'up' a curve as opposed to jumping around
function weights = climbWeights(weights)
    for i = 1:numel(weights)
        index = randi([1, numel(weights)]);
        index2 = randi([1, numel(weights)]);
        amount = (randi([1, 100],1, 1))/100;
        weights(index) = weights(index) + amount;
        weights(index2) = weights(index2) - amount;
    end
end



