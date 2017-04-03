import PlaygroundSupport
import UIKit

extension CGFloat {
    public static var random: CGFloat {
        return CGFloat(Float(arc4random()) / Float(UInt32.max))
    }
    
    public static func lerp(_ x0: CGFloat, _ x1: CGFloat, _ y0: CGFloat, _ y1: CGFloat, _ x: CGFloat) -> CGFloat {
        if x0 == x1 {
//            print("x0 == x1")
            return 0
        }
        
        return y0 + (y1 - y0) * (x - x0) / (x1 - x0);
    }
}

public let simulationSize = CGRect(x: 0, y: 0, width: 320, height: 320)

public func present(view: UIView) {
    // Set up the page
    let page = PlaygroundPage.current
    page.needsIndefiniteExecution = true
    page.liveView = view
    
    // Tell it to render
    view.setNeedsDisplay()
}

extension MetaballSystem2D {
    public func generateMetaballs(count: Int, minSize: CGFloat, maxSize: CGFloat) {
        for _ in 0..<count {
            let ball = Metaball2D(
                position:
                CGPoint(
                    x: CGFloat.random * CGFloat(width),
                    y: CGFloat.random * CGFloat(height)
                ),
                radius: CGFloat.random * (maxSize - minSize) + minSize
            )
            balls.append(ball)
        }
    }
}

extension UIColor { // Source: https://coolors.co/ffd4b3-abf5e6-fff7de-574d68-8f9491
    public static let appricot = UIColor(red: 1, green: 0.831, blue: 0.701, alpha: 1)
    public static let turquoise = UIColor(red: 0.670, green: 0.960, blue: 0.901, alpha: 1)
    public static let corsilk = UIColor(red: 1, green: 0.968, blue: 0.870, alpha: 1)
    public static let independence = UIColor(red: 0.341, green: 0.301, blue: 0.407, alpha: 1)
    public static let spanishGray = UIColor(red: 0.560, green: 0.580, blue: 0.568, alpha: 1)
}
