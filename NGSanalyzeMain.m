% Main PHASTpep file code
% created by Lindsey Brinton at the University of Virginia, 2015
% updated by Lindsey Brinton at the University of Virginia, 2016

function varargout = NGSanalyzeMain(varargin)
% NGSANALYZEMAIN MATLAB code for NGSanalyzeMain.fig
%      NGSANALYZEMAIN, by itself, creates a new NGSANALYZEMAIN or raises the existing
%      singleton*.
%
%      H = NGSANALYZEMAIN returns the handle to a new NGSANALYZEMAIN or the handle to
%      the existing singleton*.
%
%      NGSANALYZEMAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NGSANALYZEMAIN.M with the given input arguments.
%
%      NGSANALYZEMAIN('Property','Value',...) creates a new NGSANALYZEMAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NGSanalyzeMain_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NGSanalyzeMain_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NGSanalyzeMain

% Last Modified by GUIDE v2.5 06-Aug-2015 18:01:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NGSanalyzeMain_OpeningFcn, ...
                   'gui_OutputFcn',  @NGSanalyzeMain_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before NGSanalyzeMain is made visible.
function NGSanalyzeMain_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NGSanalyzeMain (see VARARGIN)

% Choose default command line output for NGSanalyzeMain
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

setappdata(0,'hMainGui',gcf); % get current figure

% UIWAIT makes NGSanalyzeMain wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = NGSanalyzeMain_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in submit1.
function submit1_Callback(hObject, eventdata, handles)
% access inputs
hMainGui = getappdata(0,'hMainGui');
mer = getappdata(hMainGui,'mer');
phdcheck = getappdata(hMainGui,'phdcheck');
othercheck = getappdata(hMainGui,'othercheck');
fileinput1 = getappdata(hMainGui,'fileinput1');
outputfile1 = getappdata(hMainGui,'outputfile1');

% if using non-phd library, read in flanking region sequences
if othercheck == 1 % other is checked
    startflank = getappdata(hMainGui,'startflank');
    endflank = getappdata(hMainGui,'finishflank');
end
    
% if using phd library, set flanking region sequences
if phdcheck == 1
    startflank = 'TCT';
    endflank = 'GGTGGAGGT';
end

display(startflank);
display (endflank);
   
% start timer
tic
    
% call function to read in .fastq file & export translated matrix to excel
toexcelfile = translatefastq(mer,fileinput1,startflank,endflank,outputfile1,phdcheck); % toexcelfile is what was exported to excel

% read timer
toc  
% hObject    handle to submit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in submit2.
function submit2_Callback(hObject, eventdata, handles)
tic
% access inputs
hMainGui = getappdata(0,'hMainGui');
libnum = getappdata(hMainGui,'libnum');
display(['libnum is: ',num2str(libnum)]);
posnum = getappdata(hMainGui,'posnum');
matnum = getappdata(hMainGui,'matnum');
outputfile2 = getappdata(hMainGui,'outputfile2');

% file 1
display('reading in set 1');
libfile1 = getappdata(hMainGui,'libfile1'); 
reffile1 = getappdata(hMainGui,'reffile1');
library1table = normalizelibrary(libfile1,reffile1,'libOne');

% file 2
display('reading in set 2');
libfile2 = getappdata(hMainGui,'libfile2');
reffile2 = getappdata(hMainGui,'reffile2');
library2table = normalizelibrary(libfile2,reffile2,'libTwo');

% combine file 1 and file 2
display('combining sets 1 & 2');
[A,ia,ja]=outerjoin(library1table,library2table,'MergeKeys',true);
clear('ia','ja','library1table','library2table');
alltogether=A;

% file 3
if libnum>2
    display('adding set 3');
    libfile3 = getappdata(hMainGui,'libfile3');
    reffile3 = getappdata(hMainGui,'reffile3');
    library3table = normalizelibrary(libfile3,reffile3,'libThree');
    [B,ib,jb]=outerjoin(A,library3table,'MergeKeys',true); % add file 3
    clear('ib','jb','A','library3table');
    alltogether=B;
end    
    
% file 4
if libnum>3    
    display('adding set 4');
    libfile4 = getappdata(hMainGui,'libfile4');
    reffile4 = getappdata(hMainGui,'reffile4');
    library4table = normalizelibrary(libfile4,reffile4,'libFour');
    [C,ic,jc]=outerjoin(B,library4table,'MergeKeys',true); % add file 4
    clear('ic','jc','B','library4table');
    alltogether=C;
end    
    
% file 5
if libnum>4    
    display('adding set 5');
    libfile5 = getappdata(hMainGui,'libfile5');
    reffile5 = getappdata(hMainGui,'reffile5');
    library5table = normalizelibrary(libfile5,reffile5,'libFive');
    [D,id,jd]=outerjoin(C,library5table,'MergeKeys',true); % add file 5
    clear('id','jd','C','library5table');
    alltogether=D;
end

% file 6
if libnum>5
    display('adding set 6');
    libfile6 = getappdata(hMainGui,'libfile6');
    reffile6 = getappdata(hMainGui,'reffile6');
    library6table = normalizelibrary(libfile6,reffile6,'libSix');
    [E,ie,je]=outerjoin(D,library6table,'MergeKeys',true); % add file 6
    clear('ie','je','D','library6table');
    alltogether=E;
end

% file 7
if libnum>6
    display('adding set 7');
    libfile7 = getappdata(hMainGui,'libfile7');
    reffile7 = getappdata(hMainGui,'reffile7');
    library7table = normalizelibrary(libfile7,reffile7,'libSeven');
    [F,iff,jf]=outerjoin(E,library7table,'MergeKeys',true); % add file 7
    clear('iff','jf','E','library7table');
    alltogether=F;
end

% file 8
if libnum>7
    display('adding set 8');
    libfile8 = getappdata(hMainGui,'libfile8');
    reffile8 = getappdata(hMainGui,'reffile8');
    library8table = normalizelibrary(libfile8,reffile8,'libEight');
    [G,ig,jg]=outerjoin(F,library8table,'MergeKeys',true); % add file 8
    clear('ig','jg','F','library8table');
    alltogether=G;
end

% file 9
if libnum>8
    display('adding set 9');
    libfile9 = getappdata(hMainGui,'libfile9');
    reffile9 = getappdata(hMainGui,'reffile9');
    library9table = normalizelibrary(libfile9,reffile9,'libNine');
    [H,ih,jh]=outerjoin(G,library9table,'MergeKeys',true); % add file 9
    clear('ih','jh','G','library9table');
    alltogether=H;
end

% file 10
if libnum>9
    display('adding set 10');
    libfile10 = getappdata(hMainGui,'libfile10');
    reffile10 = getappdata(hMainGui,'reffile10');
    library10table = normalizelibrary(libfile10,reffile10,'libTen');
    [I,ii,ji]=outerjoin(H,library10table,'MergeKeys',true); % add file 10
    clear('ii','ji','H','library10table')
    alltogether=I;
end

% file 11
if libnum>10
    display('adding set 11');
    libfile11 = getappdata(hMainGui,'libfile11');
    reffile11 = getappdata(hMainGui,'reffile11');
    library11table = normalizelibrary(libfile11,reffile11,'libEleven');
    [J,ij,jj]=outerjoin(I,library11table,'MergeKeys',true); % add file 11
    clear('ij','jj','I','library11table')
    alltogether=J;
end

% file 12
if libnum>11
    display('adding set 12');
    libfile12 = getappdata(hMainGui,'libfile12');
    reffile12 = getappdata(hMainGui,'reffile12');
    library12table = normalizelibrary(libfile12,reffile12,'libTweleve');
    [K,ik,jk]=outerjoin(J,library12table,'MergeKeys',true); % add file 12
    clear('ik','jk','J','library12table')
    alltogether=K;
end

