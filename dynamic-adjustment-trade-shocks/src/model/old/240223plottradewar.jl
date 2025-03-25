using CairoMakie
using CairoMakie.GeometryBasics: HyperRectangle
using ColorSchemes: Paired_8, Blues_9, Oranges_9
using MAT
using DataFrames
using ReadStatTables

const modeldir = "data/work/model/"
const fig = "fig/"

const halfwidth = 3.5
set_theme!()
update_theme!(Axis=(rightspinevisible=false, topspinevisible=false, spinewidth=0.7, xgridvisible=false, titlefont="Helvetica", titlegap=5, xtickwidth=0.7, titlesize=12, ytickwidth=0.7, xticksize=3, yticksize=3), font="Helvetica", fontsize=10, figure_padding=5, Legend=(patchsize = (20,10), padding=4, titlefont="Helvetica", framewidth=0.7))

function plottrade(mge, mpe, xge, xpe, H, fname)
    f1 = Figure(; size=72 .* (2*halfwidth, 3.5))
    ax1 = Axis(f1[1, 1], xlabel="Year", ylabel="Tariff-Exclusive Trade Share\n100 ✕ Log Difference from Initial Level (%)",
        title="US Import from China")
    x = 0:H-1
    ax1.xticks = 0:2:H-1
    col1, col2 = Paired_8[8], Paired_8[2]
    lw1, lw2 = 2, 2
    l1 = lines!(ax1, x, 100*view(mge,1:H,1), color=col1, linewidth=lw1)
    l2 = lines!(ax1, x, 100*view(mge,1:H,2), color=:black, linestyle=:dashdot)
    l3 = lines!(ax1, x, 100*view(mge,1:H,3), color=:black, linestyle=:dot)
    l4 = lines!(ax1, x, 100*view(mpe,1:H), color=col2, linestyle=:dash, linewidth=lw2)
    ax2 = Axis(f1[1, 2], xlabel="Year", title="China Import from US")
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
    save(fig*"$fname.pdf", f1, pt_per_unit=1)
    return f1
end

function barpricepair(P, hlr, L, fname)
    f = Figure(; size= 72 .* (2.4*halfwidth, L));
    secs = unique(P.sec)
    S = length(secs)
    df1 = P[P.iso3.=="USA",:]
    df2 = P[P.iso3.=="CN1",:]
    hmd = 2
    df1[!,:dodge] = ifelse.(df1.h.==1, 5, ifelse.(df1.h.==hmd, 3,
        ifelse.(df1.h.==hlr, 1, -1)))
    df1 = df1[df1.dodge.>0,:]
    df2[!,:dodge] = ifelse.(df2.h.==1, 5, ifelse.(df2.h.==hmd, 3,
        ifelse.(df2.h.==hlr, 1, -1)))
    df2 = df2[df2.dodge.>0,:]
    cols = [Paired_8[4], 1, Paired_8[8], 1, Paired_8[2]]
    col1 = getindex.(Ref(cols), df1.dodge);
    col2 = getindex.(Ref(cols), df2.dodge);
    # The index for plot goes in the reverse order
    ax1 = Axis(f[1,1], yticks = (S:-1:1, valuelabels(secs)), yticklabelrotation=0,
        xlabel = "Price Change Relative to Wage (%)", title = "US")
    barplot!(ax1, (S+unwrap(secs[1])).-refarray(df1.sec), df1.dP, dodge=df1.dodge, color=col1,
        direction=:x, label_size=11, gap=0.3)
    vlines!(ax1, 0, color=:grey70, linewidth=0.5)
    ax2 = Axis(f[1,2], yticks = (S:-1:1, valuelabels(secs)),
        xlabel = "Price Change Relative to Wage (%)", title = "China")
    barplot!(ax2, (S+unwrap(secs[1])).-refarray(df2.sec), df2.dP, dodge=df2.dodge, color=col2,
        direction=:x, label_size=11, gap=0.3)
    vlines!(ax2, 0, color=:grey70, linewidth=0.5)
    linkaxes!(ax1, ax2)
    hideydecorations!(ax2, grid = false)
    hidespines!(ax2, :l)
    elements = [PolyElement(polycolor=cols[i]) for i in 5:-2:1]

    Legend(f[2,1:2], elements, ["1", string(hmd), string(hlr)],
        "Horizon", tellheight=true, tellwidth=false,
        titleposition=:left, titlegap=10, nbanks=3, patchsize = (15,3))
    rowgap!(f.layout, Relative(0.02))
    save(fig*"$fname.pdf", f, pt_per_unit=1)
    return f
end



function plotwelfare(dres, H, fname)
    f1 = Figure(; size=72 .* (2*halfwidth, 3.5))
    ax1 = Axis(f1[1, 1], xlabel="Year", ylabel="100 ✕ Log Difference from Initial Level (%)",
        title="US")
    x = 0:H-1
    ax1.xticks = 0:2:H-1
    col1, col2, col3 = Paired_8[[8,2,4]]
    lw1 = 2
    iflex, idist = 1, 5
    l1 = lines!(ax1, x, 100*view(dres["lgwpUSA"],1:H), color=col1, linewidth=lw1)
    l2 = lines!(ax1, x, 100*view(dres["lgacrUSA"],1:H, iflex), color=col2, linestyle=:dash)
    #l3 = lines!(ax1, x, 100*view(dres["lgPfUSA"],1:H), color=col3, linestyle=:dot)
    ax2 = Axis(f1[1, 2], xlabel="Year", title="China")
    ax2.xticks = 0:2:H-1
    l1 = lines!(ax2, x, 100*view(dres["lgwpCHN"],1:H), color=col1, linewidth=lw1)
    l2 = lines!(ax2, x, 100*view(dres["lgacrCHN"],1:H, iflex), color=col2, linestyle=:dash)
    #l3 = lines!(ax2, x, 100*view(dres["lgPfCHN"],1:H), color=col3, linestyle=:dot)
    linkyaxes!(ax1, ax2)
    hideydecorations!(ax2, grid = false)
    hidespines!(ax2, :l)
    # Have to manually create the patches for now
    # See https://github.com/MakieOrg/Makie.jl/issues/3444
    ls = [LineElement(color=col1, linewidth=lw1),
        LineElement(color=col2, linestyle=:dash)]
    Legend(f1[2,1:2], ls, ["Total Change", "No Distortion"],
        tellheight=true, tellwidth=false, orientation=:horizontal,
        padding=(5,5,5,5), nbanks=1)
    colgap!(f1.layout, Relative(0.02))
    rowgap!(f1.layout, Relative(0.03))
    save(fig*"$fname.pdf", f1, pt_per_unit=1)
    return f1
end


function main()
    dres = matread(modeldir*"tradewar.mat")
    plottrade(dres["dlgMUSA"], dres["dlgMUSApe"], dres["dlgMCHN"], dres["dlgMCHNpe"],16, "dlgMXUSA")
    P1 = DataFrame(readstat(modeldir*"priceUSACHNdirect.dta"))
    P1.dP = 100 .* P1.P

    barpricepair(P1, 15, 6, "priceUSACN1direct")
    P2 = DataFrame(readstat(modeldir*"priceUSACHNother.dta"))
    P2.dP = 100 .* P2.P
    barpricepair(P2, 15, 4.5, "priceUSACN1other")
    plotwelfare(dres, 16, "welfareUSACHN")
end