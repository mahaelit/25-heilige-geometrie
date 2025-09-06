using Luxor
using Colors

const RADIUS = 100
const LINE_WIDTH = 2.5
const FILENAME = "saat_des_lebens.svg"
const OUTPUT_FILE = joinpath(@__DIR__, FILENAME)
const CANVAS_SIZE = (4 * RADIUS, 4 * RADIUS)
const CENTER_POINT = Point(0, 0)

function draw_seed_of_life(radius::Real, center::Point)
    circle(center, radius, :stroke)
    for k in 0:5
        c = center + polar(radius, k * 2π / 6)
        circle(c, radius, :stroke)
    end
end


Drawing(CANVAS_SIZE..., OUTPUT_FILE)
origin()
background("white")
sethue(colorant"rgba(0, 0, 0, 0.8)")
setline(LINE_WIDTH)
draw_seed_of_life(RADIUS, CENTER_POINT)
finish()
println("Grafik wurde erfolgreich als '$FILENAME' gespeichert.")

