using CairoMakie
using CairoMakie.GeometryBasics: HyperRectangle
using ColorSchemes: Paired_8, Blues_9, Oranges_9
using MAT
using DataFrames
using ReadStatTables
using FilePathsBase
using FilePathsBase: /

const iciodir = p"data/work/ICIO"
const modeldir = p"data/work/model"
const elasdir = p"data/work/elas"
const fig = p"fig2412"

const halfwidth = 3.5
set_theme!()
update_theme!(Axis=(rightspinevisible=false, topspinevisible=false, spinewidth=0.7, xgridvisible=false, titlefont="Helvetica", titlegap=5, xtickwidth=0.7, titlesize=12, ytickwidth=0.7, xticksize=3, yticksize=3), font="Helvetica", fontsize=10, figure_padding=5, Legend=(patchsize = (20,10), padding=4, titlefont="Helvetica", framewidth=0.7))

function plotelas(est::Dict, fname)
    f1 = Figure(; size=72 .* (1.2*halfwidth, 3.5))
    ax1 = Axis(f1[1, 1], xlabel="Year", ylabel="Tariff-Inclusive Trade Elasticity")
    H = length(est["bnl"])
    x = 1:H
    ax1.xticks = 1:2:H
    col1, col2 = Paired_8[8], Paired_8[2]
    lw1, lw2 = 2, 1.5
    band!(ax1, x, est["lbnl"], est["ubnl"], color=(col1, 0.3))
    l1 = lines!(ax1, x, est["bnl"], color=col1, linewidth=lw1)
    l2 = scatter!(ax1, x, est["bl"], color=col2)
    rangebars!(ax1, x, est["lbl"], est["ubl"], color=col2, linewidth=lw2)

    # Have to manually create the patches for now
    # See https://github.com/MakieOrg/Makie.jl/issues/3444
    ls = [LineElement(color=col1, linewidth=lw1),
        [LineElement(color=col2, linewidth=lw2), l2]]
    Legend(f1[2,1], ls, ["Nonlinear (Structural)", "Linear (Unrestricted)"], tellheight=true, tellwidth=false,
        orientation=:horizontal, padding=(5,5,5,5), nbanks=1)
    colgap!(f1.layout, Relative(0.02))
    rowgap!(f1.layout, Relative(0.03))
    save(string(fig/"$fname.pdf"), f1, pt_per_unit=1)
    return f1
end

