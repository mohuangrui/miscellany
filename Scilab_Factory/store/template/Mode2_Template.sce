// ***************************** Batch Scilab Mode 2 ***************************

//* Comments: this script does not store the input data within the specifid range,
//* but it stores all the rusult data. so it can use to manipulate result data
//* between cases. this feature requires less memory.

//* ******************************* configure **********************************

//* system configure: increase the memory dedicated to data

//gstacksize('max');
stacksize('max');

//* erase all variables

clear;

//* case settings:

//* data structure
Case=tlist(["CL";"Amount";"Name";"Rows";"Cols";"Data";"Rlt"],[ ],[ ],[ ],[ ],list(),list());
Row=tlist(["RowRange";"Start";"End";"Amount"],[ ],[ ],[ ]);
Col=tlist(["ColRange";"List";"Amount"],[ ],[ ]);
LoadData=list();//* use to load data from files

//* specify the row range of data to process for each case
Row.Start=1; //* the begin row No.
Row.End=$; //* the end row No., $ means the last index of array.

//* specify the column range of data to process for each case
Col.List=[$-1,$]; //* the list of target columns No.

//* system configure: specify the files for load and output

Data_In="Data.in";
Data_Out="Data.out";
Run_Log="Run.log";
Monitor_Info="Monitor.info";

//* ******************************** load data *********************************

Data_In_FID=file('open',Data_In,'unknow');
//* strip the head comments
CommentLine=read(Data_In_FID, 1, 1,'(A)');
CommentLine=read(Data_In_FID, 1, 1,'(A)');
CommentLine=read(Data_In_FID, 1, 1,'(A)');
//* get the total amount of cases
CommentLine=read(Data_In_FID, 1, 1,'(A)');
Case.Amount=read(Data_In_FID, 1, 1);
for n = 1 : Case.Amount
    CommentLine=read(Data_In_FID, 1, 1,'(A)');
    Case.Name(n)=read(Data_In_FID, 1, 1,'(A)');
    CommentLine=read(Data_In_FID, 1, 1,'(A)');
    Case.Rows=read(Data_In_FID, 1, 1);
    CommentLine=read(Data_In_FID, 1, 1,'(A)');
    Case.Cols=read(Data_In_FID, 1, 1);
    LoadData(1)=read(Data_In_FID, Case.Rows, Case.Cols);
    //* extract the specified range of data from LoadData(1) to Case.Data(1)
    Case.Data(1)=LoadData(1)(Row.Start : Row.End,Col.List);

    //* *********** execute part one: get and store result data*****************

    Case.Rlt(n)=Case.Data(1);

    //* ************************************************************************
end
CommentLine=read(Data_In_FID, 1, 1,'(A)');
file('close',Data_In_FID);

//* *************** execute part two: manipulate with result data***************



//* ***************************** output data **********************************

Data_Out_FID=file('open',Data_Out,'unknow');
//* set the head comments of Data_Out
write(Data_Out_FID,"*******************************************************",'(A)');
write(Data_Out_FID,"head info content",'(A)');
write(Data_Out_FID,"*******************************************************",'(A)');
write(Data_Out_FID,"Total amount of cases:",'(A)');
write(Data_Out_FID,Case.Amount,'(I10)');
for n = 1 : Case.Amount
    //* get the number of rows of each result data
    RltRows=size(Case.Rlt(n),'r');
    //* get the number of cols of each result data, if it > 50, then need to modify: '(50(F15.7))'
    RltCols=size(Case.Rlt(n),'c');
    write(Data_Out_FID,"*******************************************************",'(A)');
    write(Data_Out_FID,Case.Name(n),'(A)'); //* write the case name
    write(Data_Out_FID,"Rows:",'(A)');
    write(Data_Out_FID,RltRows,'(I10)'); //* write the num of rows of result data 
    write(Data_Out_FID,"Cols:",'(A)');
    write(Data_Out_FID,RltCols,'(I10)'); //* write the num of Cols of result data
    write(Data_Out_FID,Case.Rlt(n),'(50(E20.8))'); //* write the result data of case
end
write(Data_Out_FID,"*******************************************************",'(A)');
file('close',Data_Out_FID);

//* ******************************* exit ***************************************

//* exit Scilab, value "0" means succeed, "1-125" means failed
clear;
exit(0);

//* ******************************* samples ************************************

//* record run log

//if Amount < 1 then
//    Log_FID = mopen(Run_Log, 'a');
//    mputl('***************************************', Log_FID);
//    mfprintf(Log_FID, 'Total Amount= %f\n', Amount);
//    mputl('!--error, Total Amount less than 1 !', Log_FID);
//    mclose(Log_FID);
//    exit(99);
//end

//* debug

//Debug_FID=file('open',Monitor_Info,'unknow');
//write(Debug_FID,TARGET,FORMAT);
//file('close',Debug_FID);
