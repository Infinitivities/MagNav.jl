"""
    xyz2h5(xyz_file::String, xyz_h5::String, flight::Symbol;
           lines::Vector        = [()],
           lines_type::Symbol   = :exclude,
           tt_sort::Bool        = true,
           downsample_160::Bool = true,
           return_data::Bool    = false)

Convert SGL flight data file from .xyz to HDF5.
- Valid for SGL flights:
    - `:Flt1001`
    - `:Flt1001_160Hz`
    - `:Flt1002`
    - `:Flt1002_160Hz`
    - `:Flt1003`
    - `:Flt1004`
    - `:Flt1004_1005`
    - `:Flt1005`
    - `:Flt1006`
    - `:Flt1007`
    - `:Flt1008`
    - `:Flt1009`
    - `:Flt2001_2017`

May take 1+ hr for 1+ GB flight data files. For reference, a 1.23 GB flight 
data file took 46.8 min to process using a 64 GB MacBook Pro.

**Arguments:**
- `xyz_file`:       path/name of .xyz file containing flight data
- `xyz_h5`:         path/name of HDF5 file to save with flight data
- `flight`:         SGL flight (e.g. `:Flt1001`)
- `lines`:          (optional) selected line number(s) to ONLY include or exclude, must be a vector of 3-element (`line`, `start_time`, `stop_time`) Tuple(s)
- `lines_type`:     (optional) whether to ONLY `:include` (i.e. to generate testing data) or `:exclude` (i.e. to generate training data) `lines`
- `tt_sort`:        (optional) if true, sort data by time (instead of line)
- `downsample_160`: (optional) if true, downsample 160 Hz data to 10 Hz (only for 160 Hz data files)
- `return_data`:    (optional) if true, return `data` instead of writing `xyz_h5` HDF5 file 

**Returns:**
- `data`: if `return_data = true`, internal data matrix
"""
function xyz2h5(xyz_file::String, xyz_h5::String, flight::Symbol;
                lines::Vector        = [()],
                lines_type::Symbol   = :exclude,
                tt_sort::Bool        = true,
                downsample_160::Bool = true,
                return_data::Bool    = false)

    fields   = xyz_fields(flight) # list of data field names
    Nf       = length(fields)     # number of data fields (columns)
    ind_tt   = findfirst(fields .== :tt)   # time index (column)
    ind_line = findfirst(fields .== :line) # line index (column)

    # find valid data rows (correct number of columns)
    ind = [(length(split(line)) == Nf) for line in eachline(xyz_file)]

    # if 160 Hz data, find valid 10 Hz data rows (tt is multiple of 0.1)
    # probably better ways to do this, but it works ok
    if downsample_160 & (flight in [:Flt1001_160Hz,:Flt1002_160Hz])
        for (i,line) in enumerate(eachline(xyz_file))
            ind[i] && (ind[i] = (par(split(line)[ind_tt])+1e-6) % 0.1 < 1e-3)
        end
    end

    Nd   = sum(ind)     # number of valid data rows
    data = zeros(Nd,Nf) # initialize data matrix

    @info("reading in file: $xyz_file")

    # go through valid data rows and extract data
    for (i,line) in enumerate(eachline(xyz_file))
        if ind[i]
            j = cumsum(ind[1:i])[i]
            data[j,:] = par.(split(line))
        end
    end

    # check for duplicated data
    N_tt   = length(unique(data[:,ind_tt  ]))
    N_line = length(unique(data[:,ind_line]))
    Nd > N_tt + N_line && @info("xyz file may contain duplicated data")

    if return_data
        return (data)
    else
        xyz2h5(data,xyz_h5,flight;
               tt_sort    = tt_sort,
               lines      = lines,
               lines_type = lines_type)
    end
end # function xyz2h5

