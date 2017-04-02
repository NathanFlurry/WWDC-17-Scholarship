import UIKit

public class MetaballView2D: UIView { // TODO: Be able to configure colors
    public typealias DrawBlock = (_ view: MetaballView2D, _ context: CGContext) -> Void
    
    public let system: MetaballSystem2D = MetaballSystem2D()
    public var drawBlock: DrawBlock? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override public var bounds: CGRect {
        didSet {
            system.width = Int(bounds.width)
            system.height = Int(bounds.height)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        system.width = Int(bounds.width)
        system.height = Int(bounds.height)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Drawing
    override public func draw(_ rect: CGRect) {
        // Get the current context
        guard let context = UIGraphicsGetCurrentContext() else {
            print("Could not get context.")
            return
        }
        
        // Do the calculations required for everything else
        system.calculateSamples()
        system.calculateClassifications()
        
        // Clear the context
        context.clear(rect)
        
        // Draw the rest
        drawBlock?(self, context)
    }
    
    public func drawCircles(context: CGContext) {
        for ball in system.balls {
            context.strokeEllipse(in:
                CGRect(
                    x: ball.position.x - ball.radius, y: ball.position.y - ball.radius,
                    width: ball.radius * 2, height: ball.radius * 2
                )
            )
        }
    }
    
    public func drawPoints(context: CGContext) { // Just like the grid, but the points at every corner
        // Draw a dot at each point to indicate the sample
        for (i, sample) in system.samples.enumerated() {
            let position = system.point(forIndex: i)
            if sample.aboveThreshold {
                context.fill(
                    CGRect(
                        x: position.x - 1, y: position.y - 1,
                        width: 10, height: 10
                    )
                )
            }
        }
    }
    
    public func drawValues(context: CGContext) {
        // Draw text at every sample
        for (i, _) in system.samples.enumerated() {
            let position = system.point(forIndex: i)
            
            ("Hi" as NSString).draw(at: position, withAttributes: nil)
        }
    }
    
    public func drawGrid(context: CGContext, padding: CGFloat = 0, useAlpha: Bool = false, alphaAttack attack: CGFloat = 1) {
        // Calculate the size for each cell
        let width = bounds.width / CGFloat(system.width) / CGFloat(system.resolution)
        let height = bounds.height / CGFloat(system.height) / CGFloat(system.resolution)
        
        // Draw a square for each cell
        context.saveGState()
        for (i, sample) in system.samples.enumerated() {
            let position = system.point(forIndex: i)
            let rect = CGRect(
                x: position.x - width / 2 + padding, y: position.y - height / 2 + padding,
                width: width - padding * 2, height: height - padding * 2
            )
            
            // Set alpha either as a varying value or threshold
            if useAlpha {
                context.setAlpha(pow(sample.sample / system.threshold, attack))
            } else {
                context.setAlpha(sample.aboveThreshold ? 1 : 0)
            }
            
            // Fill the rect
            context.fill(rect)
        }
        context.restoreGState()
    }
    
    public func drawCells(context: CGContext, interpolate: Bool) { // Draws the metaballs using marching squares
        let lines = system.calculateLines()
        for line in lines {
            context.strokeLineSegments(between: [line.a, line.b])
        }
    }
    
    public func drawCellsPath(context: CGContext) {
        let path = system.renderPath()
        context.addPath(path)
        context.fillPath()
        context.strokePath()
    }
    
    // MARK: Interaction
    var touchStates = [UITouch: Int]() // [Touch: Ball index]
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            // Find the ball that was touched
            var ballIndex = -1
            for (i, ball) in system.balls.enumerated() {
                if sqrt(pow(ball.position.x - location.x, 2) + pow(ball.position.y - location.y, 2)) < ball.radius {
                    ballIndex = i
                    break
                }
            }
            
            // If no ball, create new ball
            if ballIndex == -1 {
                let ball = Metaball2D(position: location, radius: CGFloat.random * 10 + 30)
                system.balls.append(ball)
                ballIndex = system.balls.count - 1
            }
            
            if touch.tapCount >= 2 {
                // Delete the ball
                touchStates[touch] = nil
                system.balls.remove(at: ballIndex)
            } else {
                // Set the ball index being tapped
                touchStates[touch] = ballIndex
            }
        }
        
        setNeedsDisplay()
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            if let ballIndex = touchStates[touch] {
                system.balls[ballIndex].position = location
            }
        }
        
        setNeedsDisplay()
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchStates[touch] = nil
        }
        
        setNeedsDisplay()
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchStates[touch] = nil
        }
        
        setNeedsDisplay()
    }
}
