//: [Previous](@previous)
/*:
 # Fluid Simulation
 
 One of the most common uses of metaballs in games are for simulating fluids. In this simulation, the SpriteKit physics engine is being used in conjunction with the metaballs engine to render a fluid-like path into a `SKShapeNode`
 
 Try dragging your finger around the screen to spawn fluid particles. You can also try modifying the code below to create new obstacles and alter how large the water particles are.
 
 */

import SpriteKit

// Create the scene
let scene = MetaballFluidsScene2D(size: simulationSize.size, dropSize: 7.5)

// Add floor
let floorSize = CGSize(width: scene.size.width - 8, height: 16)
let floor = SKShapeNode(rectOf: floorSize, cornerRadius: 2)
floor.position = CGPoint(x: scene.size.width / 2, y: 12)

floor.lineWidth = 0
floor.fillColor = UIColor.white

floor.physicsBody = SKPhysicsBody(rectangleOf: floorSize)
floor.physicsBody?.isDynamic = false

scene.addChild(floor)

// Add random circles
for i in 0..<4 {
    let radius = CGFloat.random * 35 + 5
    let circle = SKShapeNode(circleOfRadius: radius)
    circle.position = CGPoint(x: CGFloat.random * scene.size.width, y: CGFloat.random * scene.size.height)
    
    circle.lineWidth = 0
    circle.fillColor = UIColor.white
    
    circle.physicsBody = SKPhysicsBody(circleOfRadius: radius)
    circle.physicsBody?.isDynamic = false
    
    scene.addChild(circle)
}

// Add random squares
for i in 0..<4 {
    let size = CGFloat.random * 35 + 5
    let square = SKShapeNode(rectOf: CGSize(width: size, height: size))
    square.position = CGPoint(x: CGFloat.random * scene.size.width, y: CGFloat.random * scene.size.height)
    square.zRotation = CGFloat.random * CGFloat.pi * 2
    
    square.lineWidth = 0
    square.fillColor = UIColor.white
    
    square.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size, height: size))
    square.physicsBody?.isDynamic = false
    
    scene.addChild(square)
}

// Create the view
let view = SKView(frame: simulationSize)
view.presentScene(scene)

present(view: view)


//: [Next](@next)