"""
    xyz2h5(data::Array, xyz_h5::String, flight::Symbol;
           tt_sort::Bool      = true,
           lines::Vector      = [()],
           lines_type::Symbol = :exclude)
"""
function xyz2h5(data::Array, xyz_h5::String, flight::Symbol;
                tt_sort::Bool      = true,
                lines::Vector      = [()],
                lines_type::Symbol = :exclude)

    fields   = xyz_fields(flight) # list of field names
    Nf_chk   = length(fields)     # number of data fields (columns)
    ind_tt   = findfirst(fields .== :tt)   # time index (column)
    ind_line = findfirst(fields .== :line) # line index (column)

    # number of valid data rows & data fields
    (Nd,Nf) = size(data)

    @assert Nf == Nf_chk "xyz fields don't match up, $Nf ≂̸ $Nf_chk"

    # check for duplicated data
    N_tt   = length(unique(data[:,ind_tt  ]))
    N_line = length(unique(data[:,ind_line]))
    Nd - N_tt > N_line && @info("xyz file may contain duplicated data")

    if !isempty(lines[1])

        # get ind for all lines
        ind = falses(Nd)
        for line in lines
            ind = ind .| get_ind(data[:,ind_tt],data[:,ind_line];
                                 lines=[line[1]],tt_lim=[line[2],line[3]])
        end

        # include or exclude lines
        if lines_type == :exclude
            ind .= .!ind
        elseif lines_type != :include
            error("$lines_type lines type not defined")
        end

    else
        ind = trues(Nd)
    end

    # write N & dt data fields
    Nd = sum(ind) # number of used data rows
    dt = Nd > 1 ? round(data[ind,ind_tt][2]-data[ind,ind_tt][1],digits=9) : 0.1 # measurement time step
    write_field(xyz_h5,:N ,Nd)
    write_field(xyz_h5,:dt,dt)

    ind_sort = tt_sort ? sortperm(data[ind,ind_tt]) : 1:Nd # sorting order

    # write other data fields
    for i = 1:Nf
        fields[i] != :ignore && write_field(xyz_h5,fields[i],
                                            data[ind,i][ind_sort,1])
    end

end # function xyz2h5

"""
    par(val::SubString{String})

Return `*` as `NaN`, otherwise parse as Float64.

**Arguments:**
- `val`: substring

**Returns:**
- `par`: parsed substring
"""
function par(val::SubString{String})
    val == "*" ? NaN : parse(Float64,val)
end # function par

"""
    delete_field(file_h5::String, field)

Delete a data field from an HDF5 file.

**Arguments:**
- `file_h5`: path/name of HDF5 file containing data
- `field`:   data field in `file_h5` to delete

**Returns:**
- `nothing`: `field` is deleted in `file_h5`
"""
function delete_field(file_h5::String, field)
    field = string.(field)
    file  = h5open(file_h5,"r+") # read-write, preserve existing contents
    delete_object(file,field)
    close(file)
end # function delete_field

"""
    write_field(file_h5::String, field, data)

Write (add) a new data field and data in an HDF5 file.

**Arguments:**
- `file_h5`: path/name of HDF5 file containing data
- `field`:   data field in `file_h5` to write
- `data`:    data to write

**Returns:**
- `nothing`: `field` with `data` is written in `file_h5`
"""
function write_field(file_h5::String, field, data)
    field = string.(field)
    h5open(file_h5,"cw") do file # read-write, create file if not existing, preserve existing contents
        write(file,field,data)
    end
end # function write_field

"""
    overwrite_field(file_h5::String, field, data)

Overwrite a data field and data in an HDF5 file.

**Arguments:**
- `file_h5`: path/name of HDF5 file containing data
- `field`:   data field in `file_h5` to overwrite
- `data`:    data to write

**Returns:**
- `nothing`: `field` with `data` is written in `file_h5`
"""
function overwrite_field(file_h5::String, field, data)
    field = string.(field)
    delete_field(file_h5,field)
    write_field(file_h5,field,data)
end # function overwrite_field

"""
    read_field(file_h5::String, field)

Read data for a data field in an HDF5 file.

**Arguments:**
- `file_h5`: path/name of HDF5 file containing data
- `field`:   data field in `file_h5` to read

**Returns:**
- `data`: data for `data field` in `file_h5`
"""
function read_field(file_h5::String, field)
    field = string.(field)
    h5open(file_h5,"r") do file # read-only
        read(file,field)
    end
end # function read_field

