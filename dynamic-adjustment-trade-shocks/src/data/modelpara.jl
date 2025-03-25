"""
Construct parameter values for model
"""

using DataFrames
using ReadStatTables

const iciodir = "data/work/ICIO/"

function inputshare(icio, seclist, sectag::Symbol, idrop::Union{Int,Nothing}=nothing)
    # No data of inputs for CHN and MEX
    # e.g., sum(icio[(icio.sorc_iso3.=="CHN").&(icio.dest_ind.<46),:value]) is 0
    # and sum(icio[(icio.dest_iso3.=="CHN").&(icio.dest_ind.<46),:value]) is 0
    # Do not drop TLS (important for not making muse too large)
    mfull = icio[(.~((icio.sorc_iso3.∈(("CHN","MEX"),)).|
        (icio.dest_iso3.∈(("CHN","MEX"),)))).&(icio.dest_ind.<46), :]
    # Faster to combine once before merging sectors
    mijd = combine(groupby(mfull, [:sorc_ind, :dest_ind, :dest_iso3]), :value=>sum, renamecols=false)
    seclist = seclist[:,[:code,sectag]]
    leftjoin!(mijd, seclist, on=:sorc_ind=>:code)
    sorctag = Symbol(:sorc_, sectag)
    rename!(mijd, sectag=>sorctag)
    leftjoin!(mijd, seclist, on=:dest_ind=>:code)
    desttag = Symbol(:dest_, sectag)
    rename!(mijd, sectag=>desttag)
    if idrop !== nothing
        mijd = mijd[.~((mijd[!,sorctag].==idrop).|(mijd[!,desttag].==idrop)), :]
    end
    mijd = combine(groupby(mijd, [sorctag, desttag, :dest_iso3]), :value=>sum, renamecols=false)
    transform!(groupby(mijd, [desttag, :dest_iso3]), :value=>sum=>:output)
    rename!(mijd, :value=>:input)
    mijd[!,:inputshare] = ifelse.(mijd.output.>0, mijd.input ./ mijd.output, 0.0)
    return mijd
end

function tradeshare(icio, seclist, sectag::Symbol, idrop::Union{Int,Nothing}=nothing)
    # Keep all final use
    xfull = icio[(icio.sorc_ind.<46), :]
    # Only need CN1/MX1 and CN2/MX2
    # All final use to CHN/MEX are for CN1/MX1
    xfull[(xfull.dest_ind.>45).&(xfull.dest_iso3.=="CHN"),:dest_iso3] .= "CN1"
    xfull[(xfull.dest_ind.>45).&(xfull.dest_iso3.=="MEX"),:dest_iso3] .= "MX1"
    # Number of rows is 45*79*45*79+45*79*77*6
    # The dropped rows all have value being 0
    xfull = xfull[.~((xfull.sorc_iso3.∈(("CHN","MEX"),)).|
        (xfull.dest_iso3.∈(("CHN","MEX"),))), :]
    seclist = seclist[:,[:code,sectag]]
    # Aggregation excludes any dest_ind that will be dropped
    if idrop !== nothing
        leftjoin!(xfull, seclist, on=:dest_ind=>:code)
        desttag = Symbol(:dest_, sectag)
        rename!(xfull, sectag=>desttag)
        xfull = xfull[xfull[!,desttag].!=idrop, :]
    end
    xisd = combine(groupby(xfull, [:sorc_ind, :sorc_iso3, :dest_iso3]), :value=>sum, renamecols=false)
    leftjoin!(xisd, seclist, on=:sorc_ind=>:code)
    sorctag = Symbol(:sorc_, sectag)
    rename!(xisd, sectag=>sorctag)
    if idrop !== nothing
        xisd = xisd[.~((xisd[!,sorctag].==idrop)), :]
    end
    xisd = combine(groupby(xisd, [sorctag, :sorc_iso3, :dest_iso3]), :value=>sum, renamecols=false)
    transform!(groupby(xisd, [sorctag, :dest_iso3]), :value=>sum=>:in_id)
    transform!(groupby(xisd, [sorctag, :sorc_iso3]), :value=>sum=>:out_is)
    # inshare is for trade share in model
    xisd[!,:inshare] = ifelse.(xisd.in_id.>0, xisd.value ./ xisd.in_id, 0.0)
    # outshare can be used to get user expenditure from output
    # outshare is not used when targeting the trade flows instead of value added
    xisd[!,:outshare] = ifelse.(xisd.out_is.>0, xisd.value ./ xisd.out_is, 0.0)
    return xisd
