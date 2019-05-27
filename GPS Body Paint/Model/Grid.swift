/*
 * Grid.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2019/2/16.
 * Copyright © 2019 Frost Land. All rights reserved.
 */

import Foundation
import CoreGraphics



struct Grid {
	
	struct Coordinate : Hashable {
		
		var col, row: Int
		
	}
	
	let path: CGPath
	let area: CGFloat
	
	let lines: CGPath
	let gridSize: CGFloat
	let nCols, nRows: Int
	
	init(shape: GameShape, in rect: CGRect, gridSize s: CGFloat) {
//		let computationStartDate = Date()
		gridSize = s
		path = shape.pathForDrawing(in: rect)
		let center = CGPoint(x: rect.midX, y: rect.midY)
		
		/* *** Computing the number of colums and rows to store *** */
		
		let approximateColsCount = Int((rect.width  / gridSize).rounded(.up))
		let approximateRowsCount = Int((rect.height / gridSize).rounded(.up))
		assert(CGFloat(approximateColsCount)*s >= rect.width)
		assert(CGFloat(approximateRowsCount)*s >= rect.height)
		
		if approximateColsCount % 2 == 0 {nCols = approximateColsCount + 1}
		else                             {nCols = approximateColsCount}
		if approximateRowsCount % 2 == 0 {nRows = approximateRowsCount + 1}
		else                             {nRows = approximateRowsCount}
		
		/* *** Computing the quadrilaterals in the grid *** */
		
		var cellsBuilding = [Quadrilateral?]()
		xStart = center.x - gridSize*(CGFloat(nCols)/2)
		yStart = center.y - gridSize*(CGFloat(nRows)/2)
		for y in stride(from: yStart, to: rect.maxY, by: gridSize) {
			for x in stride(from: xStart, to: rect.maxX, by: gridSize) {
				let tlCorner = CGPoint(x: x,            y: y)
				let trCorner = CGPoint(x: x + gridSize, y: y)
				let blCorner = CGPoint(x: x,            y: y + gridSize)
				let brCorner = CGPoint(x: x + gridSize, y: y + gridSize)
				let tlCornerContained = path.contains(tlCorner)
				let trCornerContained = path.contains(trCorner)
				let brCornerContained = path.contains(brCorner)
				let blCornerContained = path.contains(blCorner)
				
				guard tlCornerContained || trCornerContained || brCornerContained || blCornerContained else {
					cellsBuilding.append(nil)
					continue
				}
				
				let tlFinalCorner: CGPoint
				let trFinalCorner: CGPoint
				let blFinalCorner: CGPoint
				let brFinalCorner: CGPoint
				
				if tlCornerContained {tlFinalCorner = tlCorner}
				else {
					if      trCornerContained {tlFinalCorner = Grid.nearestPoint(in: path, from: tlCorner, direction: trCorner)}
					else if blCornerContained {tlFinalCorner = Grid.nearestPoint(in: path, from: tlCorner, direction: blCorner)}
					else if brCornerContained {tlFinalCorner = Grid.nearestPoint(in: path, from: tlCorner, direction: brCorner)}
					else {fatalError("Impossible configuration: no corner contained after a guard that checks that at least one is contained…")}
				}
				if trCornerContained {trFinalCorner = trCorner}
				else {
					if      tlCornerContained {trFinalCorner = Grid.nearestPoint(in: path, from: trCorner, direction: tlCorner)}
					else if brCornerContained {trFinalCorner = Grid.nearestPoint(in: path, from: trCorner, direction: brCorner)}
					else if blCornerContained {trFinalCorner = Grid.nearestPoint(in: path, from: trCorner, direction: blCorner)}
					else {fatalError("Impossible configuration: no corner contained after a guard that checks that at least one is contained…")}
				}
				if brCornerContained {brFinalCorner = brCorner}
				else {
					if      blCornerContained {brFinalCorner = Grid.nearestPoint(in: path, from: brCorner, direction: blCorner)}
					else if trCornerContained {brFinalCorner = Grid.nearestPoint(in: path, from: brCorner, direction: trCorner)}
					else if tlCornerContained {brFinalCorner = Grid.nearestPoint(in: path, from: brCorner, direction: tlCorner)}
					else {fatalError("Impossible configuration: no corner contained after a guard that checks that at least one is contained…")}
				}
				if blCornerContained {blFinalCorner = blCorner}
				else {
					if      brCornerContained {blFinalCorner = Grid.nearestPoint(in: path, from: blCorner, direction: brCorner)}
					else if tlCornerContained {blFinalCorner = Grid.nearestPoint(in: path, from: blCorner, direction: tlCorner)}
					else if trCornerContained {blFinalCorner = Grid.nearestPoint(in: path, from: blCorner, direction: trCorner)}
					else {fatalError("Impossible configuration: no corner contained after a guard that checks that at least one is contained…")}
				}
				
				cellsBuilding.append(Quadrilateral(p0: tlFinalCorner, p1: trFinalCorner, p2: brFinalCorner, p3: blFinalCorner))
			}
		}
		cells = cellsBuilding
		
		/* *** Computing the horizontal and vertical lines *** */
		
		let pathBoundingBox = path.boundingBoxOfPath
		
		let linesBuilding = CGMutablePath()
		stride(from: xStart + gridSize, to: rect.maxX, by: gridSize).forEach{ x in
			guard x > pathBoundingBox.minX && x < pathBoundingBox.maxX else {return}
			
			let p1 = CGPoint(x: x, y: pathBoundingBox.minY)
			let p2 = CGPoint(x: x, y: pathBoundingBox.maxY)
			linesBuilding.addLines(between: [p1, p2])
		}
		stride(from: yStart + gridSize, to: rect.maxY, by: gridSize).forEach{ y in
			guard y > pathBoundingBox.minY && y < pathBoundingBox.maxY else {return}
			
			let p1 = CGPoint(x: pathBoundingBox.minX, y: y)
			let p2 = CGPoint(x: pathBoundingBox.maxX, y: y)
			linesBuilding.addLines(between:[p1, p2])
		}
		lines = linesBuilding
		
		area = cells.reduce(CGFloat(0), { $0 + ($1?.area() ?? 0) })
		
		assert(nCols%2 == 1)
		assert(nRows%2 == 1)
		assert(cells.count == nCols*nRows)
		assert(CGFloat(nCols)*gridSize - rect.width  < gridSize*2)
		assert(CGFloat(nRows)*gridSize - rect.height < gridSize*2)
//		print("Computation time: \(-computationStartDate.timeIntervalSinceNow)")
		
		/* *** TESTING THE intersectionPoint METHOD *** */
//		/* (x: 0.5, y: 0.5) */
//		print(Grid.intersectionPoint(
//			between: Segment(p0: CGPoint(x: 0, y: 0), p1: CGPoint(x: 1, y: 1)),
//			and:     Segment(p0: CGPoint(x: 0, y: 1), p1: CGPoint(x: 1, y: 0))
//		))
//		/* nil */
//		print(Grid.intersectionPoint(
//			between: Segment(p0: CGPoint(x: 0, y: 0), p1: CGPoint(x: 1, y: 1)),
//			and:     Segment(p0: CGPoint(x: 0, y: 0), p1: CGPoint(x: 1, y: 1))
//		))
//		/* nil */
//		print(Grid.intersectionPoint(
//			between: Segment(p0: CGPoint(x: 0,   y: 0),   p1: CGPoint(x: 1, y: 1)),
//			and:     Segment(p0: CGPoint(x: 0.6, y: 0.4), p1: CGPoint(x: 1, y: 0))
//		))
//		/* (x: 0.5, y: 0.5) */
//		print(Grid.intersectionPoint(
//			between: Segment(p0: CGPoint(x: 0,     y: 0),     p1: CGPoint(x: 1, y: 1)),
//			and:     Segment(p0: CGPoint(x: 0.499, y: 0.501), p1: CGPoint(x: 1, y: 0))
//		))
//		/* (x: 0.5, y: 0.5) */
//		print(Grid.intersectionPoint(
//			between: Segment(p0: CGPoint(x: 0,   y: 0),   p1: CGPoint(x: 1, y: 1)),
//			and:     Segment(p0: CGPoint(x: 0.5, y: 0.5), p1: CGPoint(x: 1, y: 0))
//		))
//		/* nil */
//		print(Grid.intersectionPoint(
//			between: Segment(p0: CGPoint(x: 0, y: 0), p1: CGPoint(x: 1, y: 1)),
//			and:     Segment(p0: CGPoint(x: 0, y: 0), p1: CGPoint(x: 0, y: 0))
//		))
//		/* nil */
//		print(Grid.intersectionPoint(
//			between: Segment(p0: CGPoint(x: 0,   y: 0),   p1: CGPoint(x: 0, y: 0)),
//			and:     Segment(p0: CGPoint(x: 0.2, y: 0.1), p1: CGPoint(x: 1, y: 0))
//		))
		
		/* *** TESTING THE projectedPoint METHOD *** */
//		/* (x: 0.5, y: 0.5) */
//		print(Grid.projectedPoint(
//			CGPoint(x: 1, y: 0),
//			on: (CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 1))
//		))
//		/* (x: 0.5, y: 0.5) */
//		print(Grid.projectedPoint(
//			CGPoint(x: 0, y: 1),
//			on: (CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 1))
//		))
//		/* (x: 1, y: 1) */
//		print(Grid.projectedPoint(
//			CGPoint(x: 1, y: 1),
//			on: (CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 1))
//		))
	}
	
