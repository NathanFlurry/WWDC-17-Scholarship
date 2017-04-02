import PlaygroundSupport
import UIKit

extension CGFloat {
    public static var random: CGFloat {
        return CGFloat(Float(arc4random()) / Float(UInt32.max))
    }
    
    public static func lerp(_ x0: CGFloat, _ x1: CGFloat, _ y0: CGFloat, _ y1: CGFloat, _ x: CGFloat) -> CGFloat {
        if x0 == x1 {
            print("x0 == x1")
            return 0
        }
        
        return y0 + (y1 - y0) * (x - x0) / (x1 - x0);
    }
}

extension MetaballView2D {
    public static func generate(resolution: CGFloat = 1 / 4, drawBlock: @escaping MetaballView2D.DrawBlock) {
        // Create a view
        let view = MetaballView2D(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        
        // Set up the system
        let system = view.system
        system.resolution = resolution
        
        // Generate random balls
        for _ in 0..<10 {
            let ball = Metaball2D(
                position:
                CGPoint(
                    x: CGFloat.random * CGFloat(system.width),
                    y: CGFloat.random * CGFloat(system.height)
                ),
                radius: 20
            )
            system.balls.append(ball)
        }
        
        // Set the block
        view.drawBlock = drawBlock
        
        // Set up the page
        let page = PlaygroundPage.current
        page.needsIndefiniteExecution = true
        page.liveView = view
    }
}
