import UIKit

public class MetaballViewMovable2D: MetaballView2D {
    // The index of the ball that each touch is holding
    var touchStates = [UITouch: Int]()
    
    // The min and max ball size
    public var minBallSize: CGFloat = 30
    public var maxBallSize: CGFloat = 40
    
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
                let ball = Metaball2D(
                    position: location, 
                    radius: CGFloat.random * (maxBallSize - minBallSize) + minBallSize
                )
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
