//****************************************************************************//
//*
//*                         Data Processing with Scilab
//*
//* This script reads in data and calculate nth octave band.
//* If the data read in is a single column, it will be treated as the
//* signal; if there are more than one column of data read in, the first column
//* read in is the time stamp, and the last column will be taken as signal.
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
write(Data_Out_FID,"* Oct Frequency        SPL(dB)         RMS Amplitude        PSD          SPLA(dBA) *",'(A)');
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

    //* Sampling Numbers N of current case
    N_tSamp=size(Case.Data(1),'r');
    //* Sampling time interval Ts in time domain
    if Case.Cols > 1 then
        Ts_tSamp=Case.Data(1)(2,1)-Case.Data(1)(1,1);
    else
        //Ts_tSamp=1.69e-5;
        Ts_tSamp=2e-5;
    end
    //* Sampling frequency in time domain
    fs_tSamp=1/Ts_tSamp;
    //* Time bandwidth
    To=(N_tSamp)*Ts_tSamp;
    //* Nyquist frequency
    f_Nyquist=0.5*fs_tSamp;
    //* Sampling frequency interval in frequency domain, i.e., the width of a frequency bin(frequency resolution)
    fo_fSamp=1/To;
    //* pressure sampling sequency
    P_tSamp=Case.Data(1)(:,$);
    //* the average pressure
    Po=sum(P_tSamp)/N_tSamp;
    //* sound signal is the variation from the average pressure
    P_Sound=P_tSamp-Po;
    //* Window function:hann window(hn), no window, i.e., rect window(re)
    Win_Name='hn';
    //* Get window weights
    Win_Weight=window(Win_Name,N_tSamp)';
    //* Now Act the window function, generate the window weighted sound signal
    Sound_Windowed=P_Sound .* Win_Weight;
    //* fft manupation
    FFT=fft(Sound_Windowed,-1);
    //* after fft, only the 0<f<fmax is the target, then the max index is
    Index_Max=floor(0.5*N_tSamp);
    //* x axes counter, raw vector
    k_Counter=1:1:Index_Max;
    //* x axes of frequency, change to column vector
    fk=(k_Counter')*fo_fSamp;
    //* y axes data range
    Range=k_Counter+1;
    //* Amplitude spectrum in quantity peak
    //* Act transform factor 1/N on fft, not ifft, because we need the spectrum that the amplitude
    //* must not depend on N.
    Factor_FFT=1/N_tSamp;
    //* After fft, then get the two-sided amplitude spectrum of signal, which actually shows
    //* half the peak amplitude at the positive and negative frequencies. 
    //* to convert from a two-sided spectrum to a singled-sided spectrum,
    //* multiply each frequency except for DC(zero frequency) by two, the units of the 
    //* single-sided amplitude spectrum are then in quantity peak and give the peak
    //* amplitude of each sinusoidal component making up the time-domain signal(based 
    //* on the function space series)
    Compensate_FFT=2;
    //* Windowing the original signal would change the amplitude of the signal points accordingly,
    //* which means the loss of the total energy has happened in different degrees. And then in the
    //* spectral domain, governed by the conservation of energy, the amplitude of spectrum will also
    //* decrease compared with that of without windowing.
    //* Because windows are multiplied with the acquired time-domain signal, they introduce
    //* distortion effects of their own. the windows change the overall amplitude of the signal.
    //* window compensate scale factor, 1 for no compensate
    Compensate_Win=N_tSamp/sum(Win_Weight);
    //* Total post scale factor
    PostScale_Factor=Factor_FFT * Compensate_FFT * Compensate_Win;
    //* Calculate the scaled value
    Amp_Peak=PostScale_Factor * abs(FFT(Range));
    //* RMS scale factor
    Factor_RMS=2^(-0.5);
    //* Amplitude spectrum in volts rms
    Amp_RMS=Amp_Peak*Factor_RMS;
    //* Calculate the A(f)^2/Pref^2
    Pref=2e-5;
    SPL_Core=Pref^(-2)*Amp_RMS^2;
    //* When calculate PSD, The use of window and energy leakage increase the bandwidth of energy
    //* distribution, then introduce the bandwith factor and effective bandwidth for PSD calculate
    Factor_Bandwith=N_tSamp*(sum(Win_Weight^2))/(sum(Win_Weight))^2;
    //* The effective noise bandwidth
    fo_Effective=Factor_Bandwith*fo_fSamp;
    //* Calculate PSD based on the effective bandwith
    PSD_Core=SPL_Core/fo_Effective;
    //* Nth octave band
    Nth=3;
    //* Factor_OctBand
    Factor_OctBand=1/(2^(0.5/Nth));
    //* Lowest frequency of fft
    fmin_fft=fo_fSamp;
    //* Lowest frequency of Nth octave band
    fmin_Nth=10^(0.1*(3/Nth))*Factor_OctBand;
    //* Determine the minimun band number b_min
    if fmin_fft <= fmin_Nth then
        b_min=1;
    else
    b_min=ceil(1/3*Nth*10*log10(fmin_fft/Factor_OctBand));
    end
    //* Highest frequency of fft
    fmax_fft=f_Nyquist;
    //* Highest frequency of Nth octave band
    //  fmax_Nth=10^(0.1*(3*Max/Nth))*Factor_OctBand;
    //* Determine the maximun band number b_max
    b_max=floor(1/3*Nth*10*log10(fmax_fft/Factor_OctBand))-1;
    //* Octave Band number sequence
    OctBand_Seq=(b_min:1:b_max+1)';
    //* Total number of Octave Bands
    N_OctBand=length(OctBand_Seq)-1;
    //* Center frequency sequence
    f_BCenter=10^((3*OctBand_Seq/Nth)/10);
    //* Lower frequency sequence
    f_BLower=f_BCenter(1:N_OctBand)*Factor_OctBand;
    //* Upper frequency sequence
    f_BUpper=f_BCenter(2:N_OctBand+1)*Factor_OctBand;
    //* Get rid of the f_BCenter(N_OctBand+1)
    f_BCenter=f_BCenter(1:N_OctBand);
    //* Compute the Octave band by loop
    Oct_SPL_Core=list();
    for b = 1:N_OctBand
    //* Calculate the integral interval index
    Index_Low=ceil(f_BLower(b)/fo_fSamp);
    Index_Up=floor(f_BUpper(b)/fo_fSamp);
    if Index_Up - Index_Low < 1 then
    Part_One=0;
    Part_Two=0;
    Part_Three=0.5*(f_BUpper(b)-f_BLower(b))*(PSD_Core(Index_Low)+PSD_Core(Index_Up));
    else
    //* Use spline integral to integrate the middle part
    Int_Range=Index_Low:1:Index_Up;
    Part_One=intsplin(fk(Int_Range),PSD_Core(Int_Range));
    //* Use trapezoidal interpolation to integrate the two side part
    Part_Two=(fk(Index_Low)-f_BLower(b))*(0.75*PSD_Core(Index_Low)+0.25*PSD_Core(Index_Low-1));
    Part_Three=(f_BUpper(b)-fk(Index_Up))*(0.75*PSD_Core(Index_Up)+0.25*PSD_Core(Index_Up+1));
    end
    //* Addition three part to get Oct_SPL_Core
    Oct_SPL_Core(b)=Part_One+Part_Two+Part_Three;
    end
    //* Make list Oct_SPL_Core to vec 
    Oct_SPL_Core=list2vec(Oct_SPL_Core);
    //* Amplitude of Octave band
    Oct_Amp=(Oct_SPL_Core .^ 0.5) .* Pref;
    //* SPL
    Oct_SPL=10*log10(Oct_SPL_Core);
    //* PSD
    Oct_PSD_Core=Oct_SPL_Core ./ (f_BUpper - f_BLower);
    Oct_PSD=10*log10(Oct_PSD_Core);
    //* Over all SPL
    //* OASPL=10*log10(intsplin(fk,PSD_Core));
    //* A weighted SPL
    Shift_onek=1.9974816;
    fk_s=f_BCenter^2;
    Log_Weight_f=20*(8.1727197+2*log10(fk_s)-log10(fk_s+424.36)-log10(fk_s+1.488D+08)-0.5*log10(fk_s+11599.29)-0.5*log10(fk_s+544496.41));
    Oct_SPLA=Oct_SPL+Log_Weight_f+Shift_onek;
    //* generate the result data matrix
    //* first, initialize Case.Rlt(1) to a matrix
    Case.Rlt(1)=[];
    Case.Rlt(1)(:,5)=Oct_SPLA;
    Case.Rlt(1)(:,4)=Oct_PSD;
    Case.Rlt(1)(:,3)=Oct_Amp;
    Case.Rlt(1)(:,2)=Oct_SPL;
    //* x axes need to exclude f=0 point
    Case.Rlt(1)(:,1)=f_BCenter;

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

