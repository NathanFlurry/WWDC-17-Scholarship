/*:
 # Sampling
 
 The most important part of simulating metaballs is the sampling. Basic metaball sampling consists of three parts:
 
 * The metaballs
    * Position
    * Radius/intensity
 * The threshold
 
 Traditionally, one can determine if a point is in a circle by using the formula:
 
 ![Equation](../Resources/Circle.png)
 
 This equation can be rearranged to be used in code like so:
 
 ![Equation](../Resources/Reorganized.png)
 
 However, we want the metaballs to "blend" together. Therefore, if two circles are close to a single sample (even if either circle is not covering the point), we still want the cell to be active. In order to produce this effect, we can utilize this equation to find the sum for all surrounding metaballs:
 
 ![Equation](../Resources/Summation.png)
 
 Notice how the threshold can be manipulated in order to increase or decrease how much of the metaballs are shown.
 
 ---
 In the figure on the right, you can see each metaball indicated by the circle outlines, where the circle's radius is also the metaball's intensity. Additionally, each dark square in the background represents a single sample and the opacity of the square shows its scalar value, based on how close the surrounding metaballs are. When a square's intensity passes the threshold, the cell is active, as indicated by the turquoise dots. The transparent, turquoise "blobs" represent the final metaball path that is generated from the samples. Notice how it loosely represents the cells above the threshold.
 
 ---
 [◀ Overview](@previous) • [Marching Squares ▶](@next)
 */

import UIKit

// Create a view
let view = MetaballViewMovable2D(frame: simulationSize)
view.drawBlock = { view, context in
    UIColor.corsilk.setFill()
    context.fill(view.bounds)
    
    UIColor.spanishGray.setFill()
    view.drawGrid(context: context, padding: 0, useAlpha: true)
    
    UIColor.turquoise.setFill()
    view.drawGrid(context: context, padding: 4)
    
    context.setLineWidth(2)
    UIColor.appricot.setStroke()
    view.drawCircles(context: context)
    
    UIColor.turquoise.withAlphaComponent(0.3).setFill()
    view.drawCellsPath(context: context)
}

// Set up the system
let system = view.system
system.threshold = 1 // Try increaseing or decreasing this
system.resolution = 1 / 16
system.generateMetaballs(count: 6, minSize: 30, maxSize: 40)

// Present the view
present(view: view)
