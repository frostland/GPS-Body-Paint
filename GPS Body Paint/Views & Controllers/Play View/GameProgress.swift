/*
 * GameProgress.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2018/11/22.
 * Copyright © 2018 Frost Land. All rights reserved.
 */

import CoreGraphics
import CoreLocation
import Foundation



@objc
protocol GridPlayGame : class {
	
	var numberOfHorizontalPixels: Int {get}
	var numberOfVerticalPixels: Int {get}
	
	func gridPixels(at p: CGPoint, withPrecision precision: CGFloat) -> [CGPoint]
	func gridPixels(between p: CGPoint, withPrecision precision: CGFloat, andPoint lastPoint: CGPoint, withPrecision lastPrecision: CGFloat) -> [CGPoint]
	
	var totalArea: CGFloat {get}
	func area(atGridX x: Int, gridY y: Int) -> CGFloat
	
	/* If h == -1., heading is undefined */
	func setCurrentHeading(_ h: CLLocationDirection)
	/* p and precision are in the receiver's coordinate system */
	func setCurrentUserLocation(_ p: CGPoint, precision: CGFloat)
	func addSquareVisited(atGridX x: Int, gridY y: Int)
	
}


@objc
protocol GameProgressDelegate {
	
	func gameDidFinish(won: Bool)
	
}


class GameProgress : NSObject {
	
	private(set) var doneArea = CGFloat(0)
	private(set) var startDate: Date?
	var gridPlayGame: GridPlayGame?
	var settings: Settings
	private(set) var progress = [[CGFloat]]()
	weak var delegate: GameProgressDelegate?
	
	var percentDone: CGFloat {
		guard let gridPlayGame = gridPlayGame else {return 0}
		return (doneArea/gridPlayGame.totalArea)*100
	}
	
	var totalArea: CGFloat {
		guard let gridPlayGame = gridPlayGame else {return 0}
		return gridPlayGame.totalArea
	}
	
	init(settings s: Settings) {
		settings = s
	}
	
	deinit {
		timeLimitTimer?.invalidate()
		timeLimitTimer = nil
	}
	
	func gameDidStart(location p: CGPoint, diameter d: CGFloat) {
		guard let gridPlayGame = gridPlayGame else {return}
		let xSize = gridPlayGame.numberOfHorizontalPixels
		let ySize = gridPlayGame.numberOfVerticalPixels
		
		/* Creating grid from settings */
//		NSLog("Allocation of progress table (size %lu:%lu)", xSize, ySize)
		guard xSize != 0 && ySize != 0 else {fatalError("Got size \(xSize)x\(ySize) which is invalid.")}
		progress = [[CGFloat]](repeating: [CGFloat](repeating: 0, count: ySize), count: xSize)
		
		doneArea = 0
		startDate = Date()
		
		if settings.playingMode == .timeLimit {
			timeLimitTimer = Timer.scheduledTimer(timeInterval: settings.playingTime + 1, target: self, selector: #selector(GameProgress.finishGame(_:)), userInfo: nil, repeats: false)
		}
		
		lastPoint = p
		playerMoved(to: p, diameter: d)
	}
	
	func gameDidFinish() {
		timeLimitTimer?.invalidate()
		timeLimitTimer = nil
	}
	
	func playerMoved(to p: CGPoint, diameter d: CGFloat) {
		guard let gridPlayGame = gridPlayGame else {return}
		guard !gameOver else {return}
		guard let startDate = startDate else {return}
		
		let gridPixels = gridPlayGame.gridPixels(between: p, withPrecision: d, andPoint: lastPoint!, withPrecision: d)
		gridPlayGame.setCurrentUserLocation(p, precision: d)
		
		for pixel in gridPixels {
			let x = Int(pixel.x)
			let y = Int(pixel.y)
			
			guard x < gridPlayGame.numberOfHorizontalPixels else {continue}
			guard y < gridPlayGame.numberOfVerticalPixels else {continue}
			
			if progress[x][y] == 0 {doneArea += gridPlayGame.area(atGridX: x, gridY: y)}
			progress[x][y] += 1
			
			gridPlayGame.addSquareVisited(atGridX: x, gridY: y)
		}
		
		lastPoint = p
		
		switch settings.playingMode {
		case .fillIn:    if Int(percentDone)                >= settings.playingFillPercentToDo {gameOver = true}
		case .timeLimit: if -startDate.timeIntervalSinceNow >= settings.playingTime            {gameOver = true}
		}
		if gameOver {delegate?.gameDidFinish(won: true)}
	}
	
	func setCurrentHeading(_ h: CLLocationDirection) {
		gridPlayGame?.setCurrentHeading(h)
	}
	
	private var gameOver = false
	private var lastPoint: CGPoint?
	private var timeLimitTimer: Timer?
	
	@objc
	private func finishGame(_ timer: Timer) {
		gameOver = true
		delegate?.gameDidFinish(won: true)
	}
	
}