"""
    rename_field(file_h5::String, field_old, field_new)

Rename data field in an HDF5 file.

**Arguments:**
- `file_h5`:   path/name of HDF5 file containing data
- `field_old`: old data field in `file_h5`
- `field_new`: new data field in `file_h5`

**Returns:**
- `nothing`: `field_old` is renamed `field_new` in `file_h5`
"""
function rename_field(file_h5::String, field_old, field_new)
    field_old = string.(field_old)
    field_new = string.(field_new)
    data = read_field(file_h5,field_old)
    delete_field(file_h5,field_old)
    write_field(file_h5,field_new,data)
end # function rename_field

"""
    clear_fields(file_h5::String)

Clear all data fields and data in an HDF5 file.

**Arguments:**
- `file_h5`: path/name of HDF5 file containing data

**Returns:**
- `nothing`: all data fields and data cleared in `file_h5`
"""
function clear_fields(file_h5::String)
    file = h5open(file_h5,"cw") # read-write, create file if not existing, preserve existing contents
    close(file)
    file = h5open(file_h5,"w") # read-write, destroy existing contents
    close(file)
end # function clear_fields

"""
    print_fields(s)

Print all data fields and types for a given struct.

**Arguments:**
- `s`: struct

**Returns:**
- `nothing`: all data fields and types in struct `s` are printed out
"""
function print_fields(s)
    for field in fieldnames(typeof(s))
        t = typeof(getfield(s,field))
        if parentmodule(t) == MagNav
            for f in fieldnames(t)
                println("$field.$f  ",typeof(getfield(getfield(s,field),f)))
            end
        else
            println("$field  ",t)
        end
    end
end # function print_fields

"""
    compare_fields(s1, s2; silent::Bool=false)

Compare data for each data field in 2 structs of the same type.

**Arguments:**
- `s1`:     struct 1
- `s2`:     struct 2
- `silent`: (optional) if true, no summary print out

**Returns:**
- `N_dif`: if `silent = false`, number of different fields
"""
function compare_fields(s1, s2; silent::Bool=false)
    t1 = typeof(s1)
    t2 = typeof(s2)
    @assert t1 == t2 "$t1 & $t2 types do no match"
    N_dif = 0;
    for field in fieldnames(t1)
        t = typeof(getfield(s1,field))
        if parentmodule(t) == MagNav
            N_dif_add = compare_fields(getfield(s1,field),getfield(s2,field);
                                       silent=true)
            N_dif_add == 0 || println("($field is above)")
            N_dif += N_dif_add
        else
            if eltype(getfield(s1,field)) <: Number
                dif = sum(abs.(getfield(s1,field) - getfield(s2,field)))
                dif ≈ 0 || println("$field  ",dif)
                dif ≈ 0 || (N_dif += 1)
            elseif typeof(getfield(s1,field)) <: Chain
                m1 = getfield(s1,field)
                m2 = getfield(s2,field)
                if length(m1) != length(m2)
                    println("size of $field is different")
                    N_dif += 1
                else
                    for i in eachindex(m1)
                        for f in [:weight,:bias,:σ]
                            if getfield(m1[i],f) != getfield(m2[i],f)
                                println("$field field $f is different")
                                N_dif += 1
                            end
                        end
                    end
                end
            else
                if getfield(s1,field) != getfield(s2,field)
                    println("non-numeric field $field is different")
                    N_dif += 1
                end
            end
        end
    end

    if silent
        return (N_dif)
    else
        @info("number of different data fields: $N_dif")
    end
end # function compare_fields

"""
    field_check(s, t)

Find data fields of a specified type in given struct.

**Arguments:**
- `s`: struct
- `t`: type

**Returns:**
- `fields`: data fields of type `t` in struct `s`
"""
function field_check(s, t)
    fields = fieldnames(typeof(s))
    [fields[i] for i = findall([typeof(getfield(s,f)) for f in fields] .<: t)]
end # function field_check

"""
    field_check(s, field::Symbol)

Check if a specified data field is in a given struct.

**Arguments:**
- `s`:     struct
- `field`: data field

**Returns:**
- `AssertionError` if `field` is not in struct `s`
"""
function field_check(s, field::Symbol)
    t = typeof(s)
    @assert field in fieldnames(t) "field $field not in $t"
