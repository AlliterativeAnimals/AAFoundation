//
//  Extensions.swift
//  Line Puzzle
//
//  Created by David Godfrey on 04/01/2017.
//  Copyright © 2017 Alliterative Animals. All rights reserved.
//

import Foundation
import UIKit

public extension Comparable {
    /**
     * Ensures the returned value falls within the given bounds
     */
    public func clamped(to bounds: ClosedRange<Self>) -> Self {
        return min(max(self, bounds.lowerBound), bounds.upperBound)
    }
}

public extension UIBezierPath {
    /**
     * Optimisation to only fill if required.
     *
     * Only fills if the path might be visible within the given CGRect
     */
    public func fill(ifIntersectsWith rect: CGRect) {
        if self.bounds.intersects(rect) {
            self.fill()
        }
    }
    
    /**
     * Optimisation to only stroke if required.
     *
     * Only strokes if the path might be visible within the given CGRect
     */
    public func stroke(ifIntersectsWith rect: CGRect) {
        if self.bounds.intersects(rect) {
            self.stroke()
        }
    }
}

public extension CGPoint {
    /**
     * Returns the location of this point after being moved by a vector
     *
     * - Parameter vector: to move the point by
     */
    public func movedBy(vector: CGVector) -> CGPoint {
        return CGPoint(x: self.x + vector.dx, y: self.y + vector.dy)
    }
    
    /**
     * Returns true if the `otherPoint` is within `tolerance`
     *
     * Calculates the distance between points as the straight line between them.
     *
     * - Parameters:
     *     - otherPoint: to compare against
     *     - tolerance: to allow when comparing
     */
    public func isCloseTo(point otherPoint: CGPoint, withTolerance tolerance: CGFloat = 0) -> Bool {
        return abs(CGVector(dx: otherPoint.x - self.x, dy: otherPoint.y - self.y).squareMagnitude) < pow(tolerance, 2)
    }

    /**
     * Hash value of the point, in the form "(x,y)".hashValue
     */
    public var hashValue: Int {
        return "(\(self.x),\(self.y))".hashValue
    }
}

public extension CGVector {
    /**
     * The square of the vector's magnitude.
     *
     * Avoids a (slow, expensive) call to `sqrt`, so is to be preferred when you are only comparing vectors and do not need the exact magnitude.
     */
    public var squareMagnitude: CGFloat {
        return (dx * dx) + (dy * dy)
    }

    /**
     * The magitude (length) of the vector.
     *
     * See also `squareMagnitude` for a faster alternative avoiding a `sqrt` call if the literal magnitude is not required.
     */
    public var magnitude: CGFloat {
        return sqrt(self.squareMagnitude)
    }
    
    /**
     * The inverse of the current vector
     */
    public var inverse: CGVector {
        return CGVector(dx: -self.dx, dy: -self.dy)
    }
    
    /**
     * Returns the dot product with another given vector
     *
     * - Parameter otherVector: The other vector to calculate the dot product with
     */
    public func getDotProduct(withVector otherVector: CGVector) -> CGFloat {
        return (self.dx * otherVector.dx) + (self.dy * otherVector.dy)
    }
    
    /**
     * Scales the vector by the given multiplier and returns a new vector
     *
     * - Parameter byMultiplier: the multiplier to scale by
     */
    public func scale(byMultiplier multiplier: CGFloat) -> CGVector {
        return CGVector(dx: self.dx * multiplier, dy: self.dy * multiplier)
    }
    
    /**
     * Scales the vector by the given multiplier and returns a new vector
     *
     * - Parameter byMultiplier: the multiplier to scale by
     */
    public func scale(byMultiplier multiplier: Int) -> CGVector {
        return self.scale(byMultiplier: CGFloat(multiplier))
    }

    /**
     * Convenience initialiser to calculate vector between two points.
     */
    public init(originPoint: CGPoint, destinationPoint: CGPoint) {
        self.dx = destinationPoint.x - originPoint.x
        self.dy = destinationPoint.y - originPoint.y
    }
}

