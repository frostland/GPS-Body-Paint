/*
 * GridAnnotationView.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2018/11/8.
 * Copyright © 2018 Frost Land. All rights reserved.
 */

import Foundation
import MapKit
import UIKit



class GridAnnotationView : MKAnnotationView, GridPlayGame {
	
	var totalArea = CGFloat(0)
	var map: MKMapView!
	var gameProgress: GameProgress!
	
	var numberOfHorizontalPixels: Int {
		computeMetadataIfNeeded()
		return xSize
	}
	
	var numberOfVerticalPixels: Int {
		computeMetadataIfNeeded()
		return ySize
	}
	
	override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
		curUserLocationView = CurLocationView(frame: .zero)
		curUserLocationView.layer.zPosition = 1000000
		curUserLocationView.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin]
		
		super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
		
		isOpaque = false
		isUserInteractionEnabled = false
		
		addSubview(curUserLocationView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("Unsupported init method")
	}
	
	override func draw(_ rect: CGRect) {
		guard let c = UIGraphicsGetCurrentContext() else {return}
		computeMetadataIfNeeded()
		
		c.saveGState()
		
		c.addPath(gameProgress.settings.gameShape.pathForDrawing(in: bounds))
		c.clip()
		
		c.setStrokeColor(UIColor.black.withAlphaComponent(0.5).cgColor)
		for x in stride(from: CGFloat(xStart), to: gameRect.maxX, by: baseRect.width) {
			c.move(to: CGPoint(x: x, y: gameRect.minY))
			c.addLine(to: CGPoint(x: x, y: gameRect.maxY))
		}
		for y in stride(from: CGFloat(yStart), to: gameRect.maxY, by: baseRect.height) {
			c.move(to: CGPoint(x: gameRect.minX, y: y))
			c.addLine(to: CGPoint(x: gameRect.maxX, y: y))
		}
		c.strokePath()
		
		c.restoreGState()
		
		gameProgress.settings.gameShape.draw(in: bounds, context: c)
	}
	
	func rectFrom(gridPixelX x: Int, y: Int) -> CGRect {
		computeMetadataIfNeeded()
		return CGRect(x: CGFloat(xStart) + baseRect.width*CGFloat(x), y: CGFloat(yStart) + baseRect.height*CGFloat(y), width: baseRect.width, height: baseRect.height)
	}
	
	func addSquareVisited(atGridX x: Int, gridY y: Int) {
		guard gameProgress.progress[x][y] <= 1.0 else {return}
		
		let v = SquareFilledView(frame: rectFrom(gridPixelX: x, y: y))
		v.clippingPath = gameProgress.settings.gameShape.pathForDrawing(in: bounds)
		v.alpha = 0
		addSubview(v)
		UIView.animate(withDuration: 0.5, animations: {
			v.alpha = 0.7
		})
	}
	
	func area(atGridX x: Int, gridY y: Int) -> CGFloat {
		let points = gridDescription[x][y]
		return (
			areaOfTriangle(p1: points[0], p2: points[1], p3: points[3]) +
				areaOfTriangle(p1: points[1], p2: points[2], p3: points[3])
		)
	}
	
	func gridPixels(at p: CGPoint, withPrecision precision: CGFloat) -> [CGPoint] {
		return gridPixels(between: p, withPrecision: precision, andPoint: p, withPrecision: precision)
	}
	
	func gridPixels(between p: CGPoint, withPrecision precision: CGFloat, andPoint lastPoint: CGPoint, withPrecision lastPrecision: CGFloat) -> [CGPoint] {
		var hits = [CGPoint]()
		computeMetadataIfNeeded()
		
		if gameProgress.settings.gameShape.pathForDrawing(in: bounds).contains(p) {
			let xP = (p.x + (bounds.minX-gameRect.minX)).rounded(.towardZero)/baseRect.width
			let yP = (p.y + (bounds.minY-gameRect.minY)).rounded(.towardZero)/baseRect.height
			hits.append(CGPoint(x: xP, y: yP))
		}
		
		let pathToCheck = CGMutablePath()
		pathToCheck.addEllipse(in: CGRect(x:         p.x -     precision/2, y:         p.y -     precision/2, width: precision, height: precision))
		pathToCheck.addEllipse(in: CGRect(x: lastPoint.x - lastPrecision/2, y: lastPoint.y - lastPrecision/2, width: precision, height: precision))
		pathToCheck.move(to:    CGPoint(x:         p.x +     precision/2, y:         p.y))
		pathToCheck.addLine(to: CGPoint(x: lastPoint.x + lastPrecision/2, y: lastPoint.y))
		pathToCheck.addLine(to: CGPoint(x: lastPoint.x + lastPrecision/2, y: lastPoint.y))
		pathToCheck.addLine(to: CGPoint(x:         p.x +     precision/2, y:         p.y))
		pathToCheck.closeSubpath()
		
		for x in 0..<xSize {
			for y in 0..<ySize {
				var foundHit = false
				let curGridRect = rectFrom(gridPixelX: x, y: y)
				for i in 0..<4 {
					guard !foundHit else {break}
					var curPoint = gridDescription[x][y][i]
					curPoint.x += curGridRect.minX
					curPoint.y += curGridRect.minY
					if pathToCheck.contains(curPoint) {
						hits.append(CGPoint(x: x, y: y))
						foundHit = true
					}
				}
			}
		}
		
//		NSLog("Hits #: %lu", hits.count)
		return hits
	}
	
	func setCurrentHeading(_ h: CLLocationDirection) {
		curUserLocationView.heading = h
	}
	
	func setCurrentUserLocation(_ p: CGPoint, precision: CGFloat) {
		UIView.animate(withDuration: 0.5, animations: {
			self.curUserLocationView.precision = precision
			self.curUserLocationView.center = p
		})
	}
	
	/* ***************
      MARK: - Private
	   *************** */
	
	private var curUserLocationView: CurLocationView
	
	private var metedataComputed = false
	private var gameRect, baseRect: CGRect!
	private var xSize = 0, ySize = 0
	private var gridDescription = [[[CGPoint]]]()
	private var xStart = 0, yStart = 0
	
	/* We assume points are correct (p not in path and d in path) */
	private func nearestPoint(in path: CGPath, from p: CGPoint, direction d: CGPoint) -> CGPoint {
		var p = p
		var t = CGFloat(1)
		let xm = p.x-d.x, ym = p.y-d.y
		while !path.contains(p) {
			p.x = t*xm + d.x
			p.y = t*ym + d.y
			t -= 0.01
		}
		return p
	}
	
	private func computeMetadataIfNeeded() {
		/* We assume gameProgress.settings.gridSize and annotation.coordinate
		 * won't change once this method has been called. */
		guard !metedataComputed else {return}
//		NSLog("Computing metadata")
		metedataComputed = true
		
		gameRect = gameProgress.settings.gameShape.gameRect(from: bounds)
		baseRect = map.convert(MKCoordinateRegion(center: annotation!.coordinate, latitudinalMeters: gameProgress.settings.gridSize, longitudinalMeters: gameProgress.settings.gridSize), toRectTo: self)
		
		xSize = Int(gameRect.width  / baseRect.width)  + 1
		ySize = Int(gameRect.height / baseRect.height) + 1
		
		xStart = Int(gameRect.minX + (baseRect.minX - gameRect.minX) - ((baseRect.minX - gameRect.minX).rounded(.towardZero) / baseRect.width ) * baseRect.width)
		yStart = Int(gameRect.minY + (baseRect.minY - gameRect.minY) - ((baseRect.minY - gameRect.minY).rounded(.towardZero) / baseRect.height) * baseRect.height)
		
		computeGridDescription()
	}
	
	private func computeGridDescription() {
		gridDescription = [[[CGPoint]]](repeating: [[CGPoint]](repeating: [CGPoint](repeating: .zero, count: 4), count: ySize), count: xSize)
		
		let shapePath = gameProgress.settings.gameShape.pathForDrawing(in: bounds)
		for x in 0..<xSize {
			for y in 0..<ySize {
				let curRect = rectFrom(gridPixelX: x, y: y).standardized
				let tl = curRect.origin
				var tr = tl; tr.x += curRect.width
				var br = tr; br.y += curRect.height
				var bl = tl; bl.y += curRect.height
				let tlc = shapePath.contains(tl)
				let trc = shapePath.contains(tr)
				let brc = shapePath.contains(br)
				let blc = shapePath.contains(bl)
				
				if tlc {gridDescription[x][y][0] = tl}
				else {
					if      trc {gridDescription[x][y][0] = nearestPoint(in: shapePath, from: tl, direction: tr)}
					else if blc {gridDescription[x][y][0] = nearestPoint(in: shapePath, from: tl, direction: bl)}
					else if brc {gridDescription[x][y][0] = nearestPoint(in: shapePath, from: tl, direction: br)}
					else {
						gridDescription[x][y][0] = .zero
						gridDescription[x][y][1] = .zero
						gridDescription[x][y][2] = .zero
						gridDescription[x][y][3] = .zero
						continue
					}
				}
				if trc {gridDescription[x][y][1] = tr}
				else {
					if      tlc {gridDescription[x][y][1] = nearestPoint(in: shapePath, from: tr, direction: tl)}
					else if brc {gridDescription[x][y][1] = nearestPoint(in: shapePath, from: tr, direction: br)}
					else if blc {gridDescription[x][y][1] = nearestPoint(in: shapePath, from: tr, direction: bl)}
					else {NSException(name: NSExceptionName(rawValue: "Error when computing grid description"), reason: "No points in path, but first point placed!", userInfo: nil).raise()}
				}
				if brc {gridDescription[x][y][2] = br}
				else {
					if      blc {gridDescription[x][y][2] = nearestPoint(in: shapePath, from: br, direction: bl)}
					else if trc {gridDescription[x][y][2] = nearestPoint(in: shapePath, from: br, direction: tr)}
					else if tlc {gridDescription[x][y][2] = nearestPoint(in: shapePath, from: br, direction: tl)}
					else {NSException(name: NSExceptionName(rawValue: "Error when computing grid description"), reason: "No points in path, but first point placed!", userInfo: nil).raise()}
				}
				if blc {gridDescription[x][y][3] = bl}
				else {
					if      brc {gridDescription[x][y][3] = nearestPoint(in: shapePath, from: bl, direction: br)}
					else if tlc {gridDescription[x][y][3] = nearestPoint(in: shapePath, from: bl, direction: tl)}
					else if trc {gridDescription[x][y][3] = nearestPoint(in: shapePath, from: bl, direction: tr)}
					else {NSException(name: NSExceptionName(rawValue: "Error when computing grid description"), reason: "No points in path, but first point placed!", userInfo: nil).raise()}
				}
				/* Bringing everything back to origin 0 */
				gridDescription[x][y][0].x -= curRect.minX; gridDescription[x][y][0].y -= curRect.minY
				gridDescription[x][y][1].x -= curRect.minX; gridDescription[x][y][1].y -= curRect.minY
				gridDescription[x][y][2].x -= curRect.minX; gridDescription[x][y][2].y -= curRect.minY
				gridDescription[x][y][3].x -= curRect.minX; gridDescription[x][y][3].y -= curRect.minY
				totalArea += area(atGridX: x, gridY: y)
			}
		}
	}
	
	private func areaOfTriangle(p1: CGPoint, p2: CGPoint, p3: CGPoint) -> CGFloat {
		let dx = p1.x - p2.x
		let dy = p1.y - p2.y
		
		if dx == 0 {
			return abs(p2.y - p1.y) * abs(p3.x - p1.x) / 2
		}
		
		let a = -dy/dx
		let b = -a*p1.x - p1.y
		
		return (sqrt(dx*dx + dy*dy) * (abs(a*p3.x + p3.y + b) / sqrt(a*a + 1)))/2
	}
	
}



private class SquareFilledView : UIView {
	
	var clippingPath: CGPath!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = .clear
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("Unexpected init method")
	}
	
	override func draw(_ rect: CGRect) {
		guard let c = UIGraphicsGetCurrentContext() else {return}
		
		let r = convert(bounds, to: superview)
		c.concatenate(CGAffineTransform(translationX: bounds.minX - r.minX, y: bounds.minY - r.minY))
		c.setFillColor(UIColor(red: 0.7, green: 0.8, blue: 1, alpha: 1).cgColor)
		c.addPath(clippingPath)
		c.fillPath()
	}
	
}
