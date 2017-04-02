/*:
 # Overview
 
 ## What are metaballs?
 ...
 
 ## What will be covered?
 
 
 ## Simulation usage
 * Tap to create new metaballs
 * Drag to move metaballs
 * Double tap to remove metaballs
 */

import UIKit

// Create a view; our extension handles the generation of the view, ball generation, and live view setup
var view = MetaballView2D.generate() { view, context in
    UIColor.white.setFill()
    UIColor.red.setStroke()
    context.setLineWidth(2)
    view.drawCellsPath(context: context)
//    view.drawCells(context: context, interpolate: true)
}