public extension Collection where Indices.Iterator.Element == Index {
    /**
     * Returns the element at the specified index iff it is within bounds, otherwise nil.
     * - Parameter index: index of collection to return, if available
     */
    public subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public extension CGRect {
    /**
     * Returns true if any of the given CGPoints are within the CGRect
     */
    public func contains(anyOf points: Array<CGPoint>, includingOnBoundary: Bool = true) -> Bool {
        for point in points {
            if self.contains(point, includingOnBoundary: includingOnBoundary) {
                return true
            }
        }
        return false
    }
    
    /**
     * Returns true if all of the given CGPoints are within the CGRect
     */
    public func contains(allOf points: Array<CGPoint>, includingOnBoundary: Bool = true) -> Bool {
        for point in points {
            if !self.contains(point, includingOnBoundary: includingOnBoundary) {
                return false
            }
        }
        return true
    }
    
    /**
     * Returns true if the CGRect contains the given CGPoint
     */
    public func contains(_ point: CGPoint, includingOnBoundary: Bool) -> Bool {
        guard includingOnBoundary else {
            return self.contains(point)
        }
        
        let x = point.x
        let y = point.y
        
        return x <= self.maxX && x >= self.minX && y <= self.maxY && y >= self.minY
    }
    
    /**
     * Longest edge length (either width or height) of the CGRect
     */
    public var longestEdgeLength: CGFloat {
        return max(self.size.width, self.size.height)
    }
    
    /**
     * Shorted edge length (either width or height) of the CGRect
     */
    public var shortestEdgeLength: CGFloat {
        return min(self.size.width, self.size.height)
    }
    
    /**
     * Returns a CGRect moved by the given vector.
     *
     * Retains size, only the origin is updated.
     */
    public func movedBy(vector: CGVector) -> CGRect {
        return CGRect(origin: self.origin.movedBy(vector: vector), size: self.size)
    }
    
    // Center
    public var pointCenter: CGPoint {
        return self.pointMidXMidY
    }
    
    public var pointMidXMidY: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }

    // EightCorners - NOTE: Didn't do "top left" or similar, because that depends on the coordinate system (views vs scenekit nodes, for example)
    public var pointMinXMinY: CGPoint {
        return CGPoint(x: self.minX, y: self.minY)
    }
    
    public var pointMidXMinY: CGPoint {
        return CGPoint(x: self.midX, y: self.minY)
    }
    
    public var pointMaxXMinY: CGPoint {
        return CGPoint(x: self.maxX, y: self.minY)
    }
    
    public var pointMaxXMidY: CGPoint {
        return CGPoint(x: self.maxX, y: self.midY)
    }
    
    public var pointMaxXMaxY: CGPoint {
        return CGPoint(x: self.maxX, y: self.maxY)
    }
    
    public var pointMidXMaxY: CGPoint {
        return CGPoint(x: self.midX, y: self.maxY)
    }
    
    public var pointMinXMaxY: CGPoint {
        return CGPoint(x: self.minX, y: self.maxY)
    }
    
    public var pointMinXMidY: CGPoint {
        return CGPoint(x: self.minX, y: self.midY)
    }
}

public extension UIView {
    /**
     * All ancestors of the current view (including itsself)
     */
    public var hierarchy: Array<UIView> {
        var ancestors: Array<UIView> = [ self ]
        
        var currentView = self
        while let currentSuperview = currentView.superview {
            ancestors.append(currentSuperview)
            currentView = currentSuperview
        }
        
        return ancestors
    }
}

public extension UIColor {
    /**
     * Convenience initializer to start from a HSBA object
     */
    public convenience init(hsba: HSBA) {
        self.init(hue: hsba.hue, saturation: hsba.saturation, brightness: hsba.brightness, alpha: hsba.alpha)
    }
    
    /**
     * Creates a new color based on the current color using the given saturation
     *
     * - Parameter saturation: the value to set to; the range depends on the color space for the color, however in sRGB the range is 0.0...1.0
     */
    public func with(saturation: CGFloat) -> UIColor {
        var hsba = self.hsba
        
        hsba.saturation = saturation
        
        return type(of: self).init(hue: hsba.hue, saturation: hsba.saturation, brightness: hsba.brightness, alpha: hsba.alpha)
    }
    
