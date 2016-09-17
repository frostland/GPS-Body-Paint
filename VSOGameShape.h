/*
 * VSOGameShape.h
 * GPS Body Paint
 *
 * Created by François Lamboley on 7/20/09.
 * Copyright 2009 VSO-Software. All rights reserved.
 */

#import <Foundation/Foundation.h>

#import "Constants.h"



@interface VSOGameShape : NSObject <NSCoding> {
	CGPathRef shapeCGPath;
	NSUInteger nPoints;
	CGPoint *polygon;
}

+ (VSOGameShape *)gameShapeWithType:(VSOGameShapeType)t;

/* Designate initializer */
- (id)initWithType:(VSOGameShapeType)t;

@property(nonatomic) VSOGameShapeType shapeType;

- (CGPathRef)shapeCGPathForDrawRect:(CGRect)rect;
- (CGRect)gameRectFromRect:(CGRect)rect;
- (void)drawInRect:(CGRect)rect withContext:(CGContextRef)c;

@end
