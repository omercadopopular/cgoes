{smcl}
{ * Version 1.0 20October2014}{...}
{ cmd: help graph3d}


{title:Title}


{p2colset 5 9 22 2}{...}
graph3d {hline 2} draw three dimensional graphs
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}
{opt graph3d} {it:var1 var2 var3} [{it:var4}] [if] [in] [{cmd:,} {it:options}]  

   
{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt :{opt col:orscheme} (string)} specifies a color scheme to visualize levels of {it:var2} (or {it:var4} if specified). Supported colorschemes are {opt cr} (cyan and red), {opt bcgyr} (blue, cyan, green, yellow and red) or {opt fade:togrey} (grey shades).{p_end}
{synopt :{opt mark}} displays four different markers according to the magnitude of {it: var2} (or {it: var4} if specified).{p_end}
{synopt :{opt equi:distance}} colors and/or markers change equidistantly; default is relative to distance.{p_end}
{synopt :{opt wire}} draws a wire frame that connects all datapoints with the same levels of {it:var1} and {it:var3}. {p_end}
{synopt :{opt xang:le} (int 45)} specifies the rotation angle about the x-axis with respect to the pivot.{p_end}
{synopt :{opt yang:le} (int 45)} specifies the rotation angle about the y-axis with respect to the pivot.{p_end}
{synopt :{opt zang:le} (int 45)} specifies the rotation angle about the z-axis with respect to the pivot{p_end}
{synopt :{opt xm:ove} (int 0} moves the graph along the x-axis.{p_end}
{synopt :{opt ym:ove} (int 0)} moves the graph along the y-axis.{p_end}
{synopt :{opt zm:ove} (int 0)} moves the graph along the z-axis.{p_end}
{synopt :{opt xlabel} (string)} specifies the labelling of the x-axis. {p_end}
{synopt :{opt ylabel} (string)} specifies the labelling of the y-axis. {p_end}
{synopt :{opt zlabel} (string)} specifies the labelling of the z-axis.{p_end}
{synopt :{opt xlp:os (int 0)}} specifies the position of the label of the x-axis. See {help compassdirstyle}. {p_end}
{synopt :{opt ylp:os (int 0)}} specifies the position of the label of the y-axis. See {help compassdirstyle}. {p_end}
{synopt :{opt zlp:os (int 0)}} specifies the position of the label of the z-axis. See {help compassdirstyle}. {p_end}
{synopt :{opt xlang:le (int 0)}} specifies the angle of the x-label.{p_end}
{synopt :{opt ylang:le (int 0)}} specifies the angle of the y-label.{p_end}
{synopt :{opt zlang:le (int 0)}} specifies the angle of the z-label.{p_end}
{synopt :{opt xpiv} (string} x-coordinate of pivot.{p_end}
{synopt :{opt ypiv} (string)} y-coordinate of pivot.{p_end}
{synopt :{opt zpiv} (string)} z-coordinate of pivot.{p_end}
{synopt :{opt xcam} (real 0)} x-position of camera relative to graph.{p_end}
{synopt :{opt ycam} (real 0)} y-position of camera relative to graph.{p_end}
{synopt :{opt zcam} (real 300)} z-position of camera relative to graph.{p_end}
{synopt :{opt perspective}} perspective projection with vanishing point instead of parallel projection.{p_end}
{synopt :{opt as:pectratio} (real 1)} aspect ratio of graph, see {help aspect_option}.{p_end}
{synopt :{opt s:cale} (real 1)} scale of graph (zoom in and out).{p_end}
{synopt :{opt piv}} shows the pivot. When specifying the angles, the graph is rotated around this pivot {p_end}
{synopt :{opt cub:oid}} shows a cuboid around the graph.{p_end}
{synopt :{opt innergrid}} additional grid lines on cuboid.{p_end}
{synopt :{opt f:ormat} (string)} format of coordinates of cuboid.{p_end}
{synopt :{opt markeroptions (string)}} users can specify all {help marker_options} in parentheses, see example 12 below. {p_end}
{synopt :{opt coord:inates (string)}} specifies  coordinates of the cuboid that are displayed (1 to 8).{p_end}
{synopt :{opt blv:ertices (int 0)}} vertices and coordinates of the cuboid are displayed in black.{p_end}

{title:Description}

{pstd}
Description: {cmd:graph3d} draws a three dimensional plot given a dataset of three variables. Moving, scaling, and 360 degree rotating over all axes is fully supported. Parallel projections can be generated, however, the perspective option allows the user to produce a perspective projection of the data. The user simply has to provide the three variables and graph3d will plot small black circles indicating each data point by default.

{pstd}
graph3d can handle even four variables: three variables are plotted along the three axes, the fourth is represented by different colors/shapes of the markers. Three predefined colorschemes allow the user to emphasize how data points move along the specified axis. The marker colors and size can - among other options - be chosen according to the preferences of the user. Using graph3d it is straightforward to produce animations to visualize the big picture. 

{pstd}
Typical use of the graph3d command include, to take an example from economics, to depict a budget constraint of a couple household. Other examples are: to use graph3d to illustrate how the utility level of a utility function depends on two arguments or to plot the indifference plane of a utility function that depends on three arguments. 

{title:Remarks and tips}

{pstd}
graph3d does not adjust the length of the three axes, thus giving the user full flexibility to change the proportion of the axes by manipulating the data. When the magnitudes of the values of the three variables differ substantially (e.g. when plotting two continuous and one categorical variable, see example 16) this can be advisable in order to improve the appearance of the graph.

{pstd}
A simple way to change the perspective of the figure is using the {opt xang:le(#)}, {opt yang:le(#)} or {opt zang:le(#)} options, which rotate the figure around the specified axes (see example 2 provided below). Additionally, the perspective can be changed by changing the camera angle or the position of the pivot.

{pstd}
When rotating the cuboid and with axis labels turned on, it might be necessary to adjust the position {opt xlp:os(#)}, {opt ylp:os(#)} and {opt zlp:os(#)}) and angles ({opt xlang:le(#)}, {opt ylang:le(#)} and {opt zlang:le(#)}) of the axis labels. See examples 15 and 16 below.

{pstd}
Instead of axis value labels graph3d can currently display the coordinates of the cuboid {opt coord:inates}. Specify the points of the cuboid (up to 8), whose coordinates you want to display. See examples 13 and 14.

{pstd}
When three (four) variables and a colorscheme or the {opt mark} option are specified, the third (fourth) variable determines the marker/color. 

{pstd} 
The {opt wire} command works best, when there is only one observations for each value of {it:var1} and {it:var3}. Using {cmdab:wire} with a very large dataset can result in the error "too many sersets". In this case it is not possible to use the wire function.

{title:Examples: colorful 3D-Plots of random data}

{pstd}Setup{p_end}
{phang2}{stata clear}{p_end}
{phang2}{stata set obs 630}{p_end}
{phang2}{stata gen x = int((_n - mod(_n-1,30) -1 ) /30 ) }{p_end}
{phang2}{stata gen z = mod(_n-1,30)}{p_end}
{phang2}{stata gen y = normalden(x,10,3)*normalden(z,15,5)*10000}{p_end}
{phang2}{stata gen w = x*z}{p_end}

{pstd}1. Default 3D-Plot{p_end}
{phang2}{stata graph3d x y z}{p_end}

{pstd}2. Default 3D-Plot rotated by 70 degree about the x-axis{p_end}
{phang2}{stata graph3d x y z, xang(75)}{p_end}

{pstd}3. Wireframe 3D-Plot{p_end}
{phang2}{stata graph3d x y z, wire}{p_end}

{pstd}4. Two-colored 3D-Plot{p_end}
{phang2}{stata graph3d x y z, colorscheme(cr)}{p_end}

{pstd}5. Plot where a fourth variable determines the color of the markers{p_end}
{phang2}{stata graph3d x y z w, colorscheme(cr)}{p_end}

{pstd}6. Plot where first variable determines the color of the markers{p_end}
{phang2}{stata graph3d x y z x, colorscheme(cr)}{p_end}

{pstd}7. Two-colored 3D-Plot with changing markers{p_end}
{phang2}{stata graph3d x y z, mark colorscheme(cr)}{p_end}

{pstd}8. Equidistantly two-colored 3D-Plot with changing markers{p_end}
{phang2}{stata graph3d x y z, equi mark colorscheme(cr)}{p_end}

{pstd}9. Five-colored 3D-Plot with changing markers{p_end}
{phang2}{stata graph3d x y z, mark colorscheme(bcgyr)}{p_end}

{pstd}10. Grey scale 3D-Plot with changing markers{p_end}
{phang2}{stata graph3d x y z, mark colorscheme(fade)}{p_end}

{pstd}11. Perspective 3D-Plot{p_end}
{phang2}{stata graph3d x y z, ycam(-4) zcam(-18) cuboid innergrid blv perspective colorscheme(bcgyr)}{p_end}

{pstd}12. Marker options specified by user{p_end}
{phang2}{stata graph3d x y z, markeroptions(mcolor(red) msymbol(diamond))}{p_end}

{pstd}13. Plot with cuboid and coordinates of three points{p_end}
{phang2}{stata graph3d x y z, cuboid coordinates(5 2 8)}{p_end}

{pstd}14. Plot with cuboid and coordinates of eight points displayed in black{p_end}
{phang2}{stata graph3d x y z, cuboid coordinates(all) blv}{p_end}

{pstd}15. Plot with cuboid and user defined axis labels, rotated by 80 degree about the x axis.{p_end}
{phang2}{stata graph3d x y z, cuboid xangle(80) xlabel(test1) xlangle (330) xlpos(9) yl(test 2) ylangle(90) ylpos(3) zlabel(test 3) zlangle(33) zlpos(11)}{p_end}

{pstd}16. Ploting two continuous and one categorial variable.{p_end}
{phang2}{stata clear }{p_end}
{phang2}{stata sysuse citytemp.dta }{p_end}
{phang2}{stata gen reg = region * 1000 }{p_end}
{phang2}{stata graph3d heatdd cooldd reg, cuboid innergrid colorscheme(bcgyr) xang(15) yang(80) xlab("Heating degree days") ylab("Cooling degree days") zlab("Census Region") xlang(315) ylang(90) zlang(0) xlpos(11) ylpos(3) zlpos(11)}{p_end}

{phang2}{browse "http://davud.rostam-afschar.de/graph3d/graph3d.htm":more examples}{p_end}

{title:Authors}

Robin Jessen
Freie Universit{c a:}t Berlin
{browse "mailto:robin.jessen@fu-berlin.de":robin.jessen@fu-berlin.de}

Davud Rostam-Afschar
Freie Universit{c a:}t Berlin and DIW Berlin
{browse "mailto:davud.rostam-afschar@fu-berlin.de":davud.rostam-afschar@fu-berlin.de}

{title:See also}

Surface by Adrian Mander