    /**
     * Returns a HSBA representation of the color.
     */
    public var hsba: HSBA {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return HSBA(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
}

/**
 * Represents a color in Hue/Saturation/Brightness/Alpha format.
 *
 * As this allows the reader to visualise properties of the colour more easily than RGB, this may be preferred to standard UIColors or RGB values.
 */
public struct HSBA {
    /**
     * The hue of the color.
     *
     * This is often between 0.0...1.0, but depends on the color space the color will be presented in.
     * 
     * - Note: If saturation or brightness are zero, the hue may not make sense. For example, `UIColor.black.hsba` and UIColor.white.hsba` both have a hue of 0º, if you take only the hue and replace saturation and brightness values this will generate a red color.
     */
    public var hue: CGFloat
    
    /**
     * The saturation of the color.
     *
     * This is often between 0.0...1.0, but depends on the color space the color will be presented in.
     */
    public var saturation: CGFloat
    
    /**
     * The brightness of the color.
     *
     * This is often between 0.0...1.0, but depends on the color space the color will be presented in.
     */
    public var brightness: CGFloat
    
    /**
     * The alpha (opacity) of the color.
     *
     * This is often between 0.0...1.0, but depends on the color space the color will be presented in.
     * 
     * Lower values denote a less opaque color.
     */
    public var alpha: CGFloat
    
    /**
     * Converts the HSBA back into a UIColor for display.
     */
    public var uiColor: UIColor {
        return UIColor(hue: self.hue, saturation: self.saturation, brightness: self.brightness, alpha: self.alpha)
    }
    
    /**
     * Converts the HSBA back into a CGColor for display.
     */
    public var cgColor: CGColor {
        return self.uiColor.cgColor
    }
}

public extension UIBezierPath {
    /**
     * Convenience initialiser to create a full-circle path without having to explicitly state angles.
     */
    public convenience init(arcCenter: CGPoint, radius: CGFloat, clockwise: Bool = true) {
        self.init(arcCenter: arcCenter, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: clockwise)
    }
    
    /**
     * Generates a smoothed line through given points
     *
     * - Parameters:
     *     - points: points to draw the line through
     *     - closed: if true, the line is closed to form a continuous path
     *
     * From a [github comment by Jérôme Gangneux](https://github.com/jnfisher/ios-curve-interpolation/issues/6)
     */
    public static func interpolateHermiteFor(points: Array<CGPoint>, closed: Bool = false) -> UIBezierPath {
        guard points.count >= 2 else {
            return UIBezierPath()
        }
        
        if points.count == 2 {
            let bezierPath = UIBezierPath()
            bezierPath.move(to: points[0])
            bezierPath.addLine(to: points[1])
            return bezierPath
        }
        
        let nCurves = closed ? points.count : points.count - 1
        
        let path = UIBezierPath()
        for i in 0..<nCurves {
            var curPt = points[i]
            var prevPt: CGPoint, nextPt: CGPoint, endPt: CGPoint
            if i == 0 {
                path.move(to: curPt)
            }
            
            var nexti = (i+1)%points.count
            var previ = (i-1 < 0 ? points.count-1 : i-1)
            
            prevPt = points[previ]
            nextPt = points[nexti]
            endPt = nextPt
            
            var mx: CGFloat
            var my: CGFloat
            if closed || i > 0 {
                mx  = (nextPt.x - curPt.x) * CGFloat(0.5)
                mx += (curPt.x - prevPt.x) * CGFloat(0.5)
                my  = (nextPt.y - curPt.y) * CGFloat(0.5)
                my += (curPt.y - prevPt.y) * CGFloat(0.5)
            }
            else {
                mx = (nextPt.x - curPt.x) * CGFloat(0.5)
                my = (nextPt.y - curPt.y) * CGFloat(0.5)
            }
            
            var ctrlPt1 = CGPoint.zero
            ctrlPt1.x = curPt.x + mx / CGFloat(3.0)
            ctrlPt1.y = curPt.y + my / CGFloat(3.0)
            
            curPt = points[nexti]
            
            nexti = (nexti + 1) % points.count
            previ = i;
            
            prevPt = points[previ]
            nextPt = points[nexti]
            
            if closed || i < nCurves-1 {
                mx  = (nextPt.x - curPt.x) * CGFloat(0.5)
                mx += (curPt.x - prevPt.x) * CGFloat(0.5)
                my  = (nextPt.y - curPt.y) * CGFloat(0.5)
                my += (curPt.y - prevPt.y) * CGFloat(0.5)
            }
            else {
                mx = (curPt.x - prevPt.x) * CGFloat(0.5)
                my = (curPt.y - prevPt.y) * CGFloat(0.5)
            }
            
            var ctrlPt2 = CGPoint.zero
            ctrlPt2.x = curPt.x - mx / CGFloat(3.0)
            ctrlPt2.y = curPt.y - my / CGFloat(3.0)
            
            path.addCurve(to: endPt, controlPoint1: ctrlPt1, controlPoint2: ctrlPt2)
        }
        
        if closed {
            path.close()
        }
        
        return path
    }
}

public extension UIImage {
    public struct RotationOptions: OptionSet {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let flipOnVerticalAxis = RotationOptions(rawValue: 1)
        public static let flipOnHorizontalAxis = RotationOptions(rawValue: 2)
    }
    
    /**
     * Rotates the image with the given options.
     *
     * - Parameters:
     *     - rotationAngleRadians: the angle to rotate the image by
     *     - options: Options while rendering, eg: whether or not to flip on an axis
     *
     * - Returns: A rotated image, or nil if the image could not be rendered.
     */
    func rotated(by rotationAngleRadians: CGFloat, options: RotationOptions = []) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let rotationInRadians = rotationAngleRadians
        let transform = CGAffineTransform(rotationAngle: rotationInRadians)
        var rect = CGRect(origin: .zero, size: self.size).applying(transform)
        rect.origin = .zero
        
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        return renderer.image { renderContext in
            renderContext.cgContext.translateBy(x: rect.midX, y: rect.midY)
            renderContext.cgContext.rotate(by: rotationInRadians)
            
            let x: CGFloat = options.contains(.flipOnVerticalAxis) ? -1.0 : 1.0
            let y: CGFloat = options.contains(.flipOnHorizontalAxis) ? 1.0 : -1.0
            renderContext.cgContext.scaleBy(x: x, y: y)
            
            let drawRect = CGRect(origin: CGPoint(x: -self.size.width/2, y: -self.size.height/2), size: self.size)
            renderContext.cgContext.draw(cgImage, in: drawRect)
        }
    }
}

/**
 * Represents the result of diff-ing two collections
 */
public struct DiffResult<T: Hashable> {
    /**
     * Items only found in the first collection
     *
     *     > [1,2].diff(other: [2,3]).uniqueToFirst
     *     Set([1])
     *
     * - Note: Does not retain the original order of items.
     */
    public let uniqueToFirst: Set<T>
    /**
     * Items only found in the second collection
     *
     *     > [1,2].diff(other: [2,3]).uniqueToFirst
     *     Set([3])
     *
     * - Note: Does not retain the original order of items.
     */
    public let uniqueToSecond: Set<T>
    /**
     * Items only found in both collections
     *
     *     > [1,2].diff(other: [2,3]).uniqueToFirst
     *     Set([2])
     *
     * - Note: Does not retain the original order of items.
     */
    public let containedInBoth: Set<T>
    /**
     * (computed) Items in the first collection
     *
     *     > [1,2].diff(other: [2,3]).uniqueToFirst
     *     Set([1,2])
     *
     * - Note: Does not retain the original order of items.
     */
    public var containedInFirst: Set<T> { return self.uniqueToFirst.union(self.containedInBoth) }
    /**
     * (computed) Items in the second collection
     *
     *     > [1,2].diff(other: [2,3]).uniqueToFirst
     *     Set([2,3])
     *
     * - Note: Does not retain the original order of items.
     */
    public var containedInSecond: Set<T> { return self.uniqueToSecond.union(self.containedInBoth) }
}

public extension Array where Element: Hashable {
    /**
     * Returns the difference between two given arrays
     *
     * - Parameter other: Other array to compare against ('second' in the DiffResult)
     *
     * - Returns: A DiffResult object repressenting the differences between the arrays
     */
    public func diff(other: Array<Element>) -> DiffResult<Element> {
        let firstSet = Set(self)
        let secondSet = Set(other)
        
        return DiffResult<Element>(uniqueToFirst: firstSet.subtracting(secondSet), uniqueToSecond: secondSet.subtracting(firstSet), containedInBoth: firstSet.intersection(secondSet))
    }
}

public extension NSLayoutConstraint {
    /**
     * Convenience initalizer to also set the priority during init
     */
    public convenience init(
        item: Any,
        attribute firstAttribute: NSLayoutAttribute,
        relatedBy: NSLayoutRelation,
        toItem: Any?,
        attribute secondAttribute: NSLayoutAttribute,
        multiplier: CGFloat,
        constant: CGFloat,
        priority: UILayoutPriority
        ) {
        self.init(item: item, attribute: firstAttribute, relatedBy: relatedBy, toItem: toItem, attribute: secondAttribute, multiplier: multiplier, constant: constant)
        
        self.priority = priority
    }
}

public extension URL {
    /**
     * Convenience optional initializer to avoid another 'if let' block
     */
    public init?(string: String?, relativeTo: URL? = nil) {
        if let string = string {
            self.init(string: string, relativeTo: relativeTo)
        } else {
            return nil
        }
    }
}

public extension UIImage {
    /**
     * Scales image to given width, preserving ratio.
     *
     * - Parameter width: width to scale to
     */
    public func scaleImage(toWidth width: CGFloat) -> UIImage? {
        let scalingRatio = width / self.size.width
        let newHeight = scalingRatio * self.size.height
        return self.scaleImage(toSize: CGSize(width: width, height: newHeight))
    }
    
