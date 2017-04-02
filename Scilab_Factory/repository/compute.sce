//****************************************************************************//
//*
//*                         Data Processing with Scilab
//*
//* This script compute quantities based on inputed data.
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
//stacksize('max');

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
write(Data_Out_FID,"* Computed Data *",'(A)');
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

    //* first, initialize Case.Rlt(1) to a empty matrix
    Case.Rlt(1)=[];

    //* compute linear regression
    //x = (Case.Data(1)(:,1))';
    //y = (Case.Data(1)(:,2))';
    //[a, b] = reglin(x,y);

    //Case.Rlt(1)(:,3)=b;
    //Case.Rlt(1)(:,2)=a(:,1);
    //Case.Rlt(1)(:,1)=atand(a(:,1));

    //* compute flux
    Row.Amount=size(Case.Data(1),'r');//* the amount of target rows
    x = Case.Data(1)(:,1);
    y = Case.Data(1)(:,2);
    nx = Case.Data(1)(:,4);
    ny = Case.Data(1)(:,5);
    u = Case.Data(1)(:,8);
    v = Case.Data(1)(:,9);
    theta = atan(y, x) * 180 / %pi;
    abs_flux = abs(u .* nx + v .* ny);
    l1 = (sum(abs_flux) / Row.Amount) * ones(abs_flux);
    l2 = sqrt(sum(abs_flux .* abs_flux) / Row.Amount) * ones(abs_flux);
    lmax = max(abs_flux) * ones(abs_flux);

    Case.Rlt(1)(:,5)= lmax;
    Case.Rlt(1)(:,4)= l2;
    Case.Rlt(1)(:,3)= l1;
    Case.Rlt(1)(:,2)= abs_flux;
    Case.Rlt(1)(:,1)= theta;


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

