using CairoMakie
using CairoMakie.GeometryBasics: HyperRectangle
using ColorSchemes: Paired_8, Blues_9, Oranges_9
using MAT
using DataFrames
using ReadStatTables
using StatsFuns: norminvccdf
using FilePathsBase
using FilePathsBase: /

const iciodir = p"data/work/ICIO"
const modeldir = p"data/work/model"
const elasdir = p"data/work/elas"
const fig = p"fig"

const halfwidth = 3.5
set_theme!()
update_theme!(Axis=(rightspinevisible=false, topspinevisible=false, spinewidth=0.7, xgridvisible=false, titlefont="Helvetica", titlegap=5, xtickwidth=0.7, titlesize=12, ytickwidth=0.7, xticksize=3, yticksize=3), font="Helvetica", fontsize=10, figure_padding=5, Legend=(patchsize = (20,10), padding=4, titlefont="Helvetica", framewidth=0.7))

function plotelas(est, fit, se, fname; level=0.95)
    f1 = Figure(; size=72 .* (1.2*halfwidth, 3.5))
    ax1 = Axis(f1[1, 1], xlabel="Year", ylabel="Tariff-Inclusive Trade Elasticity")
    H = length(est)
    x = 0:H-1
    ax1.xticks = 0:2:H-1
    col1, col2 = Paired_8[8], Paired_8[2]
    lw1, lw2 = 2, 1.5
    l1 = lines!(ax1, x, fit, color=col1, linewidth=lw1)
    # l2 = lines!(ax1, x, est, color=col2, linestyle=:dash, linewidth=lw2)
    l2 = scatter!(ax1, x, est, color=col2)
    cv = norminvccdf((1 - level) / 2)
    lb = est .- cv .* se
    ub = est .+ cv .* se
    rangebars!(ax1, x, lb, ub, color=col2, linewidth=lw2)
    # Have to manually create the patches for now
    # See https://github.com/MakieOrg/Makie.jl/issues/3444
    ls = [LineElement(color=col1, linewidth=lw1),
        [LineElement(color=col2, linewidth=lw2), l2]]
    Legend(f1[2,1], ls, ["Model", "Data"], tellheight=true, tellwidth=false,
        orientation=:horizontal, padding=(5,5,5,5), nbanks=1)
    colgap!(f1.layout, Relative(0.02))
    rowgap!(f1.layout, Relative(0.03))
    save(string(fig/"$fname.pdf"), f1, pt_per_unit=1)
    return f1
end

function plotdid(dres, tag, lrange, fname; iest=:)
    f1 = Figure(; size=72 .* (1.2*halfwidth, 3.5))
    ax1 = Axis(f1[1, 1], xlabel="Year", ylabel="Tariff-Exclusive Trade Elasticity")
    b = dres["b_"*tag][iest]
    lb = dres["lb_"*tag][iest]
    ub = dres["ub_"*tag][iest]
    lmin, lmax = lrange
    H = length(b)+1
    x = lmin:lmax
    ax1.xticks = lmin:lmax
    col1, col2 = Paired_8[8], Paired_8[2]
    lw1, lw2 = 2, 2
    rangebars!(ax1, x, lb, ub, color=col2)
    scatterlines!(ax1, x, b, color=col2)
    colgap!(f1.layout, Relative(0.02))
    rowgap!(f1.layout, Relative(0.03))
    save(string(fig/"$fname.pdf"), f1, pt_per_unit=1)
    return f1
end

