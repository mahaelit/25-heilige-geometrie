include("01setup.jl")
using CairoMakie
using Colors
using GeometryBasics: Circle, Point2f

seed_centers(radius::Real, center::Point2f; rotation::Real=0) = begin
    cs = Point2f[center]
    for k in 0:5
        θ = rotation + k * 2π / 6
        push!(cs, center + Point2f(radius * cos(θ), radius * sin(θ)))
    end
    cs
end

seed_limits(radius::Real, center::Point2f; pad_ratio::Real=0.08) = begin
    r = 2 * radius * (1 + pad_ratio)
    (center[1] - r, center[1] + r, center[2] - r, center[2] + r)
end

draw_seed!(ax; radius::Real, center::Point2f, linewidth::Real=2.5, color=colorant"rgba(0, 0, 0, 0.8)", rotation::Real=0, method::Symbol=:arc) = begin
    for c in seed_centers(radius, center; rotation=rotation)
        if method === :arc
            arc!(ax, c, radius, 0, 2π; color=color, linewidth=linewidth, linecap=:round, joinstyle=:round, resolution=720)
        else
            poly!(ax, Circle(c, radius); color=:transparent, strokecolor=color, strokewidth=linewidth, linecap=:round, joinstyle=:round)
        end
    end
    ax
end

seed_figure(radius::Real; center::Point2f=Point2f(0,0), linewidth::Real=2.5, color=colorant"rgba(0, 0, 0, 0.8)", background=:white, rotation::Real=0, pad_ratio::Real=0.08, method::Symbol=:arc) = begin
    res = (Int(round(4*radius)), Int(round(4*radius)))
    f = Figure(size=res, backgroundcolor=background)
    ax = Axis(f[1, 1]; aspect=DataAspect(), limits=seed_limits(radius, center; pad_ratio=pad_ratio))
    hidedecorations!(ax); hidespines!(ax)
    draw_seed!(ax; radius=radius, center=center, linewidth=linewidth, color=color, rotation=rotation, method=method)
    (f, ax)
end

seed_svg(path::AbstractString, radius::Real; center::Point2f=Point2f(0,0), linewidth::Real=2.5, color=colorant"rgba(0, 0, 0, 0.8)", background=:white, scale::Real=1, rotation::Real=0, pad_ratio::Real=0.08, method::Symbol=:arc) = begin
    res = (Int(round(scale*4*radius)), Int(round(scale*4*radius)))
    f = Figure(size=res, backgroundcolor=background)
    ax = Axis(f[1, 1]; aspect=DataAspect(), limits=seed_limits(radius, center; pad_ratio=pad_ratio))
    hidedecorations!(ax); hidespines!(ax)
    draw_seed!(ax; radius=radius, center=center, linewidth=linewidth, color=color, rotation=rotation, method=method)
    save(path, f)
    path
end

draw_point!(ax; center::Point2f, size::Real, color) = begin
    poly!(ax, Circle(center, size); color=color, strokecolor=:transparent)
    ax
end

draw_circle!(ax; radius::Real, center::Point2f, linewidth::Real, color, method::Symbol=:arc) = begin
    if method === :arc
        arc!(ax, center, radius, 0, 2π; color=color, linewidth=linewidth, linecap=:round, joinstyle=:round, resolution=720)
    else
        poly!(ax, Circle(center, radius); color=:transparent, strokecolor=color, strokewidth=linewidth, linecap=:round, joinstyle=:round)
    end
    ax
end

 vesica_centers(radius::Real, center::Point2f; rotation::Real=0, sep_ratio::Real=1.0) = begin
     d = radius * sep_ratio / 2
     u = Point2f(cos(rotation), sin(rotation))
     c1 = center - d*u
     c2 = center + d*u
     (c1, c2)
 end
 
 draw_vesica!(ax; radius::Real, center::Point2f, linewidth::Real=2.5, color=colorant"rgba(0, 0, 0, 0.8)", rotation::Real=0, sep_ratio::Real=1.0, method::Symbol=:arc) = begin
     c1, c2 = vesica_centers(radius, center; rotation=rotation, sep_ratio=sep_ratio)
     if method === :arc
         arc!(ax, c1, radius, 0, 2π; color=color, linewidth=linewidth, linecap=:round, joinstyle=:round, resolution=720)
         arc!(ax, c2, radius, 0, 2π; color=color, linewidth=linewidth, linecap=:round, joinstyle=:round, resolution=720)
     else
         poly!(ax, Circle(c1, radius); color=:transparent, strokecolor=color, strokewidth=linewidth, linecap=:round, joinstyle=:round)
         poly!(ax, Circle(c2, radius); color=:transparent, strokecolor=color, strokewidth=linewidth, linecap=:round, joinstyle=:round)
     end
     ax
 end
 
