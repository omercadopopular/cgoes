using CairoMakie
using CairoMakie.GeometryBasics: HyperRectangle
using ColorSchemes: Paired_8, Blues_9, Oranges_9
using MAT
using DataFrames
using ReadStatTables

using FilePathsBase
using FilePathsBase: /

const modeldir = p"data/work/model"
const fig = p"fig"

const halfwidth = 3.5
set_theme!()
update_theme!(Axis=(rightspinevisible=false, topspinevisible=false, spinewidth=0.7, xgridvisible=false, titlefont="Helvetica", titlegap=5, xtickwidth=0.7, titlesize=12, ytickwidth=0.7, xticksize=3, yticksize=3), font="Helvetica", fontsize=10, figure_padding=5, Legend=(patchsize = (20,10), padding=4, titlefont="Helvetica", framewidth=0.7))

function plotwelfare(df, dflr, H, c, l, fname)
    df1 = df[(df.iso3.==c[1]).&(df.h.<=H), :]
    df1lr = dflr[(dflr.iso3.==c[1]).&(dflr.h.==3), :]
    df2 = df[(df.iso3.==c[2]).&(df.h.<=H), :]
    df2lr = dflr[(dflr.iso3.==c[2]).&(dflr.h.==3), :]

    f1 = Figure(; size=72 .* (2*halfwidth, 3.5))
    ax1 = Axis(f1[1, 1], xlabel="Year", ylabel="100 ✕ Log Difference from Initial Level (%)",
        title=l[1])
    x = 0:H
    ax1.xticks = 0:2:H
    col1, col2, col3 = Paired_8[[8,2,6]]
    lw1 = 2
    iflex, idist = 1, 5
    l1 = lines!(ax1, x, 100*view(df1.wp,1:H+1), color=col1, linewidth=lw1)
    l2 = lines!(ax1, x, 100*view(df1.flex,1:H+1)./df1.etasum[1], color=col2, linestyle=:dash)
    l3 = lines!(ax1, x, repeat([100*(df1lr.wp[1])], H+1), color=col3, linestyle=:dot)
    l4 = hlines!(ax1, [0], xmax=[1], color=:black )
    ax2 = Axis(f1[1, 2], xlabel="Year", title=l[2])
    ax2.xticks = 0:2:H-1
    l1 = lines!(ax2, x, 100*view(df2.wp,1:H+1), color=col1, linewidth=lw1)
    l2 = lines!(ax2, x, 100*view(df2.flex,1:H+1)./df2.etasum[1], color=col2, linestyle=:dash)
    l3 = lines!(ax2, x, repeat([100*(df2lr.wp[1])], H+1), color=col3, linestyle=:dot)
    l4 = hlines!(ax2, [0], xmax=[1], color=:black )
    linkyaxes!(ax1, ax2)
    hideydecorations!(ax2, grid = false)
    hidespines!(ax2, :l)
    # Have to manually create the patches for now
    # See https://github.com/MakieOrg/Makie.jl/issues/3444
    ls = [LineElement(color=col1, linewidth=lw1),
        LineElement(color=col2, linestyle=:dash),
        LineElement(color=col3, linestyle=:dot)]
    Legend(f1[2,1:2], ls, ["Total Effect", "No Distortion Term", "Long-Run Effect"],
        tellheight=true, tellwidth=false, orientation=:horizontal,
        padding=(5,5,5,5), nbanks=1)
    colgap!(f1.layout, Relative(0.02))
    rowgap!(f1.layout, Relative(0.03))
    save(string(fig/"$fname.pdf"), f1, pt_per_unit=1)
    return f1
end


