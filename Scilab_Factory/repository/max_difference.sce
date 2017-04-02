//****************************************************************************//
//*
//*                         Data Processing with Scilab
//*
//* This script calculates the differences of data between cases. The based
//* data is taken from the first case.
//*
//*                              By Huangrui Mo
//*
//****************************************************************************//

//****************************************************************************
//*
//*                             User Configuration
//*
//****************************************************************************

//* specify the row range of data to process for each case
Row_Start=1; //* the begin row number.
Row_End=$; //* the end row number, $ means the last index of array.

//* specify the column range of data to process for each case
Column_List=[1:1:$]; //* the list of target columns No.

//* increase the memory dedicated to data if required
stacksize('max');

//****************************************************************************
//*
//*                             System  Configuration
//*
//****************************************************************************

//* data structure
Case=tlist(["CL";"Amount";"Name";"Rows";"Cols";"Data";"Rlt"],[ ],[ ],[ ],[ ],list(),list());
Row=tlist(["RowRange";"Start";"End";"Amount"],[ ],[ ],[ ]);
Col=tlist(["ColRange";"List";"Amount"],[ ],[ ]);
LoadData=list();//* use to load data from files

//* get the row range of data to process for each case
Row.Start=Row_Start; //* the begin row number.
Row.End=Row_End; //* the end row number, $ means the last index of array.

//* get the column range of data to process for each case
Col.List=Column_List; //* the list of target columns No.

//* specify the files for load and output
Data_In="data.in";
Data_Out="data.out";
Run_Log="run.log";
Monitor_Info="monitor.info";

//* ************* load data -> process data -> write result data *************

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
write(Data_Out_FID,"* max abs diff in each cols with 1st data stream, Rlt=[RowNo;Abs_Diff;Origin_Data;Percent] *",'(A)');
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

    //* compare based on the first data stream
    if n == 1 then
        Base_Data=Case.Data(1);
    end
    //* get the difference data
    Abs_Diff=abs(Case.Data(1)-Base_Data);
    //* find the max in each collum of difference
    [Abs_Maxs,Abs_Maxs_RowNo]=max(Abs_Diff,'r');
    //* initialize the data gather matrix to empty for each case
    Origin_Data=[];
    //* get the corresponding data in data stream, use row vector
    for N_Col = 1:Case.Cols
    Origin_Data(1,N_Col)=Base_Data(Abs_Maxs_RowNo(N_Col),N_Col);
    end
    //* calculate the percentage
    Percent_Diff=abs(Abs_Maxs ./ Origin_Data)*100;

    //* get final result data
    Case.Rlt(1)=[Abs_Maxs_RowNo;Abs_Maxs;Origin_Data;Percent_Diff];

    //* ***************************** export data ******************************
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
//* end with an empty line

