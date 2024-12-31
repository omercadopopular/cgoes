*! version 1.0.5  02jun2010
program grc1leg

	syntax [anything] [, LEGendfrom(string)				///
			     POSition(string) RING(integer -1) SPAN	///
			     NAME(passthru) SAVing(string asis) * ]

	gr_setscheme , refscheme	// So we can have temporary styles

					// location and alignment in cell
	tempname clockpos
	if ("`position'" == "") local position 6
	.`clockpos' = .clockdir.new , style(`position')
	local location `.`clockpos'.relative_position'

	if `ring' > -1 {
		if (`ring' == 0) {
			local location "on"
			local ring ""
		}
		else	local ring "ring(`ring')"
	}
	else	local ring ""

	if "`span'" != "" {
		if "`location'" == "above" | "`location'" == "below" {
			local span spancols(all)
		}
		else	local span spanrows(all)
	}

					// allow legend to be from any graph
	if "`legendfrom'" != "" {			
		local lfrom : list posof "`legendfrom'" in anything
		if `lfrom' == 0 {
		    di as error `"`legend_from' not found in graph name list"'
		    exit 198
		}
	}
	else	local lfrom 1		// use graph 1 for legend by default


	graph combine `anything' , `options' `name' nodraw   // combine graphs


	if "`name'" != "" {				// get graph name
		local 0 `", `name'"'
		syntax [, name(string) ]
		local 0 `"`name'"'
		syntax [anything(name=name)] [, replace]
	}
	else	local name Graph

	forvalues i = 1/`:list sizeof anything' {	// turn off legends
		_gm_edit .`name'.graphs[`i'].legend.draw_view.set_false
		_gm_edit .`name'.graphs[`i'].legend.fill_if_undrawn.set_false
	}


							// insert overall legend
	.`name'.insert (legend = .`name'.graphs[`lfrom'].legend)	    ///
			`location' plotregion1 , `ring' `span'
	_gm_log  .`name'.insert (legend = .graphs[`lfrom'].legend) 	    ///
			`location' plotregion1 , `ring' `span'

	_gm_edit .`name'.legend.style.box_alignment.setstyle ,		    ///
		style(`.`clockpos'.compass2style')
	_gm_edit .`name'.legend.draw_view.set_true

			// hack to maintain serset reference counts
			// must pick up sersets by reference, they were 
			// -.copy-ied when the legend was created above
	forvalues i = 1/`.`name'.legend.keys.arrnels' {
	    if "`.`name'.legend.keys[`i'].view.serset.isa'" != "" {
		_gm_edit .`name'.legend.keys[`i'].view.serset.ref_n + 99

		.`name'.legend.keys[`i'].view.serset.ref = 		   ///
		    .`name'.graphs[`lfrom'].legend.keys[`i'].view.serset.ref
		_gm_log  .`name'.legend.keys[`i'].view.serset.ref = 	   ///
		    .graphs[`lfrom'].legend.keys[`i'].view.serset.ref
	    }
	    if "`.`name'.legend.plotregion1.key[`i'].view.serset.isa'" != "" {
		_gm_edit						   ///
		    .`name'.legend.plotregion1.key[`i'].view.serset.ref_n + 99

		.`name'.legend.plotregion1.key[`i'].view.serset.ref =  ///
		    .`name'.graphs[`lfrom'].legend.keys[`i'].view.serset.ref
		_gm_log							   ///
		    .`name'.legend.plotregion1.key[`i'].view.serset.ref =  ///
		    .graphs[`lfrom'].legend.keys[`i'].view.serset.ref
	    }
	}

	gr draw `name'					// redraw graph

	if `"`saving'"' != `""' {
		gr_save `"`name'"' `saving'
	}


end


program GetPos
	gettoken pmac  0 : 0
	gettoken colon 0 : 0

	local 0 `0'
	if `"`0'"' == `""' {
		c_local `pmac' below
		exit
	}

	local 0 ", `0'"
	syntax [ , Above Below Leftof Rightof ]

	c_local `pmac' `above' `below' `leftof' `rightof'
end
