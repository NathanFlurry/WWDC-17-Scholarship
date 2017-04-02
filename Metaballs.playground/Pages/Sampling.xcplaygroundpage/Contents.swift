//: [Previous](@previous)

/*:
 # Sampling
 
 Mataballs are just points. Sampled around the points.
 */

import UIKit

// Create a view
var view = MetaballView2D.generate(downsample: 16, threshold: 1) { view, context in
    
    UIColor.white.setFill()
    view.drawGrid(context: context, padding: 1, useAlpha: true)
    
    UIColor.green.setFill()
    view.drawGrid(context: context, padding: 4)
    
    context.setLineWidth(2)
    UIColor.red.setStroke()
    view.drawCircles(context: context)
}