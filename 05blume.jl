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

# Liefert Zentren zusammen mit Ringindex (0,1,2,...)
flower_centers_with_rings(radius::Real, center::Point2f; rings::Int=2, rotation::Real=0) = begin
    cr = Tuple{Point2f,Int}[(center, 0)]
    v1 = Point2f(cos(rotation), sin(rotation))
    v2 = Point2f(cos(rotation + π/3), sin(rotation + π/3))
    for a in -rings:rings
        for b in -rings:rings
            r = max(abs(a), abs(b), abs(a + b))
            if r <= rings && r > 0
                x = center[1] + radius * (a * v1[1] + b * v2[1])
                y = center[2] + radius * (a * v1[2] + b * v2[2])
                push!(cr, (Point2f(x, y), r))
            end
        end
    end
    cr
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

# Zeichnet alle Kreise der Blume des Lebens (optional per Ring einfärben, Umriss zeichnen, partielle Bögen)
draw_flower!(ax; radius::Real, center::Point2f, rings::Int=2, linewidth::Real=2.5, color=colorant"rgba(0, 0, 0, 0.8)", rotation::Real=0, method::Symbol=:arc,
             ring_colors::Union{Nothing,Vector}=nothing, ring_linewidths::Union{Nothing,Vector}=nothing,
             outline::Bool=false, outline_linewidth::Real=linewidth*1.4, outline_color=color,
             ring_mask::Union{Nothing,Vector{Bool}}=nothing,
             arc_fraction::Real=1.0, arc_phase::Real=0.0, arc_repeat::Union{Nothing,Int}=nothing) = begin
    cr = flower_centers_with_rings(radius, center; rings=rings, rotation=rotation)
    for (c, r) in cr
        if ring_mask !== nothing
            if length(ring_mask) < r+1 || !ring_mask[r+1]
                continue
            end
        end
        col = (ring_colors === nothing || length(ring_colors) < r+1) ? color : ring_colors[r+1]
        lw  = (ring_linewidths === nothing || length(ring_linewidths) < r+1) ? linewidth : ring_linewidths[r+1]
        if method === :arc
            if arc_fraction >= 0.9999
                arc!(ax, c, radius, 0, 2π; color=col, linewidth=lw, linecap=:round, joinstyle=:round, resolution=720)
            else
                seg_len = 2π * arc_fraction
                if arc_repeat === nothing
                    arc!(ax, c, radius, arc_phase, arc_phase + seg_len; color=col, linewidth=lw, linecap=:round, joinstyle=:round, resolution=720)
                else
                    for j in 0:arc_repeat-1
                        ϕ = arc_phase + j * (2π / arc_repeat)
                        arc!(ax, c, radius, ϕ, ϕ + seg_len; color=col, linewidth=lw, linecap=:round, joinstyle=:round, resolution=720)
                    end
                end
            end
        else
            poly!(ax, Circle(c, radius); color=:transparent, strokecolor=col, strokewidth=lw, linecap=:round, joinstyle=:round)
        end
    end
    if outline
        R = (rings + 1) * radius
        if method === :arc
            arc!(ax, center, R, 0, 2π; color=outline_color, linewidth=outline_linewidth, linecap=:round, joinstyle=:round, resolution=720)
        else
            poly!(ax, Circle(center, R); color=:transparent, strokecolor=outline_color, strokewidth=outline_linewidth, linecap=:round, joinstyle=:round)
        end
    end
    ax
end

# Figure für Blume des Lebens
flower_figure(radius::Real; center::Point2f=Point2f(0,0), rings::Int=2, linewidth::Real=2.5, color=colorant"rgba(0, 0, 0, 0.8)", background=:white, rotation::Real=0, pad_ratio::Real=0.1, method::Symbol=:arc,
              ring_colors::Union{Nothing,Vector}=nothing, ring_linewidths::Union{Nothing,Vector}=nothing,
              outline::Bool=false, outline_linewidth::Real=linewidth*1.4, outline_color=color,
              ring_mask::Union{Nothing,Vector{Bool}}=nothing,
              arc_fraction::Real=1.0, arc_phase::Real=0.0, arc_repeat::Union{Nothing,Int}=nothing) = begin
    # Größe heuristisch abhängig von rings
    sizepx = (Int(round(4 * radius * (rings + 1))), Int(round(4 * radius * (rings + 1))))
    f = Figure(size=sizepx, backgroundcolor=background)
    cs = flower_centers(radius, center; rings=rings, rotation=rotation)
    ax = Axis(f[1, 1]; aspect=DataAspect(), limits=flower_limits(radius, cs; pad_ratio=pad_ratio))
    hidedecorations!(ax); hidespines!(ax)
    draw_flower!(ax; radius=radius, center=center, rings=rings, linewidth=linewidth, color=color, rotation=rotation, method=method,
                 ring_colors=ring_colors, ring_linewidths=ring_linewidths, outline=outline, outline_linewidth=outline_linewidth, outline_color=outline_color,
                 ring_mask=ring_mask, arc_fraction=arc_fraction, arc_phase=arc_phase, arc_repeat=arc_repeat)
    (f, ax)
