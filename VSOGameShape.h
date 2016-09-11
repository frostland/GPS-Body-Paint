//
//  VSOGameShape.h
//  GPS Body Paint
//
//  Created by François Lamboley on 7/20/09.
//  Copyright 2009 VSO-Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Constants.h"

@interface VSOGameShape : NSObject <NSCoding> {
	VSOGameShapeType shapeType;
	
	CGPathRef shapeCGPath;
	NSUInteger nPoints;
	CGPoint *polygon;
}
@property() VSOGameShapeType shapeType;
+ (VSOGameShape *)gameShapeWithType:(VSOGameShapeType)t;

/* Designate initializer */
- (id)initWithType:(VSOGameShapeType)t;

- (CGPathRef)shapeCGPathForDrawRect:(CGRect)rect;
- (CGRect)gameRectFromRect:(CGRect)rect;
- (void)drawInRect:(CGRect)rect withContext:(CGContextRef)c;

@end