end

function exptooutput(x, m, sectag)
    sorctag = Symbol(:sorc_, sectag)
    desttag = Symbol(:dest_, sectag)
    # Get output implied by trade flows
    xy = combine(groupby(x, [sorctag, :sorc_iso3]), :out_is=>first, renamecols=false)
    rename!(xy, sorctag=>desttag, :sorc_iso3=>:dest_iso3)
    xy = rightjoin(xy, m, on=[desttag, :dest_iso3])
    xy.input .= ifelse.(xy.output.>0, xy.input.*xy.out_is./xy.output, 0.0)
    select!(xy, sorctag, desttag, :dest_iso3, :input, :out_is=>:output, :inputshare)
    e = combine(groupby(x, [sorctag, :dest_iso3]), :in_id=>first=>:exp)
    return xy, e
end

function intermediateuse(xy, imsecs, sectag)
    sorctag = Symbol(:sorc_, sectag)
    muse = xy[xy[!,sorctag].∈(imsecs,), :]
    muse = combine(groupby(muse, [sorctag, :dest_iso3]), :input=>sum=>:muse)
    return muse
end

function getincome(icio, e, imsecs, sectag, fusetax=true)
    desttag = Symbol(:dest_, sectag)
    if fusetax
        # Construct ratios for tax on final use across all goods
        # The magnitude of tax does not seem to be important?
        # The tax payment does serve as numeraire for prices
        # Do not drop any sorc industry
        fu = icio[icio.dest_ind.>45,:]
        fu[fu.dest_iso3.=="CHN",:dest_iso3] .= "CN1"
        fu[fu.dest_iso3.=="MEX",:dest_iso3] .= "MX1"
        # Verified that for VA sum(fu[fu.sorc_ind.==47,:value]) is 0
        fu[!,:istax] = fu.sorc_ind.==46
        tot = combine(groupby(fu, :dest_iso3), :value=>sum=>:fallexp_d)
        tax = combine(groupby(fu[.~fu.istax,:], :dest_iso3), :value=>sum=>:fallpretax)
        leftjoin!(tot, tax, on=:dest_iso3)
        tot[!,:fexpmul] = ifelse.(tot.fallpretax.>0,
            tot.fallexp_d ./ tot.fallpretax, 0.0)
        # Placeholders for CN2/MX2
        append!(tot, (dest_iso3=["CN2","MX2"], fallexp_d=zeros(2), fallpretax=zeros(2),
            fexpmul=ones(2)))
        transform!(groupby(e, :dest_iso3), :va=>sum=>:va_d, :fuse=>sum=>:fuse_d)
        leftjoin!(e, tot, on=:dest_iso3)
        e[!,:income] = e.fuse_d .* e.fexpmul
    else
        transform!(groupby(e, :dest_iso3), :va=>sum=>:va_d, :fuse=>sum=>:income)
    end

    # Expenditure in CN2/MX2 does not match intermediate purchases exactly
    # because the final use for trade shares is not exactly consistent with production
    # For CN2/MX2, let fuse entirely come from deficit and can take either sign
    e[!,:fuseinincome] = ifelse.(e.income.!=0, e.fuse ./ e.income, 0.0)
    # Absorb VA by CN2/MX2 in CN1/MX1 for computing country-level total VA
    for d in ("CN", "MX")
        id1 = e.dest_iso3.==string(d, 1)
        id2 = e.dest_iso3.==string(d, 2)
        for i in imsecs
            isec = e[!,desttag].==i
            irow1 = findfirst(isec.&id1)
            irow2 = findfirst(isec.&id2)
            e[irow1, :va_d] += e[irow2, :va_d]
            e[irow2, :va_d] = 0.0
        end
    end
    e[!,:deficit] = e.income .- e.va_d
    return e
end

