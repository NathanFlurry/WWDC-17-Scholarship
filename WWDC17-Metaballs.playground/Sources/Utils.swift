import CoreGraphics

extension CGFloat {
    public static var random: CGFloat {
        return CGFloat(Float(arc4random()) / Float(UInt32.max))
    }
}
