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
	
	@objc
	static var localizedSettingValue: String {
		let shape = UserDefaults.standard.data(forKey: Constants.UserDefault.gameShape).flatMap{ NSKeyedUnarchiver.unarchiveObject(with: $0) } as? GameShape ?? GameShape(type: .square)
		switch shape.shapeType {
		case .square:   return NSLocalizedString("square",   comment: "Square shape type")
		case .hexagon:  return NSLocalizedString("hexagon",  comment: "Hexagon shape type")
		case .triangle: return NSLocalizedString("triangle", comment: "Triangle shape type")
		}
	}
	
	@IBOutlet var segmentedControlShape: UISegmentedControl!
	@IBOutlet var shapeView: ShapeView!
	
	required init?(coder aDecoder: NSCoder) {
		shape = UserDefaults.standard.data(forKey: Constants.UserDefault.gameShape).flatMap{ NSKeyedUnarchiver.unarchiveObject(with: $0) } as? GameShape ?? GameShape(type: .square)
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		segmentedControlShape.selectedSegmentIndex = shape.shapeType.rawValue
		shapeView.gameShape = shape
	}
	
	@IBAction func shapeChanged(_ sender: AnyObject) {
		shape.shapeType = GameShapeType(rawValue: segmentedControlShape.selectedSegmentIndex) ?? .square
		UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: shape), forKey: Constants.UserDefault.gameShape)
		
		shapeView.setNeedsDisplay()
	}
	
	/* ***************
      MARK: - Private
	   *************** */
	
	private var shape: GameShape
	
}
