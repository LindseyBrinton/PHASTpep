# PHASTpep
PHage Analysis for Selective Targeted PEPtides (PHASTpep) software translates, normalizes, and sorts frequency data from next-generation sequencing files.

This software expects an input of files from an Illumina sequencer that are already sorted by barcode and in the .fastq format.

Put the following files together in a directory in MATLAB:
  1. NGSanalyzeMain.m
  2. NGSanalyzeMain.fig
  3. translatefastq.m
  4. sortmatrix.m
  5. normalizelibrary.m
  
Run NGSanalyzeMain.m to pull up a graphical user interface (GUI).
There are instructions included in the GUI for all of the inputs necessary.

Example files are included that can be run with the software:
  1. exampleAforPHASTpep.fastq can be used with part 1 of the software.
     Download the example files, noting where you put them so you can find them again.
     
     Here are example inputs to use:
          amino acids/sequence: 7
          check NEB PhD library
          raw data file: you can either browse for this or enter it directly
                         filepath, filename, and file extension that you called exampleAforPHASTpep.fastq
                         If you saved this to your desktop on a PC, it's likely similar to C:\Users\username\Desktop\exampleAforPHASTpep.fastq
                         Note that "username" will be specific to your computer
                         Note that the extension must be .fastq
          file to create: filepath, filename, and file extension - whatever you want to call the output file
                          for example C:\Users\username\Desktop\part1test.xlsx
                          Note that "username" will be specific to your computer
                          Note that the extension must be .xlsx
     Click submit and then go to the MATLAB command window to watch the progress of the program.
     Once completed, open the file in Excel.
     Highlight the columns of data and chose Data>Sort, then Sort by = Column B, Sort On = Values, and Order = Largest to Smallest
     Save the file.
     It should now look like the example output file given, Part1OutputOfExampleAforPHASTpep.xlsx
     
  2. PostiveLibraryExampleAforPHASTpep.xlsx, PostiveLibraryExampleBforPHASTpep.xlsx,
     NegativeLibraryExampleAforPHASTpep.xlsx, and exampleReferencePHASTpep.xlsx can be used with part 2 of the software.
     Download the example files, noting where you put them so you can find them again.
        
     Here are example inputs to use:
           total number of libraries: 3
           total number of positive libraries: 2
           Note that when you tell it how many positive libraries, it will shade the positive library text boxes blue and negative one pink
           sequences in matrix: 500
           browse and find PostiveLibraryExampleAforPHASTpep.xlsx as library 1
           browse and find exampleReferencePHASTpep.xlsx as ref 1
           browse and find PostiveLibraryExampleBforPHASTpep.xlsx as library 2
           browse and find exampleReferencePHASTpep.xlsx as ref 2
           browse and find NegativeLibraryExampleAforPHASTpep.xlsx as library 3
           browse and find exampleReferencePHASTpep.xlsx as ref 3
           file to create: filepath, filename, and file extension - whatever you want to call the output file
                          for example C:\Users\username\Desktop\part2test.xlsx
                          Note that "username" will be specific to your computer
                          Note that the extension must be .xlsx
     Click submit and then go to the MATLAB command window to watch the progress of the program.
     Once completed, open the file in Excel.
     It should look like the example output file given, Part2OutputforPHASTpep.xlsx
     
     
     
