import CoreGraphics

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
