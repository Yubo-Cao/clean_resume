\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{clean-resume}[2023/05/07 Clean Resume]
\LoadClass{article}
\pagestyle{empty}

\ExplSyntaxOn
\tl_new:N \l_cr_option
\tl_set:Nn \l_cr_option { }
\tl_new:N \l_cr_comma
\tl_set:Nn \l_cr_comma { , }

\DeclareOption*{
    \tl_concat:NNN \l_cr_option \l_cr_option \CurrentOption
    \tl_concat:NNN \l_cr_option \l_cr_option \l_cr_comma
}
\ProcessOptions

% ----------------------------------------
% options
% ----------------------------------------
\keys_define:nn { CR }
{
    microtype .bool_set:N = \l_cr_microtype_bool,
    inter .bool_set:N = \l_cr_inter_bool,
    small-caps .bool_set:N = \l_cr_smallcaps_bool,
    linespace .tl_set:N = \l_cr_linespace_fp,
    primary .tl_set:N = \l_cr_primary_color_tl,
    gray .tl_set:N = \l_cr_gray_color_tl,
    sidebar-width .dim_set:N = \l_cr_sidebar_width_dim,
    column-gap .dim_set:N = \l_cr_column_gap_dim,
    margin .dim_set:N = \l_cr_margin_dim,
    element-gap .dim_set:N = \l_cr_element_gap_dim
}

\clist_const:Nn \c_cr_valid_colors_clist {slate, gray, zinc, neutral, stone, red, orange, amber, yellow, lime, green, emerald, teal, cyan, sky, blue, indigo, violet, purple, fuchsia, pink, rose}

