using CairoMakie
using CairoMakie.GeometryBasics: HyperRectangle
using ColorSchemes: Paired_8, Blues_9, Oranges_9
using MAT
using DataFrames
using ReadStatTables
using TypedTables
using FilePathsBase
using FilePathsBase: /

const iciodir = p"data/work/ICIO"
const modeldir = p"data/work/model"
const elasdir = p"data/work/elas"
const fig = p"fig2412"

const halfwidth = 3.5
set_theme!()
update_theme!(Axis=(rightspinevisible=false, topspinevisible=false, spinewidth=0.7, xgridvisible=false, titlefont="Helvetica", titlegap=5, xtickwidth=0.7, titlesize=12, ytickwidth=0.7, xticksize=3, yticksize=3), font="Helvetica", fontsize=10, figure_padding=5, Legend=(patchsize = (20,10), padding=4, titlefont="Helvetica", framewidth=0.7))

const eu15 = ["AUT", "BEL", "DNK", "FIN", "FRA", "DEU", "GRC", "IRL", "ITA", "LUX", "NLD",
    "PRT", "ESP", "SWE", "GBR"]

function plotvars(dfisd, dfid, dfw, paraisd, eutau, htau, S, N, H, is, ss, ds, tag, regs;
        fillzero=0)
    # Hfull is horizons available in dfisd
    # H is for plotting
    Hfull = maximum(dfisd.horz)
    H > Hfull && throw(ArgumentError("H is too large"))
    mλ0 = reshape(paraisd.inshare, S, N, N)
    λ = reshape(dfisd.lambda, S, N, N, Hfull)
    υagg = reshape(dfisd.upsilonagg, S, N, N, Hfull)
    dλ = zeros(H, length(is))
    dυagg = similar(dλ)
    for (k, (i, s, d)) in enumerate(zip(is, ss, ds))
        λ0 = mλ0[i,s,d]
        for h in 1:H-fillzero
            dλ[h+fillzero,k] = 100 * (log(λ[i,s,d,h]) - log(λ0))
            dυagg[h+fillzero,k] = 100 * (log(υagg[i,s,d,h]) - log(λ0))
        end
    end

    f1 = Figure(; size=72 .* (1.1*halfwidth, 3.5))
    ax1 = Axis(f1[1, 1], xlabel="Year", ylabel="100 ✕ Log Difference from Initial Level (%)",
        title="Change in Shares of Varieities Imported\nSelected Bilateral Relations between NMS and EU15")
    x = 1995:1995+H-1
    ax1.xticks = 1995:5:1995+H-1
    for (k, y) in enumerate(eachcol(dυagg))
        lines!(ax1, x, y)
    end
    vlines!(ax1, 2004, color=:red, linewidth=0.5)
    save(string(fig/"eu_upsilon_$tag.pdf"), f1, pt_per_unit=1)

    f1 = Figure(; size=72 .* (1.1*halfwidth, 3.5))
    ax1 = Axis(f1[1, 1], xlabel="Year", ylabel="100 ✕ Log Difference from Initial Level (%)",
        title="Change in Import Shares\nSelected Bilateral Relations between NMS and EU15")
    x = 1995:1995+H-1
    ax1.xticks = 1995:5:1995+H-1
    for (k, y) in enumerate(eachcol(dλ))
        lines!(ax1, x, y)
    end
    vlines!(ax1, 2004, color=:red, linewidth=0.5)
    save(string(fig/"eu_lambda_$tag.pdf"), f1, pt_per_unit=1)

    f1 = Figure(; size=72 .* (2*halfwidth, 3.5))
    ax1 = Axis(f1[1, 1], xlabel="Year", ylabel="100 ✕ Log Difference from Initial Level (%)",
        title="Change in Shares of Varieities Imported")
    x = 1995:1995+H-1
    ax1.xticks = 1995:5:1995+H-1
    for (k, y) in enumerate(eachcol(dυagg))
        lines!(ax1, x, y)
    end
    vlines!(ax1, 2004, color=:red, linewidth=0.5)
    ax2 = Axis(f1[1, 2], xlabel="Year",
        title="Change in Import Shares")
    ax2.xticks = 1995:5:1995+H-1
    for (k, y) in enumerate(eachcol(dλ))
        lines!(ax2, x, y)
    end
    vlines!(ax2, 2004, color=:red, linewidth=0.5)
    linkyaxes!(ax1, ax2)
    hideydecorations!(ax2, grid = false)
    hidespines!(ax2, :l)
    save(string(fig/"eu_upsilon_lambda_$tag.pdf"), f1, pt_per_unit=1)

    wp = reshape(dfw.wp, Hfull, N)
    dw = zeros(H, length(ss))
    for (k, s) in enumerate(ss)
        for h in 1:H-fillzero
            dw[h+fillzero,k] = 100 * wp[h,s]
        end
    end

    flex = reshape(dfw.flex, Hfull, N)
    dist = reshape(dfw.dist, Hfull, N)
    dflex = zeros(H)
    ddist = zeros(H)
    iHUN = 32
    for h in 1:H-fillzero
        dflex[h+fillzero] = 100 * flex[h, iHUN]
        ddist[h+fillzero] = 100 * dist[h, iHUN]
    end

    f2 = Figure(; size=72 .* (1.1*halfwidth, 3.5))
    ax1 = Axis(f2[1, 1], xlabel="Year", ylabel="100 ✕ Log Difference from Initial Level (%)",)
        #title="Welfare Impact on NMS Countries")
    x = 1995:1995+H-1
    ax1.xticks = 1995:5:1995+H-1
    for (k, y) in enumerate(eachcol(dw))
        lines!(ax1, x, y)
    end
    vlines!(ax1, 2004, color=:red, linewidth=0.5)
    save(string(fig/"eu_wp_$tag.pdf"), f2, pt_per_unit=1)

    f3 = Figure(; size=72 .* (1.1*halfwidth, 3.5))
    ax2 = Axis(f3[1, 1], xlabel="Year", title="ACR-Style Formula\nHungary")
    ax2.xticks = 1995:5:1995+H-1
    lines!(ax2, x, 100 * dflex)
    lines!(ax2, x, 100 * ddist, linestyle=:dash)
    vlines!(ax2, 2004, color=:red, linewidth=0.5)
    save(string(fig/"eu_welfare_$tag.pdf"), f3, pt_per_unit=1)

    return f1, f2, f3
