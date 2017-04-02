//****************************************************************************//
//*
//*                         Data Processing with Scilab
//*
//* This script reads in data and calculate overall sound pressure level.
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
write(Data_Out_FID,"* OASPL *",'(A)');
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

    //* ********************* user configure part ******************************

    //* Sampling time interval Ts in time domain
    Mandatory_Ts='false';//* whether specify the Ts mandatory
    //Mandatory_Ts='true';//* whether specify the Ts mandatory
    if Case.Cols > 1 & Mandatory_Ts == 'false' then
        Ts_tSamp=Case.Data(1)(2,1)-Case.Data(1)(1,1);
    else
        Ts_tSamp=1.69e-5;
        //Ts_tSamp=2e-5;
    end
    Win_Name='hn';//* the name of window, 're' for rect, 'hn' for hanning, etc.
    Overlap='true';//* whether use overlap, overlap based on "Welch's Overlap segmented average"
    //Overlap='false';//* whether use overlap
    F_Res=(1/Ts_tSamp)/4096;//* if overlap 'true', then specify the target frequency resolution, [Hz]
    //F_Res=(1/Ts_tSamp)/8192;//* if overlap 'true', then specify the target frequency resolution, [Hz]
    //F_Res=15;//* if overlap 'true', then specify the target frequency resolution, [Hz]

    //* frequency range to consider
    //* user specify
    f_low=80;
    f_high=300;
    //* use whole valid range
    //f_low=0;
    //f_high=1/Ts_tSamp;
    //* **************************** execute part ******************************

    //* Sampling Numbers N of current case
    Num_Samp=size(Case.Data(1),'r');
    //* Sampling frequency in time domain
    fs_tSamp=1/Ts_tSamp;
    //* segment length and overlap settings 
    if Overlap == 'true' then
        N_tSamp=floor(fs_tSamp/F_Res);//* number of samples per segment
        if N_tSamp > Num_Samp then
            N_tSamp=Num_Samp;//* if samples per segment large that total number, change to total number
        end
        if Win_Name == 're' then
            Overlap_Rate=0;//* rect windows should not overlap
        else
            Overlap_Rate=0.5;//* default overlap rate, valid for 'hanning', 'hamming', 'bartlett', etc.
        end
    else
        N_tSamp=Num_Samp;//* no overlap then use whole sequency
        Overlap_Rate=0;//* no overlap
    end

    //* Time bandwidth
    To=(N_tSamp)*Ts_tSamp;
    //* Nyquist frequency
    f_Nyquist=0.5*fs_tSamp;
    //* Sampling frequency interval in frequency domain, i.e., the width of a frequency bin(frequency resolution)
    fo_fSamp=1/To;
    //* after fft, only the 0<f<fmax is the target, then the max index is
    Index_Max=floor(0.5*N_tSamp);
    //* x axes counter, raw vector
    k_Counter=1:1:Index_Max;
    //* x axes of frequency, change to column vector
    fk=(k_Counter')*fo_fSamp;
    //* y axes data range
    Range=k_Counter+1;
    //* pressure sampling sequency
    P_tSamp=Case.Data(1)(:,$);
    //* the average pressure
    Po=sum(P_tSamp)/Num_Samp;
    //* sound signal is the variation from the average pressure
    P_Sound=P_tSamp-Po;
    //* Get window weights
    Win_Weight=window(Win_Name,N_tSamp)';
    //* get the number of non overlap samples per each segment
    Nonlap_N_Seg=floor(N_tSamp*(1-Overlap_Rate));
    //* get the number of segments
    Num_Segments=floor((Num_Samp-N_tSamp)/Nonlap_N_Seg)+1;
    if Overlap == 'true' & Num_Segments < 2 then
        P_Sound=[P_Sound;P_Sound];//* catenate the signal to get at least two segments
        Num_Segments=2;
    end
    //* fft each segments data
    Intensity_FFT=[];//* must initialize the data matrix to empty for each case!
    for N_Seg = 1:Num_Segments
        Start_I=1+Nonlap_N_Seg*(N_Seg-1);//* start index for current segment
        End_I=N_tSamp+Start_I-1;//* end index for current segment
        P_Segment=P_Sound(Start_I:End_I);//* segment signal
        P_Segment=P_Segment-(sum(P_Segment)/N_tSamp);//* move DC
        //* Now Act the window function, generate the window weighted sound signal
        Sound_Windowed=P_Segment .* Win_Weight;
        //* fft manupation
        FFT=fft(Sound_Windowed,-1);
        //* get the amplitude of each segment fft
        Mag_FFT=abs(FFT(Range));
        //* get and save the energy of each segment fft
        Intensity_FFT(:,N_Seg)=Mag_FFT .^ 2;
    end
    //* now get the averaged fft, average must act on energy intensity
    Aver_Mag_FFT=(sum(Intensity_FFT,'c')/Num_Segments) .^ 0.5;
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
    Amp_Peak=PostScale_Factor * Aver_Mag_FFT;
    //* RMS scale factor
    Factor_RMS=2^(-0.5);
    //* Amplitude spectrum in volts rms
    Amp_RMS=Amp_Peak*Factor_RMS;
    //* Phase spectrum in radians
    Phase=atan(imag(FFT(Range)),real(FFT(Range)));
    //* Calculate the A(f)^2/Pref^2
    Pref=2e-5;
    SPL_Core=Pref^(-2)*(Amp_RMS .^ 2);
    //* When calculate PSD, The use of window and energy leakage increase the bandwidth of energy
    //* distribution, then introduce the bandwith factor and effective bandwidth for PSD calculate
    Factor_Bandwith=N_tSamp*(sum(Win_Weight^2))/(sum(Win_Weight))^2;
    //* The effective noise bandwidth
    fo_Effective=Factor_Bandwith*fo_fSamp;
    //* Calculate PSD based on the effective bandwith
    PSD_Core=SPL_Core/fo_Effective;
    //* get the frequency range to integrate
    Count_Start=1+floor(f_low/fo_fSamp);
    Count_End=floor(f_high/fo_fSamp);
    if Count_Start < 1 then
        Count_Start=1;
    end
    if Count_End > Index_Max then
        Count_End=Index_Max;
    end
    Integ_X=fk(Count_Start:Count_End);
    Integ_Y=PSD_Core(Count_Start:Count_End);
    //* Over all SPL
    OASPL=10*log10(intsplin(Integ_X,Integ_Y));

    //* generate the result data matrix
    //* first, initialize Case.Rlt(1) to an empty matrix
    Case.Rlt(1)=[];
    Case.Rlt(1)=OASPL;

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