end

# SVG-Export
flower_svg(path::AbstractString, radius::Real; center::Point2f=Point2f(0,0), rings::Int=2, linewidth::Real=2.5, color=colorant"rgba(0, 0, 0, 0.8)", background=:white, rotation::Real=0, pad_ratio::Real=0.1, method::Symbol=:arc, scale::Real=1,
           ring_colors::Union{Nothing,Vector}=nothing, ring_linewidths::Union{Nothing,Vector}=nothing,
           outline::Bool=false, outline_linewidth::Real=linewidth*1.4, outline_color=color,
           ring_mask::Union{Nothing,Vector{Bool}}=nothing,
           arc_fraction::Real=1.0, arc_phase::Real=0.0, arc_repeat::Union{Nothing,Int}=nothing) = begin
    sizepx = (Int(round(scale * 4 * radius * (rings + 1))), Int(round(scale * 4 * radius * (rings + 1))))
    f = Figure(size=sizepx, backgroundcolor=background)
    cs = flower_centers(radius, center; rings=rings, rotation=rotation)
    ax = Axis(f[1, 1]; aspect=DataAspect(), limits=flower_limits(radius, cs; pad_ratio=pad_ratio))
    hidedecorations!(ax); hidespines!(ax)
    draw_flower!(ax; radius=radius, center=center, rings=rings, linewidth=linewidth, color=color, rotation=rotation, method=method,
                 ring_colors=ring_colors, ring_linewidths=ring_linewidths, outline=outline, outline_linewidth=outline_linewidth, outline_color=outline_color,
                 ring_mask=ring_mask, arc_fraction=arc_fraction, arc_phase=arc_phase, arc_repeat=arc_repeat)
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



flower_svg(
    output_file, radius;
    center=Point2f(0,0), rings=rings, linewidth=linewidth,
    color=colorant"rgba(0, 0, 0, 0.8)", background=:white,
    rotation=rotation_rad, pad_ratio=0.1, method=:arc,
    outline=true, outline_linewidth=linewidth*1.6, outline_color=colorant"black",
    ring_colors=[colorant"black", colorant"black", colorant"black"],   # Ring 0..2
    ring_linewidths=[linewidth*1.2, linewidth, linewidth]
)
println("Grafik wurde erfolgreich als '$filename' gespeichert.")

# Zweite Ausgabe: erweitertes Feld (mehr Ringe, ohne äußeren Umriss)
rings_field = 6  # Passe nach Geschmack an (z.B. 5..8)
filename_field = "feld_blume_des_lebens.svg"
output_field_file = joinpath(@__DIR__, filename_field)

flower_svg(
    output_field_file, radius;
    center=Point2f(0,0), rings=rings_field, linewidth=linewidth,
    color=colorant"rgba(0, 0, 0, 0.8)", background=:white,
    rotation=rotation_rad, pad_ratio=0.08, method=:arc,
    outline=false
)
println("Grafik wurde erfolgreich als '$filename_field' gespeichert.")

# Dritte Ausgabe: Sechstel-Bögen (petal-artiges Muster), ohne Umriss
rings_petals = 6
filename_petals = "feld_sechstel_blaetter.svg"
output_petals_file = joinpath(@__DIR__, filename_petals)

flower_svg(
    output_petals_file, radius;
    center=Point2f(0,0), rings=rings_petals, linewidth=linewidth,
    color=colorant"rgba(0, 0, 0, 0.85)", background=:white,
    rotation=rotation_rad, pad_ratio=0.08, method=:arc,
    outline=false,
    arc_fraction=1/6, arc_repeat=6, arc_phase=0.0
)
println("Grafik wurde erfolgreich als '$filename_petals' gespeichert.")