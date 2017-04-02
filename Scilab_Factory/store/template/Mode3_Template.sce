// ***************************** Batch Scilab Mode 3 ***************************

//* Comments: this script does not store the input data within the specifid range,
//* nor store the rusult data. it process a single case and write out it's own 
//* result data at a time. it treats every case independently, thus it requires
//* the least memory and highest efficiency.

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
Col.Amount=length(Col.List); //* the amount of target columns

//* system configure: specify the files for load and output

Data_In="Data.in";
Data_Out="Data.out";
Run_Log="Run.log";
Monitor_Info="Monitor.info";

//* ************** load data -> process data -> write result data **************

//* load head info from Data_In
Data_In_FID=file('open',Data_In,'unknow');
//* strip the head comments
CommentLine=read(Data_In_FID, 1, 1,'(A)');
CommentLine=read(Data_In_FID, 1, 1,'(A)');
CommentLine=read(Data_In_FID, 1, 1,'(A)');
//* get the total amount of cases
CommentLine=read(Data_In_FID, 1, 1,'(A)');
Case.Amount=read(Data_In_FID, 1, 1);
//* write head info to Data_Out
Data_Out_FID=file('open',Data_Out,'unknow');
//* set the head comments of Data_Out
write(Data_Out_FID,"*******************************************************",'(A)');
write(Data_Out_FID,"head info content",'(A)');
write(Data_Out_FID,"*******************************************************",'(A)');
write(Data_Out_FID,"Total amount of cases:",'(A)');
write(Data_Out_FID,Case.Amount,'(I10)');
//* processing loop
for n = 1 : Case.Amount
    //* load data from Data_In
    CommentLine=read(Data_In_FID, 1, 1,'(A)');
    Case.Name=read(Data_In_FID, 1, 1,'(A)');
    CommentLine=read(Data_In_FID, 1, 1,'(A)');
    Case.Rows=read(Data_In_FID, 1, 1);
    CommentLine=read(Data_In_FID, 1, 1,'(A)');
    Case.Cols=read(Data_In_FID, 1, 1);
    LoadData(1)=read(Data_In_FID, Case.Rows, Case.Cols);
    //* extract the specified range of data from LoadData(1) to Case.Data(1)
    Case.Data(1)=LoadData(1)(Row.Start : Row.End,Col.List);

    //* **************************** execute part ******************************

    Case.Rlt(1)=Case.Data(1);

    //* ************************************************************************

    //* write result data to Data_Out
    //* get the number of rows of each result data
    RltRows=size(Case.Rlt(1),'r');
    //* get the number of cols of each result data, if it > 50, then need to modify: '(50(F15.7))'
    RltCols=size(Case.Rlt(1),'c');
    write(Data_Out_FID,"*******************************************************",'(A)');
    write(Data_Out_FID,Case.Name,'(A)'); //* write the case name
    write(Data_Out_FID,"Rows:",'(A)');
    write(Data_Out_FID,RltRows,'(I10)'); //* write the num of rows of result data 
    write(Data_Out_FID,"Cols:",'(A)');
    write(Data_Out_FID,RltCols,'(I10)'); //* write the num of Cols of result data
    write(Data_Out_FID,Case.Rlt(1),'(50(E20.8))'); //* write the result data of case
end
CommentLine=read(Data_In_FID, 1, 1,'(A)');
file('close',Data_In_FID);
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
