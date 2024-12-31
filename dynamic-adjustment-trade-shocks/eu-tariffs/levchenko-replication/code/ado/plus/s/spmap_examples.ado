*! -spmap_examples-: Auxiliary program for -spmap-                             
*! Version 1.3.0 - 13 March 2017                                               
*! Version 1.2.0 - 14 March 2008                                               
*! Version 1.1.0 - 7 May 2007                                                  
*! Version 1.0.0 - 7 December 2006                                             
*! Author: Maurizio Pisati                                                     
*! Department of Sociology and Social Research                                 
*! University of Milano Bicocca (Italy)                                        
*! maurizio.pisati@unimib.it                                                   




*  ----------------------------------------------------------------------------
*  1. Main program                                                             
*  ----------------------------------------------------------------------------

program spmap_examples
version 9.2
args EXAMPLE
set more off
`EXAMPLE'
end




*  ----------------------------------------------------------------------------
*  2. Choropleth maps                                                          
*  ----------------------------------------------------------------------------

program chomap01
sysuse "Italy-RegionsData.dta", clear
spmap relig1 using "Italy-RegionsCoordinates.dta", id(id)
end

program chomap02
sysuse "Italy-RegionsData.dta", clear
spmap relig1 using "Italy-RegionsCoordinates.dta", id(id)              ///
      title("Pct. Catholics without reservations", size(*0.8))         ///
      subtitle("Italy, 1994-98" " ", size(*0.8))                       
end

program chomap03
sysuse "Italy-RegionsData.dta", clear
spmap relig1 using "Italy-RegionsCoordinates.dta", id(id)              ///
      title("Pct. Catholics without reservations", size(*0.8))         ///
      subtitle("Italy, 1994-98" " ", size(*0.8))                       ///
      legstyle(2) legend(region(lcolor(black)))                        
end

program chomap04
sysuse "Italy-RegionsData.dta", clear
spmap relig1m using "Italy-RegionsCoordinates.dta", id(id)             ///
      ndfcolor(red)                                                    ///
      title("Pct. Catholics without reservations", size(*0.8))         ///
      subtitle("Italy, 1994-98" " ", size(*0.8))                       ///
      legstyle(2) legend(region(lcolor(black)))                        
end

program chomap05
sysuse "Italy-RegionsData.dta", clear
spmap relig1 using "Italy-RegionsCoordinates.dta", id(id)              ///
      clmethod(eqint) clnumber(5) eirange(20 70)                       ///
      title("Pct. Catholics without reservations", size(*0.8))         ///
      subtitle("Italy, 1994-98" " ", size(*0.8))                       ///
      legstyle(2) legend(region(lcolor(black)))                        
end

program chomap06
sysuse "Italy-RegionsData.dta", clear
spmap relig1 using "Italy-RegionsCoordinates.dta", id(id)              ///
      clnumber(20) fcolor(Reds2) ocolor(none ..)                       ///
      title("Pct. Catholics without reservations", size(*0.8))         ///
      subtitle("Italy, 1994-98" " ", size(*0.8))                       ///
      legstyle(3)                                                      
end

program chomap07
sysuse "Italy-RegionsData.dta", clear
spmap relig1 using "Italy-RegionsCoordinates.dta", id(id)              ///
      clnumber(20) fcolor(Reds2) ocolor(none ..)                       ///
      title("Pct. Catholics without reservations", size(*0.8))         ///
      subtitle("Italy, 1994-98" " ", size(*0.8))                       ///
      legstyle(3) legend(ring(1) position(3))                          
end

program chomap08
sysuse "Italy-RegionsData.dta", clear
spmap relig1 using "Italy-RegionsCoordinates.dta", id(id)              ///
      clnumber(20) fcolor(Reds2) ocolor(none ..)                       ///
      title("Pct. Catholics without reservations", size(*0.8))         ///
      subtitle("Italy, 1994-98" " ", size(*0.8))                       ///
      legstyle(3) legend(ring(1) position(3))                          ///
      plotregion(margin(vlarge))                                       
end

program chomap09
sysuse "Italy-RegionsData.dta", clear
spmap relig1 using "Italy-RegionsCoordinates.dta", id(id)              ///
      clnumber(20) fcolor(Reds2) ocolor(none ..)                       ///
      title("Pct. Catholics without reservations", size(*0.8))         ///
      subtitle("Italy, 1994-98" " ", size(*0.8))                       ///
      legstyle(3) legend(ring(1) position(3))                          ///
      plotregion(icolor(stone)) graphregion(icolor(stone))
end

program chomap10
sysuse "Italy-RegionsData.dta", clear
spmap relig1 using "Italy-RegionsCoordinates.dta", id(id)              ///
      clnumber(20) fcolor(Greens2) ocolor(white ..) osize(medthin ..)  ///
      title("Pct. Catholics without reservations", size(*0.8))         ///
      subtitle("Italy, 1994-98" " ", size(*0.8))                       ///
      legstyle(3) legend(ring(1) position(3))                          ///
      plotregion(icolor(stone)) graphregion(icolor(stone))
end

program chomap11
sysuse "Italy-RegionsData.dta", clear
spmap relig1 using "Italy-RegionsCoordinates.dta", id(id)              ///
      clnumber(20) fcolor(Greens2) ocolor(white ..) osize(thin ..)     ///
      title("Pct. Catholics without reservations", size(*0.8))         ///
      subtitle("Italy, 1994-98" " ", size(*0.8))                       ///
      legstyle(3) legend(ring(1) position(3))                          ///
      plotregion(icolor(stone)) graphregion(icolor(stone))             ///
      polygon(data("Italy-Highlights.dta") ocolor(white)               ///
      osize(medthick))
end

program chomap12
sysuse "Italy-RegionsData.dta", clear
spmap relig1 using "Italy-RegionsCoordinates.dta", id(id)          ///
  clnumber(20) fcolor(Greens2) ocolor(white ..) osize(medthin ..)  ///
  title("Pct. Catholics without reservations", size(*0.8))         ///
  subtitle("Italy, 1994-98" " ", size(*0.8))                       ///
  legstyle(3) legend(ring(1) position(3))                          ///
  plotregion(icolor(stone)) graphregion(icolor(stone))             ///
  scalebar(units(500) scale(1/1000) xpos(-100) label(Kilometers))
end




*  ----------------------------------------------------------------------------
*  3. Proportional symbol maps                                                 
*  ----------------------------------------------------------------------------

program prsmap01
sysuse "Italy-OutlineData.dta", clear
spmap using "Italy-OutlineCoordinates.dta", id(id)                 ///
  title("Pct. Catholics without reservations", size(*0.8))         ///
  subtitle("Italy, 1994-98" " ", size(*0.8))                       ///
  point(data("Italy-RegionsData.dta") xcoord(xcoord)               ///
  ycoord(ycoord) proportional(relig1) fcolor(red) size(*1.5))
end

program prsmap02
sysuse "Italy-OutlineData.dta", clear
spmap using "Italy-OutlineCoordinates.dta", id(id)                 ///
  title("Pct. Catholics without reservations", size(*0.8))         ///
  subtitle("Italy, 1994-98" " ", size(*0.8))                       ///
  point(data("Italy-RegionsData.dta") xcoord(xcoord)               ///
  ycoord(ycoord) proportional(relig1) fcolor(red) size(*1.5)       ///
  shape(s))
end

program prsmap03
sysuse "Italy-OutlineData.dta", clear
spmap using "Italy-OutlineCoordinates.dta", id(id)                 ///
  title("Pct. Catholics without reservations", size(*0.8))         ///
  subtitle("Italy, 1994-98" " ", size(*0.8))                       ///
  point(data("Italy-RegionsData.dta") xcoord(xcoord)               ///
  ycoord(ycoord) proportional(relig1) fcolor(red)                  ///
  ocolor(white) size(*3))                                          ///
  label(data("Italy-RegionsData.dta") xcoord(xcoord)               ///
  ycoord(ycoord) label(relig1) color(white) size(*0.7))
end

program prsmap04
sysuse "Italy-OutlineData.dta", clear
spmap using "Italy-OutlineCoordinates.dta", id(id)                 ///
  title("Pct. Catholics without reservations", size(*0.8))         ///
  subtitle("Italy, 1994-98" " ", size(*0.8))                       ///
  point(data("Italy-RegionsData.dta") xcoord(xcoord)               ///
  ycoord(ycoord) deviation(relig1) fcolor(red) dmax(30)            ///
  legenda(on) leglabel(Deviation from the mean))
end

program prsmap05
sysuse "Italy-OutlineData.dta", clear
spmap using "Italy-OutlineCoordinates.dta", id(id) fcolor(white)   ///
  title("Catholics without reservations", size(*0.9) box bexpand   ///
  span margin(medsmall) fcolor(sand)) subtitle(" ")                ///
  point(data("Italy-RegionsData.dta") xcoord(xcoord)               ///
  ycoord(ycoord) proportional(relig1) prange(0 70)                 ///
  psize(absolute) fcolor(red) ocolor(white) size(*0.6))            ///
  plotregion(margin(medium) color(stone))                          ///
  graphregion(fcolor(stone) lcolor(black))                         ///
  name(g1, replace) nodraw
spmap using "Italy-OutlineCoordinates.dta", id(id) fcolor(white)   ///
  title("Catholics with reservations", size(*0.9) box bexpand      ///
  span margin(medsmall) fcolor(sand)) subtitle(" ")                ///
  point(data("Italy-RegionsData.dta") xcoord(xcoord)               ///
  ycoord(ycoord) proportional(relig2) prange(0 70)                 ///
  psize(absolute) fcolor(green) ocolor(white) size(*0.6))          ///
  plotregion(margin(medium) color(stone))                          ///
  graphregion(fcolor(stone) lcolor(black))                         ///
  name(g2, replace) nodraw
spmap using "Italy-OutlineCoordinates.dta", id(id) fcolor(white)   ///
  title("Other", size(*0.9) box bexpand                            ///
  span margin(medsmall) fcolor(sand)) subtitle(" ")                ///
  point(data("Italy-RegionsData.dta") xcoord(xcoord)               ///
  ycoord(ycoord) proportional(relig3) prange(0 70)                 ///
  psize(absolute) fcolor(blue) ocolor(white) size(*0.6))           ///
  plotregion(margin(medium) color(stone))                          ///
  graphregion(fcolor(stone) lcolor(black))                         ///
  name(g3, replace) nodraw
graph combine g1 g2 g3, rows(1) title("Religious orientation")     ///
  subtitle("Italy, 1994-98" " ") xsize(5) ysize(2.6)               ///
  plotregion(margin(medsmall) style(none))                         ///
  graphregion(margin(zero) style(none))                            ///
  scheme(s1mono)
end




*  ----------------------------------------------------------------------------
*  4. Other maps                                                               
*  ----------------------------------------------------------------------------

program othmap01
sysuse "Italy-RegionsData.dta", clear
spmap using "Italy-RegionsCoordinates.dta", id(id) fcolor(stone)   ///
  title("Pct. Catholics without reservations", size(*0.8))         ///
  subtitle("Italy, 1994-98" " ", size(*0.8))                       ///
  diagram(variable(relig1) range(0 100) refweight(pop98)           ///
  xcoord(xcoord) ycoord(ycoord) fcolor(red))
end

program othmap02
sysuse "Italy-RegionsData.dta", clear
spmap using "Italy-RegionsCoordinates.dta", id(id) fcolor(stone)   ///
  diagram(variable(relig1 relig2 relig3) proportional(fortell)     ///
  xcoord(xcoord) ycoord(ycoord) legenda(on))                       ///
  legend(title("Religious orientation", size(*0.5) bexpand         ///
  justification(left)))                                            ///
  note(" "                                                         ///
  "NOTE: Chart size proportional to number of fortune tellers per million population", ///
  size(*0.75))
end

program othmap03
sysuse "Italy-RegionsData.dta", clear
spmap relig1 using "Italy-RegionsCoordinates.dta", id(id)          ///
  clmethod(stdev) clnumber(5)                                      ///
  title("Pct. Catholics without reservations", size(*0.8))         ///
  subtitle("Italy, 1994-98" " ", size(*0.8)) area(pop98)           ///
  note(" "                                                         ///
  "NOTE: Region size proportional to population", size(*0.75))
end

program othmap04
sysuse "Italy-RegionsData.dta", clear
spmap relig1 using "Italy-RegionsCoordinates.dta", id(id)          ///
  clmethod(stdev) clnumber(5)                                      ///
  title("Pct. Catholics without reservations", size(*0.8))         ///
  subtitle("Italy, 1994-98" " ", size(*0.8)) area(pop98)           ///
  map("Italy-OutlineCoordinates.dta") mfcolor(stone)               ///
  note(" "                                                         ///
  "NOTE: Region size proportional to population", size(*0.75))
end

program othmap05
sysuse "Italy-OutlineData.dta", clear
spmap using "Italy-OutlineCoordinates.dta", id(id) fc(bluishgray)  ///
  ocolor(none)                                                     ///
  title("Provincial capitals" " ", size(*0.9) color(white))        ///
  point(data("Italy-Capitals.dta") xcoord(xcoord)                  ///
  ycoord(ycoord) fcolor(emerald))                                  ///
  plotregion(margin(medium) icolor(dknavy) color(dknavy))          ///
  graphregion(icolor(dknavy) color(dknavy))
end

program othmap06
sysuse "Italy-OutlineData.dta", clear
spmap using "Italy-OutlineCoordinates.dta", id(id) fc(bluishgray)  ///
  ocolor(none)                                                     ///
  title("Provincial capitals" " ", size(*0.9) color(white))        ///
  point(data("Italy-Capitals.dta") xcoord(xcoord)                  ///
  ycoord(ycoord) by(size) fcolor(orange red maroon) shape(s ..)    ///
  legenda(on))                                                     ///
  legend(title("Population 1998", size(*0.5) bexpand               ///
  justification(left)) region(lcolor(black) fcolor(white))         ///
  position(2))                                                     ///
  plotregion(margin(medium) icolor(dknavy) color(dknavy))          ///
  graphregion(icolor(dknavy) color(dknavy))
end

program othmap07
sysuse "Italy-OutlineData.dta", clear
spmap using "Italy-OutlineCoordinates.dta", id(id) fc(sand)        ///
  title("Main lakes and rivers" " ", size(*0.9))                   ///
  polygon(data("Italy-Lakes.dta") fcolor(blue) ocolor(blue))       ///
  line(data("Italy-Rivers.dta") color(blue) )
end

program othmap08
sysuse "Italy-RegionsData.dta", clear
spmap relig1 using "Italy-RegionsCoordinates.dta" if zone==1, id(id)   ///
        fcolor(Blues2) ocolor(white ..) osize(medthin ..)              ///
        title("Pct. Catholics without reservations", size(*0.8))       ///
        subtitle("Northern Italy, 1994-98" " ", size(*0.8))            ///
        polygon(data("Italy-OutlineCoordinates.dta") fcolor(gs12)      ///
        ocolor(white) osize(medthin)) polyfirst
end

program othmap09
sysuse "Italy-OutlineData.dta", clear
spmap using "Italy-OutlineCoordinates.dta", id(id) fc(sand)        ///
  title("Main lakes and rivers" " ", size(*0.9))                   ///
  polygon(data("Italy-Lakes.dta") fcolor(blue) ocolor(blue))       ///
  line(data("Italy-Rivers.dta") color(blue) )                      ///
  freestyle aspect(1.4) xlab(400000 900000 1400000, grid)
end



