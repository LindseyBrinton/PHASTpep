% HeinisClusteringAdapt.m allows you to use a file output from an 
% Illumina platform sequencer that is already sorted by barcode. It creates
% a file that can be input into Clustering.m, available
% Rentero Rebolio,I., Sabisz,M., Baeriswyl,V., and Heinis,C. (2014)
% Identificaiton of target-binding peptide motifs by high-throughput
% sequencing of phage-selected peptides. Nucleic Acids Res., 42, e169.
%
% inputs:
%      filenamefastq: string of filepath, filename, and extension that you
%      want to use in Clustering.m
%
%      mer: number of amino acids in each peptide sequence
%
%      endflank: string of unique end flanking region of peptide (dna
%      sequence)
%
%      startflank: string of unique start flanking region of peptide (dna
%      sequence)
%      
%      PhD7: boolean of whether an NEB PhD library was used (1 for yes, 0
%      for no) - this determines whether or not the codons are constrained
%      as they are in NEB's libraries
%
%      fileoutputHeinis: string name of output file that will be input into
%      Clustering.m 
%
% output:
%      fileoutputHeinis.txt: a text file with the name indicated by user as
%      fileoutputHeinis that has the necessary format (peptide
%      sequence-abundance-nucleotide sequence) to be used in Clustering.m.
%      Note that this file will need to be imported into Excel, sorted by
%      column B from largest to smallest, and resaved as a tab delimited
%      file, then run through Clustering.m
%
% Created by Lindsey Brinton at the University of Virgina, 2016

% inputs ******************************************************************
filenamefastq = 'F:\C4G2-R1_S2_L001_R1_001.fastq';
mer = 7;
endflank='GGTGGAGGT';
startflank='TCT';
PhD7=1;
fileoutputHeinis = 'exampleHeinisAdapt';

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
PhD7=1;
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

display('Determining frequencies');
% determine frequencies
tableNA = tabulate(NukeArray);                                          % calculate frequencies of unique nucleotides
NukeArray = tableNA(:,1);                                               % make array of unique nucleotides

% convert to amino acids
display('Converting to amino acid sequences');
AAarray = nt2aa(NukeArray,'AlternativeStartCodons',false,'ACGTonly', false);
AAarray = regexprep(AAarray,'*','Q');                                   % replace stop (*) with (Q)

% put into format peptide sequence-abundance-nucleotide sequence
tableNA = [AAarray,tableNA(:,2),tableNA(:,1)];
SeqFreqTable = cell2table(tableNA);                                                 % Sequences

% write to a text file
fileoutputHeinis = SeqFreqTable;
writetable(fileoutputHeinis);
