#! /bin/bash
set -e
#******************************************************************#
#*                                                                *#
#*                       Batch Data Processing                    *#
#*                                                                *#
#* Principles                                                     *#
#* 1. Format data for importing.                                  *#
#* 2. Processing data by Scilab.                                  *#
#* 3. Gather result and information.                              *#
#*                                                                *#
#*                          By Huangrui Mo                        *#
#******************************************************************#

#******************************************************************
#*                           System
#******************************************************************
#* executable Scilab command, note it can't use any quote!!!
ExeScilab=scilab-cli

#******************************************************************
#*                        Configuration
#******************************************************************
#* specify the Scilab script for data processing.
Num_Scripts=13
Scilab_Sce_Begin="user input"
Scilab_Sce_Name[1]="format.sce"
Scilab_Sce_Name[2]="average.sce"
Scilab_Sce_Name[3]="calibration.sce"
Scilab_Sce_Name[4]="sift.sce"
Scilab_Sce_Name[5]="add_column.sce"
Scilab_Sce_Name[6]="fft.sce"
Scilab_Sce_Name[7]="oaspl.sce"
Scilab_Sce_Name[8]="nth_octave_band.sce"
Scilab_Sce_Name[9]="rms.sce"
Scilab_Sce_Name[10]="max_min.sce"
Scilab_Sce_Name[11]="max_difference.sce"
Scilab_Sce_Name[12]="converge_rate.sce"
Scilab_Sce_Name[13]="compute.sce"

#* set default scripts
Scilab_Sce=${Scilab_Sce_Name[1]}
#* set script interactively
echo "*******************************************************"
echo "set data processing script to run:"
echo "0 $Scilab_Sce_Begin"
for Num_S in `seq 1 $Num_Scripts`
do
    echo "$Num_S ${Scilab_Sce_Name[$Num_S]}"
done

OrderNum=-1
until [[ -n `echo $OrderNum | grep "^[0-9]*$"` && $OrderNum -le $Num_Scripts && $OrderNum -ge 0 ]]
do
    read -p "order number:" OrderNum
    while [[ $OrderNum == $n ]]
    do
        read -p "order number:" OrderNum
    done
    if [[ -n `echo $OrderNum | grep "^[0-9]*$"` && $OrderNum -le $Num_Scripts && $OrderNum -ge 0 ]]; then
        if [[ $OrderNum -eq 0 ]]; then
            read -p "script name:" Scilab_Sce
        else
            Scilab_Sce=${Scilab_Sce_Name[$OrderNum]}
        fi
        echo "your option is:$Scilab_Sce"
        read -p "conform(y or n):" ReadKey
        while [[ $ReadKey == $n ]]
        do
            read -p "conform(y or n):" ReadKey
        done
        if [[ $ReadKey != [y] ]]; then
            OrderNum=-1
        fi 
    else
        echo "bad option"
    fi
done

#******************************************************************
#                        Parameters
#******************************************************************
#* data and info file names
Data_In="data.in"
Data_Out="data.out"
Run_Log="run.log"
Monitor_Info="monitor.info"

#* info gather file name
Result_Gatherer="result.rlt"
Case_List="case.list"

#* temp file name
Run_Temp="run.tmp"

#* appendix name for history backup
Suffix=`date +%y%m%d%H%M`

#* set directories
Data_Importer="importer"
Process_Center="processing"
Result_Exporter="exporter"
Scripts_Repository="repository"
History="history"

#* save current bash script Dir 
ScriptDir=`pwd`

#* configure system
mkdir -p $Data_Importer
mkdir -p $Process_Center
mkdir -p $Result_Exporter
mkdir -p $Scripts_Repository
mkdir -p $History

#* get the "pwd" of directories
Data_PWD="$ScriptDir"/"$Data_Importer"
Process_PWD="$ScriptDir"/"$Process_Center"
Result_PWD="$ScriptDir"/"$Result_Exporter"
Scripts_PWD="$ScriptDir"/"$Scripts_Repository"
History_PWD="$ScriptDir"/"$History"

#******************************************************************
#                        Execution
#******************************************************************
#* before processing, backup the results of last time to $History

