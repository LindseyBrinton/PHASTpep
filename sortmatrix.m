% function to combine multiple libraries together such that their
% duplicated sequences are combined into a single row
%
% inputs: 
%       matrix: table of all libraries
%
%       libnumber: total number of libraries, not including reference
%       libraries
%
%       posnumber: number of libraries corresponding to positive screens
%
%       matrixnum: number of sequences to be included in final matrix
%
% outputs:
%       librarymatrix: cell array of sorted sequences
%       
% Created by Lindsey Brinton at the University of Virginia, 2015


function[librarymatrix]=sortmatrix(matrix,libnumber,posnumber,matrixnum)

display('sorting the matrix');

% determine average fold change across targeted & non-targeted cell screens
negnumber = libnumber - posnumber; % number of non-targeted cell screens
Seqs=table2array(matrix(:,1));
Nums=table2array(matrix(:,2:end));
emptyind=cellfun(@isempty,Nums);
for i=1:size(emptyind,2)
    Nums(emptyind(:,i),i)={min([Nums{:,i}])};
end
Nums=cell2mat(Nums); % convert to array of doubles
avgpos=sum(Nums(:,1:posnumber),2)/posnumber; % average across targeted cell screens
avgneg=sum(Nums(:,(posnumber+1):libnumber),2)/negnumber; % average across non-CAFs
bigDiff=avgpos./avgneg; % Difference between target and non-target
[bigDiffSort,sortInd]=sort(bigDiff,'descend');

% create sorted matrix
if matrixnum>size(Nums,1)   % cannot put in more sequences than exist
    matrixnum=size(Nums,1);
end

Nums=num2cell(Nums(sortInd(1:matrixnum),:));
Score=num2cell(bigDiff(sortInd(1:matrixnum)));
matrixcell=[Seqs(sortInd(1:matrixnum)),Nums,Score];
librarymatrix=cell2table(matrixcell);
end
   
    