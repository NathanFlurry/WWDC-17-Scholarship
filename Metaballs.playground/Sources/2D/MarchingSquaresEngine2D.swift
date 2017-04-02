import Foundation
import CoreGraphics

/**
 * Maps from 0-15 cell classification to compass points indicating a sequence of
 * corners to visit to form a polygon based on the pmapping described on
 * http://en.wikipedia.org/wiki/Marching_squares
 */
let classificationToPolyCorners = [
    // ..
    // ..
    [],
    
    // ..
    // #.
    ["W", "S"],
    
    // ..
    // .#
    ["E", "S"],
    
    // ..
    // ##
    ["W", "E"],
    
    // .#
    // ..
    ["N", "E"],
    
    // .#
    // #.
    ["N", "W", "S", "E"],
    
    // .#
    // .#
    ["N", "S"],
    
    // .#
    // ##
    ["N", "W"],
    
    // #.
    // ..
    ["N", "W"],
    
    // #.
    // #.
    ["N", "S"],
    
    // #.
    // .#
    ["N", "E", "S", "W"],
    
    // #.
    // ##
    ["N", "E"],
    
    // ##
    // ..
    ["E", "W"],
    
    // ##
    // #.
    ["E", "S"],
    
    // ##
    // .#
    ["S", "W"],
    
    // ##
    // ##
    []
]

// Used at each point
public class GridSample {
    // What the value is
    var sample: CGFloat = 0
    var aboveThreshold: Bool = false
    var classification: Int = 0
}

public class MarchingSquaresEngine2D {
    public typealias Index = (row: Int, col: Int)
    public typealias PointPair = (a: CGPoint, b: CGPoint)
    
    /* Parameters */
    // How many points per unit to render
    public var resolution: CGFloat = 1 {
        didSet {
            generateGrid()
        }
    }
    
    // Size of the simulation
    public var width: Int = 100 {
        didSet {
            generateGrid()
        }
    }
    public var height: Int = 100 {
        didSet {
            generateGrid()
        }
    }
    
    // Columns and rows include resolution; add 1 so it goes to the edge
    public var cols: Int {
        return Int(CGFloat(width) * resolution) + 1
    }
    public var rows: Int {
        return Int(CGFloat(height) * resolution) + 1
    }
    
    // At what point to cut off
    public var threshold: CGFloat = 1
    
    // State
    public private(set) var samples: [GridSample] = []
    
    init() {
        generateGrid()
    }
    
    func renderPath() -> CGPath {
        // Do calculations
        let lines = calculateLines()
        
        // Generate the path
        return pathFromLines(lines: lines)
    }
    
    // Creates a new grid of a specified size
    private func generateGrid() {
        let itemCount = rows * cols
        
        // Add missing items
        while samples.count < itemCount {
            samples.append(GridSample())
        }
        
        // Remove extra items
        samples.removeSubrange(itemCount..<samples.count)
    }
    
    // Calculates the values in the grid
    public func calculateSamples() {
        // Calculate if over the threashold
        for sample in samples {
            sample.aboveThreshold = sample.sample >= threshold
        }
    }
    
    // Calculates what type of value each sample is
    public func calculateClassifications() {
        // Classify the samples
        for (i, sample) in samples.enumerated() {
            let (row, col) = columnAndRow(forIndex: i)
            
            // Make sure not at the outer edge; this looks at other items, so it shouldn't look at the outer edge
            guard col != cols - 1 && row != rows - 1 else { continue }
            
            // Get the surrounding samples; `hashValue` converts the bool to either a 1 or 0 for true and false
            // respectively.
            let NW = sampleAt(row: row,   col: col  ).aboveThreshold.hashValue
            let NE = sampleAt(row: row,   col: col+1).aboveThreshold.hashValue
            let SW = sampleAt(row: row+1, col: col  ).aboveThreshold.hashValue
            let SE = sampleAt(row: row+1, col: col+1).aboveThreshold.hashValue
            
            // Update the classification
            sample.classification =
                (SW << 0) +
                (SE << 1) +
                (NE << 2) +
                (NW << 3)
        }
    }
    