    /**
     * Scales image to given height, preserving ratio.
     *
     * - Parameter height: height to scale to
     */
    public func scaleImage(toHeight height: CGFloat) -> UIImage? {
        let scalingRatio = height / self.size.height
        let newWidth = scalingRatio * self.size.width
        return self.scaleImage(toSize: CGSize(width: newWidth, height: height))
    }
    
    /**
     * Scales image to given size, ignoring original ratio.
     *
     * - Parameter size: to scale to
     */
    public func scaleImage(toSize size: CGSize) -> UIImage? {
        let newRect = CGRect(x: 0, y: 0, width: size.width, height: size.height).integral
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            context.interpolationQuality = .high
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height)
            context.concatenate(flipVertical)
            context.draw(self.cgImage!, in: newRect)
            let newImage = UIImage(cgImage: context.makeImage()!)
            UIGraphicsEndImageContext()
            return newImage
        }
        return nil
    }
}

public extension URL {
    public enum URLQueryItemsError: Error {
        case CannotGetComponents(fromUrl: URL)
        case CannotGetUrl(fromComponents: URLComponents)
    }

    private func getComponents() throws -> URLComponents {
        // Get components from current URL
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            throw URLQueryItemsError.CannotGetComponents(fromUrl: self)
        }
        return components
    }
    
    /**
     * Replaces the given query items.
     *
     * Also adds missing keys if they were not in the original query items.
     *
     *     let aUrl = "http://example.com?foo=bar"
     *     let replacements = [ "foo" : "replaced", "bar": "added" ]
     *     print(
     *         URL(string: aUrl)
     *             .replacing(queryItems: replacements)
     *             .absoluteString
     *     )
     *
     * output:
     *
     *     "http://example.com?foo=baz&bar=added"
     *
     * - Parameter queryItems: String Dictionary of keys to replace in query items
     */
    public func replacing(queryItems: [String:String]) throws -> URL {
        var components = try self.getComponents()
        
        let bannedKeys = Array(queryItems.keys)
        
        components.queryItems = (components.queryItems ?? []).filter({ !bannedKeys.contains($0.name) })
        
        for (key, value) in queryItems {
            components.queryItems?.append(URLQueryItem(name: key, value: value))
        }
        
        guard let url = components.url else {
            throw URLQueryItemsError.CannotGetUrl(fromComponents: components)
        }
        
        return url
    }
    
    /**
     * Removes the given query item keys
     *
     *     let aUrl = "http://example.com?foo=bar&baz=quux"
     *     let removals = [ "foo", "corge" ]
     *     print(
     *         URL(string: aUrl)
     *             .replacing(queryItems: replacements)
     *             .absoluteString
     *     )
     *
     * output:
     *
     *     "http://example.com?baz=quux"
     *
     * - Parameter queryItems: Array of keys to remove from query items
     */
    public func removing(queryItems: [String]) throws -> URL {
        var components = try self.getComponents()
        
        let bannedKeys = queryItems
        
        components.queryItems = (components.queryItems ?? []).filter({ !bannedKeys.contains($0.name) })
        
        guard let url = components.url else {
            throw URLQueryItemsError.CannotGetUrl(fromComponents: components)
        }
        
        return url
    }
}

public extension CGAffineTransform {
    /**
     * Calculates the X scale involved in the transformation
     *
     * - Note: this uses `sqrt` so is a relatively expensive calculation. If it is possible to record the scale some other way it may be more efficient.
     */
    var xScale: CGFloat {
        return sqrt(self.a * self.a + self.c * self.c);
    }
    
    /**
     * Calculates the Y scale involved in the transformation
     *
     * - Note: this uses `sqrt` so is a relatively expensive calculation. If it is possible to record the scale some other way it may be more efficient.
     */
    var yScale: CGFloat {
        return sqrt(self.b * self.b + self.d * self.d);
    }
}

