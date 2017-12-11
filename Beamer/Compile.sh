#---------------------------------------------------------------------------#
#-                      LaTeX Automated Compiler                           -#
#---------------------------------------------------------------------------#
#! /bin/bash
#---------------------------------------------------------------------------#
#->> Preprocessing
#---------------------------------------------------------------------------#
#-
#-> Get source filename
#-
if [[ "$#" == "1" ]]; then
    FileName=`echo *.tex`
elif [[ "$#" == "2" ]]; then
    FileName="$2"
else
    echo "---------------------------------------------------------------------------"
    echo "Usage: "$0"  <x|xa|xb|p|pa|pb>  <filename>"
    echo "Parameters: <x:xelatex>, <p:pdflatex>, <a:auto bibtex>, <b:auto biblatex>"
    echo "Compile failed: \"X\" to terminate the terminal..."
    echo "---------------------------------------------------------------------------"
    exit
fi
FileName=${FileName/.tex}
#-
#-> Get tex compiler
#-
if [[ $1 == *'p'* ]]; then
    TexCompiler="pdflatex"
else
    TexCompiler="xelatex"
fi
#-
#-> Get bib compiler
#-
if [[ $1 == *'a'* ]]; then
    BibCompiler="bibtex"
elif [[ $1 == *'b'* ]]; then
    BibCompiler="biber"
else
    BibCompiler=""
fi
#-
#-> Set the temp directory for storing compiled files
#-
Tmp="Tmp"
if [[ ! -d $Tmp ]]; then
    mkdir -p $Tmp
fi
#-
#-> Set LaTeX environmental variables to include subdirs into search path
#-
export TEXINPUTS=".//:$TEXINPUTS"
export BIBINPUTS=".//:$BIBINPUTS"
export BSTINPUTS=".//:$BSTINPUTS"
#---------------------------------------------------------------------------#
#->> Compiling
#---------------------------------------------------------------------------#
#-
#-> Build textual content
#-
$TexCompiler -output-directory=$Tmp $FileName || exit
#-
#-> Build links and references
#-
if [[ -n $BibCompiler ]]; then
    $BibCompiler ./$Tmp/$FileName
    $TexCompiler -output-directory=$Tmp $FileName || exit
    $TexCompiler -output-directory=$Tmp $FileName || exit
fi
#---------------------------------------------------------------------------#
#->> Postprocessing
#---------------------------------------------------------------------------#
#-
#-> Set PDF viewer
#-
System_Name=`uname`
if [[ $System_Name == "Linux" ]]; then
    PDFviewer="xdg-open"
elif [[ $System_Name == "Darwin" ]]; then
    PDFviewer="open"
else
    PDFviewer="open"
fi
#-
#-> Open the compiled file
#-
$PDFviewer ./$Tmp/"$FileName".pdf || exit
echo "---------------------------------------------------------------------------"
echo "$TexCompiler $BibCompiler "$FileName".tex finished..."
echo "---------------------------------------------------------------------------"

