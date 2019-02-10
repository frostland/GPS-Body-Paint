/*
 * PlayingMode.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2019/2/9.
 * Copyright © 2019 Frost Land. All rights reserved.
 */

import Foundation



enum PlayingMode {
	
	static let fillInId = 0
	static let timeLimitId = 1
	
	case fillIn(percentGoal: Int)
	case timeLimit(duration: TimeInterval)
	
	var id: Int {
		switch self {
		case .fillIn:    return PlayingMode.fillInId
		case .timeLimit: return PlayingMode.timeLimitId
		}
	}
	
}
