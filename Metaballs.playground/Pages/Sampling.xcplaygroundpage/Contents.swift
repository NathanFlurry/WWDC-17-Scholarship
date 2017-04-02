//: [Previous](@previous)

/*:
 # Sampling
 
 Mataballs are just points. Sampled around the points.
 */

import UIKit

// Create a view; our extension handles the generation of the view, ball generation, and live view setup
var view = MetaballView2D.generate(downsample: 16, threshold: 1) { view, context in
    
    context.setFillColor(UIColor.white.cgColor)
    view.drawGrid(context: context, useAlpha: true)
    
    context.setFillColor(UIColor.green.cgColor)
    view.drawGrid(context: context, padding: 4)
    
    context.setStrokeColor(UIColor.red.cgColor)
    context.setLineWidth(1)
    view.drawCircles(context: context)
}