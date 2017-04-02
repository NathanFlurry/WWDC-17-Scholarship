//: [Previous](@previous)

/*:
 # Marching Squares
 
 < make sure to talk about interpolation too >
 
 ## Instructions
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

//: [Next](@next)