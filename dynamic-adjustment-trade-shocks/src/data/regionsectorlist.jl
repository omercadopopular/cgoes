"""
Generate lists of regions and industries to be considered in model
"""

using CSV
using DataFrames
using PooledArrays
using ReadStatTables
using XLSX

const rawicio = "data/ICIO/240126/"
const iciodir = "data/work/ICIO/"
const rawwiod = "data/WIOD/raw/2016_release/WIOTS_in_STATA/"
const concdir = "data/work/concordance/"

# Create short names
const smap34 = Dict("Agriculture, forestry and fishing"=>"Agriculture",
    "Mining and quarrying"=>"Mining",
    "Food products, beverages and tobacco"=>"Food",
    "Textiles, textile products, leather and footwear"=>"Textiles",
    "Wood and products of wood and cork"=>"Wood",
    "Paper products and printing"=>"Paper and printing",
    "Coke and refined petroleum products"=>"Coke and petroleum",
    "Chemicals and chemical products"=>"Chemicals",
    "Pharmaceuticals, medicinal and botanical products"=>"Pharmaceuticals",
    "Rubber and plastics products"=>"Rubber and plastics",
    "Other non-metallic mineral products"=>"Non-metallic minerals",
    "Fabricated metal products"=>"Fabricated metals",
    "Computer, electronic and optical equipment"=>"Computer",
    "Machinery and equipment"=>"Machinery",
    "Motor vehicles, trailers and semi-trailers"=>"Motor vehicles",
    "Other transport equipment"=>"Other transport equip.",
    "Furniture and other manufacturing"=>"Furniture and others",
    "Wholesale and retail trade; repair of motor vehicles"=>"Wholesale and retail",
    "Transportation and storage"=>"Transportation",
    "Accommodation and food service activities"=>"Accommodation",
    "Information and communication"=>"Information",
    "Financial and insurance activities"=>"Finance and insurance",
    "Real estate activities"=>"Real estate",
    "Professional, scientific and technical activities"=>"Professional services",
    "Administrative and support services"=>"Administrative services",
    "Human health and social work activities"=>"Health and social work",
    "Arts, entertainment and recreation"=>"Arts and entertainment")

