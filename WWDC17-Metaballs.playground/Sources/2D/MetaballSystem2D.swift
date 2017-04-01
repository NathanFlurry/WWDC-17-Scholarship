//
// Created by Nathan Flurry on 2/22/17.
// Copyright (c) 2017 NathanFlurry. All rights reserved.
//

import Foundation
import CoreGraphics

// Inspired from http://jamie-wong.com/2014/08/19/metaballs-and-marching-squares/

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

public class MetaballSystem2D {
    public typealias Index = (row: Int, col: Int)
    public typealias PointPair = (a: CGPoint, b: CGPoint)
    
    /* Parameters */
    public var balls: [Metaball2D] = []
    
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
    public var height: Int = 100{
        didSet {
            generateGrid()
        }
    }
    
    // Columns and rows include resolution
    public var cols: Int {
        return Int(CGFloat(width) * resolution)
    }
    public var rows: Int {
        return Int(CGFloat(height) * resolution)
    }
    
    // At what point to cut off
    public var threshold: CGFloat = 1
    
    // State
    public private(set) var samples: [GridSample] = []
    
    init() {
        generateGrid()
    }
    
    func render() -> CGPath {
        // Do calculations
        calculateSamples()
        calculateClassifications()
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
        // Sample the metaballs
        for (i, sample) in samples.enumerated() {
            let position = point(forIndex: i)
            
            // Update the sample
            sample.sample = calculateSample(position: position)
            
            // Set the threshold
            sample.aboveThreshold = sample.sample > threshold
        }
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
    
    // Calculates what type of value each sample is
    public func calculateClassifications() {
        // Classify the samples
        for (i, sample) in samples.enumerated() {
            let (col, row) = columnAndRow(forIndex: i)
            
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
            let (col, row) = columnAndRow(forIndex: i)
            
            // Make sure not at the outer edge; looks beyond the edge if it does
            guard col != cols - 1 && row != rows - 1 else { continue }
            
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
                "N": CGPoint(x: cgRow,     y: cgCol + N),
                "W": CGPoint(x: cgRow + W, y: cgCol    ),
                "E": CGPoint(x: cgRow + E, y: cgCol + 1),
                "S": CGPoint(x: cgRow + 1, y: cgCol + S)
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
            while let (index, from, joint, to) = findMatching(line: line, in: lines) {
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
            }
            
            // Get the finishing point before closing
            let finishPosition = path.currentPoint
            
            // Close the subpath
            //            path.closeSubpath()
            
            // Determine if the path was closed; print it and add an indicator
            let shapeRect = CGRect(x: finishPosition.x - 5, y: finishPosition.y - 5, width: 10, height: 10)
            if startPosition == finishPosition {
                print("Closed path")
                // Add point indicating where it ended
                path.addEllipse(in: shapeRect)
            } else {
                print("Open path")
                //                path.addRect(shapeRect)
            }
        }
        
        return path
    }
    
    // Given a pair of points, it finds another line that's attached to the same point; it returns the index of the
    // other line, the dangling end of the given line, the point at which the two lines intersect, and the dangling point
    // of the other line.
    private func findMatching(line: PointPair, in lines: [PointPair]) -> (index: Int, from: CGPoint, joint: CGPoint, to: CGPoint)? {
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
            
            let t: CGFloat = 0.2
            if
                distance(a: line.a, b: other.a) < t ||
                    distance(a: line.a, b: other.b) < t ||
                    distance(a: line.b, b: other.a) < t ||
                    distance(a: line.b, b: other.b) < t
            {
                print("Found close but not the same. \(line) \(other)")
            }
        }
        return nil
    }
    
    private func distance(a: CGPoint, b: CGPoint) -> CGFloat {
        return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2))
    }
    
    // Get a sample at an index
    public func sampleAt(row: Int, col: Int) -> GridSample {
        return samples[row * cols + col]
    }
    
    // Get the column and row for index
    public func columnAndRow(forIndex i: Int) -> Index {
        return (i % rows, i / rows)
    }
    
    // Get the point for an index
    public func point(forIndex i: Int) -> CGPoint {
        let (col, row) = columnAndRow(forIndex: i)
        return CGPoint(
            x: CGFloat(row) / resolution,
            y: CGFloat(col) / resolution
        )
    }
}
