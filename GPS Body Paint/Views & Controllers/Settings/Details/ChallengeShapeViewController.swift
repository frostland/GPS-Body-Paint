/*
 * ChallengeShapeViewController.swift
 * GPS Body Paint
 *
 * Created by François Lamboley on 2018/11/25.
 * Copyright © 2018 Frost Land. All rights reserved.
 */

import Foundation
import UIKit



class ChallengeShapeViewController : UIViewController {
	
	static var localizedSettingValue: String {
		switch S.sp.appSettings.gameShape.shapeType {
		case .square:   return NSLocalizedString("square",   comment: "Square shape type")
		case .hexagon:  return NSLocalizedString("hexagon",  comment: "Hexagon shape type")
		case .triangle: return NSLocalizedString("triangle", comment: "Triangle shape type")
		}
	}
	
	@IBOutlet var segmentedControlShape: UISegmentedControl!
	@IBOutlet var shapeView: ShapeView!
	
	required init?(coder aDecoder: NSCoder) {
		shape = s.gameShape
		
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		segmentedControlShape.selectedSegmentIndex = min(shape.shapeType.rawValue, segmentedControlShape.numberOfSegments)
		shapeView.gameShape = shape
	}
	
	@IBAction func shapeChanged(_ sender: AnyObject) {
		shape.shapeType = GameShapeType(rawValue: segmentedControlShape.selectedSegmentIndex) ?? .square
		shapeView.setNeedsDisplay()
		
		s.gameShape = shape
	}
	
	/* ***************
      MARK: - Private
	   *************** */
	
	/* Dependencies */
	private let s = S.sp.appSettings
	
	private var shape: GameShape
	
}
