include("01setup.jl")
using CairoMakie
using Colors
using GeometryBasics: Circle, Point2f

# Hexagonales Gitter der Zentren bis 'rings' in 60°-Orientierung
flower_centers(radius::Real, center::Point2f; rings::Int=2, rotation::Real=0) = begin
    cs = Point2f[center]
    v1 = Point2f(cos(rotation), sin(rotation))
    v2 = Point2f(cos(rotation + π/3), sin(rotation + π/3))
    for a in -rings:rings
        for b in -rings:rings
            # Bedingung für hexagonale Ringe in axialen Koordinaten:
            if max(abs(a), abs(b), abs(a + b)) <= rings
                if a == 0 && b == 0
                    continue
                end
                x = center[1] + radius * (a * v1[1] + b * v2[1])
                y = center[2] + radius * (a * v1[2] + b * v2[2])
                push!(cs, Point2f(x, y))
            end
        end
    end
    cs
end

# Limits aus allen Kreismittelpunkten inkl. Radius und Padding
flower_limits(radius::Real, centers::Vector{Point2f}; pad_ratio::Real=0.1) = begin
    pad = radius * pad_ratio
    minx = minimum(c[1] - radius for c in centers) - pad
    maxx = maximum(c[1] + radius for c in centers) + pad
    miny = minimum(c[2] - radius for c in centers) - pad
    maxy = maximum(c[2] + radius for c in centers) + pad
    (minx, maxx, miny, maxy)
end

# Zeichnet alle Kreise der Blume des Lebens
draw_flower!(ax; radius::Real, center::Point2f, rings::Int=2, linewidth::Real=2.5, color=colorant"rgba(0, 0, 0, 0.8)", rotation::Real=0, method::Symbol=:arc) = begin
    cs = flower_centers(radius, center; rings=rings, rotation=rotation)
    for c in cs
        if method === :arc
            arc!(ax, c, radius, 0, 2π; color=color, linewidth=linewidth, linecap=:round, joinstyle=:round, resolution=720)
        else
            poly!(ax, Circle(c, radius); color=:transparent, strokecolor=color, strokewidth=linewidth, linecap=:round, joinstyle=:round)
        end
    end
    ax
end

# Figure für Blume des Lebens
flower_figure(radius::Real; center::Point2f=Point2f(0,0), rings::Int=2, linewidth::Real=2.5, color=colorant"rgba(0, 0, 0, 0.8)", background=:white, rotation::Real=0, pad_ratio::Real=0.1, method::Symbol=:arc) = begin
    # Größe heuristisch abhängig von rings
    sizepx = (Int(round(4 * radius * (rings + 1))), Int(round(4 * radius * (rings + 1))))
    f = Figure(size=sizepx, backgroundcolor=background)
    cs = flower_centers(radius, center; rings=rings, rotation=rotation)
    ax = Axis(f[1, 1]; aspect=DataAspect(), limits=flower_limits(radius, cs; pad_ratio=pad_ratio))
    hidedecorations!(ax); hidespines!(ax)
    draw_flower!(ax; radius=radius, center=center, rings=rings, linewidth=linewidth, color=color, rotation=rotation, method=method)
    (f, ax)
end

# SVG-Export
flower_svg(path::AbstractString, radius::Real; center::Point2f=Point2f(0,0), rings::Int=2, linewidth::Real=2.5, color=colorant"rgba(0, 0, 0, 0.8)", background=:white, rotation::Real=0, pad_ratio::Real=0.1, method::Symbol=:arc, scale::Real=1) = begin
    sizepx = (Int(round(scale * 4 * radius * (rings + 1))), Int(round(scale * 4 * radius * (rings + 1))))
    f = Figure(size=sizepx, backgroundcolor=background)
    cs = flower_centers(radius, center; rings=rings, rotation=rotation)
    ax = Axis(f[1, 1]; aspect=DataAspect(), limits=flower_limits(radius, cs; pad_ratio=pad_ratio))
    hidedecorations!(ax); hidespines!(ax)
    draw_flower!(ax; radius=radius, center=center, rings=rings, linewidth=linewidth, color=color, rotation=rotation, method=method)
    save(path, f)
    path
end

# Ausführung: erzeugt blume_des_lebens.svg
radius = 100
linewidth = 2.5
rings = 2                    # 2 Ringe → 19 Kreise
rotation_deg = 90
rotation_rad = rotation_deg * (π/180)
filename = "blume_des_lebens.svg"
output_file = joinpath(@__DIR__, filename)

flower_svg(output_file, radius; center=Point2f(0,0), rings=rings, linewidth=linewidth, color=colorant"rgba(0, 0, 0, 0.8)", background=:white, rotation=rotation_rad, pad_ratio=0.1, method=:arc)
println("Grafik wurde erfolgreich als '$filename' gespeichert.")