	subscript(coordinate: Coordinate) -> Quadrilateral? {
		return self[coordinate.col, coordinate.row]
	}
	
	subscript(col: Int, row: Int) -> Quadrilateral? {
		assert(row >= 0 && row < nRows)
		assert(col >= 0 && col < nCols)
		return cells[col + row*nCols]
	}
	
	func coordinatesIntersectingSurfaceBetweenCircles(_ c1: Circle, _ c2: Circle, blacklisted: Set<Coordinate> = []) -> Set<Coordinate> {
		var result = Set<Coordinate>()
		
		let maxRadius = max(c1.radius, c2.radius)
		let minReachablePoint = CGPoint(x: min(c1.center.x, c2.center.x) - maxRadius, y: min(c1.center.y, c2.center.y) - maxRadius)
		let maxReachablePoint = CGPoint(x: max(c1.center.x, c2.center.x) + maxRadius, y: max(c1.center.y, c2.center.y) + maxRadius)
		
		for col in 0..<nCols {
			for row in 0..<nRows {
				let c = Grid.Coordinate(col: col, row: row)
				guard let q = self[c] else {continue}
				guard !blacklisted.contains(c) else {continue}
				
				let enclosingRect = square(at: c)
				/* Basic detection of unreachable quadrilaterals. */
				guard enclosingRect.minX <= maxReachablePoint.x else {continue}
				guard enclosingRect.minY <= maxReachablePoint.y else {continue}
				guard enclosingRect.maxX >= minReachablePoint.x else {continue}
				guard enclosingRect.maxY >= minReachablePoint.y else {continue}
				
				if q.points.contains(where: { $0.distance(from: c1.center) <= c1.radius || $0.distance(from: c2.center) <= c2.radius }) {
					/* The quadrilateral has at least one point inside at least one
					 * of the circles (easiest case). */
					result.insert(c)
					continue
				}
				
				/* Basic detection did not see a hit. Let’s dig deeper. */
				
				// TODO: Dig deeper
				//          1) Do any of the segments of the quadrilateral intersect
				//             with either of the circles
				//          2) Do any of the segments of the quadrilateral intersect
				//             with the segment from the center of c1 to the center
				//             of c2?
				//          3) Do any of the segments of the quadrilateral intersect
				//             with the segments parallels to the previous segment,
				//             until the border of the circle?
			}
		}
		
		return result
	}
	