end


function main()
    elas = matread(string(elasdir/"gmmelasbase.mat"))

    H = 21
    sectag = "i32"
    S, N = 32, 79
    parajd = readstat(iciodir/"parajd_$(sectag).dta")
    regs = parajd.dest_iso3[1:S:end]
    dreg = Dict(regs.=>1:length(regs))
    secs = DataFrame(readstat(iciodir/"sectorlist.dta"))
    secs[!,:i32short] = LabeledArray(disallowmissing(unwrap.(secs[!,:i32short])),
        getvaluelabels(secs[!,:i32short]))
    fsuf = "_1995"
    paraisd = readstat(iciodir/"paraisd_$(sectag)$(fsuf).dta")

    eutau = DataFrame(readstat(iciodir/"eutariff.dta"))
    disallowmissing!(eutau)
    oneshock = true
    oneshock && (eutau = eutau[eutau.year.==2004,:])
    NMS = unique(eutau.sorc_iso3)
    iNMS = [dreg[n] for n in NMS]
    iEU = [dreg[n] for n in eu15]

    topnms = matread(string(iciodir/"nmstoptrade1.mat"))
    isel = (1:10).!=9
    itopnms = topnms["sorc_i32"][isel]
    stopnms = [dreg[n] for n in topnms["sorc_iso3"][isel]]
    dtopnms = [dreg[n] for n in topnms["dest_iso3"][isel]]

    dfisd = DataFrame(readstat(modeldir/"euenlarge_isd_base.dta"))
    dfid = DataFrame(readstat(modeldir/"euenlarge_id_base.dta"))
    dfw = DataFrame(readstat(modeldir/"euenlarge_welfare_base.dta"))
    plotvars(dfisd, dfid, dfw, paraisd, eutau, 10, S, N, H, itopnms, stopnms, dtopnms, "base", regs)

    y0 = 2002
    dfisd = DataFrame(readstat(modeldir/"euenlarge_isd_y0_$y0.dta"))
    dfid = DataFrame(readstat(modeldir/"euenlarge_id_y0_$y0.dta"))
    dfw = DataFrame(readstat(modeldir/"euenlarge_welfare_y0_$y0.dta"))
    plotvars(dfisd, dfid, dfw, paraisd, eutau, 10, S, N, H, itopnms, stopnms, dtopnms, "y0_$y0", regs, fillzero=9)
end

@time main()