    // Calculate the paths used to generate the metaballs
    public func calculateLines() -> [PointPair] {
        var lines = [PointPair]()
        for (i, sample) in samples.enumerated() {
            let (row, col) = columnAndRow(forIndex: i)
            
            // Make sure not at the outer edge; looks beyond the edge if it does
            guard col < cols - 1 && row < rows - 1 else { continue }
            
            // Get the classification and corners
            let classification = sample.classification
            let polyCompassCorners = classificationToPolyCorners[classification]
            
            // Get the samples at the 4 corners of the current cell
            let NW = sampleAt(row: row, col: col).sample
            let NE = sampleAt(row: row, col: col+1).sample
            let SW = sampleAt(row: row+1, col: col).sample
            let SE = sampleAt(row: row+1, col: col+1).sample
            
            // Get the offset from top or left that the line intersection should be.
            let N = (classification & 4) == (classification & 8) ? 0.5 : CGFloat.lerp(NW, NE, 0, 1, threshold)
            let E = (classification & 2) == (classification & 4) ? 0.5 : CGFloat.lerp(NE, SE, 0, 1, threshold)
            let S = (classification & 1) == (classification & 2) ? 0.5 : CGFloat.lerp(SW, SE, 0, 1, threshold)
            let W = (classification & 1) == (classification & 8) ? 0.5 : CGFloat.lerp(NW, SW, 0, 1, threshold)
            
            // Construct the points
            let cgRow = CGFloat(row)
            let cgCol = CGFloat(col)
            var compassCoords = [
                "N": CGPoint(x: cgCol + N, y: cgRow),
                "W": CGPoint(x: cgCol,     y: cgRow + W),
                "E": CGPoint(x: cgCol + 1, y: cgRow + E),
                "S": CGPoint(x: cgCol + S, y: cgRow + 1)
            ]
            
            // Scale down the points by the resolution
            for (i, coord) in compassCoords {
                compassCoords[i] = CGPoint(x: coord.x / resolution, y: coord.y / resolution)
            }
            
            // Draw first line
            if polyCompassCorners.count >= 2 {
                guard
                    let a = compassCoords[polyCompassCorners[0]],
                    let b = compassCoords[polyCompassCorners[1]]
                    else {
                        print("Could not get compass coords.")
                        break
                }
                
                lines.append((a, b))
                
                // Draw other line, if needed
                if polyCompassCorners.count == 4 {
                    guard
                        let c = compassCoords[polyCompassCorners[2]],
                        let d = compassCoords[polyCompassCorners[3]]
                        else {
                            print("Could not get compass coords.")
                            break
                    }
                    
                    lines.append((c, d))
                }
            }
        }
        
        return lines
    }
    
    // Takes the previously generated lines and creates a path
    private func pathFromLines(lines: [PointPair]) -> CGPath {
        /*
         - Save all lines for (col, row) -> (col, row) in an array
         - Need to group all connected items
         - Start with first item
         - Look for another item that shares a start or end with original start or end
         - If so, remove that item and add to that array
         - If none, find another point to do a path with
         - Repeat until complete
         - Then do the path
         - Find a line that doesn't share one end with another, otherwise choose the first item if none exists
         - Start at the dangling end
         - Find next connected line, add that to the path
         - Continue until gone through all points
         - Then close the subpath
         
         
         Another approach:
         - Find line with only one connected item
         - Start new path there
         - Find another line whose start begins with the end
         - Draw to that line
         - Continue until a dangling line is found
         
         Issue:
         - Blobs may overlap the edge fo the screen multiple times
         
         Possible solution 1:
         - Expand the canvas for all of the metaballs by default
         - Need to calculate the canvas size and offset first
         - Could expand to the size of one metaball
         - Issue is that constantly recreating the grid
         
         Possible solution 2:
         - When reach an edge with a *dangling line*
         - Example: dangling edge on right side
         - Look above, see that it's in threshold
         - Follow the edge counterclockwise until find another edge point
         - Things to consider
         - Need to add a point at corners
         */
        
        // Copy the array for modification
        var lines = lines
        
        // Create the path
        let path = CGMutablePath()
        while lines.count > 0 {
            // Get the line to use and create a group
            var line = lines.remove(at: 0)
            var firstItem = true
            var startPosition: CGPoint? // The point the path started from; used to determine if a closed path.
            
            // Find all associated items
            var danglingPoint: CGPoint?
            while let (index, from, joint, to) = findMatching(line: line, in: lines, start: startPosition) {
                // If at first line, draw first line
                if firstItem {
                    startPosition = from
                    path.move(to: from)
                    path.addLine(to: joint)
                    firstItem = false
                }
                
                // Add a line to the end
                path.addLine(to: to)
                
                // Remove the line and save it for next time
                let other = lines.remove(at: index)
                line = other
                
                // Save the last point
                danglingPoint = to
            }
            
            // Get the finishing point before closing
            let finishPosition = path.currentPoint
            
            // Determine if the path was closed; print it and add an indicator
            let shapeRect = CGRect(x: finishPosition.x - 5, y: finishPosition.y - 5, width: 10, height: 10)
            if startPosition == finishPosition {
//                print("Closed path")
                // Add point indicating where it ended
//                path.addEllipse(in: shapeRect)
            } else {
//                print("Open path")
                 path.addRect(shapeRect)
                
                // Get the actual index
                guard let danglingPoint = danglingPoint else {
                    print("No dangling point for open path.")
                    continue
                }
                
                // Make sure the point is not on an edge
                guard
                    danglingPoint.x == 0 || danglingPoint.x == CGFloat(width) ||
                    danglingPoint.y == 0 || danglingPoint.y == CGFloat(height)
                else {
                    print("Dangling point not on edge.", danglingPoint)
                    continue
                }
                
                // Do initial test for point above threshold
//                let clockwiseTest = sampleAt(index: stepIndex(index: index, clockwise: true))
//                var clockwise = clockwise
//                var testIndex =
            }
        }
        
        return path
    }
    