#* first, need to check whether the $Result_Exporter is empty
ResultEmpty=`ls $Result_Exporter`
#* if it's not empty, then need to backup
#* -n means if string is not zero length, then true
#* -z means if string is zero length, then true
if [[ -n "$ResultEmpty" ]]; then
    mkdir -p $History_PWD/"result_$Suffix"
    mv $Result_Exporter/* $History_PWD/"result_$Suffix"/
fi

#* change current dir to data dir
cd $Data_PWD

#* find the file list in data importer
File_List=`ls ./`
if [[ -z $File_List ]];then
    echo "*******************************************************"
    echo "Error, No files in $Data_Importer..."
    echo "*******************************************************"
    exit
fi

#* change current dir to process dir
cd $Process_PWD

#* configure process center
:>$Data_In
:>$Data_Out
:>$Run_Log
:>$Run_Temp
:>$Monitor_Info
:>$Case_List

#* configure run log
echo "*******************************************************" >> $Run_Log
echo "                        Run Log                        " >> $Run_Log
echo "*******************************************************" >> $Run_Log

#* copy necessary file to process dir
if [[ -f $Scripts_PWD/$Scilab_Sce ]]; then
    cp $Scripts_PWD/$Scilab_Sce $Process_PWD/
else
    echo "*******************************************************"
    echo "the script \"$Scripts_Repository/$Scilab_Sce\" dones not exist..."
    echo "*******************************************************"
    exit
fi

#* count the amount of cases and record their names
for File in $File_List
do
    #* only processing while it is a regular file not directories!
    if [[ -f $Data_PWD/$File ]]; then
        #* record the current file name to $Case_List
        echo "$File" >> $Case_List
    else
        echo "Warning: the \"$File\" aborted, it's not a regular file" >> $Run_Log
        echo "*******************************************************" >> $Run_Log
    fi
done

#* get the total amount of cases
Case_Amount=`wc -l $Case_List | awk '{print $1}'`
if [[ $Case_Amount -eq 0 ]]; then
    echo "*******************************************************"
    echo "case list is empty, no data file in \"$Data_Importer\"!"
    echo "*******************************************************"
    exit
fi

#* import data to $Data_In

#* configure the head info of $Data_In
echo "*******************************************************" >> $Data_In
echo "                      Data to Load                     " >> $Data_In
echo "*******************************************************" >> $Data_In
echo "Total amount of cases:" >> $Data_In
echo "$Case_Amount" >> $Data_In

#* batch format data files
echo "*******************************************************"
echo "formatting data file..."

for Case in `cat $Case_List`
do
    #* extract the data part of current case to $Run_Temp: 
    #* delete space of each line head, extract the data part
    sed 's/^[[:space:]]*//g' $Data_PWD/$Case | grep '^[+-]\{0,1\}[[:digit:]]' > $Run_Temp
    #* get the rows of data
    Rows=`wc -l $Run_Temp | awk '{print $1}'`
    #* get the columns of data
    Cols=`head -1 $Run_Temp | wc -w`
    #* null data file detect
    if [[ $Rows -eq 0 ]]; then
        echo "*******************************************************"
        echo "no data in the file \"$Case\"!"
        echo "*******************************************************"
        exit
    fi
    #* now write case info to $Data_In
    echo "*******************************************************" >> $Data_In
    #* record current case name to $Data_In
    echo "$Case" >> $Data_In
    #* record the number of rows of data for current case
    echo "Rows:" >> $Data_In
    echo "$Rows" >> $Data_In
    #* record the number of cols of data for current case
    echo "Cols:" >> $Data_In
    echo "$Cols" >> $Data_In
    #* format the data and import them to the "$Data_In" for Scilab
    cat $Run_Temp >> $Data_In
done
echo "*******************************************************" >> $Data_In

#* now run the Scilab to process data, results are in "$Data_Out"
echo "*******************************************************"
echo "running Scilab..."
echo "Scilab start at `date +'%F %k:%M:%S'`" >> $Run_Log
echo "exec('./$Scilab_Sce', -1)" | $ExeScilab >> $Run_Log
echo "Scilab end at `date +'%F %k:%M:%S'`" >> $Run_Log
echo "*******************************************************" >> $Run_Log

#* Error detect and control
Error=`grep '!--error' $Run_Log | wc -l`
if [[ $Error -eq 0 ]]; then
    Warning=`grep 'Warning' $Run_Log | wc -l`
    if [[ $Warning -eq 0 ]]; then
        echo "*******************************************************"
    else
        echo "*******************************************************"
        echo "there are warnings, please check the \"$Run_Log\" file..."
        echo "*******************************************************"
    fi
    #* if no errors, then orgnize and collect the result data to "$Result_Gatherer"
    cat $Data_Out | sed 's/^[[:space:]]*//g' > $Result_PWD/$Result_Gatherer
else
    echo "*******************************************************"
    echo "there are errors, please check the \"$Run_Log\" file..."
    echo "*******************************************************"
    exit
fi

#* clean files for $Process_Center
rm ./$Scilab_Sce
rm ./$Run_Temp

#* finish $Run_Log
echo "total of \"$Case_Amount\" files processed..." >> $Run_Log
echo "*******************************************************" >> $Run_Log

#* now generate separate result data files for each case

cd $Result_PWD
for Case in `cat $Process_PWD/$Case_List`
do
    #* get the rows of data of current case, when use "grep", be careful with
    #* the "part match" situation, such as "Part_Name" and "Part_Name_New", 
    #* they both match "Part_Name", to only match the whole word, need option:
    #* -w for Select only those lines containing matches that form whole words.
    #* -x for Select only those matches that exactly  match  the  whole  line.
    Data_Rows=`grep -A2 -x "$Case" $Result_Gatherer | awk 'NR==3{print $1}'` 
    NRows=$(($Data_Rows + 4))
    #* extract the result data of current case to a single file
    grep -A"$NRows" -x "$Case" $Result_Gatherer > $Run_Temp
    tail -n+6 $Run_Temp > $Case
done

#* clean files for $Result_Exporter
rm ./$Run_Temp

#* after processing, backup the input data of this time to $History
cd $ScriptDir
mkdir -p $History_PWD/"data_$Suffix"
mv $Data_Importer/* $History_PWD/"data_$Suffix"/

#* summary info
echo "total of \"$Case_Amount\" files processed..."
echo "*******************************************************"
echo "data processing finished, please check dir:"
echo "$Result_PWD"
echo "*******************************************************"
