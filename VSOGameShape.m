//
//  VSOGameShape.m
//  GPS Body Paint
//
//  Created by François Lamboley on 7/20/09.
//  Copyright 2009 VSO-Software. All rights reserved.
//

#import "VSOGameShape.h"

#import "VSOUtils.h"

@implementation VSOGameShape

@synthesize shapeType;

+ (VSOGameShape *)gameShapeWithType:(VSOGameShapeType)t
{
	return [(VSOGameShape *)[self alloc] initWithType:t];
}

- (id)init
{
	NSDLog(@"Initing a VSOGameShape");
	nPoints = 0;
	polygon = NULL;
	
	shapeCGPath = NULL;
	
	return [super init];
}

- (id)initWithType:(VSOGameShapeType)t
{
	if ((self = [self init]) != nil) {
		self.shapeType = t;
	}
	
	return self;
}

- (void)setShapeType:(VSOGameShapeType)t
{
	shapeType = t;
	CGPathRelease(shapeCGPath);
	shapeCGPath = NULL;
	
	switch (shapeType) {
		case VSOGameShapeTypeSquare:
			nPoints = 4;
			polygon = mallocTable(nPoints, sizeof(CGPoint));
			polygon[0] = CGPointMake(0., 0.);
			polygon[1] = CGPointMake(0., 1.);
			polygon[2] = CGPointMake(1., 1.);
			polygon[3] = CGPointMake(1., 0.);
			break;
		case VSOGameShapeTypeHexagon:
			nPoints = 6;
			polygon = mallocTable(nPoints, sizeof(CGPoint));
			CGAffineTransform t = CGAffineTransformMakeRotation(M_PI/3.);
			polygon[0] = CGPointMake(1., 0.);
			polygon[1] = CGPointApplyAffineTransform(polygon[0], t);
			polygon[2] = CGPointApplyAffineTransform(polygon[1], t);
			polygon[3] = CGPointApplyAffineTransform(polygon[2], t);
			polygon[4] = CGPointApplyAffineTransform(polygon[3], t);
			polygon[5] = CGPointApplyAffineTransform(polygon[4], t);
			break;
		case VSOGameShapeTypeTriangle:
			nPoints = 3;
			polygon = mallocTable(nPoints, sizeof(CGPoint));
			polygon[0] = CGPointMake(1., 1.);
			polygon[1] = CGPointMake(0.5, 0.);
			polygon[2] = CGPointMake(0., 1.);
			break;
		default: [NSException raise:@"Unknown challenge shape" format:@"The shape with id %d is not a valid shape", shapeType];
	}
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeValueOfObjCType:@encode(VSOGameShapeType) at:&shapeType];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [self init]) != nil) {
		[aDecoder decodeValueOfObjCType:@encode(VSOGameShapeType) at:&shapeType];
		self.shapeType = shapeType; /* This will create the polygon! */
	}
	
	return self;
}

- (CGRect)gameRectFromRect:(CGRect)rect
{
	CGRect drawingRect;
	CGFloat *minSide, *otherSide;
	CGFloat *minOrigin, *otherOrigin;
	
	drawingRect = rect;
	if (drawingRect.size.width < drawingRect.size.height) {
		minSide   = &drawingRect.size.width; otherSide   = &drawingRect.size.height;
		minOrigin = &drawingRect.origin.x;   otherOrigin = &drawingRect.origin.y;
	} else {
		minSide   = &drawingRect.size.height; otherSide   = &drawingRect.size.width;
		minOrigin = &drawingRect.origin.y;    otherOrigin = &drawingRect.origin.x;
	}
	*minOrigin +=    (*minSide)*0.1;
	*minSide   -= 2.*(*minSide)*0.1;
	*otherOrigin += ((*otherSide)-(*minSide))/2.;
	*otherSide = *minSide;
	
	return drawingRect;
}

- (CGPathRef)shapeCGPathForDrawRect:(CGRect)rect
{
	if (shapeCGPath != NULL) return shapeCGPath;
	
	CGRect drawingRect = [self gameRectFromRect:rect];
	CGMutablePathRef path = CGPathCreateMutable();
	
	CGPathAddLines(path, NULL, polygon, nPoints);
	CGPathCloseSubpath(path);
	
	CGRect bb = CGPathGetBoundingBox(path);
	CGAffineTransform t = CGAffineTransformIdentity;
	t = CGAffineTransformConcat(CGAffineTransformMakeTranslation(drawingRect.size.width/2. + drawingRect.origin.x, drawingRect.size.height/2. + drawingRect.origin.y), t);
	t = CGAffineTransformConcat(CGAffineTransformMakeScale(drawingRect.size.width/bb.size.width, drawingRect.size.height/bb.size.height), t);
	t = CGAffineTransformConcat(CGAffineTransformMakeTranslation(-(bb.size.width/2. + bb.origin.x), -(bb.size.height/2. + bb.origin.y)), t);
	CGPathRelease(path);
	
	shapeCGPath = CGPathCreateMutable();
	CGPathAddLines(path, &t, polygon, nPoints);
	CGPathCloseSubpath(path);
	
	return shapeCGPath;
}

- (void)drawInRect:(CGRect)rect withContext:(CGContextRef)c
{
	CGContextSaveGState(c);
	
	CGContextSetLineWidth(c, 0.5);
	
	CGContextSetStrokeColorWithColor(c, [[UIColor redColor] CGColor]);
	CGContextSetFillColorWithColor(c, [[[UIColor redColor] colorWithAlphaComponent:0.15] CGColor]);
	
	CGContextAddPath(c, [self shapeCGPathForDrawRect:rect]);
	CGContextDrawPath(c, kCGPathFillStroke);
	
	CGContextRestoreGState(c);
}

- (void)dealloc
{
	NSDLog(@"Deallocing a VSOGameShape");
	
	if (shapeCGPath) CGPathRelease(shapeCGPath);
	if (polygon) free(polygon);
	shapeCGPath = NULL;
	polygon = NULL;
}

@end
