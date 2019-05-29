/*
 * GameShape.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2018/10/24.
 * Copyright © 2018 Frost Land. All rights reserved.
 */

import CoreGraphics
import Foundation
import UIKit



enum BuiltInGameShapeId : Int {
	
	case square = 0
	case hexagon = 1
	case triangle = 2
	
	var polygon: [CGPoint] {
		switch self {
		case .square:
			return [
				CGPoint(x: 0, y: 0),
				CGPoint(x: 0, y: 1),
				CGPoint(x: 1, y: 1),
				CGPoint(x: 1, y: 0),
			]
			
		case .hexagon:
			let t = CGAffineTransform(rotationAngle: CGFloat.pi/3.0)
			let p0 = CGPoint(x: 1, y: 0)
			let p1 = p0.applying(t)
			let p2 = p1.applying(t)
			let p3 = p2.applying(t)
			let p4 = p3.applying(t)
			let p5 = p4.applying(t)
			return [p0, p1, p2, p3, p4, p5]
			
		case .triangle:
			return [
				CGPoint(x:   1, y: 1),
				CGPoint(x: 0.5, y: 0),
				CGPoint(x:   0, y: 1)
			]
		}
	}
	
}


class GameShape {
	
	/** The polygon for the shape. */
	let polygon: [CGPoint]
	/** The built-in shape id for the current shape. Can be `nil` if the polygon
	was set manually on the shape. */
	let builtinGameShapeId: BuiltInGameShapeId?
	
	init(polygon p: [CGPoint]) {
		builtinGameShapeId = nil
		polygon = p
	}
	
	init(shapeId: BuiltInGameShapeId) {
		builtinGameShapeId = shapeId
		polygon = shapeId.polygon
	}
	
	/** The path for the shape in the given rect. The path will be not have any
	padding or magins from the rect. */
	func pathForDrawing(in drawingRect: CGRect) -> CGPath {
		if let path = shapePathCache[drawingRect] {return path}
		
		let tmpPath = CGMutablePath()
		tmpPath.addLines(between: polygon)
		tmpPath.closeSubpath()
		
		let bb = tmpPath.boundingBox
		let scale = min(drawingRect.width/bb.width, drawingRect.height/bb.height)
		
		let t = CGAffineTransform.identity
			.concatenating(CGAffineTransform(translationX: -bb.midX, y: -bb.midY))
			.concatenating(CGAffineTransform(scaleX: scale, y: scale))
			.concatenating(CGAffineTransform(translationX: drawingRect.midX, y: drawingRect.midY))
		
		let path = CGMutablePath()
		path.addLines(between: polygon, transform: t)
		path.closeSubpath()
		shapePathCache[drawingRect] = path
		
		return path
	}
	
	/* ***************
      MARK: - Private
	   *************** */
	
	private var shapePathCache = [CGRect: CGPath]()
	
	/** Compute the game rect from the map bounds. The game rect is a square
	whose side is a little shorter than the shorter side of the input rect (90%
	of the size), centered in the input rect. */
//	private func gameRect(from rect: CGRect) -> CGRect {
//		let size = min(rect.width, rect.height)*0.9
//		let center = CGPoint(x: rect.midX, y: rect.midY)
//
//		return CGRect(x: center.x - size/2, y: center.y - size/2, width: size, height: size).integral
//	}
	
}
