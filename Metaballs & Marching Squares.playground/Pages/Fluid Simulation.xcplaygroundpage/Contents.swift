//: [Previous](@previous)

import SpriteKit

class MetaballSpriteKitScene: SKView {
    let metaballOverlay: MetaballView2D
    var waterDrops: [SKNode] = []
    
    override init(frame: CGRect) {
        metaballOverlay = MetaballView2D(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        
        super.init(frame: frame)
        
        // Create the scene
        let scene = SKScene(size: frame.size)
        scene.scaleMode = .resizeFill
        scene.backgroundColor = UIColor.blue
        presentScene(scene)
        
        // Setup the metaballs
        metaballOverlay.frame = bounds
        metaballOverlay.backgroundColor = UIColor.clear
        metaballOverlay.drawBlock = { view, context in
            UIColor.white.setFill()
            view.drawCellsPath(context: context)
        }
        addSubview(metaballOverlay)
        
        let system = metaballOverlay.system
        system.resolution = 1 / 4
        system.generateMetaballs(count: 6, minSize: 30, maxSize: 45)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        metaballOverlay.frame = bounds
        metaballOverlay.setNeedsDisplay()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            addDrop(location: location)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            addDrop(location: location)
        }
    }
    
    private func addDrop(location: CGPoint) {
        let node = SKShapeNode(circleOfRadius: 5)
        node.position = location
        scene?.addChild(node)
        waterDrops.append(node)
    }
}

let view = MetaballSpriteKitScene(frame: simulationSize)

present(view: view)


//: [Next](@next)
