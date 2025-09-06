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

draw_seed!(ax; radius::Real, center::Point2f, linewidth::Real=2.5, color=colorant"rgba(0, 0, 0, 0.8)", rotation::Real=0) = begin
    for c in seed_centers(radius, center; rotation=rotation)
        poly!(ax, Circle(c, radius); color=:transparent, strokecolor=color, strokewidth=linewidth)
    end
    ax
end

seed_figure(radius::Real; center::Point2f=Point2f(0,0), linewidth::Real=2.5, color=colorant"rgba(0, 0, 0, 0.8)", background=:white, rotation::Real=0, pad_ratio::Real=0.08) = begin
    res = (Int(round(4*radius)), Int(round(4*radius)))
    f = Figure(size=res, backgroundcolor=background)
    ax = Axis(f[1, 1]; aspect=DataAspect(), limits=seed_limits(radius, center; pad_ratio=pad_ratio))
    hidedecorations!(ax); hidespines!(ax)
    draw_seed!(ax; radius=radius, center=center, linewidth=linewidth, color=color, rotation=rotation)
    (f, ax)
end

seed_svg(path::AbstractString, radius::Real; center::Point2f=Point2f(0,0), linewidth::Real=2.5, color=colorant"rgba(0, 0, 0, 0.8)", background=:white, scale::Real=1, rotation::Real=0, pad_ratio::Real=0.08) = begin
    res = (Int(round(scale*4*radius)), Int(round(scale*4*radius)))
    f = Figure(size=res, backgroundcolor=background)
    ax = Axis(f[1, 1]; aspect=DataAspect(), limits=seed_limits(radius, center; pad_ratio=pad_ratio))
    hidedecorations!(ax); hidespines!(ax)
    draw_seed!(ax; radius=radius, center=center, linewidth=linewidth, color=color, rotation=rotation)
    save(path, f)
    path
end

radius = 100
linewidth = 2.5
rotation_deg = 0
rotation_rad = rotation_deg * (π/180)
filename = "saat_des_lebens.svg"
output_file = joinpath(@__DIR__, filename)
seed_svg(output_file, radius; center=Point2f(0,0), linewidth=linewidth, color=colorant"rgba(0, 0, 0, 0.8)", background=:white, rotation=rotation_rad, pad_ratio=0.1)
println("Grafik wurde erfolgreich als '$filename' gespeichert.")