function plottrade(mge, mpe, xge, xpe, H, fname)
    f1 = Figure(; size=72 .* (2*halfwidth, 3.5))
    ax1 = Axis(f1[1, 1], xlabel="Year", ylabel="Tariff-Inclusive Trade Flow\n100 ✕ Log Difference from Initial Level (%)",
        title="US Imports from China")
    x = 0:H-1
    ax1.xticks = 0:2:H-1
    col1, col2 = Paired_8[8], Paired_8[2]
    lw1, lw2 = 2, 2
    l1 = lines!(ax1, x, 100*view(mge,1:H,1), color=col1, linewidth=lw1)
    l2 = lines!(ax1, x, 100*view(mge,1:H,2), color=:black, linestyle=:dashdot)
    l3 = lines!(ax1, x, 100*view(mge,1:H,3), color=:black, linestyle=:dot)
    l4 = lines!(ax1, x, 100*view(mpe,1:H), color=col2, linestyle=:dash, linewidth=lw2)
    ax2 = Axis(f1[1, 2], xlabel="Year", title="China Imports from US")
    ax2.xticks = 0:2:H-1
    l1 = lines!(ax2, x, 100*view(xge,1:H,1), color=col1, linewidth=lw1)
    l2 = lines!(ax2, x, 100*view(xge,1:H,2), color=:black, linestyle=:dashdot)
    l3 = lines!(ax2, x, 100*view(xge,1:H,3), color=:black, linestyle=:dot)
    l4 = lines!(ax2, x, 100*view(xpe,1:H), color=col2, linestyle=:dash, linewidth=lw2)
    linkyaxes!(ax1, ax2)
    hideydecorations!(ax2, grid = false)
    hidespines!(ax2, :l)
    # Have to manually create the patches for now
    # See https://github.com/MakieOrg/Makie.jl/issues/3444
    ls = [LineElement(color=col1, linewidth=lw1),
        LineElement(color=:black, linestyle=:dashdot),
        LineElement(color=:black, linestyle=:dot)]
    Legend(f1[2,1:2], [ls, [LineElement(color=col2, linestyle=:dash, linewidth=lw2)]],
        [["Total", "Regular Sectors", "Export-Only Sectors"], ["Total"]],
        ["GE Response", "PE Response"], tellheight=true, tellwidth=false,
        titleposition=:top, orientation=:horizontal, titlegap=2,
        padding=(5,5,5,5), nbanks=1)
    colgap!(f1.layout, Relative(0.02))
    rowgap!(f1.layout, Relative(0.03))
    save(string(fig/"$fname.pdf"), f1, pt_per_unit=1)
    return f1
end

function barpricepair(P, ir, hlr, pvar, xlab, L, fname)
    f = Figure(; size= 72 .* (2.4*halfwidth, L));
    P = P[P.sec.∈(ir,),:]
    # Assume sectors are sorted in P
    secs = unique(P.sec)
    S = length(secs)
    df1 = P[(P.iso3.=="USA"),:]
    df2 = P[(P.iso3.=="CN1"),:]
    hmd = 2
    df1[!,:dodge] = ifelse.(df1.h.==hmd, 3,
        ifelse.(df1.h.==hlr, 1, -1))
    df1 = df1[df1.dodge.>0,:]
    df2[!,:dodge] = ifelse.(df2.h.==hmd, 3,
        ifelse.(df2.h.==hlr, 1, -1))
    df2 = df2[df2.dodge.>0,:]
    cols = [Paired_8[2], 1, Paired_8[8], 1, Paired_8[2]]
    col1 = getindex.(Ref(cols), df1.dodge);
    col2 = getindex.(Ref(cols), df2.dodge);
    # The index for plot goes in the reverse order
    ax1 = Axis(f[1,1], yticks = (S:-1:1, valuelabels(secs)), yticklabelrotation=0,
        xlabel = xlab, title = "US")
    barplot!(ax1, (S+unwrap(secs[1])).-refarray(df1.sec), 100*df1[!,pvar], dodge=df1.dodge, color=col1,
        direction=:x, label_size=11, gap=0.3)
    vlines!(ax1, 0, color=:grey70, linewidth=0.5)
    ax2 = Axis(f[1,2], yticks = (S:-1:1, valuelabels(secs)),
        xlabel = xlab, title = "China")
    barplot!(ax2, (S+unwrap(secs[1])).-refarray(df2.sec), 100*df2[!,pvar], dodge=df2.dodge, color=col2,
        direction=:x, label_size=11, gap=0.3)
    vlines!(ax2, 0, color=:grey70, linewidth=0.5)
    linkaxes!(ax1, ax2)
    hideydecorations!(ax2, grid = false)
    hidespines!(ax2, :l)
    elements = [PolyElement(polycolor=cols[i]) for i in 3:-2:1]

    Legend(f[2,1:2], elements, [string(hmd), string(hlr)],
        "Horizon", tellheight=true, tellwidth=false,
        titleposition=:left, titlegap=10, nbanks=3, patchsize = (15,3))
    rowgap!(f.layout, Relative(0.03))
    save(string(fig/"$fname.pdf"), f, pt_per_unit=1)
    return f
end

