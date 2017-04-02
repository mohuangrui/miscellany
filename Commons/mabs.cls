%%%%% --------------------------------------------------------------------------------
%%
%%%%***************************** Version Information ********************************
%%
%% A LaTeX class for MABS, by Huangrui Mo <huangrui.mo@gmail.com> 
%% This is free software: you can redistribute it and/or modify it
%% under the terms of the GNU General Public License as published by
%% the Free Software Foundation, either version 3 of the License, or
%% (at your option) any later version.
%%
\NeedsTeXFormat{LaTeX2e}[1995/12/01]
\ProvidesClass{mabs}
  [2016/09/05 v0.1 mabs
   document class]
%%%%% --------------------------------------------------------------------------------
%%
%%%%*************************** Declare Options **************************************
%%
%% end-user parameters, each option is declared by one declare option command
\DeclareOption*{% handle non-implemented options
  \PassOptionsToClass{\CurrentOption}{article}%
}
%% terminates all options processing
\ProcessOptions\relax
%%%%% --------------------------------------------------------------------------------
%%
%%%%*************************** Loadclass Infomation *********************************
%%
\LoadClass[12pt]{article}
%%%%% --------------------------------------------------------------------------------
%%
%%%%***************************** Package Infomation *********************************
%%
\RequirePackage{microtype}% improves general appearance of the text
\RequirePackage[square,comma,numbers,sort&compress]{natbib}% citation
\RequirePackage{graphicx}% graphic support
\RequirePackage{amsmath,amssymb,amstext}% math support
\RequirePackage{newtxtext,newtxmath}% font support
\RequirePackage{enumitem}% customizing enumerated lists
\RequirePackage{subcaption}% subfigures
\RequirePackage[section]{placeins}% to prevent floats from being moved over section
\RequirePackage[paper=letterpaper,left=25mm,right=25mm,top=25mm,bottom=25mm]{geometry}% layout
\RequirePackage{setspace}% line spacing
\RequirePackage{titlesec}% section title configure
\RequirePackage[affil-it]{authblk}% affilation
\RequirePackage[hidelinks]{hyperref}% hypelinks
%%%%% --------------------------------------------------------------------------------
%%
%%%%********************* Some Style Control Commands ********************************
%%
%%%%% --------------------------------------------------------------------------------
\titleformat{\section}[block]{\bfseries\normalsize\filcenter}{}{0em}{}[\vspace{-2.2ex}]
\titleformat{\subsection}[hang]{\normalsize}{}{0em}{\underline}[\vspace{-1ex}]
\titleformat{\subsubsection}[hang]{\normalsize\itshape}{}{0em}{}[\vspace{-1ex}]
\renewcommand*{\Authfont}{\normalsize}% author fontsize
\renewcommand*{\Affilfont}{\normalsize\itshape}% affiliation fontsize
\singlespacing% line spacing
\setlength{\parindent}{0pt}% no indent for paragraphs
\setlength{\parskip}{6pt}% vertical space before a paragraph.
\pagenumbering{gobble}% no page numbering
\date{}% no date information
\graphicspath{{./}{./img/}}% figures path
\bibliographystyle{apsa-leeper}% reference style
\renewcommand{\bibfont}{\footnotesize}% reference fontsize
\setlength{\bibsep}{6pt}% reference entry spacing
\renewcommand*{\refname}{REFERENCES}% reference section title
%%
%%%%******************* Commands of Titlepage Items **********************************
%%
\renewcommand\title[1]{\def\@title{\vspace{-4.4ex}\large\bfseries#1\vspace{1.2ex}}}
\let\mymaketitle\maketitle
\renewcommand\maketitle{\mymaketitle\vspace{-7.6ex}}
%%%%% --------------------------------------------------------------------------------
\endinput
%% End of file
%%%%% --------------------------------------------------------------------------------
