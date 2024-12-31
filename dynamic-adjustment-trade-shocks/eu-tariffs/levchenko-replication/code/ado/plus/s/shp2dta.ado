*! version 1.0.9 15jul2015
* -----version 1.0.8 15jul2015------
* Added support for all shapefile formats
* -----version 1.0.8 01oct2012------
* fixed st_addvar(): 3300 bug when dbf variable name had a invalid character
* dbf orginal variable name now stored as variable label
* -----version 1.0.7 01oct2012------
* added support for null (type 0) shape types
* fixed  st_addvar():  3300 error for dbase str variables
*	over 244 in length
* -----version 1.0.5 13jul2011------
* Removed memory error for Stata 12
* Fix bug with dbase files generating error
*	bufget():  3300  argument out of range
* ------version 1.0.4 13may2008-----
* Stata 10.1 -_ID variable will automatically be
* created in the dbf file.
* Added support for line and point shp files
program define shp2dta
	version 9

	syntax using/ , DATAbase(string) COORdinates(string) ///
			[replace GENCentroids(name) genid(name)]

					// Check for shape file
	if (strpos(`"`using'"', ".")==0) {
			local using `"`using'.shp"'
	}
	local shp_file `"`using'"'
					// Create macros for the .dbf file
	local dbf_file : subinstr local shp_file `".shp"' `".dbf"'

					// Confirm shp and dbf file exist
	confirm file `"`shp_file'"'
	confirm file `"`dbf_file'"'

					// Preserve and clear data in memory
	preserve
	drop _all

					// Read shp file
	mata: read_shp(`"`shp_file'"')

					// Compress, sort, and save coordinates
	qui {
		compress
		tempname TEMP
		generate long `TEMP' = _n
		sort _ID `TEMP'
		drop `TEMP'
		local cfilename : subinstr local coordinates `".dta"' `""'
		save `"`cfilename'"', `replace'
	}

					// Clear coordinates dataset
	drop _all

					// Read dbf file
	mata: read_dbf(`"`dbf_file'"')

					// Compress and save database dataset
	qui {
		if `"`genid'"' != "" {
			generate long `genid' = _n
			sort `genid'
		}
		else {
			if (_caller() > 10.0) {
				generate long _ID = _n
				sort _ID
			}
		}
		compress
		local dfilename : subinstr local database `".dta"' `""'
		save `"`dfilename'"', `replace'
	}

					// Create centroids x and y variables
	if "`gencentroids'"!="" {
		if `"`genid'"' == "" {
			dis as error ///
				"you must also specify the genid(name) option"
			exit(198)
		}
		quietly {
use `"`cfilename'"', clear
bys _ID: gen float TEMPa=(_X*_Y[_n+1])-(_X[_n+1]*_Y) if _n>1 & _n<_N
bys _ID: gen float _AREA=sum(TEMPa)
bys _ID: replace _AREA=_AREA[_N]/2
bys _ID: gen float TEMPx=(_X+_X[_n+1])*(_X*_Y[_n+1]-_X[_n+1]*_Y) if _n>1 & _n<_N
bys _ID: gen float _CX=sum(TEMPx)
bys _ID: replace _CX=_CX[_N]/(6*_AREA)
bys _ID: gen float TEMPy=(_Y+_Y[_n+1])*(_X*_Y[_n+1]-_X[_n+1]*_Y) if _n>1 & _n<_N
bys _ID: gen float _CY=sum(TEMPy)
bys _ID: replace _CY=_CY[_N]/(6*_AREA)
collapse _CX _CY, by(_ID)
rename _ID `genid'
rename _CX x_`gencentroids'
rename _CY y_`gencentroids'
lab var `genid' "Area ID"
lab var x_`gencentroids' "x-coordinate of area centroid"
lab var y_`gencentroids' "y-coordinate of area centroid"
sort `genid'
merge `genid' using `"`dfilename'"'
drop _merge
compress
save `"`dfilename'"', replace
		}
	}
end

/* -------------------------------------------------------------------- */
local BUFSIZE	200
version 9.0
mata:

void read_shp(string scalar shp_file)
{
	real scalar		fh_in
	transmorphic colvector	C
	real rowvector		parts

	real scalar field_code, length, ver, type, x, y, num_bytes, start_byte
	real scalar record_num, content_length, next_record
	real scalar num_parts, num_points, num_of_obs, i, j, cols, points
	real scalar pstart, pend, sobs, obs, n
	real scalar bufsize, numofbufs, numPointsInPart, null_count
	real scalar posi, posf, posz, posm, skipz, skipm, skip, obscounter, measure
	real matrix tmp

	// Open shape file .shp, open buffer, and set byte order
	fh_in = fopen(shp_file, "r")
	C = bufio()
	bufbyteorder(C, 1)

	// Get field code and file length from shape file
	field_code = fbufget(C, fh_in, "%4b")
	fseek(fh_in, 24, -1)
	length = fbufget(C, fh_in, "%4b")

	// Change byte order and get version and shape type
	bufbyteorder(C, 2)
	ver = fbufget(C, fh_in, "%4b")
	type = fbufget(C, fh_in, "%4b")
	printf("type: %s\n", strofreal(type))

	// Check shape file header for field code and version
	if (field_code!=9994 | ver!=1000) {
		errprintf("%s: invalid shape file\n", shp_file)
		exit(610)
	}

	// Create variables and check shape type
		if (type == 1 | type == 8 | type == 3 | type == 5) {
			(void) st_addvar(("long","double","double"), ("_ID", "_X", "_Y"))
		}
		else if (type == 11 | type == 18 | type == 13 | type == 15) {
			(void) st_addvar(("long","double","double","double","double"), ("_ID", "_X", "_Y","_Z","_M"))
		}
		else if (type == 21 | type == 28 | type == 23 | type == 25) {
			(void) st_addvar(("long","double","double","double"), ("_ID", "_X", "_Y","_M"))
		}
		else if (type == 31) {
			(void) st_addvar(("long","long","double","double","double","double"), ("_ID", "Part_type", "_X", "_Y","_Z","_M"))
		}
		else if (type == 0) {
		}
		else {
			errprintf("%s: shapefile type not supported\n", shp_file)
			exit(610)
	}

	// Go to byte 100
	fseek(fh_in, 100, -1)

	// Calculate the number of bytes
	num_bytes = (length * 16)/8

	if (st_numscalar("c(stata_version)") < 12 ) {
		if (num_bytes >= st_numscalar("c(memory)")) {
			errprintf("insufficient memory\n")
			errprintf("{p 4 4 2}\n")
			errprintf("To process this data, Stata will need at \n")
			errprintf("least %g megs of memory.\n",
				num_bytes/(1024^2))
			errprintf("{p_end}\n")
			exit(901)
		}
	}

	// Loop over bytes to get each record and create observation counter
	start_byte = 100
	obs = 1
	null_count = 0
	obscounter = 0

	while (start_byte < num_bytes) {
		// Change byte order and get record number and length
		bufbyteorder(C, 1)
		fseek(fh_in, start_byte, -1)

		record_num = fbufget(C, fh_in, "%4b")
		content_length = fbufget(C, fh_in, "%4b")

		// Find start of next record
		next_record = ((content_length+4)*16) / 8
		numberofbytes = content_length*16/8

		// Change byte order and get shapetype
		bufbyteorder(C, 2)
		type = fbufget(C, fh_in, "%4b")

		// Read in data based on shape type
		if (type == 0) {
			//null
			start_byte = start_byte + next_record
			null_count++
			continue
		}
		else if (type == 1) {
			//point
			// Get the id X Y values
			st_addobs(1)
			st_store(obs, (1,2,3), (obs, fbufget(C, fh_in, "%8z", 1, 2)))
			obs = obs + 1
		}
		else if (type == 8) {
			//multipoint
			// Get the number of points for the record
			fseek(fh_in, 32, 0)
			num_points = fbufget(C, fh_in, "%4b")

			// Add obs to dataset
			num_of_obs = num_points + 1
			st_addobs(num_of_obs)

			// Store the first obs of record as missing
			st_store(obs, (1,2,3), (record_num, ., .))
			sobs = obs++

			// Store X and Y obs in `BUFSIZE' block chunks
			bufsize = `BUFSIZE'
			numofbufs = floor(num_points/bufsize)

			for (j=1; j<=numofbufs; j++) {
				st_store((obs,obs+bufsize-1), (2,3),
					fbufget(C, fh_in, "%8z", bufsize, 2))
				obs = obs + bufsize
			}

			// Store the remainder of observations
			bufsize = num_points - numofbufs*bufsize
			if (bufsize) {
				st_store((obs,obs+bufsize-1), (2,3),
					fbufget(C, fh_in, "%8z", bufsize, 2))
				obs = obs + bufsize
			}
			n = obs - sobs

			// Fill in record num for record
			st_store((sobs,obs-1), 1, J(n,1,record_num))
		}
		else if (type == 3 | type == 5) {
			//polyline and polygon
			// Get the number of parts and points for the record
			fseek(fh_in, 32, 0)
			num_parts  = fbufget(C, fh_in, "%4b")
			num_points = fbufget(C, fh_in, "%4b")

			// Create rowvector of parts array
			parts = fbufget(C, fh_in, "%4b", num_parts)

			// Get the number of obs and add to dataset
			num_of_obs = num_points + num_parts
			st_addobs(num_of_obs)

			// Loop of parts row vector
			cols = cols(parts)
			points = num_points

			for (i=1; i<=cols; i++) {
				if (i==cols) {
					numPointsInPart = points
				}
				else {
					pstart          = parts[i]
					pend            = parts[i + 1]
					numPointsInPart = pend - pstart
				}

				// Store the first obs of part as missing
				st_store(obs, (1,2,3), (record_num, ., .))
				sobs = obs++

				// Store X and Y obs in `BUFSIZE' block chunks
				bufsize = `BUFSIZE'
				numofbufs = floor(numPointsInPart/bufsize)

				for (j=1; j<=numofbufs; j++) {
					st_store((obs,obs+bufsize-1), (2,3),
						fbufget(C, fh_in, "%8z", bufsize, 2))
					obs = obs + bufsize
				}

				// Store the remainder of observations
				bufsize = numPointsInPart - numofbufs*bufsize
				if (bufsize) {
					st_store((obs,obs+bufsize-1), (2,3),
						fbufget(C, fh_in, "%8z", bufsize, 2))
					obs = obs + bufsize
				}
				n = obs - sobs

				// Fill in record num for part
				st_store((sobs,obs-1), 1, J(n,1,record_num))
				points = points - (pend - pstart)
			}
		}
		else if (type == 21) {
			//pointM
			// Get the id X Y M values
			st_addobs(1)
			st_store(obs, (1,2,3,4), (obs, fbufget(C, fh_in, "%8z", 1, 3)))
			obs = obs + 1
		}
		else if (type == 28) {
			//multipointM
			// Get the number of points for the record
			fseek(fh_in, 32, 0)
			num_points = fbufget(C, fh_in, "%4b")

			// Determine if M values are specified
			if (numberofbytes == (40 + 16*num_points + 16 + 8*num_points)) {
				measure = 1
			}
			else {
				measure = 0
			}

			// Add obs to dataset
			num_of_obs = num_points + 1
			st_addobs(num_of_obs)

			// Set pos for skips
			posi = ftell(fh_in)

			if (measure) {
				skip = 16*num_points+16
				fseek(fh_in, posi, -1)
				fseek(fh_in, skip, 0)
				posm = ftell(fh_in)
			}

			fseek(fh_in, posi, -1)
			posf = posi

			// Store the first obs of record as missing
			st_store(obs, (1,2,3,4), (record_num, ., ., .))
			sobs = obs++

			// Store X Y & M obs in `BUFSIZE' block chunks
			bufsize = `BUFSIZE'
			numofbufs = floor(num_points/bufsize)

			for (j=1; j<=numofbufs; j++) {
				//skip back to after last point read
				fseek(fh_in, posf, -1)

				// store x & y values
				st_store((obs,obs+bufsize-1), (2,3),
					fbufget(C, fh_in, "%8z", bufsize, 2))
				posf = ftell(fh_in)

				if (measure) {
					// skip to m array
					skipm = (obs-obscounter-2)*8
					fseek(fh_in, posm, -1)
					fseek(fh_in, skipm, 0)

					// store m values
					st_store((obs,obs+bufsize-1), (4),
						fbufget(C, fh_in, "%8z", bufsize, 1))
				}
				else {
					// store . for all m values
					tmp = J(bufsize,1,0)
					for (i=1; i<=bufsize; i++) {
						tmp[i,1] = .
					}
					st_store((obs,obs+bufsize-1), (4), tmp)
				}

				obs = obs + bufsize
			}


			// Store the remainder of observations
			bufsize = num_points - numofbufs*bufsize

			if (bufsize) {
				//skip back to after last point read
				fseek(fh_in, posf, -1)

				// store x & y values
				st_store((obs,obs+bufsize-1), (2,3),
					fbufget(C, fh_in, "%8z", bufsize, 2))
				posf = ftell(fh_in)

				if (measure) {
					// skip to m array
					skipm = (obs-obscounter-2)*8
					fseek(fh_in, posm, -1)
					fseek(fh_in, skipm, 0)

					// store m values
					st_store((obs,obs+bufsize-1), (4),
						fbufget(C, fh_in, "%8z", bufsize, 1))
				}
				else {
					// store . for all m values
					tmp = J(bufsize,1,0)
					for (i=1; i<=bufsize; i++) {
						tmp[i,1] = .
					}
					st_store((obs,obs+bufsize-1), (4), tmp)
				}

				obs = obs + bufsize
			}
			n = obs - sobs

			// Fill in record num for record
			st_store((sobs,obs-1), 1, J(n,1,record_num))
		}
		else if (type == 23 | type == 25) {
			//polylineM and polygonM
			// Get the number of parts and points for the record
			fseek(fh_in, 32, 0)
			num_parts  = fbufget(C, fh_in, "%4b")
			num_points = fbufget(C, fh_in, "%4b")

			// Determine if M values are specified
			if (numberofbytes == (44 + 4*num_parts + 16*num_points + 16 + 8*num_points)) {
				measure = 1
			}
			else {
				measure = 0
			}

			// Create rowvector of parts array
			parts = fbufget(C, fh_in, "%4b", num_parts)

			// Get the number of obs and add to dataset
			num_of_obs = num_points + num_parts
			st_addobs(num_of_obs)

			// Set pos for skips
			posi = ftell(fh_in)

			if (measure) {
				skip = 16*num_points+16
				fseek(fh_in, posi, -1)
				fseek(fh_in, skip, 0)
				posm = ftell(fh_in)
			}

			fseek(fh_in, posi, -1)
			posf = posi

			// Loop of parts row vector
			cols = cols(parts)
			points = num_points

			for (i=1; i<=cols; i++) {
				if (i==cols) {
					numPointsInPart = points
				}
				else {
					pstart          = parts[i]
					pend            = parts[i + 1]
					numPointsInPart = pend - pstart
				}

				// Store the first obs of part as missing
				st_store(obs, (1,2,3,4), (record_num, ., ., .))
				sobs = obs++

				// Store X Y & M obs in `BUFSIZE' block chunks
				bufsize = `BUFSIZE'
				numofbufs = floor(numPointsInPart/bufsize)

				for (j=1; j<=numofbufs; j++) {

					//skip back to after last point read
					fseek(fh_in, posf, -1)

					// store x & y values
					st_store((obs,obs+bufsize-1), (2,3),
						fbufget(C, fh_in, "%8z", bufsize, 2))
					posf = ftell(fh_in)

					if (measure) {
						// skip to m array
						skipm = (obs-obscounter-2)*8
						fseek(fh_in, posm, -1)
						fseek(fh_in, skipm, 0)

						// store m values
						st_store((obs,obs+bufsize-1), (4),
							fbufget(C, fh_in, "%8z", bufsize, 1))
					}
					else {
						// store . for all m values
						tmp = J(bufsize,1,0)
						for (i=1; i<=bufsize; i++) {
							tmp[i,1] = .
						}
						st_store((obs,obs+bufsize-1), (4), tmp)
					}

					obs = obs + bufsize
				}

				// Store the remainder of observations
				bufsize = numPointsInPart - numofbufs*bufsize
				if (bufsize) {
					//skip back to after last x,y point read
					fseek(fh_in, posf, -1)

					// store x & y values
					st_store((obs,obs+bufsize-1), (2,3),
						fbufget(C, fh_in, "%8z", bufsize, 2))
					posf = ftell(fh_in)

					if (measure) {
						// skip to m array
						skipm = (obs-obscounter-2)*8
						fseek(fh_in, posm, -1)
						fseek(fh_in, skipm, 0)

						// store m values
						st_store((obs,obs+bufsize-1), (4),
							fbufget(C, fh_in, "%8z", bufsize, 1))
					}
					else {
						// store . for all m values
						tmp = J(bufsize,1,0)
						for (i=1; i<=bufsize; i++) {
							tmp[i,1] = .
						}
						st_store((obs,obs+bufsize-1), (4), tmp)
					}

					obs = obs + bufsize
				}
				n = obs - sobs

				// Fill in record num for part
				st_store((sobs,obs-1), 1, J(n,1,record_num))
				points = points - (pend - pstart)
			}
		}
		else if (type == 11) {
			//pointZ
			// Get the id X Y Z M values
			st_addobs(1)
			st_store(obs, (1,2,3,4,5), (obs,fbufget(C, fh_in, "%8z", 1, 4)))
			obs = obs + 1
		}
		else if (type ==18) {
			//multipointZ
			// Get the number of points for the record
			fseek(fh_in, 32, 0)
			num_points = fbufget(C, fh_in, "%4b")

			// Determine if M values are specified
			if (numberofbytes == (40 + 16*num_points + 16 + 8*num_points + 16 + 8*num_points)) {
				measure = 1
			}
			else {
				measure = 0
			}

			// Add obs to dataset
			num_of_obs = num_points + 1
			st_addobs(num_of_obs)

			// Set pos for skips

			posi = ftell(fh_in)

			skip = 16*num_points+16
			fseek(fh_in, skip, 0)
			posz = ftell(fh_in)

			if (measure) {
				skip = 8*num_points+16
				fseek(fh_in, posz, -1)
				fseek(fh_in, skip, 0)
				posm = ftell(fh_in)
			}

			fseek(fh_in, posi, -1)
			posf = posi

			// Store the first obs of record as missing
			st_store(obs, (1,2,3,4,5), (record_num, ., ., ., .))
			sobs = obs++

			// Store X Y Z & M obs in `BUFSIZE' block chunks
			bufsize = `BUFSIZE'
			numofbufs = floor(num_points/bufsize)

			for (j=1; j<=numofbufs; j++) {
				//skip back to after last point read
				fseek(fh_in, posf, -1)

				// store x & y values
				st_store((obs,obs+bufsize-1), (2,3),
					fbufget(C, fh_in, "%8z", bufsize, 2))
				posf = ftell(fh_in)

				// skip to z array
				skipz = (obs-obscounter-2)*8
				fseek(fh_in, posz, -1)
				fseek(fh_in, skipz, 0)

				// store z values
				st_store((obs,obs+bufsize-1), (4),
				fbufget(C, fh_in, "%8z", bufsize, 1))

				if (measure) {
					// skip to m array
					skipm = (obs-obscounter-2)*8
					fseek(fh_in, posm, -1)
					fseek(fh_in, skipm, 0)

					// store m values
					st_store((obs,obs+bufsize-1), (5),
						fbufget(C, fh_in, "%8z", bufsize, 1))
				}
				else {
					// store . for all m values
					tmp = J(bufsize,1,0)
					for (i=1; i<=bufsize; i++) {
						tmp[i,1] = .
					}
					st_store((obs,obs+bufsize-1), (5), tmp)
				}

				obs = obs + bufsize
			}


			// Store the remainder of observations
			bufsize = num_points - numofbufs*bufsize

			if (bufsize) {
				//skip back to after last point read
				fseek(fh_in, posf, -1)

				// store x & y values
				st_store((obs,obs+bufsize-1), (2,3),
					fbufget(C, fh_in, "%8z", bufsize, 2))
				posf = ftell(fh_in)

				// skip to z array
				skipz = (obs-obscounter-2)*8
				fseek(fh_in, posz, -1)
				fseek(fh_in, skipz, 0)

				// store z values
				st_store((obs,obs+bufsize-1), (4),
				fbufget(C, fh_in, "%8z", bufsize, 1))

				if (measure) {
					// skip to m array
					skipm = (obs-obscounter-2)*8
					fseek(fh_in, posm, -1)
					fseek(fh_in, skipm, 0)

					// store m values
					st_store((obs,obs+bufsize-1), (5),
						fbufget(C, fh_in, "%8z", bufsize, 1))
				}
				else {
					// store . for all m values
					tmp = J(bufsize,1,0)
					for (i=1; i<=bufsize; i++) {
						tmp[i,1] = .
					}
					st_store((obs,obs+bufsize-1), (5), tmp)
				}

				obs = obs + bufsize
			}
			n = obs - sobs

			// Fill in record num for record
			st_store((sobs,obs-1), 1, J(n,1,record_num))
		}
		else if (type == 13 | type == 15) {
			//polylineZ and polygonZ
			// Get the number of parts and points for the record
			fseek(fh_in, 32, 0)
			num_parts  = fbufget(C, fh_in, "%4b")
			num_points = fbufget(C, fh_in, "%4b")

			// Determine if M values are specified
			if (numberofbytes == (44 + 4*num_parts + 16*num_points + 16 + 8*num_points + 16 + 8*num_points)) {
				measure = 1
			}
			else {
				measure = 0
			}

			// Create rowvector of parts array
			parts = fbufget(C, fh_in, "%4b", num_parts)

			// Get the number of obs and add to dataset
			num_of_obs = num_points + num_parts
			st_addobs(num_of_obs)

			// Set pos for skips
			posi = ftell(fh_in)

			skip = 16*num_points+16
			fseek(fh_in, skip, 0)
			posz = ftell(fh_in)

			if (measure) {
				skip = 8*num_points+16
				fseek(fh_in, posz, -1)
				fseek(fh_in, skip, 0)
				posm = ftell(fh_in)
			}

			fseek(fh_in, posi, -1)
			posf = posi

			// Loop of parts row vector
			cols = cols(parts)
			points = num_points

			for (i=1; i<=cols; i++) {
				if (i==cols) {
					numPointsInPart = points
				}
				else {
					pstart          = parts[i]
					pend            = parts[i + 1]
					numPointsInPart = pend - pstart
				}

				// Store the first obs of part as missing
				st_store(obs, (1,2,3,4,5), (record_num, ., ., ., .))
				sobs = obs++

				// Store X Y Z & M obs in `BUFSIZE' block chunks
				bufsize = `BUFSIZE'
				numofbufs = floor(numPointsInPart/bufsize)

				for (j=1; j<=numofbufs; j++) {

					//skip back to after last point read
					fseek(fh_in, posf, -1)

					// store x & y values
					st_store((obs,obs+bufsize-1), (2,3),
						fbufget(C, fh_in, "%8z", bufsize, 2))
					posf = ftell(fh_in)

					// skip to z array
					skipz = (obs-obscounter-2)*8
					fseek(fh_in, posz, -1)
					fseek(fh_in, skipz, 0)

					// store z values
					st_store((obs,obs+bufsize-1), (4),
						fbufget(C, fh_in, "%8z", bufsize, 1))

					if (measure) {
						// skip to m array
						skipm = (obs-obscounter-2)*8
						fseek(fh_in, posm, -1)
						fseek(fh_in, skipm, 0)

						// store m values
						st_store((obs,obs+bufsize-1), (5),
							fbufget(C, fh_in, "%8z", bufsize, 1))
					}
					else {
						// store . for all m values
						tmp = J(bufsize,1,0)
						for (i=1; i<=bufsize; i++) {
							tmp[i,1] = .
						}
						st_store((obs,obs+bufsize-1), (5), tmp)
					}

					obs = obs + bufsize
				}


				// Store the remainder of observations
				bufsize = numPointsInPart - numofbufs*bufsize
				if (bufsize) {

					//skip back to after last x,y point read
					fseek(fh_in, posf, -1)

					// store x & y values
					st_store((obs,obs+bufsize-1), (2,3),
						fbufget(C, fh_in, "%8z", bufsize, 2))
					posf = ftell(fh_in)

					// skip to z array
					skipz = (obs-obscounter-2)*8
					fseek(fh_in, posz, -1)
					fseek(fh_in, skipz, 0)

					// store z values
					st_store((obs,obs+bufsize-1), (4),
						fbufget(C, fh_in, "%8z", bufsize, 1))

					if (measure) {
						// skip to m array
						skipm = (obs-obscounter-2)*8
						fseek(fh_in, posm, -1)
						fseek(fh_in, skipm, 0)

						// store m values
						st_store((obs,obs+bufsize-1), (5),
							fbufget(C, fh_in, "%8z", bufsize, 1))
					}
					else {
						// store . for all m values
						tmp = J(bufsize,1,0)
						for (i=1; i<=bufsize; i++) {
							tmp[i,1] = .
						}
						st_store((obs,obs+bufsize-1), (5), tmp)
					}

					obs = obs + bufsize
				}
				n = obs - sobs

				// Fill in record num for part
				st_store((sobs,obs-1), 1, J(n,1,record_num))
				points = points - (pend - pstart)
			}
		}
		else if (type == 31) {
			//multipatch
			// Get the number of parts and points for the record
			fseek(fh_in, 32, 0)
			num_parts  = fbufget(C, fh_in, "%4b")
			num_points = fbufget(C, fh_in, "%4b")

			// Determine if M values are specified
			if (numberofbytes == (44 + 4*num_parts + 4*numparts + 16*num_points + 16 + 8*num_points + 16 + 8*num_points)) {
				measure = 1
			}
			else {
				measure = 0
			}

			// Create rowvector of parts array
			parts = fbufget(C, fh_in, "%4b", num_parts)
			part_type = fbufget(C, fh_in, "%4b", num_parts)

			// Get the number of obs and add to dataset
			num_of_obs = num_points + num_parts
			st_addobs(num_of_obs)

			// Set pos for skips
			posi = ftell(fh_in)

			skip = 16*num_points+16
			fseek(fh_in, skip, 0)
			posz = ftell(fh_in)

			if (measure) {
				skip = 8*num_points+16
				fseek(fh_in, posz, -1)
				fseek(fh_in, skip, 0)
				posm = ftell(fh_in)
			}

			fseek(fh_in, posi, -1)
			posf = posi

			// Loop of parts row vector
			cols = cols(parts)
			points = num_points

			for (i=1; i<=cols; i++) {
				if (i==cols) {
					numPointsInPart = points
				}
				else {
					pstart          = parts[i]
					pend            = parts[i + 1]
					numPointsInPart = pend - pstart
				}

				// Store the first obs of part as missing
				st_store(obs, (1,2,3,4,5,6), (record_num, ., ., ., ., .))
				sobs = obs++

				// Store X Y Z & M obs in `BUFSIZE' block chunks
				bufsize = `BUFSIZE'
				numofbufs = floor(numPointsInPart/bufsize)

				for (j=1; j<=numofbufs; j++) {

					//skip back to after last point read
					fseek(fh_in, posf, -1)

					// store x & y values
					st_store((obs,obs+bufsize-1), (2,3),
						fbufget(C, fh_in, "%8z", bufsize, 2))
					posf = ftell(fh_in)

					// skip to z array
					skipz = (obs-obscounter-2)*8
					fseek(fh_in, posz, -1)
					fseek(fh_in, skipz, 0)

					// store z values
					st_store((obs,obs+bufsize-1), (4),
						fbufget(C, fh_in, "%8z", bufsize, 1))

					if (measure) {
						// skip to m array
						skipm = (obs-obscounter-2)*8
						fseek(fh_in, posm, -1)
						fseek(fh_in, skipm, 0)

						// store m values
						st_store((obs,obs+bufsize-1), (5),
							fbufget(C, fh_in, "%8z", bufsize, 1))
					}
					else {
						// store . for all m values
						tmp = J(bufsize,1,0)
						for (i=1; i<=bufsize; i++) {
							tmp[i,1] = .
						}
						st_store((obs,obs+bufsize-1), (5), tmp)
					}

					obs = obs + bufsize
				}


				// Store the remainder of observations
				bufsize = numPointsInPart - numofbufs*bufsize
				if (bufsize) {

					//skip back to after last x,y point read
					fseek(fh_in, posf, -1)

					// store x & y values
					st_store((obs,obs+bufsize-1), (2,3),
						fbufget(C, fh_in, "%8z", bufsize, 2))
					posf = ftell(fh_in)

					// skip to z array
					skipz = (obs-obscounter-2)*8
					fseek(fh_in, posz, -1)
					fseek(fh_in, skipz, 0)

					// store z values
					st_store((obs,obs+bufsize-1), (4),
						fbufget(C, fh_in, "%8z", bufsize, 1))

					if (measure) {
						// skip to m array
						skipm = (obs-obscounter-2)*8
						fseek(fh_in, posm, -1)
						fseek(fh_in, skipm, 0)

						// store m values
						st_store((obs,obs+bufsize-1), (5),
							fbufget(C, fh_in, "%8z", bufsize, 1))
					}
					else {
						// store . for all m values
						tmp = J(bufsize,1,0)
						for (i=1; i<=bufsize; i++) {
							tmp[i,1] = .
						}
						st_store((obs,obs+bufsize-1), (5), tmp)
					}

					obs = obs + bufsize
				}
				n = obs - sobs

				// Fill in part type for part
				st_store((sobs,obs-1), 2, J(n,1,part_type[i]))

				// Fill in record num for part
				st_store((sobs,obs-1), 1, J(n,1,record_num))
				points = points - (pend - pstart)
			}
		}
		start_byte = start_byte + next_record
		obscounter = obs - 1
	}

	if (null_count) {
		printf("{text}%f null shapes skipped\n", null_count)
	}
	fclose(fh_in)
}


void read_dbf(string scalar dbf_file)
{

	real matrix   length_decimal
	real scalar   fh_in
	string scalar vname, vlength, format, rlength
	string scalar val
	transmorphic  colvector C

	real scalar   ver, year, num_of_records, num_bytes_header
	real scalar   num_bytes_record, field_des_bytes, num_of_vars
	real scalar   next_var, next_type, next_length, vars_types
	real scalar   k, i, j, type, vlen, bufsize, numofbufs, obs, lines
	real scalar   start_str, num_vlength


	// Open dBASE file .dbf, open buffer, and set byte order
	fh_in = fopen(dbf_file, "r")
	C = bufio()
	bufbyteorder(C, 1)

	// Get .dbase version
	ver = fbufget(C, fh_in, "%1b")
	bufbyteorder(C, 2)

	// Get year of file
	year = fbufget(C, fh_in, "%1bu") + 1900

	if (ver!=3| year<1900 | year>2050) {
		errprintf("%s: invalid dbase (.dbf) file\n", dbf_file)
		exit(610)
	}

	// Number of records in the table
	fseek(fh_in, 4, -1)
	num_of_records = fbufget(C, fh_in, "%4bu")

	// Number of bytes in the header.
	num_bytes_header = fbufget(C, fh_in, "%2bu")

	// Number of bytes in the record
	num_bytes_record = fbufget(C, fh_in, "%2bu")

	// Starting value of descriptor bytes and number of vars
	field_des_bytes = num_bytes_header - 33
	num_of_vars = field_des_bytes/32

	// Set starting byte postion for fields of descriptor bytes
	next_var = 32
	next_type = 43
	next_length = 48

	// Create matrix for var names and types
	vars_types = J(num_of_vars,2,"")

	// Create matrix for var length
	length_decimal = J(num_of_vars,1,.)

	//Loop over each descriptor
	for (i=1; field_des_bytes!=0; i++) {
		// Get var name
		fseek(fh_in, next_var, -1)
		vars_types[i,1] = fbufget(C, fh_in, "%11s")

		// Get var type
		fseek(fh_in, next_type, -1)
		vars_types[i,2] = fbufget(C, fh_in, "%5s")

		// Get var length
		fseek(fh_in, next_length, -1)
		length_decimal[i,1] = fbufget(C, fh_in, "%1bu")

		next_var    = next_var + 32
		next_type   = next_type + 32
		next_length = next_length + 32

		field_des_bytes = field_des_bytes - 32
	}

	// Create dataset
	st_addobs(num_of_records)

	// Create variables
	for(i=1; i<=num_of_vars; i++ ) {
		vname   = strtoname(strtrim(vars_types[i,1]))
		type    = vars_types[i,2]
		vlength = strofreal(length_decimal[i,1])
		format  = "str" + vlength
		num_vlength = strtoreal(vlength)

		if (num_vlength > st_numscalar("c(maxstrvarlen)")) {
			printf("{text}variable {cmd:%s} truncated\n", vname)
			format = "str" + "244"
		}
		if (type == "C") {
			if (rc = _st_addvar(format, vname)<0) {
				vname = dbf_get_varname()
				(void) st_addvar(format, vname)
			}
		}
		else if (type == "L") {
			if (rc = _st_addvar("format", vname)<0) {
				vname = dbf_get_varname()
				(void) st_addvar(format, vname)
			}
		}
		else if (type == "N") {
			if (rc = _st_addvar("double", vname)<0) {
				vname = dbf_get_varname()
				(void) st_addvar("double", vname)
			}
		}
		else if (type == "F") {
			if (rc = _st_addvar("float", vname)<0) {
				vname = dbf_get_varname()
				(void) st_addvar("float", vname)
			}
		}
		else if (type == "D") {
			if (rc = _st_addvar("long", vname)<0) {
				vname = dbf_get_varname()
				(void) st_addvar("long", vname)
			}
		}
		else  {
			errprintf("{cmd:%s}: invalid dBASE data type\n", dbf_file)
			exit(610)
		}
		(void) st_varlabel(vname, vars_types[i,1])
	}

	// Go to start of obserations
	fseek(fh_in, num_bytes_header, -1)

	// Read observations in 200 block chunks
	bufsize = 200
	numofbufs = floor(num_of_records/bufsize)

	obs = 1
	for (k=1; k<=numofbufs; k++) {
		rlength = strofreal(num_bytes_record)
		format = "%" + rlength + "s"
		lines = fbufget(C, fh_in, format, bufsize, 1)

		for(i=1; i<=bufsize; i++) {
			start_str = 2
			for(j=1; j<=num_of_vars; j++) {
				type    = vars_types[j,2]
				vlen    = length_decimal[j,1]
				val     = strtrim(substr(lines[i,1],
						start_str, vlen))

				if (type=="C" | type=="L") {
					st_sstore(obs,j,val)
				}
				else	st_store(obs,j, strtoreal(val))
				start_str = start_str + vlen
			}
			obs++
		}
	}

	// Store the remander of observations
	bufsize = num_of_records - numofbufs*bufsize
	if (bufsize) {
		rlength = strofreal(num_bytes_record)
		format = "%" + rlength + "s"
		lines = fbufget(C, fh_in, format, bufsize, 1)
		for(i=1; i<=bufsize; i++) {
			start_str = 2
			for(j=1; j<=num_of_vars; j++) {
				type = vars_types[j,2]
				vlen = length_decimal[j,1]
				val  = strtrim(substr(lines[i,1],
						start_str, vlen))

				if (type == "C" | type == "L") {
					st_sstore(obs,j,val)
				}
				else {
					st_store(obs,j, strtoreal(val))
				}
				start_str = start_str + vlen
			}
			obs++
		}
	}

	fclose(fh_in)
}

string scalar dbf_get_varname()
{
	real scalar rc, i
	string scalar varname

	for(i=1; i<st_numscalar("c(max_k_theory)"); i++) {
		varname = "var" + strofreal(i)
		rc = _stata(sprintf("quietly confirm new variable %s", varname), 1)
		if (rc==0) {
			return(varname)
		}
	}
	return("___x111")
}

end
