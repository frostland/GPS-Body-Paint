/*
 * CGRect+Hashable.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2018/11/4.
 * Copyright © 2018 Frost Land. All rights reserved.
 */

import CoreGraphics
import Foundation



extension CGRect : Hashable {
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(origin.x)
		hasher.combine(origin.y)
		hasher.combine(size.width)
		hasher.combine(size.height)
	}
	
}