function plotwelfare(df, dflr, H, d1, d2, n1, n2, tag)
    df1 = df[(df.iso3.==d1).&(df.h.<=H), :]
    df1lr = dflr[(dflr.iso3.==d1).&(dflr.h.<=H), :]
    df2 = df[(df.iso3.==d2).&(df.h.<=H), :]
    df2lr = dflr[(dflr.iso3.==d2).&(dflr.h.<=H), :]

    # Real wage changes with an ACR term
    f1 = Figure(; size=72 .* (2*halfwidth, 3.5))
    ax1 = Axis(f1[1, 1], xlabel="Year", ylabel="100 ✕ Log Difference from Initial Level (%)",
        title=n1)
    x = 0:H
    ax1.xticks = 0:2:H
    col1, col2, col3 = Paired_8[[8,2,6]]
    lw1 = 2
    l1 = lines!(ax1, x, 100*df1.wp, color=col1, linewidth=lw1)
    # l2 = lines!(ax1, x, 100*df1.flex, color=col2, linestyle=:dash)
    l3 = lines!(ax1, x, 100*df1lr.wp, color=col3, linestyle=:dot)
    ax2 = Axis(f1[1, 2], xlabel="Year", title=n2)
    ax2.xticks = 0:2:H
    l1 = lines!(ax2, x, 100*df2.wp, color=col1, linewidth=lw1)
    # l2 = lines!(ax2, x, 100*df2.flex, color=col2, linestyle=:dash)
    l3 = lines!(ax2, x, 100*df2lr.wp, color=col3, linestyle=:dot)
    linkyaxes!(ax1, ax2)
    hideydecorations!(ax2, grid = false)
    hidespines!(ax2, :l)
    # Have to manually create the patches for now
    # See https://github.com/MakieOrg/Makie.jl/issues/3444
    ls = [LineElement(color=col1, linewidth=lw1),
        #LineElement(color=col2, linestyle=:dash),
        LineElement(color=col3, linestyle=:dot)]
    Legend(f1[2,1:2], ls, ["Total Effect", "No Friction"],
        tellheight=true, tellwidth=false, orientation=:horizontal,
        padding=(5,5,5,5), nbanks=1)
    colgap!(f1.layout, Relative(0.02))
    rowgap!(f1.layout, Relative(0.03))
    save(string(fig/"acr_$tag.pdf"), f1, pt_per_unit=1)

    # Real wage changes with an ACR term
    f1 = Figure(; size=72 .* (2*halfwidth, 3.5))
    ax1 = Axis(f1[1, 1], xlabel="Year", ylabel="100 ✕ Log Difference from Initial Level (%)",
        title=n1)
    x = 0:H
    ax1.xticks = 0:2:H
    col1, col2, col3 = Paired_8[[8,2,6]]
    lw1 = 2
    l1 = lines!(ax1, x, 100*df1.wp, color=col1, linewidth=lw1)
    l2 = lines!(ax1, x, 100*df1.flex, color=col2, linestyle=:dash)
    ax2 = Axis(f1[1, 2], xlabel="Year", title=n2)
    ax2.xticks = 0:2:H
    l1 = lines!(ax2, x, 100*df2.wp, color=col1, linewidth=lw1)
    l2 = lines!(ax2, x, 100*df2.flex, color=col2, linestyle=:dash)
    linkyaxes!(ax1, ax2)
    hideydecorations!(ax2, grid = false)
    hidespines!(ax2, :l)
    # Have to manually create the patches for now
    # See https://github.com/MakieOrg/Makie.jl/issues/3444
    ls = [LineElement(color=col1, linewidth=lw1),
        LineElement(color=col2, linestyle=:dash)]
    Legend(f1[2,1:2], ls, ["Total Effect", "No Distortion Term"],
        tellheight=true, tellwidth=false, orientation=:horizontal,
        padding=(5,5,5,5), nbanks=1)
    colgap!(f1.layout, Relative(0.02))
    rowgap!(f1.layout, Relative(0.03))
    save(string(fig/"acrdist_$tag.pdf"), f1, pt_per_unit=1)

    # Real wage changes with an ACR term
    f2 = Figure(; size=72 .* (2*halfwidth, 3.5))
    ax1 = Axis(f2[1, 1], xlabel="Year", ylabel="100 ✕ Log Difference from Initial Level (%)",
        title=n1)
    x = 0:H
    ax1.xticks = 0:2:H
    col1, col2, col3 = Paired_8[[8,2,6]]
    lw1 = 2
    l1 = lines!(ax1, x, 100*df1.wp, color=col1, linewidth=lw1)
    l2 = lines!(ax1, x, 100*df1.W, color=col2, linestyle=:dash)
    l3 = lines!(ax1, x, 100*df1.Pf, color=col3, linestyle=:dot)
    ax2 = Axis(f2[1, 2], xlabel="Year", title=n2)
    ax2.xticks = 0:2:H
    l1 = lines!(ax2, x, 100*df2.wp, color=col1, linewidth=lw1)
    l2 = lines!(ax2, x, 100*df2.W, color=col2, linestyle=:dash)
    l3 = lines!(ax2, x, 100*df2.Pf, color=col3, linestyle=:dot)
    linkyaxes!(ax1, ax2)
    hideydecorations!(ax2, grid = false)
    hidespines!(ax2, :l)
    # Have to manually create the patches for now
    # See https://github.com/MakieOrg/Makie.jl/issues/3444
    ls = [LineElement(color=col1, linewidth=lw1),
        LineElement(color=col2, linestyle=:dash),
        LineElement(color=col3, linestyle=:dot)]
    Legend(f2[2,1:2], ls, ["Real Wage", "Wage", "Price"],
        tellheight=true, tellwidth=false, orientation=:horizontal,
        padding=(5,5,5,5), nbanks=1)
    colgap!(f2.layout, Relative(0.02))
    rowgap!(f2.layout, Relative(0.03))
    save(string(fig/"wageprice_$tag.pdf"), f2, pt_per_unit=1)

    # Cumulative welfare impact
    f3 = Figure(; size=72 .* (2*halfwidth, 3.5))
    ax1 = Axis(f3[1, 1], xlabel="Year", ylabel="100 ✕ Log Difference from Initial Level (%)",
        title=n1)
    x = 0:H
    ax1.xticks = 0:2:H
    col1, col2, col3 = Paired_8[[8,2,6]]
    lw1 = 2
    l1 = lines!(ax1, x, 100*df1.wpcum, color=col1, linewidth=lw1)
    l2 = lines!(ax1, x, 100*df1.flexcum, color=col2, linestyle=:dash)
    l3 = lines!(ax1, x, 100*df1lr.wpcum, color=col3, linestyle=:dot)
    ax2 = Axis(f3[1, 2], xlabel="Year", title=n2)
    ax2.xticks = 0:2:H
    l1 = lines!(ax2, x, 100*df2.wpcum, color=col1, linewidth=lw1)
    l2 = lines!(ax2, x, 100*df2.flexcum, color=col2, linestyle=:dash)
    l3 = lines!(ax2, x, 100*df2lr.wpcum, color=col3, linestyle=:dot)
    linkyaxes!(ax1, ax2)
    hideydecorations!(ax2, grid = false)
    hidespines!(ax2, :l)
    # Have to manually create the patches for now
    # See https://github.com/MakieOrg/Makie.jl/issues/3444
    ls = [LineElement(color=col1, linewidth=lw1),
        LineElement(color=col2, linestyle=:dash),
        LineElement(color=col3, linestyle=:dot)]
    Legend(f3[2,1:2], ls, ["Total Effect", "No Distortion Term", "No Friction"],
        tellheight=true, tellwidth=false, orientation=:horizontal,
        padding=(5,5,5,5), nbanks=1)
    colgap!(f3.layout, Relative(0.02))
    rowgap!(f3.layout, Relative(0.03))
    save(string(fig/"acrcum_$tag.pdf"), f3, pt_per_unit=1)
    return f1, f2, f3
