% function to normalize libraries to read depth and amplification bias
%
% inputs:
%       library: string containing the filepath and filename
%       of the excel file containing the translated library. Library
%       should be translated using the function "translatefastq", as set up
%       in the program "NGSanalyzeMain.m".
%
%       reflibrary: string containing the filepath and filename of the
%       excel file containing the translated reference library. Reference
%       library refers to a sequenced amplification of the naive library
%       that has been diluted 1:10. The aliquot should have the same lot
%       number as the other input library. The reference library should be
%       translated using the function "translatefastq.m", as set up in the
%       program "NGSanalyzeMain.m".
%       
%       libraryname: string containing a unique name for this library
%
% output:
%       libraryNtable: table containing sequences and normalized read 
%       frequencies for a library   
%
% Created by Lindsey Brinton at the University of Virginia, 2015


function[libraryNtable]=normalizelibrary(library,reflibrary,libraryname)
display('starting library normalization');
% create table for reference library
[x,libref1a,r] = xlsread(reflibrary,'A:A'); 
[libref1b] = xlsread(reflibrary,'B:B');
tableref1 = table(libref1a,libref1b,'VariableNames',{'Peptide','RefLibrary'});

% create table for library 1
[x,lib1a,r] = xlsread(library,'A:A');
[lib1b] = xlsread(library,'B:B');
table1 = table(lib1a,lib1b,'VariableNames',{'Peptide','Library'});

% join the reference library and library together
[mergelibrary,a,b]=outerjoin(tableref1,table1,'MergeKeys',true);

% clear extra variables
clear('x','libref1a','r','libref1b','tableref1','x','lib1a','r','lib1b');
clear('table1','a','b');

% convert table to two arrays
Seqs = table2array(mergelibrary(:,{'Peptide'})); % array of strings (sequences)
Nums = table2array(mergelibrary(:,2:end));       % array of doubles (read frequencies)

% separate reference library and library
readlengths = [nansum(Nums(:,1)), nansum(Nums(:,2))];     % get readlengths before changes

% only keep sequences with frequencies >10 in library
display('deleting sequences with frequencies < 11');
lib=Nums(:,2);reflib=Nums(:,1);
[greaterthan10ind,i1]=find(lib>10);  
lib=lib(greaterthan10ind,:);
reflib=reflib(greaterthan10ind,:);
Seqs=Seqs(greaterthan10ind);

% normalize to read length (division)
display('normalizing to read length');
reflib(isnan(reflib)) = mode(reflib(reflib>0));   % make NaN = nonzero mode
reflib = reflib/readlengths(1);                  % normalize reference library
lib = lib/readlengths(2);                        % normalize library

% normalize library to reference library
display('normalizing to reference library');
libraryN = lib./reflib;
libraryN = num2cell(libraryN);                   % convert to cell

% combine sequences and quantities
libraryNtable = table(Seqs,libraryN,'VariableNames',{'Peptide',libraryname});
display('library normalization complete');
end



