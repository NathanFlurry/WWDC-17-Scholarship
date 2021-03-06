import Foundation
import SpriteKit

public class MetaballFluidsScene2D: SKScene {
    var waterShape: SKShapeNode = SKShapeNode()
    var waterDrops: [SKNode] = []
    var system: MetaballSystem2D
    var dropSize: CGFloat = 10
    
    public override var size: CGSize {
        didSet {
            system.width = Int(size.width)
            system.height = Int(size.height)
        }
    }
    
    public override init(size: CGSize) {
        system = MetaballSystem2D()
        system.width = Int(size.width)
        system.height = Int(size.height)
        
        super.init(size: size)
        
        // Create the scene
        scaleMode = .resizeFill
        backgroundColor = UIColor.independence
        
        // Set up the system
        system.resolution = 1 / 4
        
        // Set up the shape node
        waterShape.lineWidth = 0
        waterShape.fillColor = UIColor.turquoise
        addChild(waterShape)
    }
    
    public convenience init(size: CGSize, dropSize: CGFloat) {
        self.init(size: size)
        
        self.dropSize = dropSize
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func didSimulatePhysics() {
        super.didSimulatePhysics()
        
        // Check if need to remove balls
        for i in (0..<waterDrops.count).reversed() {
            let drop = waterDrops[i]
            if
                drop.position.x < -dropSize || drop.position.x > size.width + dropSize ||
                drop.position.y < -dropSize || drop.position.y > size.height + dropSize
            {
                drop.removeFromParent()
                waterDrops.remove(at: i)
            }
        }
        
        // Generate the metaballs
        system.balls = waterDrops.map {
            return Metaball2D(position: $0.position, radius: dropSize)
        }
        system.calculateSamples()
        system.calculateClassifications()
        waterShape.path = system.renderPath()
    }
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: scene!)
            addDrop(location: location)
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: scene!)
            addDrop(location: location)
        }
    }
    
    private func addDrop(location: CGPoint) {
//        let node = SKShapeNode(circleOfRadius: 5)
        let node = SKNode()
        node.physicsBody = SKPhysicsBody(circleOfRadius: dropSize)
        node.physicsBody?.angularDamping = 0
        node.position = location
        scene?.addChild(node)
        waterDrops.append(node)
    }
}