draw_step!(ax, step::Symbol; radius::Real, center::Point2f, linewidth::Real, color, rotation::Real, method::Symbol, pointsize::Real, vesica_sep_ratio::Real=1.0) = begin
    if step === :point
        draw_point!(ax; center=center, size=pointsize, color=color)
    elseif step === :circle
        draw_circle!(ax; radius=radius, center=center, linewidth=linewidth, color=color, method=method)
    elseif step === :vesica
        draw_vesica!(ax; radius=radius, center=center, linewidth=linewidth, color=color, rotation=rotation, sep_ratio=vesica_sep_ratio, method=method)
    else
        draw_seed!(ax; radius=radius, center=center, linewidth=linewidth, color=color, rotation=rotation, method=method)
    end
    ax
end

seed_step_figure(step::Symbol, radius::Real; center::Point2f=Point2f(0,0), linewidth::Real=2.5, color=colorant"rgba(0, 0, 0, 0.8)", background=:white, rotation::Real=0, pad_ratio::Real=0.08, method::Symbol=:arc, pointsize::Real=radius*0.06, vesica_sep_ratio::Real=1.0) = begin
    res = (Int(round(4*radius)), Int(round(4*radius)))
    f = Figure(size=res, backgroundcolor=background)
    ax = Axis(f[1, 1]; aspect=DataAspect(), limits=seed_limits(radius, center; pad_ratio=pad_ratio))
    hidedecorations!(ax); hidespines!(ax)
    draw_step!(ax, step; radius=radius, center=center, linewidth=linewidth, color=color, rotation=rotation, method=method, pointsize=pointsize, vesica_sep_ratio=vesica_sep_ratio)
    (f, ax)
end

seed_strip_figure(radius::Real; steps=(:point, :circle, :vesica, :seed), center::Point2f=Point2f(0,0), linewidth::Real=2.5, color=colorant"rgba(0, 0, 0, 0.8)", background=:white, rotation::Real=0, pad_ratio::Real=0.08, method::Symbol=:arc, pointsize::Real=radius*0.06, gap::Float64=6.0, vesica_sep_ratio::Real=1.0) = begin
    n = length(steps)
    res = (Int(round(4*radius*n)), Int(round(4*radius)))
    f = Figure(size=res, backgroundcolor=background)
    lims = seed_limits(radius, center; pad_ratio=pad_ratio)
    for (i, s) in enumerate(steps)
        ax = Axis(f[1, i]; aspect=DataAspect(), limits=lims)
        hidedecorations!(ax); hidespines!(ax)
        draw_step!(ax, s; radius=radius, center=center, linewidth=linewidth, color=color, rotation=rotation, method=method, pointsize=pointsize, vesica_sep_ratio=vesica_sep_ratio)
    end
    f
end

seed_strip_svg(path::AbstractString, radius::Real; steps=(:point, :circle, :vesica, :seed), center::Point2f=Point2f(0,0), linewidth::Real=2.5, color=colorant"rgba(0, 0, 0, 0.8)", background=:white, rotation::Real=0, pad_ratio::Real=0.08, method::Symbol=:arc, pointsize::Real=radius*0.06, vesica_sep_ratio::Real=1.0) = begin
    f = seed_strip_figure(radius; steps=steps, center=center, linewidth=linewidth, color=color, background=background, rotation=rotation, pad_ratio=pad_ratio, method=method, pointsize=pointsize, vesica_sep_ratio=vesica_sep_ratio)
    save(path, f)
    path
end

radius = 100
linewidth = 2.5
rotation_deg = 90
rotation_rad = rotation_deg * (π/180)
filename = "saat_des_lebens.svg"
output_file = joinpath(@__DIR__, filename)
seed_svg(output_file, radius; center=Point2f(0,0), linewidth=linewidth, color=colorant"rgba(0, 0, 0, 0.8)", background=:white, rotation=rotation_rad, pad_ratio=0.1, method=:arc)
println("Grafik wurde erfolgreich als '$filename' gespeichert.")

series_filename = "serie_saat_des_lebens.svg"
series_output = joinpath(@__DIR__, series_filename)
seed_strip_svg(series_output, radius; steps=(:point, :circle, :vesica, :seed), center=Point2f(0,0), linewidth=linewidth, color=colorant"rgba(0, 0, 0, 0.8)", background=:white, rotation=rotation_rad, pad_ratio=0.1, method=:arc)
println("Grafik wurde erfolgreich als '$series_filename' gespeichert.")

f, ax = seed_figure(100,rotation=90*π/180)

f