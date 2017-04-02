//: [Previous](@previous)

/*:
 # Marching Squares
 
 < make sure to talk about interpolation too >
 
 ## Instructions
 */

// Create a view
let view = MarchingSquaresView2D(frame: simulationSize)

// Set up the system
let system = view.system
system.resolution = 1 / 16

// Present the view
present(view: view)

//: [Next](@next)
