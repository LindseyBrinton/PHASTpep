% function to normalize libraries to translate DNA sequences into amino
% acid sequences of peptides
%
% inputs:
%       mer: number of peptides per sequence
%
%       filenamefastq: string containing the filepath, filename, and
%       extension of the raw data file from deep sequencing
%       
%       startflank: sequence prior to the beginning of the peptide sequence
%
%       endflank: sequence following the end of the peptide sequence
%
%       filenameoutput: string containing the filepath, filename, and
%       extension of the excel file to be created
%
%       PhD7: boolean identifier of whether the files correspond to screens
%       completed using NEB's PhD library
%
% output:
%       libraryexcel: table of sequences and frequencies to be exported to excel   
%
% Created by Lindsey Brinton at the University of Virginia, 2015

function[libraryexcel]=translatefastq(mer,filenamefastq,startflank,endflank,filenameoutput,PhD7)

display(['Importing file ',filenamefastq]);
% import fastq file
[Header, RawData, Qual] = fastqread(filenamefastq);
display('Input file successfully imported');
basepairs=3*mer;                                                        % calculate number of basepairs

% put nucleotide sequences in array
display('Isolating peptide sequences');
indices = strfind(RawData,endflank);                                    % find end, PhD7 = 'GGTGGAGGT'

display('Eliminating misreads with double endflank');
% misreads
for j=1:size(indices,2)                                                 % deal with misreads that contain endflank twice
    if length(indices{j})>1 
        indices{j}=[];
    elseif indices{j}<(3*mer+4)                                         % deal with reads that have endflank at beginning
        indices{j}=[];
    end
end

display('Eliminating misreads with no endflank');
% reads without end flanking region
RawData(cellfun('isempty',indices))=[];                                 % delete reads without endflank
indicesMat = cell2mat(indices);                                         % delete emppty rows

display('Finding indices with startflank');
% find indices with startflank
rep1 = ones(size(indicesMat));
indstart1 = (indicesMat-(basepairs+length(startflank)).*rep1);          % start of where startflank should be
indstart2 = (indicesMat-(basepairs+1).*rep1);                           % end of where startflank should be

RawData=char(RawData);                                                  % convert to string
startMat=char(zeros(size(indstart1,2),3));
for i=1:size(indstart1,2)
    startMat(i,:)=RawData(i,indstart1(i):indstart2(i));
end

RawData=cellstr(RawData);                                              % convert to cell array
startMatCell=cellstr(startMat);                                        % convert to cell array
RawData(~(strcmp(startflank,startMatCell)))=[];

% clear unused variables
clear('Header','Qual','indices','mer',...
    'indstart1','indstart2','RawDataChar','startMat','startCell');

display('Isolating indices of correct reads');
% isolate indices of correct reads
indicesMat = num2cell(indicesMat);                                     % convert to cell to delete incorrect reads
indicesMat(~(strcmp(startflank,startMatCell)))=[];                     % delete rest of incorrect reads
indicesMat=cell2mat(indicesMat);                                       % convert to double

display('Making array of indices of sequences');
% make array of indices of sequences
rep1 = ones(size(indicesMat)); 
indSeq1 = (indicesMat-basepairs*rep1); indSeq2 = (indicesMat-rep1);

% pull out sequences
RawData=char(RawData);                                                 % convert to string 

NukeArray=char(zeros(size(RawData,1),basepairs));
for i=1:size(RawData,1)
    NukeArray(i,:)=RawData(i,indSeq1(i):indSeq2(i));
end

display('Getting rid of codons not used by PhD7 library');
% If PhD7 library, get rid of codons not used by PhD7 library
if PhD7 == 1 % phd=1 when box selected in GUI
    badRead1=cellstr(NukeArray(:,3));
    badRead2=cellstr(NukeArray(:,6));
    badRead3=cellstr(NukeArray(:,9));
    badRead4=cellstr(NukeArray(:,12));
    badRead5=cellstr(NukeArray(:,15));
    badRead6=cellstr(NukeArray(:,18));
    badRead7=cellstr(NukeArray(:,21));
    badReadMatrix=[strcmp('A',badRead1),strcmp('A',badRead2),...
        strcmp('A',badRead3),strcmp('A',badRead4),strcmp('A',badRead5),...
        strcmp('A',badRead6),strcmp('A',badRead7),...
        strcmp('C',badRead1),strcmp('C',badRead2),...
        strcmp('C',badRead3),strcmp('C',badRead4),strcmp('C',badRead5),...
        strcmp('C',badRead6),strcmp('C',badRead7)];
    [brRow brCol]=find(badReadMatrix);                                  % find indices of instances of bad reads
    NukeArray=cellstr(NukeArray);                                       % convert to cell array
    NukeArray(unique(brRow))=[];                                        % delete bad codon reads
else
    NukeArray=cellstr(NukeArray);                                       % convert to cell array
end

% clear unused variables
clear('RawData','indSeq1','indicesMat','basepairs','rep1','indSeq2',...
    'RawDataChar2','indices2', 'brCol','brRow','badRead1','badRead2',...
    'badRead3','badRead4','badRead5','badRead6','badRead7','badReadMatrix');

% convert to amino acids
display('Converting to amino acid sequences');
AAarray = nt2aa(NukeArray,'AlternativeStartCodons',false,'ACGTonly', false);
AAarray = regexprep(AAarray,'*','Q');                                   % replace stop (*) with (Q)
clear('NukeArray');

display('Determining frequencies');
% determine frequencies
tableAA = tabulate(AAarray);                                            % calculate frequencies
tableAA = sortrows(tableAA,2);                                          % sort table
SeqFreqTable = tableAA(:,1:2);                                          % Sequences

% display stats
display(['Number of total valid reads: ',num2str(size(AAarray,1))]);
display(['Number of unique reads: ',num2str(size(SeqFreqTable,1))]);
clear('tableAA','AAarray');

display('Starting export');
% export to excel
iterationsXLS = ceil(size((SeqFreqTable),1)/(1000000));                 % Determine if for loops necessary
p=1;                                                                    % initialize counter
if iterationsXLS==1
    display('Exporting to excel: one sheet');
    [status1,message1]=xlswrite(filenameoutput,SeqFreqTable(1:length(SeqFreqTable),:),1); % write excel file--> only 1e6 rows each sheet
else
for w=1:(iterationsXLS)
    warning('off','MATLAB:xlswrite:AddSheet');
    display('Exporting to excel: multiple sheets');
    sheetI = p;                                                         % determine sheet to use
    ind2 = w*1e6; 
    ind1 = ind2-1e6+1;                                                  % find indexes within Sequence Array
    ind3 = size((SeqFreqTable),1);
    if (ind3-ind1)>(1e6-1)
        [status2,message2]=xlswrite(filenameoutput,SeqFreqTable(ind1:ind2,:),sheetI);
    else
        [status3,message3]=xlswrite(filenameoutput,SeqFreqTable(ind1:ind3,:),sheetI); % write excel file--> only 1e6 rows each sheet
    end
    p=p+1;                                                              % count up
end
end
clear('iterationsXLS');
libraryexcel=SeqFreqTable;                                              % output
display('Part 1 of program finished');
end