\NewDocumentCommand{\setup}{m}
{
    \keys_set:nn {CR} {#1}
    % Check primary color
    \clist_if_in:NVTF \c_cr_valid_colors_clist \l_cr_primary_color_tl
    {} 
    {\msg_error:nnn {CR} {invalid-primary-color} {\l_cr_primary_color_tl}}

    % Check gray color
    \clist_if_in:NVTF \c_cr_valid_colors_clist \l_cr_gray_color_tl
    {} 
    {\msg_error:nnn {CR} {invalid-gray-color} {\l_cr_gray_color_tl}}

    % Check column-gap
    \dim_compare:nNnTF {\l_cr_column_gap_dim} < {3em}
    {\msg_warning:nn {CR} {small-column-gap}}
    {}

    % Check small-caps and inter
    \bool_if:nTF { \l_cr_smallcaps_bool && \l_cr_inter_bool }
    {
        \msg_error:nn {CR} {smallcaps-inter}
    } { }
}

\msg_new:nnn {CR} {invalid-primary-color} 
{
    Invalid~primary~color~"\exp_not:n{#1}".~Valid~colors~are~slate,~gray,~zinc,~neutral,~stone,~red,~orange,~amber,
    ~yellow,~lime,~green,~emerald,~teal,~cyan,~sky,~blue,~indigo,~violet,~purple,~fuchsia,~pink,~and~rose.
}
\msg_new:nnn {CR} {invalid-gray-color} 
{
    Invalid~gray~color~"\exp_not:n{#1}".~Valid~colors~are~slate,~gray,~zinc,~neutral,~stone,~red,~orange,~amber,
    ~yellow,~lime,~green,~emerald,~teal,~cyan,~sky,~blue,~indigo,~violet,~purple,~fuchsia,~pink,~and~rose.
}
\msg_new:nnn {CR} {small-column-gap} {Column gap is smaller than 3em.}

\setup
{
    microtype=true, 
    inter=false, 
    small-caps=false, 
    linespace=1.25, 
    primary=slate, 
    gray=slate,
    sidebar-width=0.25\paperwidth,
    column-gap=3em,
    margin=0.4in,
    element-gap=0.5em
}
\exp_args:No \setup \l_cr_option

% ----------------------------------------
% packages
% ----------------------------------------

% dimension calculation
\RequirePackage{calc}

% typography
\RequirePackage{phonenumbers}
\RequirePackage{xspace}

% link
\RequirePackage[
    unicode=true, 
    bookmarks=false, 
    breaklinks=false, 
    pdfborder={0~0~0}
]{hyperref}

% multicol
\RequirePackage{multicol}

% list
\RequirePackage{enumitem}

% graphics
\ExplSyntaxOff
\RequirePackage{tikz}
\usetikzlibrary{arrows.meta, calc, positioning}
\RequirePackage{graphicx}
\RequirePackage{tailwind-colors}
\ExplSyntaxOn

% icon
\RequirePackage{fontawesome5}

% page setup
\RequirePackage{geometry, afterpage}
\geometry{letterpaper, margin=\l_cr_margin_dim}

% ----------------------------------------
% utilities
% ----------------------------------------

% integer
\prg_new_protected_conditional:Npnn \if_is_int:n #1 { T, F, TF }
{
    \regex_match:nnTF { \G[\+\-]?[\d]+\K } {#1} % $ 
        { \prg_return_true: }
        { \prg_return_false: }
}

% boolean
\msg_new:nnn {cr} {invalid-boolean-option}
  {Invalid~boolean~option:~`#1`. ~Valid~options~are~True~or~False~(case~insensitive)}

\cs_new:Nn \cr_validate_bool:n {
    \bool_if:nTF { 
        !\str_if_eq_p:nn { #1 } { true } && 
        !\str_if_eq_p:nn { #1 } { false } &&
        !\str_if_eq_p:nn { #1 } { True } &&
        !\str_if_eq_p:nn { #1 } { False }
    }{
        \msg_error:nnn {cr} {invalid-boolean-option} {#1}
    }{ }
}

\prg_new_protected_conditional:Npnn \if_tl_true:n #1 { T, F, TF }
{
    \cr_validate_bool:n {#1}
    \str_if_eq:nnTF { #1 } { true } 
        { \prg_return_true: }
        { \prg_return_false: }
}

% colors
\bool_if:NTF \l_cr_inter_bool 
{
    \prop_const_from_keyval:Nn \l_cr_shade_prop 
    {
        text=600,
        title=800,
        subtitle=700,
        weak=500,
        emph=600
    }
}
{
    \prop_const_from_keyval:Nn \l_cr_shade_prop 
    {
        text=700,
        title=950,
        subtitle=900,
        weak=500,
        emph=700
    }
}

\msg_new:nnn {cr} {invalid-color}
  {Invalid~color~'#1'.~Valid~options~are~'text',~'title',~'subtitle',~'weak',~and~'emph'.}

\cs_new:Nn \cr_primary:n {
    \if_is_int:nTF {#1} {
        \exp_args:NV \color { \l_cr_primary_color_tl-#1 }
    } {
        \prop_get:NnNTF \l_cr_shade_prop {#1} \l_tmpa_tl
            {\exp_args:NV \color {\l_cr_primary_color_tl-\l_tmpa_tl}}
            {\msg_error:nnn {cr} {invalid-color} {#1}}
    }
}

\cs_new:Nn \cr_gray:n {
    \if_is_int:nTF {#1} {
        \exp_args:NV \color { \l_cr_gray_color_tl-#1 }
    }{
        \prop_get:NnNTF \l_cr_shade_prop {#1} \l_tmpa_tl
            {\exp_args:NV \color {\l_cr_gray_color_tl-\l_tmpa_tl}}
            {\msg_error:nnn {cr} {invalid-color} {#1}}
    }
}

% abbreviations
\NewDocumentCommand{\ie}{}{\textit{i.e.}\xspace}
\NewDocumentCommand{\eg}{}{\textit{e.g.}\xspace}
\NewDocumentCommand{\vs}{}{\textit{v.s.}\xspace}
\NewDocumentCommand{\etc}{}{\textit{etc.}\xspace}

% emph
\let\emph\undefined
\NewDocumentCommand{\emph}{m}{
    \bool_if:nT { \l_cr_smallcaps_bool } 
    { \bfseries\scshape\cr_gray:n{emph} #1 } 
    { \textbf{\cr_gray:n{emph} #1} }
}

% line spacing
\RequirePackage{setspace}
\setstretch{\l_cr_linespace_fp}

% small caps
\bool_if:nTF { \l_cr_smallcaps_bool } { \RequirePackage[T1]{fontenc} } { }

% microtype
\bool_if:nTF { \l_cr_microtype_bool } { \RequirePackage{microtype} } { }

% inter
\bool_if:nTF { \l_cr_inter_bool } {
    % if used fontenc already, error
    \bool_if:nTF { \l_cr_smallcaps_bool } {
        \PackageError{clean-resume}{Cannot use inter with fontenc}{}
    }{
        \RequirePackage{fontspec}
        \setmainfont [ BoldFont = { Inter~Semi~Bold } ] { Inter }
        \setsansfont{Inter}
        \renewcommand{\normalsize}{\fontsize{9pt}{12pt}\selectfont} 
    }
} { }

% date formatter
\prop_const_from_keyval:Nn \l_cr_month_prop {
  1 = January,
  2 = February,
  3 = March,
  4 = April,
  5 = May,
  6 = June,
  7 = July,
  8 = August,
  9 = September,
  10 = October,
  11 = November,
  12 = December
}
\cs_new:Nn \cr_month:n {
  \prop_get:NnNTF \l_cr_month_prop {#1} \l_tmpa_tl
  {\tl_use:N \l_tmpa_tl}
  {}
}
\cs_new:Nn \cr_day:n { #1 }
\cs_new:Nn \cr_year:n { #1 }

\let\date\undefined
\NewDocumentCommand{\date}{ >{\SplitArgument{2}{/}}m }{ \cr_format_date:nnn #1 }

\cs_new_protected:Npn \cr_format_date:nnn #1 #2 #3 {
    \str_if_eq:nnTF { #3 } { -NoValue- }
    {
        \str_if_eq:nnTF { #2 } { -NoValue- }
        { \cr_year:n{#1} }
        { \cr_month:n{#2},~\cr_year:n{#1} }
    }
    { \cr_month:n{#2}~\cr_day:n{#3},~\cr_year:n{#1} }
}

\let\range\undefined
\NewDocumentCommand{\range}{ >{\SplitArgument{1}{--}}m }{ \cr_format_range:nn #1 }
\cs_new_protected:Npn \cr_format_range:nn #1 #2 {
    \str_if_eq:nnTF { #2 } { -NoValue- }
    { \date{#1}--now }
    { \date{#1}--\date{#2} }
}

% ----------------------------------------
% layout
% ----------------------------------------

% sidebar
\let\sidebar\undefined
\keys_define:nn { cr / sidebar }
{
    width .dim_set:N = \l_cr_width_dim,
    width .initial:n = \l_cr_sidebar_width_dim,
    top .dim_set:N = \l_cr_top_dim,
    top .initial:n = \l_cr_margin_dim,
    bottom .dim_set:N = \l_cr_bottom_dim,
    bottom .initial:n = \l_cr_margin_dim,
    left .dim_set:N = \l_cr_left_dim,
    left .initial:n = \l_cr_margin_dim,
    padding .dim_set:N = \l_cr_padding_dim,
    padding .initial:n = 1.25em,
}
\NewDocumentEnvironment{sidebar}{O{}}
{
    \keys_set:nn { cr / sidebar } {#1}

    \tikz[remember~picture, overlay]{
        \node[
            rectangle,
            fill=\l_cr_primary_color_tl-50,
            anchor=north~west,
            minimum~width=\l_cr_width_dim ,
            minimum~height=\paperheight - \l_cr_top_dim - \l_cr_bottom_dim,
            rounded~corners
        ](bar) at ([xshift=\l_cr_left_dim, yshift=-\l_cr_top_dim] current~page.north~west){};
    }
    
    \hspace{\l_cr_padding_dim}
    \begin{minipage}[t]{\l_cr_sidebar_width_dim - \l_cr_padding_dim - \l_cr_padding_dim }
    \setstretch{1.45}
    \vspace{\l_cr_padding_dim}
}
{ \end{minipage} }

\NewDocumentCommand{\sep}{}{ \hspace{ \l_cr_column_gap_dim } }

\NewDocumentEnvironment{main}{}
{
    \begin{minipage}[t]{ \textwidth - \l_cr_column_gap_dim - \l_cr_sidebar_width_dim }
}
{ \end{minipage} }

% ----------------------------------------
% components
% ----------------------------------------

\bool_new:N \g_cr_header_flag_bool

% header
\let\header\undefined
\NewDocumentCommand{\header}{ m O{-\parskip + 0.15em} }
{
    \bool_gset_true:N \g_cr_header_flag_bool

    \dim_set:Nn \l_tmpa_dim {#2}
    \vspace{\l_tmpa_dim}
    \group_begin:
        \Large\emph{\cr_gray:n{subtitle} #1}\par
        \vspace{-0.75em}
        \cr_gray:n{weak} \hrulefill
    \group_end:
}

% element separator
\cs_new:Nn \cr_el_sep: {
    \bool_if:NTF \g_cr_header_flag_bool 
    { \bool_gset_false:N \g_cr_header_flag_bool }
    { \vspace{\l_cr_element_gap_dim} }
}

% titled list
\let\lst\undefined
\setlist[itemize] {
    topsep = 0pt,
    itemsep = -0.3em,
    label = \raisebox{0.1\baselineskip}{ \cr_gray:n{300} \footnotesize\textbullet },
    leftmargin = 1.5em
}
\keys_define:nn { cr / lst }
{
    title .tl_set:N = \l_lst_title_tl,
    title .initial:n = {},
    columns .tl_set:N = \l_lst_columns_tl,
    columns .initial:n = {},
    oneline .bool_set:N = \l_lst_oneline_bool,
    oneline .initial:n = false
}
\msg_new:nnn { CR } { invalid-oneline-with-columns }
{
    You~can't~set~both~oneline~and~multi-columns~simultaneously.
}
\NewDocumentEnvironment{lst}{ O{} }
{
    \cr_el_sep:
    \keys_set:nn { cr / lst } {#1}
    \bool_if:NTF \l_lst_oneline_bool
    {
        \tl_if_empty:NTF \l_lst_columns_tl { } 
        { \msg_error:nnn { CR } { invalid-oneline-with-columns } }
        \tl_if_empty:NTF \l_lst_title_tl 
        { } { \emph { \l_lst_title_tl } \xspace }
    }
    {
        \tl_if_empty:NTF \l_lst_title_tl 
        { } { \emph { \l_lst_title_tl } \\[-1.8em] }
        
        \tl_if_empty:NTF \l_lst_columns_tl
        { \begin{itemize} }
        {
            \begin{multicols}{ \l_lst_columns_tl }
            \begin{itemize}
        }
    }
}
{
    \bool_if:NTF \l_lst_oneline_bool { }
    {
        \end{itemize}
        \tl_if_empty:NTF \l_lst_columns_tl { } { \end{multicols} }
    }
}


% avatar
\keys_define:nn { cr / avatar }
{
    yshift .dim_set:N = \l_cr_avatar_yshift_dim,
    yshift .initial:n = 0cm,
    xshift .dim_set:N = \l_cr_avatar_xshift_dim,
    xshift .initial:n = 0cm,
    size .dim_set:N = \l_cr_avatar_size_dim,
    size .initial:n = 1.5cm,
    scale .fp_set:N = \l_cr_avatar_scale_fp,
    scale .initial:n = 1.0,
}
\NewDocumentCommand{\avatar}{O{} m}
{
    \keys_set:nn { cr / avatar } {#1}
    \begin{center}
        \begin{tikzpicture}
            \fill[\l_cr_primary_color_tl-200] (0, 0) circle (\l_cr_avatar_size_dim);
            \clip (0, 0) circle (\l_cr_avatar_size_dim);
            \path (\l_cr_avatar_xshift_dim, \l_cr_avatar_yshift_dim) node{\includegraphics[width = \fp_use:N\l_cr_avatar_scale_fp\l_cr_avatar_size_dim]{ #2 }};
        \end{tikzpicture}
    \end{center}
}

% title
\let\title\undefined
\NewDocumentCommand{\title}{m O{}}
{
    \textbf{\huge\cr_gray:n{title} #1}\\[-0.25em]
    \cr_gray:n{weak}#2
}

% icon
\let\icon\undefined
\NewDocumentCommand{\icon}{O{1.25em} m}{
    \dim_set:Nn \l_tmpa_dim {#1}
    \raisebox{-0.25\l_tmpa_dim}{
        \resizebox{#1}{!}{
            \tikz{
                \fill[\l_cr_primary_color_tl-200] (0, 0) circle (0.5cm);
                \node at (0, 0) {\cr_primary:n{emph}\resizebox{0.437cm}{!}{\faIcon{#2}}};
            }
        }
    }
}

% contact info
\let\email\undefined
\NewDocumentCommand{\email}{m}{
    \href{mailto:#1}{\texttt{#1}}
}

\let\phone\undefined
\NewDocumentCommand{\phone}{m}{
    \href{tel:#1}{\phonenumber[country=US, area-code-sep=brackets]{#1}}
}

\prop_new:N \l_contact_prop
\keys_define:nn { cr / contact }
{
    email .code:n = {\prop_put:Nnn \l_contact_prop {envelope} {\email{#1}}},
    phone .code:n = {\prop_put:Nnn \l_contact_prop {phone} {\phone{#1}}},
    address .code:n = {\prop_put:Nnn \l_contact_prop {map-marker-alt} {#1}},
    website .code:n = {\prop_put:Nnn \l_contact_prop {globe} {\url{#1}}}
}

\NewDocumentCommand{\contact}{m}{
    \prop_clear:N \l_contact_prop
    \keys_set:nn { cr / contact } {#1}
    \begin{description}[itemsep=-0.1em, topsep=0pt]
        \prop_map_inline:Nn \l_contact_prop {
            \item[\icon{##1}] ##2
        }
    \end{description}
}

% experience
\let\experience\undefined
\keys_define:nn { cr / experience }
{
    organization .tl_set:N = \l_cr_organization_tl,
    duration .tl_set:N = \l_cr_duration_tl,
    title .tl_set:N = \l_cr_title_tl,
}
\NewDocumentEnvironment{experience}{m}
{
    \cr_el_sep:
    \keys_set:nn { cr / experience } {#1}
    \emph { \l_cr_organization_tl } \hfill { \cr_gray:n{weak} \l_cr_duration_tl } \\[-0.25em]
    \textit { \cr_gray:n{weak} \l_cr_title_tl } \\[-1.5em]
    \begin{itemize}
}
{ \end{itemize} }

% education
\keys_define:nn { cr / education } {
    school .tl_set:N = \l_cr_education_school_tl,
    graduation .tl_set:N = \l_cr_education_graduation_tl,
    gpa .tl_set:N = \l_cr_education_gpa_tl,
    nga .tl_set:N = \l_cr_education_nga_tl,
}

\NewDocumentCommand{\education}{m}{
    \cr_el_sep:
    \keys_set:nn { cr / education } { #1 }
    \emph{\cr_gray:n{subtitle} \l_cr_education_school_tl}\\[-0.45em]
    {\cr_gray:n{weak} Expected~Graduation:~\l_cr_education_graduation_tl}
    \cr_el_sep:\par
    \emph{GPA}~\l_cr_education_gpa_tl/4.0 \qquad 
    \emph{NGA}~\l_cr_education_nga_tl/100
}

\setlength\multicolsep{1.5pt}
\setlength{\parindent}{0pt}
