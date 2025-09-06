include("01setup.jl")
using CairoMakie
using Colors
using GeometryBasics: Circle, Point2f

vesica_centers(radius::Real, center::Point2f; rotation::Real=0, sep_ratio::Real=1.0) = begin
    d = radius * sep_ratio / 2
    u = Point2f(cos(rotation), sin(rotation))
    c1 = center - d*u
    c2 = center + d*u
    (c1, c2)
end

vesica_limits(radius::Real, center::Point2f; rotation::Real=0, sep_ratio::Real=1.0, pad_ratio::Real=0.1) = begin
    c1, c2 = vesica_centers(radius, center; rotation=rotation, sep_ratio=sep_ratio)
    pad = radius * pad_ratio
    minx = min(c1[1]-radius, c2[1]-radius) - pad
    maxx = max(c1[1]+radius, c2[1]+radius) + pad
    miny = min(c1[2]-radius, c2[2]-radius) - pad
    maxy = max(c1[2]+radius, c2[2]+radius) + pad
    (minx, maxx, miny, maxy)
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

vesica_figure(radius::Real; center::Point2f=Point2f(0,0), linewidth::Real=2.5, color=colorant"rgba(0, 0, 0, 0.8)", background=:white, rotation::Real=0, sep_ratio::Real=1.0, pad_ratio::Real=0.1, method::Symbol=:arc) = begin
    sizepx = (Int(round(4*radius)), Int(round(4*radius)))
    f = Figure(size=sizepx, backgroundcolor=background)
    ax = Axis(f[1, 1]; aspect=DataAspect(), limits=vesica_limits(radius, center; rotation=rotation, sep_ratio=sep_ratio, pad_ratio=pad_ratio))
    hidedecorations!(ax); hidespines!(ax)
    draw_vesica!(ax; radius=radius, center=center, linewidth=linewidth, color=color, rotation=rotation, sep_ratio=sep_ratio, method=method)
    (f, ax)
end

vesica_svg(path::AbstractString, radius::Real; center::Point2f=Point2f(0,0), linewidth::Real=2.5, color=colorant"rgba(0, 0, 0, 0.8)", background=:white, rotation::Real=0, sep_ratio::Real=1.0, pad_ratio::Real=0.1, method::Symbol=:arc, scale::Real=1) = begin
    sizepx = (Int(round(scale*4*radius)), Int(round(scale*4*radius)))
    f = Figure(size=sizepx, backgroundcolor=background)
    ax = Axis(f[1, 1]; aspect=DataAspect(), limits=vesica_limits(radius, center; rotation=rotation, sep_ratio=sep_ratio, pad_ratio=pad_ratio))
    hidedecorations!(ax); hidespines!(ax)
    draw_vesica!(ax; radius=radius, center=center, linewidth=linewidth, color=color, rotation=rotation, sep_ratio=sep_ratio, method=method)
    save(path, f)
    path
end

radius = 100
linewidth = 2.5
filename = "vesica_piscis.svg"
output_file = joinpath(@__DIR__, filename)
vesica_svg(output_file, radius; center=Point2f(0,0), linewidth=linewidth, color=colorant"rgba(0, 0, 0, 0.8)", background=:white, rotation=0, sep_ratio=1.0, pad_ratio=0.1, method=:arc)
println("Grafik wurde erfolgreich als 'vesica_piscis.svg' gespeichert.")
 