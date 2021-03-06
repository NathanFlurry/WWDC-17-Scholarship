/*:
 # Marching Squares
 
 The marching squares algorithm is commonly used in computer programs to generate outlines for a given set of samples. In other words, given a rough shape in samples, the marching squares algorithm will generate a smooth outline. Similar to the metaballs algorithm, it works in any number of dimensions, but it is easiest to demonstrate in just two.
 
 The first thing this algorithm does when given a set of samples is classifies each sample based on the values of surrounding samples. These classifications indicate what type of line to draw, wether it's a diagonal line, a horizontal line, etc. here are all 16 classifications for two dimensions:
 
 ![Classifications](../Resources/MarchingSquares.png "Source: Polytech")
 
 Try tapping and dragging the squares on the right to see the way the marching squares algorithm smooths out the shape. Observe how the patterns in the interactive view correspond to the lines in the diagram above.
 
 ---
 However, when using the metaballs algorithm, a field of scalar samples are created with a value of 0 to 1, depending on how close the surrounding metaballs are. The metaballs algorithm can also use these values in order to morph between different classifications to create even smoother contours. While not demonstrated in the view on the right, this can be seen in any of the other full metaball demonstrations.
 
 ---
 Marching squares are also used in many other fields, such as drawing contour lines on elevation maps, smoothing out 3D scans, and procedural terrain generation. Read more about the marching squares algorithm [here](https://en.wikipedia.org/wiki/Marching_squares).
 
 ---
 [◀ Sampling](@previous) • [Example: Loading indicators ▶](@next)
 */

import UIKit

// Create a view
let view = MarchingSquaresView2D(frame: simulationSize)

// Set up the system
let system = view.system
system.resolution = 1 / 16

// Fill the center of the system with a circle
let center = CGPoint(
    x: CGFloat(system.width) / 2,
    y: CGFloat(system.height) / 2
)
for (i, sample) in system.samples.enumerated() {
    let position = system.point(forIndex: i)
    if sqrt(pow(position.x - center.x, 2) + pow(position.y - center.y, 2)) < 80 {
        sample.sample = system.threshold * 2
        sample.aboveThreshold = true
    }
}

// Present the view
present(view: view)