function plottariff(mtau, xtau, fname)
    taucols = [:tau18, :tau19, :taumax19]
    f1 = Figure(; size=72 .* (2*halfwidth, 3.5))
    ax1 = Axis(f1[1, 1], xlabel="Year", ylabel="Change in Average Tariff (%)",
        title="US Tariffs on China")
    ax1.xticks = 0:2
    xlims!(ax1, -0.2, 2.2)
    col1, col2 = Paired_8[8], Paired_8[2]
    lw1, lw2 = 2, 2
    xs = 0:2
    ys = zeros(3)
    ms = zeros(3)
    
    markersc = 1
    for i in 1:nrow(mtau)
        w = mtau[i,:val]
        for (k, col) in enumerate(taucols)
            v = mtau[i,col]
            ys[k] = 100 * (v - 1)
            ms[k] += w * v
        end
        scatter!(ax1, xs, ys, markersize=markersc*mtau[i,:lgval])
    end
    ms .= 100 .* ((ms ./ sum(mtau[!,:val])) .- 1)
    l1 = lines!(ax1, xs, ms, color=col1, linewidth=lw1)

    ax2 = Axis(f1[1, 2], xlabel="Year", title="Retaliatory Tariffs on US")
    ax2.xticks = 0:2
    xlims!(ax2, -0.2, 2.2)

    for i in 1:nrow(xtau)
        w = xtau[i,:val]
        for (k, col) in enumerate(taucols)
            v = xtau[i,col]
            ys[k] = 100 * (v - 1)
            ms[k] += w * v
        end
        scatter!(ax2, xs, ys, markersize=markersc*xtau[i,:lgval])
    end
    ms .= 100 .* ((ms ./ sum(xtau[!,:val])) .- 1)
    l2 = lines!(ax2, xs, ms, color=col1, linewidth=lw1)
    linkyaxes!(ax1, ax2)
    hideydecorations!(ax2, grid = false)
    hidespines!(ax2, :l)

    ls = [MarkerElement(color = :black, marker = :circle, markersize = 9,
        strokecolor = :black), LineElement(color=col1, linewidth=lw1)]
    Legend(f1[2,1:2], ls, ["2-Digit ISIC", "All Industries"], "Aggregation Level",
        tellheight=true, tellwidth=false,
        titleposition=:left, orientation=:horizontal, titlegap=25,
        padding=(5,5,5,5), nbanks=1)
    colgap!(f1.layout, Relative(0.02))
    rowgap!(f1.layout, Relative(0.03))
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
    l4 = lines!(ax1, x, 100*view(mpe,1:H), color=col2, linestyle=:dash, linewidth=lw2)
    ax2 = Axis(f1[1, 2], xlabel="Year", title="China Imports from US")
    ax2.xticks = 0:2:H-1
    l1 = lines!(ax2, x, 100*view(xge,1:H,1), color=col1, linewidth=lw1)
    l4 = lines!(ax2, x, 100*view(xpe,1:H), color=col2, linestyle=:dash, linewidth=lw2)
    linkyaxes!(ax1, ax2)
    hideydecorations!(ax2, grid = false)
    hidespines!(ax2, :l)
    # Have to manually create the patches for now
    # See https://github.com/MakieOrg/Makie.jl/issues/3444
    ls = [LineElement(color=col1, linewidth=lw1),
        LineElement(color=col2, linestyle=:dash, linewidth=lw2)]
    Legend(f1[2,1:2], ls,
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
    l3 = lines!(ax1, x, 100*df1lr.wp, color=col3, linestyle=:dot)
    ax2 = Axis(f1[1, 2], xlabel="Year", title=n2)
    ax2.xticks = 0:2:H
    l1 = lines!(ax2, x, 100*df2.wp, color=col1, linewidth=lw1)
    l2 = lines!(ax2, x, 100*df2.flex, color=col2, linestyle=:dash)
    l3 = lines!(ax2, x, 100*df2lr.wp, color=col3, linestyle=:dot)
    linkyaxes!(ax1, ax2)
    hideydecorations!(ax2, grid = false)
    hidespines!(ax2, :l)
    # Have to manually create the patches for now
    # See https://github.com/MakieOrg/Makie.jl/issues/3444
    ls = [LineElement(color=col1, linewidth=lw1),
        LineElement(color=col2, linestyle=:dash),
        LineElement(color=col3, linestyle=:dot)]
    Legend(f1[2,1:2], ls, ["Full Model (Actual)", "Static ACR, Long-Run Elas.", "Static ACR, Elas. by Horizon"],
        tellheight=true, tellwidth=false, orientation=:horizontal,
        padding=(5,5,5,5), nbanks=1)
    colgap!(f1.layout, Relative(0.02))
    rowgap!(f1.layout, Relative(0.03))
    save(string(fig/"acrdist_$tag.pdf"), f1, pt_per_unit=1)

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

    return f1, f2
end

function plotbymodel(dfsufs, dests, tags, fsuf)
    df, df0, dflr = dfsufs
    d1, d2 = dests
    n1, n2 = tags
    H = 12
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
    l1 = lines!(ax1, x, 100*df1.wp, color=col1, linewidth=lw1)
    l2 = lines!(ax1, x, 100*df10.wp, color=col2, linestyle=:dash)
    l3 = lines!(ax1, x, 100*df1lr.wp, color=col3, linestyle=:dot)
    ax2 = Axis(f3[1, 2], xlabel="Year", title=n2)
    ax2.xticks = 0:2:H
    l1 = lines!(ax2, x, 100*df2.wp, color=col1, linewidth=lw1)
    l2 = lines!(ax2, x, 100*df20.wp, color=col2, linestyle=:dash)
    l3 = lines!(ax2, x, 100*df2lr.wp, color=col3, linestyle=:dot)
    linkyaxes!(ax1, ax2)
    hideydecorations!(ax2, grid = false)
    hidespines!(ax2, :l)
    # Have to manually create the patches for now
    # See https://github.com/MakieOrg/Makie.jl/issues/3444
    ls = [LineElement(color=col1, linewidth=lw1),
        LineElement(color=col2, linestyle=:dash),
        LineElement(color=col3, linestyle=:dot)]
    Legend(f3[2,1:2], ls, ["Friction, Forward Looking", "Friction, Myopia", "No Friction, Myopia"],
        tellheight=true, tellwidth=false, orientation=:horizontal,
        padding=(5,5,5,5), nbanks=1)
    colgap!(f3.layout, Relative(0.02))
    rowgap!(f3.layout, Relative(0.03))
    save(string(fig/"realwagebymodel$fsuf.pdf"), f3, pt_per_unit=1)
    f3
end

function main()
    elas = matread(string(elasdir/"gmmelasbase.mat"))
    plotelas(elas, "gmmelasbase")

    H = 13
    sectag = "i32"
    S = 32
    parajd = readstat(iciodir/"parajd_$(sectag).dta")
    regs = parajd.dest_iso3[1:S:end]
    dreg = Dict(regs.=>1:length(regs))
    # Needed for setshock!
    dreg["CHN"] = dreg["CN1"]
    dreg["MEX"] = dreg["MX1"]

    mtau = DataFrame(readstat(iciodir/"mtau.dta"))
    xtau = DataFrame(readstat(iciodir/"xtau.dta"))
    mtau[!,:lgval] = log.(mtau.val)
    mtau = view(mtau, mtau.iso3.=="CHN", :)
    xtau[!,:lgval] = log.(xtau.val)
    # Drop utilities
    xtau = view(xtau, (xtau.iso3.=="CHN").&(xtau.i34.!=20), :)
    plottariff(mtau, xtau, "mtauxtau")

    dres = matread(string(modeldir/"tradewar_Gbase.mat"))
    plottrade(dres["dlgMUSA"], dres["dlgMUSApe"], dres["dlgMCHN"], dres["dlgMCHNpe"], 13, "dlgMXUSA")
    P1 = DataFrame(readstat(modeldir/"price_Gbase.dta"))
    barpricepair(P1, 1:19, 12, :P, "Price Change Relative to Initial Level (%)", 5, "P_USACN1direct")
    barpricepair(P1, 1:19, 12, :Pw, "Price Change Relative to Wage (%)", 5, "Pw_USACN1direct")
    barpricepair(P1, 20:32, 12, :P, "Price Change Relative to Initial Level (%)", 4, "P_USACN1other")
    barpricepair(P1, 20:32, 12, :Pw, "Price Change Relative to Wage (%)", 4, "Pw_USACN1other")

    for suf in ["base"]
        dfw = DataFrame(readstat(modeldir/"welfare_G$(suf).dta"))
        dfwmyo = DataFrame(readstat(modeldir/"welfare_Gmyo$(suf).dta"))
        dfwlr = DataFrame(readstat(modeldir/"welfare_Glr$(suf).dta"))
        plotwelfare(dfw, dfwlr, 13, "USA", "CN1", "US", "China", "USACHN_G"*suf)
        plotwelfare(dfw, dfwlr, 13, "MX1", "VNM", "Mexico", "Vietnam", "MEXVNM_G"*suf)

        dfs = [dfw, dfwmyo, dfwlr]
        plotbymodel(dfs, ("USA", "CN1"), ("US", "China"), "_USACHN")
        plotbymodel(dfs, ("MX1", "VNM"),  ("Mexico", "Vietnam"), "_MEXVNM")
    end
end

@time main()
