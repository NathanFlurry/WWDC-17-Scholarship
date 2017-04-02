import UIKit

public class MarchingSquaresView2D: UIView {
    public let system: MarchingSquaresEngine2D = MarchingSquaresEngine2D()
    
    override public var bounds: CGRect {
        didSet {
            system.width = Int(bounds.width)
            system.height = Int(bounds.height)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set the size
        system.width = Int(bounds.width)
        system.height = Int(bounds.height)
        
        // Fill the center
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
        
        // Calculate the size for each cell
//        let width = bounds.width / CGFloat(system.width) / CGFloat(system.resolution)
//        let height = bounds.height / CGFloat(system.height) / CGFloat(system.resolution)
        
        // Draw a square for each cell
        context.setFillColor(UIColor.white.cgColor)
        let ellipseSize: CGFloat = 8
        for (i, sample) in system.samples.enumerated() {
            let position = system.point(forIndex: i)
            
            // Fill the rect
            if sample.aboveThreshold {
                context.fillEllipse(in:
                    CGRect(
                        x: position.x - ellipseSize / 2, y: position.y - ellipseSize / 2,
                        width: ellipseSize, height: ellipseSize
                    )
                )
            }
        }
        
        // Draw the lines
        UIColor.red.setStroke()
        context.setLineWidth(2)
        let lines = system.calculateLines()
        for line in lines {
            context.strokeLineSegments(between: [line.a, line.b])
        }
    }
    
    // MARK: Interaction
    var touchStates = [UITouch: Bool]() // [Touch: Is turning on]
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            // Find the state of the touched cell and determine wether to paint or erase
            let (row, col) = indexForPoint(point: location)
            let squareIndex = row * system.cols + col
            let state = !system.samples[squareIndex].aboveThreshold
            touchStates[touch] = state
            
            // Set the square
            setSquare(at: location, value: state)
        }
        
        setNeedsDisplay()
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            // Set the square
            if let state = touchStates[touch] {
                setSquare(at: location, value: state)
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
    
    func indexForPoint(point: CGPoint) -> MarchingSquaresEngine2D.Index {
        // Get the size of each cell
        let width = bounds.width / CGFloat(system.width) / CGFloat(system.resolution)
        let height = bounds.height / CGFloat(system.height) / CGFloat(system.resolution)
        
        // Get the position where it was touched and clamp it; subtract half width so it's an accurate position
        return (
            row: clamp(row: Int((point.y + height / 2) / height)),
            col: clamp(col: Int((point.x + width / 2) / width))
        )
    }
    
    func setSquare(at location: CGPoint, value: Bool) {
        // Set the sample to either on or off
        setSquare(at: indexForPoint(point: location), value: value)
    }
    
    private func setSquare(at index: MarchingSquaresEngine2D.Index, value: Bool, branch: Bool = false) {
        // Set the square
        let squareIndex = clamp(row: index.row) * system.cols + clamp(col: index.col)
        system.samples[squareIndex].sample = value ? system.threshold * 2 : 0
        
        // Set the branching values
        if !branch {
            setSquare(at: (index.row - 1, index.col), value: value, branch: true)
            setSquare(at: (index.row + 1, index.col), value: value, branch: true)
            setSquare(at: (index.row, index.col - 1), value: value, branch: true)
            setSquare(at: (index.row, index.col + 1), value: value, branch: true)
        }
    }
    
    private func clamp(row: Int) -> Int {
        return min(max(row, 0), system.rows - 1)
    }
    
    private func clamp(col: Int) -> Int {
        return min(max(col, 0), system.cols - 1)
    }
}