% file 13
if libnum>12
    display('adding set 13');
    libfile13 = getappdata(hMainGui,'libfile13');
    reffile13 = getappdata(hMainGui,'reffile13');
    library13table = normalizelibrary(libfile13,reffile13,'libThirteen');
    [L,il,jl]=outerjoin(K,library13table,'MergeKeys',true); % add file 13
    clear('il','jl','K','library13table')
    alltogether=L;
end

% file 14
if libnum>13
    display('adding set 14');
    libfile14 = getappdata(hMainGui,'libfile14');
    reffile14 = getappdata(hMainGui,'reffile14');
    library14table = normalizelibrary(libfile14,reffile14,'libFourteen');
    [M,im,jm]=outerjoin(L,library14table,'MergeKeys',true); % add file 14
    clear('im','jm','L','library14table')
    alltogether=M;
end

% file 15
if libnum>14
    display('adding set 15');
    libfile15 = getappdata(hMainGui,'libfile15');
    reffile15 = getappdata(hMainGui,'reffile15');
    library15table = normalizelibrary(libfile15,reffile15,'libFifteen');
    [N,in,jn]=outerjoin(M,library15table,'MergeKeys',true); % add file 15
    clear('in','jn','M','library15table')
    alltogether=N;
end

% file 16
if libnum>15
    display('adding set 16');
    libfile16 = getappdata(hMainGui,'libfile16');
    reffile16 = getappdata(hMainGui,'reffile16');
    library16table = normalizelibrary(libfile16,reffile16,'libSixteen');
    [O,io,jo]=outerjoin(N,library16table,'MergeKeys',true); % add file 16
    clear('io','jo','N','library16table')
    alltogether=O;
end

% file 17
if libnum>16
    display('adding set 17');
    libfile17 = getappdata(hMainGui,'libfile17');
    reffile17 = getappdata(hMainGui,'reffile17');
    library17table = normalizelibrary(libfile17,reffile17,'libSeventeen');
    [P,ip,jp]=outerjoin(O,library17table,'MergeKeys',true); % add file 17
    clear('ip','jp','O','library17table')
    alltogether=P;
end

% file 18
if libnum>17
    display('adding set 18');
    libfile18 = getappdata(hMainGui,'libfile18');
    reffile18 = getappdata(hMainGui,'reffile18');
    library18table = normalizelibrary(libfile18,reffile18,'libEighteen');
    [Q,iq,jq]=outerjoin(P,library18table,'MergeKeys',true); % add file 18
    clear('iq','jq','P','library18table')
    alltogether=Q;
end

% file 19
if libnum>18
    display('adding set 19');
    libfile19 = getappdata(hMainGui,'libfile19');
    reffile19 = getappdata(hMainGui,'reffile19');
    library19table = normalizelibrary(libfile19,reffile19,'libNineteen');
    [R,ir,jr]=outerjoin(Q,library19table,'MergeKeys',true); % add file 19
    clear('ir','jr','Q','library19table')
    alltogether=R;
end

% file 20
if libnum>19
    display('adding set 20');
    libfile20 = getappdata(hMainGui,'libfile20');
    reffile20 = getappdata(hMainGui,'reffile20');
    library20table = normalizelibrary(libfile20,reffile20,'libTwenty');
    [S,is,js]=outerjoin(R,library20table,'MergeKeys',true); % add file 20
    clear('is','js','R','library20table')
    alltogether=S;
end


% sort matrix
sortedmatrix=sortmatrix(alltogether,libnum,posnum,matnum);

% write table
display('creating matrix file');
writetable(sortedmatrix,outputfile2);
%writetable(sortedmatrix,outputfile2);
display('matrix file completed');
toc

% hObject    handle to submit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function outputfile2_Callback(hObject, eventdata, handles)
% hObject    handle to outputfile2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outputfile2 as text
%        str2double(get(hObject,'String')) returns contents of outputfile2 as a double
hMainGui = getappdata(0,'hMainGui');
outputfile2 = get(hObject,'String');
setappdata(hMainGui,'outputfile2',outputfile2);

% --- Executes during object creation, after setting all properties.
function outputfile2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outputfile2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browse.
function browse_Callback(hObject, eventdata, handles)
% hObject    handle to browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.fastq');  % browse to find .fastq file
inputfile1name=[browsepath,browsename];
display(['file selected: ', inputfile1name]);
setappdata(hMainGui,'inputfile1name',inputfile1name);
if length(inputfile1name)>2
    display('File selected using browse');
end
inputfile1_Callback(hObject, eventdata, handles);


% --- Executes on button press in phd.
function phd_Callback(hObject, eventdata, handles)
% hObject    handle to phd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
phdcheck = get(hObject,'Value');
setappdata(hMainGui,'phdcheck',phdcheck);
% Hint: get(hObject,'Value') returns toggle state of phd


