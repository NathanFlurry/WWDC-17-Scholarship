import Foundation
import CoreGraphics

public class MetaballSystem2D: MarchingSquaresEngine2D {
    public typealias Index = (row: Int, col: Int)
    public typealias PointPair = (a: CGPoint, b: CGPoint)
    
    /* Parameters */
    public var balls: [Metaball2D] = []
    
    // Calculates the values in the grid
    public override func calculateSamples() {
        // Sample the metaballs
        for (i, sample) in samples.enumerated() {
            let position = point(forIndex: i)
            
            // Update the sample
            sample.sample = calculateSample(position: position)
        }
        
        super.calculateSamples()
    }
    
    // Calculates the value at a point based off of the metaballs
    public func calculateSample(position: CGPoint) -> CGFloat {
        var sum: CGFloat = 0
        
        for ball in balls {
            let dx = position.x - ball.position.x
            let dy = position.y - ball.position.y
            
            let d2 = dx * dx + dy * dy
            sum += ball.radius2 / d2
        }
        
        return sum
    }
    
    private func distance(a: CGPoint, b: CGPoint) -> CGFloat {
        return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2))
    }
}
