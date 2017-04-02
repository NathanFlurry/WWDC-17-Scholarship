//: [Previous](@previous)

/*:
 # Sampling
 
 Mataballs are just points. Sampled around the points.
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
}

// Set up the system
let system = view.system
system.resolution = 1 / 16
system.generateMetaballs(count: 6, minSize: 30, maxSize: 40)

// Present the view
present(view: view)