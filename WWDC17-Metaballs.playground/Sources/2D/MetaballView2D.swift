import UIKit

public class MetaballView2D: UIView { // TODO: Be able to configure colors
    public typealias DrawBlock = (_ view: MetaballView2D, _ context: CGContext) -> Void
    
    public let system: MetaballSystem2D = MetaballSystem2D()
    public var drawBlock: DrawBlock?
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        // Set the size of the system
        system.width = Int(bounds.width)
        system.height = Int(bounds.height)
    }
    
    override public func draw(_ rect: CGRect) {
        // Get the current context
        guard let context = UIGraphicsGetCurrentContext() else {
            print("Could not get context.")
            return
        }
        
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
    
    public func drawValues(context: CGContext) {
//        ("Hello, world" as NSString).draw(at: <#T##CGPoint#>, withAttributes: <#T##[String : Any]?#>) // http://stackoverflow.com/questions/7251065/iphone-draw-white-text-on-black-view-using-cgcontext
    }
    
    public func drawGrid(context: CGContext) { // Use the system's resolution + threshold
        
    }
    
    public func drawPoints(context: CGContext) { // Just like the grid, but the points at every corner
        
    }
    
    public func drawCells(context: CGContext, interpolate: Bool) { // Draws the metaballs using marching squares
        system.calculateSamples()
        system.calculateClassifications()
        let lines = system.calculateLines()
        for line in lines {
            context.strokeLineSegments(between: [line.a, line.b])
        }
    }
}