    func stepIndex(index: Index, clockwise: Bool) -> Index {
        // Find the side
        let isTop = index.row == 0
        let isBottom = index.row == rows - 1
        let isLeft = index.col == 0
        let isRight = index.col == cols - 1
        
        // Assure the index is in the right position
        if !(isTop || isBottom) || !(isLeft || isRight) {
            print("Index is not touching edge to step", index)
        }
        
        // Step the index
        if clockwise {
            if isTop && isLeft { // Corners
                return (0, 1)
            } else if isTop && isRight {
                return (1, cols - 1)
            } else if isRight && isBottom {
                return (rows - 1, cols - 2)
            } else if isBottom && isLeft {
                return (rows - 2, 0)
            } else if isTop { // Sides
                return (0, index.col + 1)
            } else if isRight {
                return (index.row + 1, cols - 1)
            } else if isBottom {
                return (rows - 1, index.col - 1)
            } else if isLeft {
                return (index.row - 1, 0)
            }
        } else {
            if isTop && isLeft { // Corners
                return (1, 0)
            } else if isTop && isRight {
                return (0, cols - 2)
            } else if isRight && isBottom {
                return (rows - 2, cols - 1)
            } else if isBottom && isLeft {
                return (rows - 1, 1)
            } else if isTop { // Sides
                return (0, index.col - 1)
            } else if isRight {
                return (index.row - 1, cols - 1)
            } else if isBottom {
                return (rows - 1, index.col + 1)
            } else if isLeft {
                return (index.row + 1, 0)
            }
        }
        
        fatalError("Every case should be covered.")
    }
    
    // Given a pair of points, it finds another line that's attached to the same point; it returns the index of the
    // other line, the dangling end of the given line, the point at which the two lines intersect, and the dangling point
    // of the other line.
    private func findMatching(line: PointPair, in lines: [PointPair], start: CGPoint?) -> (index: Int, from: CGPoint, joint: CGPoint, to: CGPoint)? {
        // Check if path closed
        if line.a == start || line.b == start {
            return nil
        }
        
        // Find exact matches
        for (i, other) in lines.enumerated() {
            if line.a == other.a {
                return (i, line.b, other.a, other.b)
            } else if line.a == other.b {
                return (i, line.b, other.b, other.a)
            } else if line.b == other.a {
                return (i, line.a, other.a, other.b)
            } else if line.b == other.b {
                return (i, line.a, other.b, other.a)
            }
            
//            let t: CGFloat = 0.2
//            if
//                distance(a: line.a, b: other.a) < t ||
//                    distance(a: line.a, b: other.b) < t ||
//                    distance(a: line.b, b: other.a) < t ||
//                    distance(a: line.b, b: other.b) < t
//            {
//                print("Found close but not the same. \(line) \(other)")
//            }
        }
        
        // Find the side that's on the edge
        let dangling: CGPoint
        if onEdge(line.a) {
            dangling = line.a
        } else if onEdge(line.b) {
            dangling = line.b
        } else {
            print("No dangling line on the edge.", line)
            return nil
        }
        
        // Look for matches on the same edge
        if dangling.x == 0 || dangling.x == CGFloat(width) {
            for other in lines {
                if other.a.x == dangling.x || other.b.x == dangling.x {
                    print("Found matching on edge X")
                }
            }
        }
        if dangling.y == 0 || dangling.y == CGFloat(height) {
            for other in lines {
                if other.a.y == dangling.y || other.b.y == dangling.y {
                    print("Found matching on edge Y")
                }
            }
        }
        
        
        return nil
    }
    
    private func distance(a: CGPoint, b: CGPoint) -> CGFloat {
        return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2))
    }
    
    private func onEdge(_ point: CGPoint) -> Bool {
        return point.x == 0 || point.x == CGFloat(width) || point.y == 0 || point.y == CGFloat(height)
    }
    
    // Get a sample at an index
    public func sampleAt(row: Int, col: Int) -> GridSample {
        return samples[row * cols + col]
    }
    
    public func sampleAt(index: Index) -> GridSample {
        return samples[index.row * cols + index.col]
    }
    
    // Get the column and row for index
    public func columnAndRow(forIndex i: Int) -> Index {
        return (i / cols, i % cols)
    }
    
    // Get the point for an index
    public func point(forIndex i: Int) -> CGPoint {
        let (row, col) = columnAndRow(forIndex: i)
        return CGPoint(
            x: CGFloat(col) / resolution,
            y: CGFloat(row) / resolution
        )
    }
}