function targettradeflows(icio, seclist, sectag::Symbol, imsecs, idrop)
    sorctag = Symbol(:sorc_, sectag)
    desttag = Symbol(:dest_, sectag)
    iva = refarray(seclist[!,sectag])[findfirst(valuelabels(seclist[!,Symbol(sectag, :code)]).=="VA")]
    itls = refarray(seclist[!,sectag])[findfirst(valuelabels(seclist[!,Symbol(sectag, :code)]).=="TLS")]
    m = inputshare(icio, seclist, sectag, idrop)
    x = tradeshare(icio, seclist, sectag, idrop)
    # Get the levels of sectoral bilateral trade flows exactly as in data
    # All other quantities are derived based on targeted ratios and identities
    xy, e = exptooutput(x, m, sectag)
    # Combine VA and TLS to ensure intermediate and VA shares sum to one
    y = xy[xy[!,sorctag].∈((iva, itls),), [desttag, :dest_iso3, :input, :output]]
    y = combine(groupby(y, [desttag, :dest_iso3]),
        :input=>sum=>:va, :output=>first=>:output)
    y[!,:vainoutput] = ifelse.(y.output.>0, y.va ./ y.output, 0.0)
    muse = intermediateuse(xy, imsecs, sectag)
    # exp always stands for expenditure/total use
    # Levels of trade flows are directly targeted and hence expenditure
    rename!(e, sorctag=>desttag)
    leftjoin!(e, y, on=[desttag, :dest_iso3])
    leftjoin!(e, muse, on=[desttag=>sorctag, :dest_iso3])
    disallowmissing!(y) # No missing actually present
    # muse in CN2/MX2 is absorbed in CN1/MX1
    e[!,:fuse] = e.exp .- e.muse
    e = getincome(icio, e, imsecs, sectag)

    # Check no NaN e[any.(isnan, eachrow(e[!,3:end])), :]
    # Check negative values e[any.(<(0), eachrow(e[!,3:end-1])), :]
    ipos = .~(e.dest_iso3.∈(("CN2","MX2"),))
    Nissue = nrow(e[any.(isnan, eachrow(e[!,3:end])), :]) +
        nrow(e[(any.(<(0), eachrow(e[!,3:end-1]))).&ipos, :])
    Nissue > 0 && @warn "Certain rows contain abnormal values"
    sort!(e, [:dest_iso3, desttag])
    xy = xy[xy[!,sorctag].∈(imsecs,), Not(:output)]
    sort!(xy, [:dest_iso3, desttag, sorctag])
    sort!(x, [:dest_iso3, :sorc_iso3, sorctag])

    eout = ReadStatTable(e, ".dta")
    colmetadata!(eout, desttag, :display_width, 55)
    writestat(iciodir*"parajd_$(sectag).dta", eout)
    xyout = ReadStatTable(xy, ".dta")
    colmetadata!(xyout, sorctag, :display_width, 55)
    colmetadata!(xyout, desttag, :display_width, 55)
    writestat(iciodir*"paraijd_$(sectag).dta", xyout)
    xout = ReadStatTable(x, ".dta")
    colmetadata!(xout, sorctag, :display_width, 55)
    writestat(iciodir*"paraisd_$(sectag).dta", xout)
    return e, xy, x
end

function main()
    icio = DataFrame(readstat(iciodir*"2017.dta"))
    # Drop the useless output rows
    icio = icio[icio.sorc_ind.!=48,:]
    # Two flows that are supposed to be positive are negative:
    # icio[(icio.value.<0).&(icio.sorc_ind.!=46).&(icio.dest_ind.!=53),:]
    # VA for C21 in ISL and VA for H51 in CYP
    # Manually fix the negative vlaues to avoid negative value added share
    # sum(e[(e.dest_iso3.=="ISL").&(e.dest_i32.!=9),:vainoutput])/31 ≈ 0.4582
    icio[(icio.sorc_ind.==47).&(icio.sorc_iso3.=="ISL").&(icio.dest_ind.==12).&
        (icio.dest_iso3.=="ISL"), :value] .=
        sum(icio[(icio.sorc_ind.<46).&(icio.dest_ind.==12).&
            (icio.dest_iso3.=="ISL"), :value]) * 0.46 / (1-0.46)
    # sum(e[(e.dest_iso3.=="CYP").&(e.dest_i32.!=23),:vainoutput])/31 ≈ 0.45
    icio[(icio.sorc_ind.==47).&(icio.sorc_iso3.=="CYP").&(icio.dest_ind.==29).&
        (icio.dest_iso3.=="CYP"), :value] .=
        sum(icio[(icio.sorc_ind.<46).&(icio.dest_ind.==29).&
            (icio.dest_iso3.=="CYP"), :value]) * 0.45 / (1-0.45)

    seclist = DataFrame(readstat(iciodir*"sectorlist.dta"))
    for v in (:code, :i32, :i34)
        seclist[!,v] = LabeledArray(disallowmissing(unwrap.(seclist[!,v])),
            getvaluelabels(seclist[!,v]))
    end

    e, xy, x = targettradeflows(icio, seclist, :i32, 1:32, 33)
    e34, xy34, x34 = targettradeflows(icio, seclist, :i34, 1:34, nothing)

    return e, xy, x
end

@time e, xy, x = main()