end # function field_check

"""
    field_check(s, field::Symbol, t)

Check if a specified data field is in a given struct and of a given type.

**Arguments:**
- `s`:     struct
- `field`: data field
- `t`:     type

**Returns:**
- `AssertionError` if `field` is not in struct `s` or not type `t`
"""
function field_check(s, field::Symbol, t)
    field_check(s,field)
    @assert typeof(getfield(s,field)) <: t "$field is not $t type"
end # function field_check

"""
    field_extrema(xyz::XYZ, field::Symbol, val)

Determine time extrema for specific value of data field.

**Arguments:**
- `xyz`:   `XYZ` flight data struct
- `field`: data field
- `val`:   specific value of `field`

**Returns:**
- `field_extrema`: time extrema for given field
"""
function field_extrema(xyz::XYZ, field::Symbol, val)
    if sum(getfield(xyz,field).==val) > 0
        extrema(xyz.traj.tt[getfield(xyz,field).==val])
    else
        error("$val not in $field")
    end
end # function field_extrema

"""
    xyz_fields(flight::Symbol)

Get field names for given SGL flight.
- Valid for SGL flights:
    - `:Flt1001`
    - `:Flt1001_160Hz`
    - `:Flt1002`
    - `:Flt1002_160Hz`
    - `:Flt1003`
    - `:Flt1004`
    - `:Flt1004_1005`
    - `:Flt1005`
    - `:Flt1006`
    - `:Flt1007`
    - `:Flt1008`
    - `:Flt1009`
    - `:Flt2001_2017`
    - `:Flt2001`
    - `:Flt2002`
    - `:Flt2004`
    - `:Flt2005`
    - `:Flt2006`
    - `:Flt2007`
    - `:Flt2008`
    - `:Flt2015`
    - `:Flt2016`
    - `:Flt2017`

**Arguments:**
- `flight`: SGL flight (e.g. `:Flt1001`)

**Returns:**
- `fields`: list of data field names (Symbols)
"""
function xyz_fields(flight::Symbol)

    # get csv files containing fields from sgl_flight_data_fields artifact
    fields20  = string(sgl_fields(),"/fields_sgl_2020.csv")
    fields21  = string(sgl_fields(),"/fields_sgl_2021.csv")
    fields160 = string(sgl_fields(),"/fields_sgl_160.csv" )

    d = Dict{Symbol,Any}()
    push!(d, :fields20  => Symbol.(vec(readdlm(fields20 ,','))))
    push!(d, :fields21  => Symbol.(vec(readdlm(fields21 ,','))))
    push!(d, :fields160 => Symbol.(vec(readdlm(fields160,','))))

    if flight in keys(d)

        return (d[flight])

    elseif flight in [:Flt1001,:Flt1002]

        # no mag_6_uc or flux_a for these flights
        exc = [:mag_6_uc,:flux_a_x,:flux_a_y,:flux_a_z,:flux_a_t]
        ind = .!(d[:fields20] .∈ (exc,))

        return (d[:fields20][ind])

    elseif flight in [:Flt1003,:Flt1004,:Flt1005,:Flt1004_1005,
                      :Flt1006,:Flt1007]

        # no mag_6_uc for these flights
        exc = [:mag_6_uc]
        ind = .!(d[:fields20] .∈ (exc,))

        return (d[:fields20][ind])

    elseif flight in [:Flt1008,:Flt1009]

        return (d[:fields20])

    elseif flight in [:Flt1001_160Hz,:Flt1002_160Hz]

        # no mag_6_uc or flux_a for these flights
        exc = [:mag_6_uc,:flux_a_x,:flux_a_y,:flux_a_z,:flux_a_t]
        ind = .!(d[:fields160] .∈ (exc,))

        return (d[:fields160][ind])

    elseif flight in [:Flt2001_2017,
                      :Flt2001,:Flt2002,:Flt2004,:Flt2005,:Flt2006,
                      :Flt2007,:Flt2008,:Flt2015,:Flt2016,:Flt2017]

        return (d[:fields21])

    else
        error("$flight flight not defined")
    end

end # function xyz_fields
