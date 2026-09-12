%
% 2025 (C) Diego Carvalho - diego.carvalho@cefet-rj.br
%
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{cefet-lex}[2025/07/12 Cefet Lex LaTeX class]
\LoadClass[11pt,a4paper,oneside]{mwbk}

\RequirePackage[normalem]{ulem}

\widowpenalty 1000
\clubpenalty  1000
\displaywidowpenalty 1000

\SetSectionFormatting{section}
{12pt}
{\centering\large\textbf{\ifHeadingNumbered
		Se\c{c}\~{a}o~
		\HeadingNumber\enspace\fi\\[8pt] %retirei o ponto
		\HeadingText}}
{6pt}

\renewcommand{\thesection}{\Roman{section}}

\renewcommand{\thechapter}{\Roman{chapter}}

%%%SECTION IN TOC%%%%
\renewcommand*\l@section[2]{\mw@tocline{1}{1.5em}{4em}{Seção~ #1}{#2}}
%%%%%%%%%%%%%%%%%%%%%%%%%%%

\RequirePackage[all]{nowidow}

\RequirePackage{ifxetex}
\RequirePackage{ifluatex}
\ifxetex
    \RequirePackage{fontspec}
    \RequirePackage{polyglossia}
    \setmainlanguage{brazil}
\else
    \ifluatex
        \RequirePackage{fontspec}
        \RequirePackage{polyglossia}
        \setmainlanguage{brazil}
    \else
        \RequirePackage[utf8]{inputenc}
        \RequirePackage[brazil]{babel}
    \fi
\fi

\RequirePackage{textcase}

%%risca partes do texto
\newcommand{\cortado}[1]{\sout{#1}}

\newcommand{\titulo}[1]{
    \thispagestyle{empty}
	\begin{center}
	    \vspace{12pt}
		\centering \bfseries \large #1
		\vspace{12pt}
	\end{center}
}

\newcommand{\descricao}[1]{\hfill%
	\begin{minipage}{0.5\textwidth}
		#1
	\end{minipage}
	\vspace{\baselineskip}
	}




% % % Para começar capítulos na mesma página:


% opção de começar capítulos na mesma página: capitulo

\DeclareOption{capitulo}{%
%\SetSectionFormatting[wholewidth]{chapter}
%{12pt}
%{\centering\Large\textbf{\ifHeadingNumbered
%		\@chapapp\enspace
%		\HeadingNumber\enspace\fi\\[8pt] %retirei o ponto
%		\HeadingText}}
%{6pt}



\SetSectionFormatting[wholewidth]{chapter}
{11pt}
{\FormatRigidChapterHeading{4\baselineskip}{0pt}%
	{\centering\large\MakeUppercase\@chapapp\space}{\large\MakeUppercase}}
{\baselineskip}

}


%%%capítulos em maiúsculas

\SetSectionFormatting[breakbefore,wholewidth]{chapter}
{12pt}
{\FormatRigidChapterHeading{4\baselineskip}{0pt}%
	{\centering\large\MakeUppercase\@chapapp\space}{\large\MakeUppercase}}
{\baselineskip}



%%%%%



\DeclareOption{paragrafoespaco}{%
\setlength{\parskip}{8pt}%
\setlength{\parindent}{0pt}%
}

\DeclareOption{paragrafonormal}{%
	\setlength{\parskip}{0pt}%
}

\ExecuteOptions{paragrafoespaco}

\ProcessOptions\relax




%%%%%%%%%
%# a unidade básica de articulação será o artigo, indicado pela abreviatura "Art.", seguida de numeração ordinal até o nono e cardinal a partir deste;
%
%# os artigos desdobrar-se-ão em parágrafos ou em incisos; os parágrafos em incisos, os incisos em alíneas e as alíneas em itens;
%
%# os parágrafos serão representados pelo sinal gráfico "§", seguido de numeração ordinal até o nono e cardinal a partir deste, utilizando-se, quando existente apenas um, a expressão "parágrafo único" por extenso;
%
%# os incisos serão representados por algarismos romanos, as alíneas por letras minúsculas e os itens por algarismos arábicos;
%%%%%


\newcounter{artigo}
\newcommand{\artigo}{\refstepcounter{artigo} %
    \setlength{\parskip}{1em}
	\par
	\ifnum\theartigo<10 %
	{\bfseries Art.~\arabic{artigo}º~~}%
	\else
	{\bfseries Art. \arabic{artigo}.~~}%
	\fi
	%Art. \arabic{artigo}.~
	\setcounter{inciso}{0}
}

\newcounter{paragrafo}[artigo]
\newcommand{\paragrafo}{\refstepcounter{paragrafo} %
	\par
	\ifnum\theparagrafo<10 %
	\hangindent=2em \hangafter=0 \S~\arabic{paragrafo}º~%
	\else
	\hangindent=2em \hangafter=0 \S~\arabic{paragrafo}.~%
	\fi
}

\newcommand{\paragrafounico}{\hangindent=2em \hangafter=0 \emph{Parágrafo único.}\enspace}


\newcounter{inciso}[paragrafo]
\newcommand{\inciso}{\refstepcounter{inciso} %
	\par
	\setlength{\parskip}{0.5em}
	\ifnum\theparagrafo=0 %
	\hangindent=2em \hangafter=0
	\else
	\hangindent=3.5em \hangafter=0
	\fi
\Roman{inciso} --
}



\newcounter{alinea}[inciso]
\newcommand{\alinea}{\refstepcounter{alinea} %
\par
 \hangindent=5em  \hangafter=0	\alph{alinea})
}

\newcounter{itens}[alinea]
\newcommand{\itens}{\refstepcounter{itens} %
\par
 \hangindent=6.5em \hangafter=0	\arabic{itens}.
}


\RequirePackage{xcolor}
\definecolor{slcolor}{HTML}{882B21}

\RequirePackage{graphicx}
\RequirePackage{geometry}
\RequirePackage{xspace}
\RequirePackage{booktabs}
\RequirePackage{xcolor}
\RequirePackage{refcount}
\RequirePackage{etoolbox}
\RequirePackage{refcount}
\RequirePackage{fancyhdr}
\RequirePackage{modroman}


\RequirePackage[a-2b]{pdfx}


\geometry{a4paper,
    left=20mm,
    right=20mm,
    top=20mm,
    bottom=20mm
}

\pagestyle{fancy}
\renewcommand{\headrulewidth}{0pt}
\fancyhead{}
\fancyfoot{}
\fancyhf{}
\fancyfoot[C]{\thepage}

\renewcommand\theinciso{{\Roman{inciso}}}

\graphicspath{ {./_extensions/clx} }

\newcommand{\todo}[1]{{\color{red}#1}}
\newcommand{\RRoman}[1]{\uppercase\expandafter{\romannumeral \getrefnumber{#1}}}

\newcommand{\cabecalho}[1]{%
\clearpage\thispagestyle{plain}
\begin{center}
\includegraphics[height=2cm]{brasao.pdf} \\
{\large Ministério da Educação\\
{\large Secretaria de Educação Superior} \\
{\large Universidade Federal de Ciência e Inovação do Rio de Janeiro} \\
{\large #1}}
\end{center}
}

\newcommand{\nomedocumento}[2]{%
{\vspace{0.5cm}\raggedleft\bf  #1 nº #2}\vspace{0.5cm}
}

\newcommand{\topico}[1]{%
{\vspace{0.5cm}\raggedleft\bf\MakeUppercase{#1}}\vspace{0.5cm}
}

\newcommand{\assinatura}[2]{%
\vspace{2cm}
\begin{center}
{#1\\
#2}
\end{center}
}
