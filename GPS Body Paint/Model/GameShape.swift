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
	
	func pathForDrawing(in rect: CGRect) -> CGPath {
		if let path = shapePathCache[rect] {return path}
		
		let drawingRect = gameRect(from: rect)
		let tmpPath = CGMutablePath()
		
		tmpPath.addLines(between: polygon)
		tmpPath.closeSubpath()
		
		let bb = tmpPath.boundingBox
		let t = CGAffineTransform.identity
			.concatenating(CGAffineTransform(translationX: -bb.midX, y: -bb.midY))
			.concatenating(CGAffineTransform(scaleX: drawingRect.width/bb.width, y: drawingRect.height/bb.height))
			.concatenating(CGAffineTransform(translationX: drawingRect.midX, y: drawingRect.midY))
		
		let path = CGMutablePath()
		path.addLines(between: polygon, transform: t)
		path.closeSubpath()
		shapePathCache[rect] = path
		
		return path
	}
	
	/** Compute the game rect from the map bounds. The game rect is a square
	whose side is a little shorter than the shorter side of the input rect (90%
	of the size), centered in the input rect. */
	func gameRect(from rect: CGRect) -> CGRect {
		let size = min(rect.width, rect.height)*0.9
		let center = CGPoint(x: rect.midX, y: rect.midY)
		
		return CGRect(x: center.x - size/2, y: center.y - size/2, width: size, height: size).integral
	}
	
	func draw(in rect: CGRect, context: CGContext) {
		context.saveGState()
		
		context.setLineWidth(0.5)
		
		context.setStrokeColor(UIColor.red.cgColor)
		context.setFillColor(UIColor.red.withAlphaComponent(0.15).cgColor)
		
		context.addPath(pathForDrawing(in: rect))
		context.drawPath(using: .fillStroke)
		
		context.restoreGState()
	}
	
	/* ***************
      MARK: - Private
	   *************** */
	
	private var shapePathCache = [CGRect: CGPath]()
	
}
