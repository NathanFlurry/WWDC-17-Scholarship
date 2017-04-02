/*:
 # Overview
 
 ## What are metaballs?
 Metaballs are shapes which are used to create organic-looking simulations. Like many other algorithms, metaballs can be expanded into infinite dimentions; however, for the purpose of simplicity, this playground will simply use 2-dimentional metaballs.
 
 ## Simulation usage
 Every simulation in this playground is interactive. For the playgrounds demonstrating metaballs, you can interact with it in these ways:
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