end

function main()
    # ttbdest = matread(string(elasdir/"estttbdbaci.mat"))
    # plotdid(ttbdest, "base", (-5, 8), "estttbdbacibase"; iest=:)
    elas0 = matread(string(elasdir/"elasparam.mat"))
    elas = matread(string(elasdir/"elasparam_blp_cp.mat"))
    θ, σ, ζ = elas["theta_sigma_zeta_blp_h_eff"][:,1]
    # Must get ζ back to half-year frequency
    ζ = 1 - sqrt(1 - ζ)
    horzs = 1:2:21
    fitted = @.(-θ * (1 - (1-ζ)^(horzs)) + (1-σ) * (1-ζ)^(horzs))
    plotelas(elas0["est_blp_baseline"], fitted, elas0["se_blp_baseline"], "elasparam")

    dres = matread(string(modeldir/"tradewar_G.mat"))
    plottrade(dres["dlgMUSA"], dres["dlgMUSApe"], dres["dlgMCHN"], dres["dlgMCHNpe"], 13, "dlgMXUSA")
    P1 = DataFrame(readstat(modeldir/"price_G.dta"))
    barpricepair(P1, 1:19, 12, :P, "Price Change Relative to Initial Level (%)", 5, "P_USACN1direct")
    barpricepair(P1, 1:19, 12, :Pw, "Price Change Relative to Wage (%)", 5, "Pw_USACN1direct")
    barpricepair(P1, 20:32, 12, :P, "Price Change Relative to Initial Level (%)", 4, "P_USACN1other")
    barpricepair(P1, 20:32, 12, :Pw, "Price Change Relative to Wage (%)", 4, "Pw_USACN1other")

    W1 = DataFrame(readstat(modeldir/"welfare_base.dta"))
    W1lr = DataFrame(readstat(modeldir/"welfare_baselr.dta"))
    plotwelfare(W1, W1lr, 13, "USA", "CN1", "US", "China", "USACHN")
    plotwelfare(W1, W1lr, 13, "MX1", "VNM", "Mexico", "Vietnam", "MEXVNM")

    sufs = ["", "_ex56", "_ex47", "_zeta02", "_zeta04", "_theta5"]
    for suf in ["", "try", "try0"]#sufs
        #=
        W1 = DataFrame(readstat(modeldir/"welfare_base$(suf).dta"))
        W1lr = DataFrame(readstat(modeldir/"welfare_baselr$(suf).dta"))
        plotwelfare(W1, W1lr, 13, "USA", "CN1", "US", "China", "USACHN"*suf)
        plotwelfare(W1, W1lr, 13, "MX1", "VNM", "Mexico", "Vietnam", "MEXVNM"*suf)
        =#
        W2 = DataFrame(readstat(modeldir/"welfare_G$(suf).dta"))
        W2lr = DataFrame(readstat(modeldir/"welfare_Glr$(suf).dta"))
        plotwelfare(W2, W2lr, 13, "USA", "CN1", "US", "China", "USACHN_G"*suf)
        plotwelfare(W2, W2lr, 13, "MX1", "VNM", "Mexico", "Vietnam", "MEXVNM_G"*suf)

        #if suf == ""
        #    plotwelfare(W2, W2lr, 13, "AUS", "NZL", "Australia", "New Zealand", "AUSNZL_G")
        #    plotwelfare(W2, W2lr, 13, "GBR", "CAN", "United Kingdom", "Canada", "GBRCAN_G")
        #end
    end