	func square(at coordinates: Coordinate) -> CGRect {
		assert(coordinates.row >= 0 && coordinates.row < nRows)
		assert(coordinates.col >= 0 && coordinates.col < nCols)
		return CGRect(
			x: xStart + CGFloat(coordinates.col) * gridSize,
			y: yStart + CGFloat(coordinates.row) * gridSize,
			width: gridSize, height: gridSize
		)
	}
	
	/* ***************
	   MARK: - Private
	   *************** */
	
	private let xStart, yStart: CGFloat
	private let cells: [Quadrilateral?]
	
	/* Converted straight from Objective-C from FLGraphicsUtils.m in the
	 * Logiblocs project. I don’t really understand the method anymore… */
	private static func intersectionPoint(between s1: Segment, and s2: Segment) -> CGPoint? {
		var currentDenomin = (
			(s1.p0.y - s1.p1.y) * (s2.p1.x - s2.p0.x) -
			(s2.p1.y - s2.p0.y) * (s1.p0.x - s1.p1.x)
		)
		guard abs(currentDenomin) > 0.000001 else {return nil}
		
		let coeffForIsInLine = (
			((s2.p0.y - s1.p1.y) * (s1.p0.x - s1.p1.x) -
			 (s1.p0.y - s1.p1.y) * (s2.p0.x - s1.p1.x)) /
			currentDenomin
		)
		
		let linesIntersect = (coeffForIsInLine >= 0 && coeffForIsInLine <= 1)
		guard linesIntersect else {return nil}
		
		let coeffForResize: CGFloat
		currentDenomin = s1.p0.x - s1.p1.x
		if abs(currentDenomin) > 0.000001 {
			coeffForResize = (coeffForIsInLine * (s2.p1.x - s2.p0.x) + s2.p0.x - s1.p1.x) / currentDenomin
		} else {
			currentDenomin = s1.p0.y - s1.p1.y
			if abs(currentDenomin) > 0.000001 {
				coeffForResize = (coeffForIsInLine * (s2.p1.y - s2.p0.y) + s2.p0.y - s1.p1.y) / currentDenomin
			} else {
				return nil
			}
		}
		
		return CGPoint(
			x: s1.p1.x + (s1.p0.x - s1.p1.x) * coeffForResize,
			y: s1.p1.y + (s1.p0.y - s1.p1.y) * coeffForResize
		)
	}
	