function main()
    sec1 = DataFrame(XLSX.readtable(rawicio*"ReadMe_ICIO_extended.xlsx", "Area_Activities",
        "I:K", first_row=3, header=true, infer_eltypes=true, stop_in_empty_row=true))
    select!(sec1, :Code=>:code, :Industry=>:industry, Symbol("ISIC Rev.4")=>:isic4)
    # Manually fix a missing space in raw data for the ease of later purposes (split)
    sec1[44,:isic4] = "94, 95, 96"
    # Manually insert non-industry categories
    append!(sec1,
        (code=["TLS","VA","OUT","HFCE","NPISH","GGFC","GFCF","INVNT","DPABR"],
        industry=["Taxes less subsidies", "Value added", "Output",
        "Household final consumption expenditure",
        "Non-profit institutions serving households",
        "General government final consumption",
        "Gross fixed capital formation",
        "Changes in inventories and valuables",
        "Direct purchases abroad by residents"],
        isic4=fill("", 9)))
    # Fix some names
    sec1[11,:industry] = "Chemicals and chemical products"
    sec1[19,:industry] = "Machinery and equipment"

    # Baseline industries
    sec1[!,:i32code] = copy(sec1.code)
    sec1[!,:i32] = copy(sec1.industry)
    sec1[1:2,:i32code] .= "A"
    sec1[1:2,:i32] .= "Agriculture, forestry and fishing"
    sec1[3:5,:i32code] .= "B"
    sec1[3:5,:i32] .= "Mining and quarrying"
    # Change the name only
    sec1[12,:i32] = "Pharmaceuticals, medicinal and botanical products"
    sec1[22,:i32] = "Furniture and other manufacturing"
    sec1[23:24,:i32code] .= "DE"
    sec1[23:24,:i32] .= "Utilities"
    sec1[27:31,:i32code] .= "H"
    sec1[27:31,:i32] .= "Transportation and storage"
    sec1[33:35,:i32code] .= "J"
    sec1[33:35,:i32] .= "Information and communication"

    sec1[!,:i32short] = [get(smap34, n, n) for n in sec1.i32]

    # Add an alternative that does not drop any sector
    sec1[!,:i34code] = copy(sec1.i32code)
    sec1[!,:i34] = copy(sec1.i32)

    idrop = [40,44,45]
    sec1[idrop,:i32code] .= "_DROP"
    sec1[idrop,:i32] .= "_DROP"
    sec1[idrop,:i32short] .= "_DROP"

    sec1[44:45,:i34code] .= "ST"
    sec1[44:45,:i34] .= "Other service activities; households as employers"

    sec1[!,:i34short] = [get(smap34, n, n) for n in sec1.i34]

    for col in union(1:2, 7:9)
        sec1[!,col] = PooledArray(sec1[!,col], Int8)
    end
    # Make sure that _DROP is at the end when assigning the integer code
    sort!(view(sec1, 1:45, :), :i32code)
    for col in 4:6
        sec1[!,col] = PooledArray(sec1[!,col], Int8)
    end
    sort!(view(sec1, 1:45, :), :code)
    sec1 = ReadStatTable(sec1, ".dta")
    for col in (:industry, :i32, :i34)
        colmetadata!(sec1, col, "display_width", 55)
    end
    writestat(iciodir*"sectorlist.dta", sec1)

    reg1 = DataFrame(XLSX.readtable(rawicio*"ReadMe_ICIO_extended.xlsx", "Area_Activities",
        "C:E", first_row=3, header=true, infer_eltypes=true, stop_in_empty_row=true))
    select!(reg1, :Code=>:iso3, :countries=>:region)
    # Adjust certain names and remove the footnote numbers
    reg1[13,:region] = "China"
    reg1[29,:region] = "Hong Kong"
    reg1[18,:region] = "Cyprus"
    reg1[36,:region] = "Israel"
    reg1[42,:region] = "South Korea"
    reg1[43,:region] = "Lao"
    reg1[62,:region] = "Russia"
    reg1[72,:region] = "Taiwan"
    reg1[78,:region] = "Mexico, non-processing"
    reg1[79,:region] = "Mexico, processing"
    reg1[80,:region] = "China, non-processing"
    reg1[81,:region] = "China, processing"
    reg1[!,:region] = PooledArray(reg1[:,:region], Int8)

    # Collect code used by US Census for merging with trade data
    census = CSV.read(concdir*"country.txt", DataFrame, delim='|',
        header=[:censuscode, :censusname, :iso2],
        skipto=6, footerskip=4, stripwhitespace=true, downcast=true)
    # Map ISO2 to ISO3
    iso = CSV.read(concdir*"UNSD — Methodology.csv", DataFrame)
    iso = iso[!,["ISO-alpha2 Code", "ISO-alpha3 Code"]]
    rename!(iso, [:iso2, :iso3])
    leftjoin!(census, iso, on=:iso2)
    # Check missing values census[ismissing.(census.iso3),:]
    # Manually fill in all missing ones
    census[census.iso2.=="KV",:iso3] .= "KOS"
    census[census.iso2.=="GZ",:iso3] .= "ISR"
    census[census.iso2.=="WE",:iso3] .= "ISR"
    census[census.iso2.=="TW",:iso3] .= "TWN"
    census[census.iso2.=="rCD",:iso3] .= "COD"
    census = census[.~(ismissing.(census.iso3)), :]
    # Save the full list for dealing with trade data
    writestat(concdir*"censusregion.dta", census)

    census = census[.~(census.iso2.∈(("GZ","WE"),)), Not(:iso2)]
    leftjoin!(reg1, census, on=:iso3)
    # Manually verified that country names match
    select!(reg1, [:iso3, :region, :censuscode])
    # Fill in a dummy value for ROW
    reg1[reg1.iso3.=="ROW",:censuscode] .= 0

    reg1 = ReadStatTable(reg1, ".dta")
    colmetadata!(reg1, :region, "display_width", 33)
    writestat(iciodir*"regionlist.dta", reg1)
    return sec1, reg1
end

@time sec1, reg1 = main()