end

#@time main()

function temp()
    df = DataFrame(readstat(modeldir/"welfare_Gtry.dta"))
    dflr = DataFrame(readstat(modeldir/"welfare_Glrtry.dta"))
    df0 = DataFrame(readstat(modeldir/"welfare_Gtry0.dta"))
    d1, d2, n1, n2 = "USA", "CN1", "US", "China"
    H = 31
    df1 = df[(df.iso3.==d1).&(df.h.<=H), :]
    df1lr = dflr[(dflr.iso3.==d1).&(dflr.h.<=H), :]
    df10 = df0[(df0.iso3.==d1).&(df0.h.<=H), :]
    df2 = df[(df.iso3.==d2).&(df.h.<=H), :]
    df2lr = dflr[(dflr.iso3.==d2).&(dflr.h.<=H), :]
    df20 = df0[(df0.iso3.==d2).&(df0.h.<=H), :]

    f3 = Figure(; size=72 .* (2*halfwidth, 3.5))
    ax1 = Axis(f3[1, 1], xlabel="Year", ylabel="100 ✕ Log Difference from Initial Level (%)",
        title=n1)
    x = 0:H
    ax1.xticks = 0:2:H
    col1, col2, col3 = Paired_8[[8,2,6]]
    lw1 = 2
    l1 = lines!(ax1, x, 100*df10.wp, color=col1, linewidth=lw1)
    l2 = lines!(ax1, x, 100*df1lr.wp, color=col2, linestyle=:dash)
    l3 = lines!(ax1, x, 100*df1.wp, color=col3, linestyle=:dot)
    ax2 = Axis(f3[1, 2], xlabel="Year", title=n2)
    ax2.xticks = 0:2:H
    l1 = lines!(ax2, x, 100*df20.wp, color=col1, linewidth=lw1)
    l2 = lines!(ax2, x, 100*df2lr.wp, color=col2, linestyle=:dash)
    l3 = lines!(ax2, x, 100*df2.wp, color=col3, linestyle=:dot)
    linkyaxes!(ax1, ax2)
    hideydecorations!(ax2, grid = false)
    hidespines!(ax2, :l)
    # Have to manually create the patches for now
    # See https://github.com/MakieOrg/Makie.jl/issues/3444
    ls = [LineElement(color=col1, linewidth=lw1),
        LineElement(color=col2, linestyle=:dash),
        LineElement(color=col3, linestyle=:dot)]
    Legend(f3[2,1:2], ls, ["No Forward Looking", "No Friction", "With Forward Looking (t=1)"],
        tellheight=true, tellwidth=false, orientation=:horizontal,
        padding=(5,5,5,5), nbanks=1)
    colgap!(f3.layout, Relative(0.02))
    rowgap!(f3.layout, Relative(0.03))
    save(string(fig/"acrtry.pdf"), f3, pt_per_unit=1)
    f3
end