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
	
	func area() -> CGFloat {
		return cells.reduce(CGFloat(0), { $0 + ($1?.area() ?? 0) })
	}
	
	subscript(index: (row: Int, column: Int)) -> Quadrilateral? {
		return self[index.row, index.column]
	}
	
	subscript(row: Int, column: Int) -> Quadrilateral? {
		assert(row >= 0 && row < nXCells)
		assert(column >= 0 && column < nYCells)
		return cells[row + column*nXCells]
	}
	
	private let nXCells, nYCells: Int
	private let cells: [Quadrilateral?]
	
}