	private static func projectedPoint(_ p: CGPoint, on line: (CGPoint, CGPoint)) -> CGPoint? {
		let dx = line.1.x - line.0.x
		let dy = line.1.y - line.0.y
		
		let denomin = dx * dx + dy * dy
		guard denomin > 0.000001 else {
			/* The points of the line are too close, or even equal. */
			return nil
		}
		
		let coeffForIntersectPoint = (
			((line.1.x - line.0.x) * (p.x - line.0.x) +
			 (line.1.y - line.0.y) * (p.y - line.0.y)) /
			denomin
		)
		return CGPoint(x: line.0.x + coeffForIntersectPoint*(line.1.x - line.0.x),
							y: line.0.y + coeffForIntersectPoint*(line.1.y - line.0.y))
	}
	
	/* We assume points are correct (p not in path and d in path).
	 * Note this method uses a terrible algorithm. We should use maths to find
	 * the value we want instead of iterating points on the lines until I we
	 * reach what we search for…
	 * Actually the method above (intersectionPoint) could probably do this job
	 * for us. */
	private static func nearestPoint(in path: CGPath, from p: CGPoint, direction d: CGPoint) -> CGPoint {
		let precision = CGFloat(0.001)
		
		var curP = p
		var t = CGFloat(1)
		let xm = p.x-d.x, ym = p.y-d.y
		while !path.contains(curP) {
			curP.x = t*xm + d.x
			curP.y = t*ym + d.y
			t -= precision
			
			guard t >= 0 else {
				/* We did the whole line between p and d, but still did not find a
				 * point in the line contained in the path. Either the input values
				 * are incorrect, or we were not precise enough.
				 * In order to return something, we’ll return the point in the
				 * middle between p and d. */
				return CGPoint(x: (p.x + d.x)/2, y: (p.y + d.y)/2)
			}
		}
		return curP
	}
	
}