% --- Executes on button press in other.
function other_Callback(hObject, eventdata, handles)
% hObject    handle to other (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
othercheck = get(hObject,'Value');
setappdata(hMainGui,'othercheck',othercheck);
% Hint: get(hObject,'Value') returns toggle state of other



function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
startflank = get(hObject,'String');
setappdata(hMainGui,'startflank',startflank);
% Hints: get(hObject,'String') returns contents of start as text
%        str2double(get(hObject,'String')) returns contents of start as a double


% --- Executes during object creation, after setting all properties.
function start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function finish_Callback(hObject, eventdata, handles)
% hObject    handle to finish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
finishflank = get(hObject,'String');
setappdata(hMainGui,'finishflank',finishflank);
% Hints: get(hObject,'String') returns contents of finish as text
%        str2double(get(hObject,'String')) returns contents of finish as a double


% --- Executes during object creation, after setting all properties.
function finish_CreateFcn(hObject, eventdata, handles)
% hObject    handle to finish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mer_Callback(hObject, eventdata, handles)
% hObject    handle to mer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
mer = str2double(get(hObject,'String'));
setappdata(hMainGui,'mer',mer);
% Hints: get(hObject,'String') returns contents of mer as text
%        str2double(get(hObject,'String')) returns contents of mer as a double


% --- Executes during object creation, after setting all properties.
function mer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function inputfile1_Callback(hObject, eventdata, handles)
% hObject    handle to inputfile1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
fileinput1 = get(hObject,'String');
setappdata(hMainGui,'fileinput1',fileinput1);

fileinputed1 = getappdata(hMainGui,'inputfile1name'); % replace text after select something in browse

if length(fileinputed1)>2
    set(handles.inputfile1,'String',fileinputed1);
    setappdata(hMainGui,'fileinput1',fileinputed1);
end
% Hints: get(hObject,'String') returns contents of inputfile1 as text
%        str2double(get(hObject,'String')) returns contents of inputfile1 as a double


% --- Executes during object creation, after setting all properties.
function inputfile1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputfile1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lib1_Callback(hObject, eventdata, handles)
% hObject    handle to lib1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
libfile1 = get(hObject,'String');
setappdata(hMainGui,'libfile1',libfile1);

libfiled1 = getappdata(hMainGui,'libfile1name'); % replace text after select something in browse
if length(libfiled1)>2
    set(handles.lib1,'String',libfiled1);
    setappdata(hMainGui,'libfile1',libfiled1);
end

% Hints: get(hObject,'String') returns contents of lib1 as text
%        str2double(get(hObject,'String')) returns contents of lib1 as a double


% --- Executes during object creation, after setting all properties.
function lib1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lib1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lib2_Callback(hObject, eventdata, handles)
% hObject    handle to lib2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
libfile2 = get(hObject,'String');
setappdata(hMainGui,'libfile2',libfile2);

libfiled2 = getappdata(hMainGui,'libfile2name'); % replace text after select something in browse
if length(libfiled2)>2
    set(handles.lib2,'String',libfiled2);
    setappdata(hMainGui,'libfile2',libfiled2);
end
% Hints: get(hObject,'String') returns contents of lib2 as text
%        str2double(get(hObject,'String')) returns contents of lib2 as a double


% --- Executes during object creation, after setting all properties.
function lib2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lib2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lib3_Callback(hObject, eventdata, handles)
% hObject    handle to lib3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
libfile3 = get(hObject,'String');
setappdata(hMainGui,'libfile3',libfile3);

libfiled3 = getappdata(hMainGui,'libfile3name'); % replace text after select something in browse
if length(libfiled3)>2
    set(handles.lib3,'String',libfiled3);
    setappdata(hMainGui,'libfile3',libfiled3);
end
% Hints: get(hObject,'String') returns contents of lib3 as text
%        str2double(get(hObject,'String')) returns contents of lib3 as a double


% --- Executes during object creation, after setting all properties.
function lib3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lib3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lib4_Callback(hObject, eventdata, handles)
% hObject    handle to lib4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
libfile4 = get(hObject,'String');
setappdata(hMainGui,'libfile4',libfile4);

libfiled4 = getappdata(hMainGui,'libfile4name'); % replace text after select something in browse
if length(libfiled4)>2
    set(handles.lib4,'String',libfiled4);
    setappdata(hMainGui,'libfile4',libfiled4);
end
% Hints: get(hObject,'String') returns contents of lib4 as text
%        str2double(get(hObject,'String')) returns contents of lib4 as a double


% --- Executes during object creation, after setting all properties.
function lib4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lib4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lib5_Callback(hObject, eventdata, handles)
% hObject    handle to lib5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
libfile5 = get(hObject,'String');
setappdata(hMainGui,'libfile5',libfile5);

libfiled5 = getappdata(hMainGui,'libfile5name'); % replace text after select something in browse
if length(libfiled5)>2
    set(handles.lib5,'String',libfiled5);
    setappdata(hMainGui,'libfile5',libfiled5);
end
% Hints: get(hObject,'String') returns contents of lib5 as text
%        str2double(get(hObject,'String')) returns contents of lib5 as a double


% --- Executes during object creation, after setting all properties.
function lib5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lib5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lib6_Callback(hObject, eventdata, handles)
% hObject    handle to lib6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
libfile6 = get(hObject,'String');
setappdata(hMainGui,'libfile6',libfile6);

libfiled6 = getappdata(hMainGui,'libfile6name'); % replace text after select something in browse
if length(libfiled6)>2
    set(handles.lib6,'String',libfiled6);
    setappdata(hMainGui,'libfile6',libfiled6);
end
% Hints: get(hObject,'String') returns contents of lib6 as text
%        str2double(get(hObject,'String')) returns contents of lib6 as a double


% --- Executes during object creation, after setting all properties.
function lib6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lib6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lib7_Callback(hObject, eventdata, handles)
% hObject    handle to lib7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
libfile7 = get(hObject,'String');
setappdata(hMainGui,'libfile7',libfile7);

libfiled7 = getappdata(hMainGui,'libfile7name'); % replace text after select something in browse
if length(libfiled7)>2
    set(handles.lib7,'String',libfiled7);
    setappdata(hMainGui,'libfile7',libfiled7);
end
% Hints: get(hObject,'String') returns contents of lib7 as text
%        str2double(get(hObject,'String')) returns contents of lib7 as a double


% --- Executes during object creation, after setting all properties.
function lib7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lib7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lib8_Callback(hObject, eventdata, handles)
% hObject    handle to lib8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
libfile8 = get(hObject,'String');
setappdata(hMainGui,'libfile8',libfile8);

libfiled8 = getappdata(hMainGui,'libfile8name'); % replace text after select something in browse
if length(libfiled8)>2
    set(handles.lib8,'String',libfiled8);
    setappdata(hMainGui,'libfile8',libfiled8);
end
% Hints: get(hObject,'String') returns contents of lib8 as text
%        str2double(get(hObject,'String')) returns contents of lib8 as a double


% --- Executes during object creation, after setting all properties.
function lib8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lib8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lib9_Callback(hObject, eventdata, handles)
% hObject    handle to lib9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
libfile9 = get(hObject,'String');
setappdata(hMainGui,'libfile9',libfile9);

libfiled9 = getappdata(hMainGui,'libfile9name'); % replace text after select something in browse
if length(libfiled9)>2
    set(handles.lib9,'String',libfiled9);
    setappdata(hMainGui,'libfile9',libfiled9);
end
% Hints: get(hObject,'String') returns contents of lib9 as text
%        str2double(get(hObject,'String')) returns contents of lib9 as a double


% --- Executes during object creation, after setting all properties.
function lib9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lib9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lib10_Callback(hObject, eventdata, handles)
% hObject    handle to lib10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
libfile10 = get(hObject,'String');
setappdata(hMainGui,'libfile10',libfile10);

libfiled10 = getappdata(hMainGui,'libfile10name'); % replace text after select something in browse
if length(libfiled10)>2
    set(handles.lib10,'String',libfiled10);
    setappdata(hMainGui,'libfile10',libfiled10);
end
% Hints: get(hObject,'String') returns contents of lib10 as text
%        str2double(get(hObject,'String')) returns contents of lib10 as a double


% --- Executes during object creation, after setting all properties.
function lib10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lib10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lib11_Callback(hObject, eventdata, handles)
% hObject    handle to lib11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
libfile11 = get(hObject,'String');
setappdata(hMainGui,'libfile11',libfile11);

libfiled11 = getappdata(hMainGui,'libfile11name'); % replace text after select something in browse
if length(libfiled11)>2
    set(handles.lib11,'String',libfiled11);
    setappdata(hMainGui,'libfile11',libfiled11);
end
% Hints: get(hObject,'String') returns contents of lib11 as text
%        str2double(get(hObject,'String')) returns contents of lib11 as a double


% --- Executes during object creation, after setting all properties.
function lib11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lib11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lib12_Callback(hObject, eventdata, handles)
% hObject    handle to lib12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
libfile12 = get(hObject,'String');
setappdata(hMainGui,'libfile12',libfile12);

libfiled12 = getappdata(hMainGui,'libfile12name'); % replace text after select something in browse
if length(libfiled12)>2
    set(handles.lib12,'String',libfiled12);
    setappdata(hMainGui,'libfile12',libfiled12);
end
% Hints: get(hObject,'String') returns contents of lib12 as text
%        str2double(get(hObject,'String')) returns contents of lib12 as a double


% --- Executes during object creation, after setting all properties.
function lib12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lib12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lib13_Callback(hObject, eventdata, handles)
% hObject    handle to lib13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
libfile13 = get(hObject,'String');
setappdata(hMainGui,'libfile13',libfile13);

libfiled13 = getappdata(hMainGui,'libfile13name'); % replace text after select something in browse
if length(libfiled13)>2
    set(handles.lib13,'String',libfiled13);
    setappdata(hMainGui,'libfile13',libfiled13);
end
% Hints: get(hObject,'String') returns contents of lib13 as text
%        str2double(get(hObject,'String')) returns contents of lib13 as a double


% --- Executes during object creation, after setting all properties.
function lib13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lib13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lib14_Callback(hObject, eventdata, handles)
% hObject    handle to lib14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
libfile14 = get(hObject,'String');
setappdata(hMainGui,'libfile14',libfile14);

libfiled14 = getappdata(hMainGui,'libfile14name'); % replace text after select something in browse
if length(libfiled14)>2
    set(handles.lib14,'String',libfiled14);
    setappdata(hMainGui,'libfile1',libfiled14);
end
% Hints: get(hObject,'String') returns contents of lib14 as text
%        str2double(get(hObject,'String')) returns contents of lib14 as a double


% --- Executes during object creation, after setting all properties.
function lib14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lib14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lib15_Callback(hObject, eventdata, handles)
% hObject    handle to lib15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
libfile15 = get(hObject,'String');
setappdata(hMainGui,'libfile15',libfile15);

libfiled15 = getappdata(hMainGui,'libfile15name'); % replace text after select something in browse
if length(libfiled15)>2
    set(handles.lib15,'String',libfiled15);
    setappdata(hMainGui,'libfile15',libfiled15);
end
% Hints: get(hObject,'String') returns contents of lib15 as text
%        str2double(get(hObject,'String')) returns contents of lib15 as a double


% --- Executes during object creation, after setting all properties.
function lib15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lib15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ref1_Callback(hObject, eventdata, handles)
% hObject    handle to ref1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
reffile1 = get(hObject,'String');
setappdata(hMainGui,'reffile1',reffile1);

reffiled1 = getappdata(hMainGui,'reffile1name'); % replace text after select something in browse
if length(reffiled1)>2
    set(handles.ref1,'String',reffiled1);
    setappdata(hMainGui,'reffile1',reffiled1);
end
% Hints: get(hObject,'String') returns contents of ref1 as text
%        str2double(get(hObject,'String')) returns contents of ref1 as a double


% --- Executes during object creation, after setting all properties.
function ref1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ref2_Callback(hObject, eventdata, handles)
% hObject    handle to ref2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
reffile2 = get(hObject,'String');
setappdata(hMainGui,'reffile2',reffile2);

reffiled2 = getappdata(hMainGui,'reffile2name'); % replace text after select something in browse
if length(reffiled2)>2
    set(handles.ref2,'String',reffiled2);
    setappdata(hMainGui,'reffile2',reffiled2);
end
% Hints: get(hObject,'String') returns contents of ref2 as text
%        str2double(get(hObject,'String')) returns contents of ref2 as a double


% --- Executes during object creation, after setting all properties.
function ref2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ref3_Callback(hObject, eventdata, handles)
% hObject    handle to ref3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
reffile3 = get(hObject,'String');
setappdata(hMainGui,'reffile3',reffile3);

reffiled3 = getappdata(hMainGui,'reffile3name'); % replace text after select something in browse
if length(reffiled3)>2
    set(handles.ref3,'String',reffiled3);
    setappdata(hMainGui,'reffile3',reffiled3);
end
% Hints: get(hObject,'String') returns contents of ref3 as text
%        str2double(get(hObject,'String')) returns contents of ref3 as a double


% --- Executes during object creation, after setting all properties.
function ref3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ref4_Callback(hObject, eventdata, handles)
% hObject    handle to ref4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
reffile4 = get(hObject,'String');
setappdata(hMainGui,'reffile4',reffile4);

reffiled4 = getappdata(hMainGui,'reffile4name'); % replace text after select something in browse
if length(reffiled4)>2
    set(handles.ref4,'String',reffiled4);
    setappdata(hMainGui,'reffile4',reffiled4);
end
% Hints: get(hObject,'String') returns contents of ref4 as text
%        str2double(get(hObject,'String')) returns contents of ref4 as a double


% --- Executes during object creation, after setting all properties.
function ref4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ref5_Callback(hObject, eventdata, handles)
% hObject    handle to ref5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
reffile5 = get(hObject,'String');
setappdata(hMainGui,'reffile5',reffile5);

reffiled5 = getappdata(hMainGui,'reffile5name'); % replace text after select something in browse
if length(reffiled5)>2
    set(handles.ref5,'String',reffiled5);
    setappdata(hMainGui,'reffile5',reffiled5);
end
% Hints: get(hObject,'String') returns contents of ref5 as text
%        str2double(get(hObject,'String')) returns contents of ref5 as a double


% --- Executes during object creation, after setting all properties.
function ref5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ref6_Callback(hObject, eventdata, handles)
% hObject    handle to ref6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
reffile6 = get(hObject,'String');
setappdata(hMainGui,'reffile6',reffile6);

reffiled6 = getappdata(hMainGui,'reffile6name'); % replace text after select something in browse
if length(reffiled6)>2
    set(handles.ref6,'String',reffiled6);
    setappdata(hMainGui,'reffile6',reffiled6);
end
% Hints: get(hObject,'String') returns contents of ref6 as text
%        str2double(get(hObject,'String')) returns contents of ref6 as a double


% --- Executes during object creation, after setting all properties.
function ref6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ref7_Callback(hObject, eventdata, handles)
% hObject    handle to ref7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
reffile7 = get(hObject,'String');
setappdata(hMainGui,'reffile7',reffile7);

reffiled7 = getappdata(hMainGui,'reffile7name'); % replace text after select something in browse
if length(reffiled7)>2
    set(handles.ref7,'String',reffiled7);
    setappdata(hMainGui,'reffile7',reffiled7);
end
% Hints: get(hObject,'String') returns contents of ref7 as text
%        str2double(get(hObject,'String')) returns contents of ref7 as a double


% --- Executes during object creation, after setting all properties.
function ref7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ref8_Callback(hObject, eventdata, handles)
% hObject    handle to ref8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
reffile8 = get(hObject,'String');
setappdata(hMainGui,'reffile8',reffile8);

reffiled8 = getappdata(hMainGui,'reffile8name'); % replace text after select something in browse
if length(reffiled8)>2
    set(handles.ref8,'String',reffiled8);
    setappdata(hMainGui,'reffile8',reffiled8);
end
% Hints: get(hObject,'String') returns contents of ref8 as text
%        str2double(get(hObject,'String')) returns contents of ref8 as a double


% --- Executes during object creation, after setting all properties.
function ref8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ref9_Callback(hObject, eventdata, handles)
% hObject    handle to ref9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
reffile9 = get(hObject,'String');
setappdata(hMainGui,'reffile9',reffile9);

reffiled9 = getappdata(hMainGui,'reffile9name'); % replace text after select something in browse
if length(reffiled9)>2
    set(handles.ref9,'String',reffiled9);
    setappdata(hMainGui,'reffile9',reffiled9);
end
% Hints: get(hObject,'String') returns contents of ref9 as text
%        str2double(get(hObject,'String')) returns contents of ref9 as a double


% --- Executes during object creation, after setting all properties.
function ref9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ref10_Callback(hObject, eventdata, handles)
% hObject    handle to ref10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
reffile10 = get(hObject,'String');
setappdata(hMainGui,'reffile10',reffile10);

reffiled10 = getappdata(hMainGui,'reffile10name'); % replace text after select something in browse
if length(reffiled10)>2
    set(handles.ref10,'String',reffiled10);
    setappdata(hMainGui,'reffile10',reffiled10);
end
% Hints: get(hObject,'String') returns contents of ref10 as text
%        str2double(get(hObject,'String')) returns contents of ref10 as a double


% --- Executes during object creation, after setting all properties.
function ref10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ref11_Callback(hObject, eventdata, handles)
% hObject    handle to ref11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
reffile11 = get(hObject,'String');
setappdata(hMainGui,'reffile11',reffile11);

reffiled11 = getappdata(hMainGui,'reffile11name'); % replace text after select something in browse
if length(reffiled11)>2
    set(handles.ref11,'String',reffiled11);
    setappdata(hMainGui,'reffile11',reffiled11);
end
% Hints: get(hObject,'String') returns contents of ref11 as text
%        str2double(get(hObject,'String')) returns contents of ref11 as a double


% --- Executes during object creation, after setting all properties.
function ref11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ref12_Callback(hObject, eventdata, handles)
% hObject    handle to ref12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
reffile12 = get(hObject,'String');
setappdata(hMainGui,'reffile12',reffile12);

reffiled12 = getappdata(hMainGui,'reffile12name'); % replace text after select something in browse
if length(reffiled12)>2
    set(handles.ref12,'String',reffiled12);
    setappdata(hMainGui,'reffile12',reffiled12);
end
% Hints: get(hObject,'String') returns contents of ref12 as text
%        str2double(get(hObject,'String')) returns contents of ref12 as a double


% --- Executes during object creation, after setting all properties.
function ref12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ref13_Callback(hObject, eventdata, handles)
% hObject    handle to ref13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
reffile13 = get(hObject,'String');
setappdata(hMainGui,'reffile13',reffile13);

reffiled13 = getappdata(hMainGui,'reffile13name'); % replace text after select something in browse
if length(reffiled13)>2
    set(handles.ref13,'String',reffiled13);
    setappdata(hMainGui,'reffile13',reffiled13);
end
% Hints: get(hObject,'String') returns contents of ref13 as text
%        str2double(get(hObject,'String')) returns contents of ref13 as a double


% --- Executes during object creation, after setting all properties.
function ref13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ref14_Callback(hObject, eventdata, handles)
% hObject    handle to ref14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
reffile14 = get(hObject,'String');
setappdata(hMainGui,'reffile14',reffile14);

reffiled14 = getappdata(hMainGui,'reffile14name'); % replace text after select something in browse
if length(reffiled14)>2
    set(handles.ref14,'String',reffiled14);
    setappdata(hMainGui,'reffile14',reffiled14);
end
% Hints: get(hObject,'String') returns contents of ref14 as text
%        str2double(get(hObject,'String')) returns contents of ref14 as a double


% --- Executes during object creation, after setting all properties.
function ref14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ref15_Callback(hObject, eventdata, handles)
% hObject    handle to ref15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
reffile15 = get(hObject,'String');
setappdata(hMainGui,'reffile15',reffile15);

reffiled15 = getappdata(hMainGui,'reffile15name'); % replace text after select something in browse
if length(reffiled15)>2
    set(handles.ref15,'String',reffiled15);
    setappdata(hMainGui,'reffile15',reffiled15);
end
% Hints: get(hObject,'String') returns contents of ref15 as text
%        str2double(get(hObject,'String')) returns contents of ref15 as a double


% --- Executes during object creation, after setting all properties.
function ref15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browse1.
function browse1_Callback(hObject, eventdata, handles)
% hObject    handle to browse1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
libfile1name=[browsepath,browsename];
display(['file 1 selected: ', libfile1name]);
setappdata(hMainGui,'libfile1name',libfile1name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
lib1_Callback(hObject, eventdata, handles);


% --- Executes on button press in browse2.
function browse2_Callback(hObject, eventdata, handles)
% hObject    handle to browse2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
libfile2name=[browsepath,browsename];
display(['file 2 selected: ', libfile2name]);
setappdata(hMainGui,'libfile2name',libfile2name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
lib2_Callback(hObject, eventdata, handles);


% --- Executes on button press in browse3.
function browse3_Callback(hObject, eventdata, handles)
% hObject    handle to browse3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
libfile3name=[browsepath,browsename];
display(['file 3 selected: ', libfile3name]);
setappdata(hMainGui,'libfile3name',libfile3name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
lib3_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse4.
function browse4_Callback(hObject, eventdata, handles)
% hObject    handle to browse4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
libfile4name=[browsepath,browsename];
display(['file 4 selected: ', libfile4name]);
setappdata(hMainGui,'libfile4name',libfile4name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
lib4_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse5.
function browse5_Callback(hObject, eventdata, handles)
% hObject    handle to browse5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
libfile5name=[browsepath,browsename];
display(['file 5 selected: ', libfile5name]);
setappdata(hMainGui,'libfile5name',libfile5name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
lib5_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse6.
function browse6_Callback(hObject, eventdata, handles)
% hObject    handle to browse6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
libfile6name=[browsepath,browsename];
display(['file 6 selected: ', libfile6name]);
setappdata(hMainGui,'libfile6name',libfile6name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
lib6_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse7.
function browse7_Callback(hObject, eventdata, handles)
% hObject    handle to browse7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
libfile7name=[browsepath,browsename];
display(['file 7 selected: ', libfile7name]);
setappdata(hMainGui,'libfile7name',libfile7name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
lib7_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse8.
function browse8_Callback(hObject, eventdata, handles)
% hObject    handle to browse8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
libfile8name=[browsepath,browsename];
display(['file 8 selected: ', libfile8name]);
setappdata(hMainGui,'libfile8name',libfile8name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
lib8_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse9.
function browse9_Callback(hObject, eventdata, handles)
% hObject    handle to browse9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
libfile9name=[browsepath,browsename];
display(['file 9 selected: ', libfile9name]);
setappdata(hMainGui,'libfile9name',libfile9name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
lib9_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse10.
function browse10_Callback(hObject, eventdata, handles)
% hObject    handle to browse10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
libfile10name=[browsepath,browsename];
display(['file 10 selected: ', libfile10name]);
setappdata(hMainGui,'libfile10name',libfile10name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
lib10_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse11.
function browse11_Callback(hObject, eventdata, handles)
% hObject    handle to browse11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
libfile11name=[browsepath,browsename];
display(['file 11 selected: ', libfile11name]);
setappdata(hMainGui,'libfile11name',libfile11name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
lib11_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse12.
function browse12_Callback(hObject, eventdata, handles)
% hObject    handle to browse12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
libfile12name=[browsepath,browsename];
display(['file 12 selected: ', libfile12name]);
setappdata(hMainGui,'libfile12name',libfile12name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
lib12_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse13.
function browse13_Callback(hObject, eventdata, handles)
% hObject    handle to browse13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
libfile13name=[browsepath,browsename];
display(['file 13 selected: ', libfile13name]);
setappdata(hMainGui,'libfile13name',libfile13name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
lib13_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse14.
function browse14_Callback(hObject, eventdata, handles)
% hObject    handle to browse14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
libfile14name=[browsepath,browsename];
display(['file 14 selected: ', libfile14name]);
setappdata(hMainGui,'libfile14name',libfile14name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
lib14_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse15.
function browse15_Callback(hObject, eventdata, handles)
% hObject    handle to browse15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
libfile15name=[browsepath,browsename];
display(['file 15 selected: ', libfile15name]);
setappdata(hMainGui,'libfile15name',libfile15name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
lib15_Callback(hObject, eventdata, handles);

% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in browse22.
function browse22_Callback(hObject, eventdata, handles)
% hObject    handle to browse22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
reffile2name=[browsepath,browsename];
display(['ref file 2 selected: ', reffile2name]);
setappdata(hMainGui,'reffile2name',reffile2name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
ref2_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse23.
function browse23_Callback(hObject, eventdata, handles)
% hObject    handle to browse23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
reffile3name=[browsepath,browsename];
display(['ref file 3 selected: ', reffile3name]);
setappdata(hMainGui,'reffile3name',reffile3name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
ref3_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse24.
function browse24_Callback(hObject, eventdata, handles)
% hObject    handle to browse24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
reffile4name=[browsepath,browsename];
display(['ref file 4 selected: ', reffile4name]);
setappdata(hMainGui,'reffile4name',reffile4name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
ref4_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse25.
function browse25_Callback(hObject, eventdata, handles)
% hObject    handle to browse25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
reffile5name=[browsepath,browsename];
display(['ref file 5 selected: ', reffile5name]);
setappdata(hMainGui,'reffile5name',reffile5name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
ref5_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse26.
function browse26_Callback(hObject, eventdata, handles)
% hObject    handle to browse26 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
reffile6name=[browsepath,browsename];
display(['ref file 6 selected: ', reffile6name]);
setappdata(hMainGui,'reffile6name',reffile6name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
ref6_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse27.
function browse27_Callback(hObject, eventdata, handles)
% hObject    handle to browse27 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
reffile7name=[browsepath,browsename];
display(['ref file 7 selected: ', reffile7name]);
setappdata(hMainGui,'reffile7name',reffile7name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
ref7_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse28.
function browse28_Callback(hObject, eventdata, handles)
% hObject    handle to browse28 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
reffile8name=[browsepath,browsename];
display(['ref file 8 selected: ', reffile8name]);
setappdata(hMainGui,'reffile8name',reffile8name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
ref8_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse29.
function browse29_Callback(hObject, eventdata, handles)
% hObject    handle to browse29 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
reffile9name=[browsepath,browsename];
display(['ref file 9 selected: ', reffile9name]);
setappdata(hMainGui,'reffile9name',reffile9name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
ref9_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse30.
function browse30_Callback(hObject, eventdata, handles)
% hObject    handle to browse30 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
reffile10name=[browsepath,browsename];
display(['ref file 10 selected: ', reffile10name]);
setappdata(hMainGui,'reffile10name',reffile10name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
ref10_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse31.
function browse31_Callback(hObject, eventdata, handles)
% hObject    handle to browse31 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
reffile11name=[browsepath,browsename];
display(['ref file 11 selected: ', reffile11name]);
setappdata(hMainGui,'reffile11name',reffile11name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
ref11_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse32.
function browse32_Callback(hObject, eventdata, handles)
% hObject    handle to browse32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
reffile12name=[browsepath,browsename];
display(['ref file 12 selected: ', reffile12name]);
setappdata(hMainGui,'reffile12name',reffile12name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
ref12_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse33.
function browse33_Callback(hObject, eventdata, handles)
% hObject    handle to browse33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
reffile13name=[browsepath,browsename];
display(['ref file 13 selected: ', reffile13name]);
setappdata(hMainGui,'reffile13name',reffile13name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
ref13_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse34.
function browse34_Callback(hObject, eventdata, handles)
% hObject    handle to browse34 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
reffile14name=[browsepath,browsename];
display(['ref file 14 selected: ', reffile14name]);
setappdata(hMainGui,'reffile14name',reffile14name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
ref14_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse35.
function browse35_Callback(hObject, eventdata, handles)
% hObject    handle to browse35 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
reffile15name=[browsepath,browsename];
display(['ref file 15 selected: ', reffile15name]);
setappdata(hMainGui,'reffile15name',reffile15name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
ref15_Callback(hObject, eventdata, handles);


function libnum_Callback(hObject, eventdata, handles)
% hObject    handle to libnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
libnum = str2double(get(hObject,'String'));
display(['libnum_callback libnum ',libnum]);
setappdata(hMainGui,'libnum',libnum);

% reset backgrounds
set(handles.lib1,'BackgroundColor','white');
set(handles.lib2,'BackgroundColor','white');
set(handles.lib3,'BackgroundColor','white');
set(handles.lib4,'BackgroundColor','white');
set(handles.lib5,'BackgroundColor','white');
set(handles.lib6,'BackgroundColor','white');
set(handles.lib7,'BackgroundColor','white');
set(handles.lib8,'BackgroundColor','white');
set(handles.lib9,'BackgroundColor','white');
set(handles.lib10,'BackgroundColor','white');
set(handles.lib11,'BackgroundColor','white');
set(handles.lib12,'BackgroundColor','white');
set(handles.lib13,'BackgroundColor','white');
set(handles.lib14,'BackgroundColor','white');
set(handles.lib15,'BackgroundColor','white');
set(handles.lib16,'BackgroundColor','white');
set(handles.lib17,'BackgroundColor','white');
set(handles.lib18,'BackgroundColor','white');
set(handles.lib19,'BackgroundColor','white');
set(handles.lib20,'BackgroundColor','white');
set(handles.ref1,'BackgroundColor','white');
set(handles.ref2,'BackgroundColor','white');
set(handles.ref3,'BackgroundColor','white');
set(handles.ref4,'BackgroundColor','white');
set(handles.ref5,'BackgroundColor','white');
set(handles.ref6,'BackgroundColor','white');
set(handles.ref7,'BackgroundColor','white');
set(handles.ref8,'BackgroundColor','white');
set(handles.ref9,'BackgroundColor','white');
set(handles.ref10,'BackgroundColor','white');
set(handles.ref11,'BackgroundColor','white');
set(handles.ref12,'BackgroundColor','white');
set(handles.ref13,'BackgroundColor','white');
set(handles.ref14,'BackgroundColor','white');
set(handles.ref15,'BackgroundColor','white');
set(handles.ref16,'BackgroundColor','white');
set(handles.ref17,'BackgroundColor','white');
set(handles.ref18,'BackgroundColor','white');
set(handles.ref19,'BackgroundColor','white');
set(handles.ref20,'BackgroundColor','white');
% Hints: get(hObject,'String') returns contents of libnum as text
%        str2double(get(hObject,'String')) returns contents of libnum as a double


% --- Executes during object creation, after setting all properties.
function libnum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to libnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function posnum_Callback(hObject, eventdata, handles)
% hObject    handle to posnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
libnum = getappdata(hMainGui,'libnum');
posnum = str2double(get(hObject,'String'));
setappdata(hMainGui,'posnum',posnum);

% reset backgrounds
set(handles.lib1,'BackgroundColor','white');
set(handles.lib2,'BackgroundColor','white');
set(handles.lib3,'BackgroundColor','white');
set(handles.lib4,'BackgroundColor','white');
set(handles.lib5,'BackgroundColor','white');
set(handles.lib6,'BackgroundColor','white');
set(handles.lib7,'BackgroundColor','white');
set(handles.lib8,'BackgroundColor','white');
set(handles.lib9,'BackgroundColor','white');
set(handles.lib10,'BackgroundColor','white');
set(handles.lib11,'BackgroundColor','white');
set(handles.lib12,'BackgroundColor','white');
set(handles.lib13,'BackgroundColor','white');
set(handles.lib14,'BackgroundColor','white');
set(handles.lib15,'BackgroundColor','white');
set(handles.lib16,'BackgroundColor','white');
set(handles.lib17,'BackgroundColor','white');
set(handles.lib18,'BackgroundColor','white');
set(handles.lib19,'BackgroundColor','white');
set(handles.lib20,'BackgroundColor','white');
set(handles.ref1,'BackgroundColor','white');
set(handles.ref2,'BackgroundColor','white');
set(handles.ref3,'BackgroundColor','white');
set(handles.ref4,'BackgroundColor','white');
set(handles.ref5,'BackgroundColor','white');
set(handles.ref6,'BackgroundColor','white');
set(handles.ref7,'BackgroundColor','white');
set(handles.ref8,'BackgroundColor','white');
set(handles.ref9,'BackgroundColor','white');
set(handles.ref10,'BackgroundColor','white');
set(handles.ref11,'BackgroundColor','white');
set(handles.ref12,'BackgroundColor','white');
set(handles.ref13,'BackgroundColor','white');
set(handles.ref14,'BackgroundColor','white');
set(handles.ref15,'BackgroundColor','white');
set(handles.ref16,'BackgroundColor','white');
set(handles.ref17,'BackgroundColor','white');
set(handles.ref18,'BackgroundColor','white');
set(handles.ref19,'BackgroundColor','white');
set(handles.ref20,'BackgroundColor','white');

if libnum>0
    set(handles.lib1,'BackgroundColor',[1 0.75 0.8]);
    set(handles.ref1,'BackgroundColor',[1 0.75 0.8]);
end

if libnum>1
    set(handles.lib2,'BackgroundColor',[1 0.75 0.8]);
    set(handles.ref2,'BackgroundColor',[1 0.75 0.8]);
end

if libnum>2
    set(handles.lib3,'BackgroundColor',[1 0.75 0.8]);
    set(handles.ref3,'BackgroundColor',[1 0.75 0.8]);
end

if libnum>3
    set(handles.lib4,'BackgroundColor',[1 0.75 0.8]);
    set(handles.ref4,'BackgroundColor',[1 0.75 0.8]);
end

if libnum>4
    set(handles.lib5,'BackgroundColor',[1 0.75 0.8]);
    set(handles.ref5,'BackgroundColor',[1 0.75 0.8]);
end

if libnum>5
    set(handles.lib6,'BackgroundColor',[1 0.75 0.8]);
    set(handles.ref6,'BackgroundColor',[1 0.75 0.8]);
end

if libnum>6
    set(handles.lib7,'BackgroundColor',[1 0.75 0.8]);
    set(handles.ref7,'BackgroundColor',[1 0.75 0.8]);
end

if libnum>7
    set(handles.lib8,'BackgroundColor',[1 0.75 0.8]);
    set(handles.ref8,'BackgroundColor',[1 0.75 0.8]);
end

if libnum>8
    set(handles.lib9,'BackgroundColor',[1 0.75 0.8]);
    set(handles.ref9,'BackgroundColor',[1 0.75 0.8]);
end

if libnum>9
    set(handles.lib10,'BackgroundColor',[1 0.75 0.8]);
    set(handles.ref10,'BackgroundColor',[1 0.75 0.8]);
end

if libnum>10
    set(handles.lib11,'BackgroundColor',[1 0.75 0.8]);
    set(handles.ref11,'BackgroundColor',[1 0.75 0.8]);
end

if libnum>11
    set(handles.lib12,'BackgroundColor',[1 0.75 0.8]);
    set(handles.ref12,'BackgroundColor',[1 0.75 0.8]);
end

if libnum>12
    set(handles.lib13,'BackgroundColor',[1 0.75 0.8]);
    set(handles.ref13,'BackgroundColor',[1 0.75 0.8]);
end

if libnum>13
    set(handles.lib14,'BackgroundColor',[1 0.75 0.8]);
    set(handles.ref14,'BackgroundColor',[1 0.75 0.8]);
end

if libnum>14
    set(handles.lib15,'BackgroundColor',[1 0.75 0.8]);
    set(handles.ref15,'BackgroundColor',[1 0.75 0.8]);
end

if libnum>15
    set(handles.lib16,'BackgroundColor',[1 0.75 0.8]);
    set(handles.ref16,'BackgroundColor',[1 0.75 0.8]);
end

if libnum>16
    set(handles.lib17,'BackgroundColor',[1 0.75 0.8]);
    set(handles.ref17,'BackgroundColor',[1 0.75 0.8]);
end

if libnum>17
    set(handles.lib18,'BackgroundColor',[1 0.75 0.8]);
    set(handles.ref18,'BackgroundColor',[1 0.75 0.8]);
end

if libnum>18
    set(handles.lib19,'BackgroundColor',[1 0.75 0.8]);
    set(handles.ref19,'BackgroundColor',[1 0.75 0.8]);
end

if libnum>19
    set(handles.lib20,'BackgroundColor',[1 0.75 0.8]);
    set(handles.ref20,'BackgroundColor',[1 0.75 0.8]);
end

if posnum>0
    set(handles.lib1,'BackgroundColor',[0.79 1 1]);
    set(handles.ref1,'BackgroundColor',[0.79 1 1]);
end

if posnum>1
    set(handles.lib2,'BackgroundColor',[0.79 1 1]);
    set(handles.ref2,'BackgroundColor',[0.79 1 1]);
end

if posnum>2
    set(handles.lib3,'BackgroundColor',[0.79 1 1]);
    set(handles.ref3,'BackgroundColor',[0.79 1 1]);
end

if posnum>3
    set(handles.lib4,'BackgroundColor',[0.79 1 1]);
    set(handles.ref4,'BackgroundColor',[0.79 1 1]);
end

if posnum>4
    set(handles.lib5,'BackgroundColor',[0.79 1 1]);
    set(handles.ref5,'BackgroundColor',[0.79 1 1]);
end

if posnum>5
    set(handles.lib6,'BackgroundColor',[0.79 1 1]);
    set(handles.ref6,'BackgroundColor',[0.79 1 1]);
end

if posnum>6
    set(handles.lib7,'BackgroundColor',[0.79 1 1]);
    set(handles.ref7,'BackgroundColor',[0.79 1 1]);
end

if posnum>7
    set(handles.lib8,'BackgroundColor',[0.79 1 1]);
    set(handles.ref8,'BackgroundColor',[0.79 1 1]);
end

if posnum>8
    set(handles.lib9,'BackgroundColor',[0.79 1 1]);
    set(handles.ref9,'BackgroundColor',[0.79 1 1]);
end

if posnum>9
    set(handles.lib10,'BackgroundColor',[0.79 1 1]);
    set(handles.ref10,'BackgroundColor',[0.79 1 1]);
end

if posnum>10
    set(handles.lib11,'BackgroundColor',[0.79 1 1]);
    set(handles.ref11,'BackgroundColor',[0.79 1 1]);
end

if posnum>11
    set(handles.lib12,'BackgroundColor',[0.79 1 1]);
    set(handles.ref12,'BackgroundColor',[0.79 1 1]);
end

if posnum>12
    set(handles.lib13,'BackgroundColor',[0.79 1 1]);
    set(handles.ref13,'BackgroundColor',[0.79 1 1]);
end

if posnum>13
    set(handles.lib14,'BackgroundColor',[0.79 1 1]);
    set(handles.ref14,'BackgroundColor',[0.79 1 1]);
end

if posnum>14
    set(handles.lib15,'BackgroundColor',[0.79 1 1]);
    set(handles.ref15,'BackgroundColor',[0.79 1 1]);
end

if posnum>15
    set(handles.lib16,'BackgroundColor',[0.79 1 1]);
    set(handles.ref16,'BackgroundColor',[0.79 1 1]);
end

if posnum>16
    set(handles.lib17,'BackgroundColor',[0.79 1 1]);
    set(handles.ref17,'BackgroundColor',[0.79 1 1]);
end

if posnum>17
    set(handles.lib18,'BackgroundColor',[0.79 1 1]);
    set(handles.ref18,'BackgroundColor',[0.79 1 1]);
end

if posnum>18
    set(handles.lib19,'BackgroundColor',[0.79 1 1]);
    set(handles.ref19,'BackgroundColor',[0.79 1 1]);
end

if posnum>19
    set(handles.lib20,'BackgroundColor',[0.79 1 1]);
    set(handles.ref20,'BackgroundColor',[0.79 1 1]);
end
% Hints: get(hObject,'String') returns contents of posnum as text
%        str2double(get(hObject,'String')) returns contents of posnum as a double


% --- Executes during object creation, after setting all properties.
function posnum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to posnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function matnum_Callback(hObject, eventdata, handles)
% hObject    handle to matnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
matnum = str2double(get(hObject,'String'));
setappdata(hMainGui,'matnum',matnum);
% Hints: get(hObject,'String') returns contents of matnum as text
%        str2double(get(hObject,'String')) returns contents of matnum as a double


% --- Executes during object creation, after setting all properties.
function matnum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to matnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lib16_Callback(hObject, eventdata, handles)
% hObject    handle to lib16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
libfile16 = get(hObject,'String');
setappdata(hMainGui,'libfile16',libfile16);

libfiled16 = getappdata(hMainGui,'libfile16name'); % replace text after select something in browse
if length(libfiled16)>2
    set(handles.lib16,'String',libfiled16);
    setappdata(hMainGui,'libfile16',libfiled16);
end
% Hints: get(hObject,'String') returns contents of lib16 as text
%        str2double(get(hObject,'String')) returns contents of lib16 as a double


% --- Executes during object creation, after setting all properties.
function lib16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lib16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lib17_Callback(hObject, eventdata, handles)
% hObject    handle to lib17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
libfile17 = get(hObject,'String');
setappdata(hMainGui,'libfile17',libfile17);

libfiled17 = getappdata(hMainGui,'libfile17name'); % replace text after select something in browse
if length(libfiled17)>2
    set(handles.lib17,'String',libfiled17);
    setappdata(hMainGui,'libfile17',libfiled17);
end
% Hints: get(hObject,'String') returns contents of lib17 as text
%        str2double(get(hObject,'String')) returns contents of lib17 as a double


% --- Executes during object creation, after setting all properties.
function lib17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lib17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lib18_Callback(hObject, eventdata, handles)
% hObject    handle to lib18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
libfile18 = get(hObject,'String');
setappdata(hMainGui,'libfile18',libfile18);

libfiled18 = getappdata(hMainGui,'libfile18name'); % replace text after select something in browse
if length(libfiled18)>2
    set(handles.lib18,'String',libfiled18);
    setappdata(hMainGui,'libfile18',libfiled18);
end
% Hints: get(hObject,'String') returns contents of lib18 as text
%        str2double(get(hObject,'String')) returns contents of lib18 as a double


% --- Executes during object creation, after setting all properties.
function lib18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lib18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lib19_Callback(hObject, eventdata, handles)
% hObject    handle to lib19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
libfile19 = get(hObject,'String');
setappdata(hMainGui,'libfile19',libfile19);

libfiled19 = getappdata(hMainGui,'libfile19name'); % replace text after select something in browse
if length(libfiled19)>2
    set(handles.lib19,'String',libfiled19);
    setappdata(hMainGui,'libfile19',libfiled19);
end
% Hints: get(hObject,'String') returns contents of lib19 as text
%        str2double(get(hObject,'String')) returns contents of lib19 as a double


% --- Executes during object creation, after setting all properties.
function lib19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lib19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lib20_Callback(hObject, eventdata, handles)
% hObject    handle to lib20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
libfile20 = get(hObject,'String');
setappdata(hMainGui,'libfile20',libfile20);

libfiled20 = getappdata(hMainGui,'libfile20name'); % replace text after select something in browse
if length(libfiled20)>2
    set(handles.lib20,'String',libfiled20);
    setappdata(hMainGui,'libfile20',libfiled20);
end
% Hints: get(hObject,'String') returns contents of lib20 as text
%        str2double(get(hObject,'String')) returns contents of lib20 as a double


% --- Executes during object creation, after setting all properties.
function lib20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lib20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ref16_Callback(hObject, eventdata, handles)
% hObject    handle to ref16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
reffile16 = get(hObject,'String');
setappdata(hMainGui,'reffile16',reffile16);

reffiled16 = getappdata(hMainGui,'reffile16name'); % replace text after select something in browse
if length(reffiled16)>2
    set(handles.ref16,'String',reffiled16);
    setappdata(hMainGui,'reffile16',reffiled16);
end
% Hints: get(hObject,'String') returns contents of ref16 as text
%        str2double(get(hObject,'String')) returns contents of ref16 as a double


% --- Executes during object creation, after setting all properties.
function ref16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ref17_Callback(hObject, eventdata, handles)
% hObject    handle to ref17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
reffile17 = get(hObject,'String');
setappdata(hMainGui,'reffile17',reffile17);

reffiled17 = getappdata(hMainGui,'reffile17name'); % replace text after select something in browse
if length(reffiled17)>2
    set(handles.ref17,'String',reffiled17);
    setappdata(hMainGui,'reffile17',reffiled17);
end
% Hints: get(hObject,'String') returns contents of ref17 as text
%        str2double(get(hObject,'String')) returns contents of ref17 as a double


% --- Executes during object creation, after setting all properties.
function ref17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ref18_Callback(hObject, eventdata, handles)
% hObject    handle to ref18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
reffile18 = get(hObject,'String');
setappdata(hMainGui,'reffile18',reffile18);

reffiled18 = getappdata(hMainGui,'reffile18name'); % replace text after select something in browse
if length(reffiled18)>2
    set(handles.ref18,'String',reffiled18);
    setappdata(hMainGui,'reffile18',reffiled18);
end
% Hints: get(hObject,'String') returns contents of ref18 as text
%        str2double(get(hObject,'String')) returns contents of ref18 as a double


% --- Executes during object creation, after setting all properties.
function ref18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ref19_Callback(hObject, eventdata, handles)
% hObject    handle to ref19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
reffile19 = get(hObject,'String');
setappdata(hMainGui,'reffile19',reffile19);

reffiled19 = getappdata(hMainGui,'reffile19name'); % replace text after select something in browse
if length(reffiled19)>2
    set(handles.ref19,'String',reffiled19);
    setappdata(hMainGui,'reffile19',reffiled19);
end
% Hints: get(hObject,'String') returns contents of ref19 as text
%        str2double(get(hObject,'String')) returns contents of ref19 as a double


% --- Executes during object creation, after setting all properties.
function ref19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ref20_Callback(hObject, eventdata, handles)
% hObject    handle to ref20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
reffile20 = get(hObject,'String');
setappdata(hMainGui,'reffile20',reffile20);

reffiled20 = getappdata(hMainGui,'reffile20name'); % replace text after select something in browse
if length(reffiled20)>2
    set(handles.ref20,'String',reffiled20);
    setappdata(hMainGui,'reffile20',reffiled20);
end
% Hints: get(hObject,'String') returns contents of ref20 as text
%        str2double(get(hObject,'String')) returns contents of ref20 as a double


% --- Executes during object creation, after setting all properties.
function ref20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browse16.
function browse16_Callback(hObject, eventdata, handles)
% hObject    handle to browse16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
libfile16name=[browsepath,browsename];
display(['file 16 selected: ', libfile16name]);
setappdata(hMainGui,'libfile16name',libfile16name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
lib16_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse17.
function browse17_Callback(hObject, eventdata, handles)
% hObject    handle to browse17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
libfile17name=[browsepath,browsename];
display(['file 17 selected: ', libfile17name]);
setappdata(hMainGui,'libfile17name',libfile17name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
lib17_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse18.
function browse18_Callback(hObject, eventdata, handles)
% hObject    handle to browse18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
libfile18name=[browsepath,browsename];
display(['file 18 selected: ', libfile18name]);
setappdata(hMainGui,'libfile18name',libfile18name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
lib18_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse19.
function browse19_Callback(hObject, eventdata, handles)
% hObject    handle to browse19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
libfile19name=[browsepath,browsename];
display(['file 19 selected: ', libfile19name]);
setappdata(hMainGui,'libfile19name',libfile19name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
lib19_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse20.
function browse20_Callback(hObject, eventdata, handles)
% hObject    handle to browse20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
libfile20name=[browsepath,browsename];
display(['file 20 selected: ', libfile20name]);
setappdata(hMainGui,'libfile20name',libfile20name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
lib20_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse36.
function browse36_Callback(hObject, eventdata, handles)
% hObject    handle to browse36 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
reffile16name=[browsepath,browsename];
display(['ref file 16 selected: ', reffile16name]);
setappdata(hMainGui,'reffile16name',reffile16name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
ref16_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse37.
function browse37_Callback(hObject, eventdata, handles)
% hObject    handle to browse37 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
reffile17name=[browsepath,browsename];
display(['ref file 17 selected: ', reffile17name]);
setappdata(hMainGui,'reffile17name',reffile17name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
ref17_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse38.
function browse38_Callback(hObject, eventdata, handles)
% hObject    handle to browse38 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
reffile18name=[browsepath,browsename];
display(['ref file 18 selected: ', reffile18name]);
setappdata(hMainGui,'reffile18name',reffile18name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
ref18_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse39.
function browse39_Callback(hObject, eventdata, handles)
% hObject    handle to browse39 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
reffile19name=[browsepath,browsename];
display(['ref file 19 selected: ', reffile19name]);
setappdata(hMainGui,'reffile19name',reffile19name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
ref19_Callback(hObject, eventdata, handles);

% --- Executes on button press in browse40.
function browse40_Callback(hObject, eventdata, handles)
% hObject    handle to browse40 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
reffile20name=[browsepath,browsename];
display(['ref file 20 selected: ', reffile20name]);
setappdata(hMainGui,'reffile20name',reffile20name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
ref20_Callback(hObject, eventdata, handles);


function outputfile1_Callback(hObject, eventdata, handles)
% hObject    handle to outputfile1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outputfile1 as text
%        str2double(get(hObject,'String')) returns contents of outputfile1 as a double
hMainGui = getappdata(0,'hMainGui');
outputfile1 = get(hObject,'String');
setappdata(hMainGui,'outputfile1',outputfile1);

% --- Executes during object creation, after setting all properties.
function outputfile1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outputfile1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browse21.
function browse21_Callback(hObject, eventdata, handles)
hMainGui = getappdata(0,'hMainGui');
[browsename,browsepath,browseindex] = uigetfile('*.xlsx');  % browse to find .fastq file
reffile1name=[browsepath,browsename];
display(['ref file 1 selected: ', reffile1name]);
setappdata(hMainGui,'reffile1name',reffile1name);
%if length(inputfile1)>2
%    feedbackFilepath
%end
ref1_Callback(hObject, eventdata, handles);
% hObject    handle to browse21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
