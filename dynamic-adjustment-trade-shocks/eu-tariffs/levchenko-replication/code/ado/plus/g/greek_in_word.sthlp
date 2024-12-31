{smcl}
{* *! version 1.00  31aug2010}{...}
{cmd:help greek_in_word}
{hline}

{title:Title}

    {hi:Greek} and other Unicode characters in Word Rich Text Format (RTF) documents

{pstd}
In Word RTF files, Greek letters and other Unicode characters can be included in the text as follows: a four digit decimal Unicode code preceded by "\u" and followed by "?".  
Complete Unicode code tables are available at {browse "http://www.unicode.org/charts":www.unicode.org/charts}.  
For use in Word RTF files, the hexadecimal codes in the tables must be converted to decimal numbers. 

{pstd}
For example, for the Greek lowercase character alpha, the hexadecimal Unicode code is 03B1, which is equivalent to 945 decimal.  
We can make this into a four digit number by putting a "0" on the front, so the appropriate RTF code would be "\u0945?".  

{pstd}
For another example, the Euro currency symbol is hexadecimal Unicode 20AC which is 8364 decimal, so the inline RTF code would be "\u8364?".

{pstd}
The Unicode characters displayed in the Word file are only limited by which Unicode characters are diplayable in the font being used.  
For fonts like Times New Roman and Arial, a very wide range of characters can be displayed.

{phang}
{help greek_in_word##lower:Lowercase Greek letters}{p_end}
{phang}
{help greek_in_word##upper:Uppercase Greek letters}{p_end}

{marker lower}{...}
{phang}
{bf:Lowercase Greek letters}

{p2colset 10 25 27 55}{...}
{p2col:Greek letter}RTF code{p_end}
{p2line}
{p2colset 12 26 28 55}{...}
{p2col:alpha}\u0945?{p_end}
{p2col:beta}\u0946?{p_end}
{p2col:gamma}\u0947?{p_end}
{p2col:delta}\u0948?{p_end}
{p2col:epsilon}\u0949?{p_end}
{p2col:zeta}\u0950?{p_end}
{p2col:eta}\u0951?{p_end}
{p2col:theta}\u0952?{p_end}
{p2col:iota}\u0953?{p_end}
{p2col:kappa}\u0954?{p_end}
{p2col:lambda}\u0955?{p_end}
{p2col:mu}\u0956?{p_end}
{p2col:nu}\u0957?{p_end}
{p2col:xi}\u0958?{p_end}
{p2col:omicron}\u0959?{p_end}
{p2col:pi}\u0960?{p_end}
{p2col:rho}\u0961?{p_end}
{p2col:sigma}\u0963?{p_end}
{p2col:tau}\u0964?{p_end}
{p2col:upsilon}\u0965?{p_end}
{p2col:phi}\u0966?{p_end}
{p2col:chi}\u0967?{p_end}
{p2col:psi}\u0968?{p_end}
{p2col:omega}\u0969?{p_end}
{p2colset 10 25 27 55}{...}
{p2line}


{marker upper}{...}
{phang}
{bf:Uppercase Greek letters}{p_end}

{p2colset 10 25 27 55}{...}
{p2col:Greek letter}RTF code{p_end}
{p2line}
{p2colset 12 26 28 55}{...}
{p2col:ALPHA}\u0913?{p_end}
{p2col:BETA}\u0914?{p_end}
{p2col:GAMMA}\u0915?{p_end}
{p2col:DELTA}\u0916?{p_end}
{p2col:EPSILON}\u0917?{p_end}
{p2col:ZETA}\u0918?{p_end}
{p2col:ETA}\u0919?{p_end}
{p2col:THETA}\u0920?{p_end}
{p2col:IOTA}\u0921?{p_end}
{p2col:KAPPA}\u0922?{p_end}
{p2col:LAMBDA}\u0923?{p_end}
{p2col:MU}\u0924?{p_end}
{p2col:NU}\u0925?{p_end}
{p2col:XI}\u0926?{p_end}
{p2col:OMICRON}\u0927?{p_end}
{p2col:PI}\u0928?{p_end}
{p2col:RHO}\u0929?{p_end}
{p2col:SIGMA}\u0931?{p_end}
{p2col:TAU}\u0932?{p_end}
{p2col:UPSILON}\u0933?{p_end}
{p2col:PHI}\u0934?{p_end}
{p2col:CHI}\u0935?{p_end}
{p2col:PSI}\u0936?{p_end}
{p2col:OMEGA}\u0937?{p_end}
{p2colset 10 25 27 55}{...}
{p2line}

