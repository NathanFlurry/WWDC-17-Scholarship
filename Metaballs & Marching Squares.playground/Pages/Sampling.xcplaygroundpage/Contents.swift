//: [Previous](@previous)

/*:
 # Sampling
 
 The most important part of simulating metaballs is the sampling. Basic metaball sampling consists of three parts:
 
 * The metaballs
 * Position
 * Radius/intensity
 * The threshold
 
 Traditionally, one can determine if a point is in a circle by using the formula:
 
 (x−x0)2+(y−y0)2 <= r2
 
 This equation can be rearranged to be used in code like so:
 
 r2(x−x0)2+(y−y0)2 ≥ 1
 
 However, we want the metaballs to "blend" together. Therefore, if two circles are close to a single sample but not covering it, we still want the cell to be active. In order to produce this effect, we can utilize this equation to find the sum for all surrounding metaballs, like this:
 
 ∑i=0nr2i(x−xi)2+(y−yi)2 ≥ threshold
 
 Notice how the threshold can be manipulated in order to increase or decrese how much of the metaballs are shown.
 
 In the figure on the right, you can see each metaball indicated by the red circles, where the circle's radius is also the metaball's intensity. Additionally, each which square represents a single sample and the opacity of the square shows its intensity. When a square's intensity passes the threshold, the cell is active, as indicated by the green dots. The blue "blobs" represent the final metaball path that is generated.
 */

import UIKit

// Create a view
let view = MetaballViewMovable2D(frame: simulationSize)
view.drawBlock = { view, context in
    UIColor.white.setFill()
    view.drawGrid(context: context, padding: 1, useAlpha: true)
    
    UIColor.green.setFill()
    view.drawGrid(context: context, padding: 4)
    
    context.setLineWidth(2)
    UIColor.red.setStroke()
    view.drawCircles(context: context)
    
    UIColor.blue.withAlphaComponent(0.3).setFill()
    view.drawCellsPath(context: context)
}

// Set up the system
let system = view.system
system.threshold = 1 // Try increaseing or decreasing this
system.resolution = 1 / 16
system.generateMetaballs(count: 6, minSize: 30, maxSize: 40)

// Present the view
present(view: view)
