/*:
 # Overview
 
 ## What are metaballs?
 ...
 
 ## What will be covered?
 
 ## Technologies
 
 ## Simulation usage
 * Tap to create new metaballs
 * Drag to move metaballs
 * Double tap to remove metaballs
 */

import UIKit

// Create a view
let view = MetaballViewMovable2D(frame: simulationSize)
view.drawBlock = { view, context in
    UIColor.white.setFill()
    view.drawCellsPath(context: context)
}

// Set up the system
let system = view.system
system.resolution = 1 / 4
system.generateMetaballs(count: 6, minSize: 30, maxSize: 40)

// Present the view
present(view: view)