function plotratio(df, dflr, H, c, l, fname)
    df1 = df[(df.iso3.==c[1]).&(df.h.<=H), :]
    df1lr = dflr[(dflr.iso3.==c[1]).&(dflr.h.==3), :]
    df2 = df[(df.iso3.==c[2]).&(df.h.<=H), :]
    df2lr = dflr[(dflr.iso3.==c[2]).&(dflr.h.==3), :]

    f1 = Figure(; size=72 .* (2*halfwidth, 3.5))
    ax1 = Axis(f1[1, 1], xlabel="Year", ylabel="Ratio with respect to long-run effect",
        title=l[1])
    x = 0:H
    ax1.xticks = 0:2:H
    col1, col2, col3 = Paired_8[[8,2,6]]
    lw1 = 2
    iflex, idist = 1, 5
    l1 = lines!(ax1, x, view(df1.wp ./ df1lr.wp[1],1:H+1), color=col1, linewidth=lw1)
    l2 = lines!(ax1, x, view(df1.flex ./ df1lr.wp[1],1:H+1)./df1.etasum[1], color=col2, linestyle=:dash)
    l3 = hlines!(ax1, [0], xmax=[1], color=:black )
    l4 = hlines!(ax1, [1], xmax=[1], color=col3, linestyle=:dot )
    ax2 = Axis(f1[1, 2], xlabel="Year", title=l[2])
    ax2.xticks = 0:2:H-1
    l1 = lines!(ax2, x, view(df2.wp ./ df2lr.wp[1],1:H+1), color=col1, linewidth=lw1)
    l2 = lines!(ax2, x, view(df2.flex ./ df2lr.wp[1],1:H+1)./df2.etasum[1], color=col2, linestyle=:dash)
    l3 = hlines!(ax2, [0], xmax=[1], color=:black )
    l4 = hlines!(ax2, [1], xmax=[1], color=col3, linestyle=:dot )
    linkyaxes!(ax1, ax2)
    hideydecorations!(ax2, grid = false)
    hidespines!(ax2, :l)
    # Have to manually create the patches for now
    # See https://github.com/MakieOrg/Makie.jl/issues/3444
    ls = [LineElement(color=col1, linewidth=lw1),
        LineElement(color=col2, linestyle=:dash),
        LineElement(color=col3, linestyle=:dot)]
    Legend(f1[2,1:2], ls, ["Total Effect", "No Distortion Term", "Long-Run Effect"],
        tellheight=true, tellwidth=false, orientation=:horizontal,
        padding=(5,5,5,5), nbanks=1)
    colgap!(f1.layout, Relative(0.02))
    rowgap!(f1.layout, Relative(0.03))
    save(string(fig/"ratio_$fname.pdf"), f1, pt_per_unit=1)
    return f1
end

function main()
    W1 = DataFrame(readstat(modeldir/"welfare_base.dta"))
    W1lr = DataFrame(readstat(modeldir/"welfare_baselr.dta"))
    plotwelfare(W1, W1lr, 15, ["MX1", "VNM"], ["Mexico", "Vietnam"], "welfareMEXVNM")
    plotratio(W1, W1lr, 15, ["MX1", "VNM"], ["Mexico", "Vietnam"], "welfareMEXVNM")
    plotwelfare(W1, W1lr, 15, ["USA", "CN1"], ["USA", "China"], "welfareUSACHN")
    plotratio(W1, W1lr, 15, ["USA", "CN1"], ["USA", "China"], "welfareUSACHN")
    W2 = DataFrame(readstat(modeldir/"welfare_G.dta"))
    W2lr = DataFrame(readstat(modeldir/"welfare_Glr.dta"))
    plotwelfare(W2, W2lr, 15, ["MX1", "VNM"], ["Mexico", "Vietnam"], "welfareMEXVNM_G")
    plotratio(W2, W2lr, 15, ["MX1", "VNM"], ["Mexico", "Vietnam"], "welfareMEXVNM_G")
    plotwelfare(W1, W1lr, 15, ["USA", "CN1"], ["USA", "China"], "welfareUSACHN")
    plotratio(W1, W1lr, 15, ["USA", "CN1"], ["USA", "China"], "welfareUSACHN")
end

main()
