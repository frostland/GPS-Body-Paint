/*
 * VSOGridAnnotationView.m
 * GPS Body Paint
 *
 * Created by François Lamboley on 7/15/09.
 * Copyright 2009 VSO-Software. All rights reserved.
 */

#import "VSOGridAnnotationView.h"

#import "GPS_Body_Paint-Swift.h"

#import "VSOUtils.h"



@interface VSOFilledSquareView : UIView

@property(nonatomic, assign) CGPathRef clippingPath;

@end


@implementation VSOFilledSquareView

- (id)initWithFrame:(CGRect)f
{
	if ((self = [super initWithFrame:f]) != nil) {
		self.backgroundColor = UIColor.clearColor;
	}
	
	return self;
}


- (void)drawRect:(CGRect)rect
{
	CGContextRef c = UIGraphicsGetCurrentContext();
	
	CGRect r = [self convertRect:self.bounds toView:[self superview]];
	CGContextConcatCTM(c, CGAffineTransformMakeTranslation(+(self.bounds.origin.x - r.origin.x), +(self.bounds.origin.y - r.origin.y)));
	CGContextSetFillColorWithColor(c, [UIColor colorWithRed:0.7 green:0.8 blue:1. alpha:1.].CGColor);
	CGContextAddPath(c, self.clippingPath);
	CGContextFillPath(c);
}

@end



#pragma mark -
@interface VSOGridAnnotationView ()

@property(nonatomic, assign) CGFloat totalArea;

@end


@implementation VSOGridAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
	if ((self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) != nil) {
		self.opaque = NO;
		self.userInteractionEnabled = NO;
		curUserLocationView = [[VSOCurLocationView alloc] initWithFrame:CGRectZero];
		curUserLocationView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
		[self addSubview:curUserLocationView];
		[curUserLocationView.layer setZPosition:1000000.];
		
		metedataComputed = NO;
		gridDescription = NULL;
	}
	return self;
}

/* We assume points are correct (p not in path and d in path) */
- (CGPoint)nearestPointInPathFrom:(CGPoint)p direction:(CGPoint)d withPath:(CGPathRef)path
{
	CGFloat t = 1.;
	CGFloat xm = p.x-d.x, ym = p.y-d.y;
	while (!CGPathContainsPoint(path, NULL, p, NO)) {
		p.x = t*xm + d.x;
		p.y = t*ym + d.y;
		t -= 0.01;
	}
	return p;
}

- (void)computeGridDescription
{
	gridDescription = (CGPoint***)malloc3DTable(xSize, ySize, 4, sizeof(CGPoint));
	
	CGPathRef shapePath = [self.gameProgress.settings.gameShape pathForDrawingIn:self.bounds];
	for (NSUInteger x = 0; x<xSize; x++) {
		for (NSUInteger y = 0; y<ySize; y++) {
			CGRect curRect = CGRectStandardize([self rectFromGridPixelAtX:x andY:y]);
			CGPoint tl = curRect.origin;
			CGPoint tr = tl; tr.x += curRect.size.width;
			CGPoint br = tr; br.y += curRect.size.height;
			CGPoint bl = tl; bl.y += curRect.size.height;
			BOOL tlc = CGPathContainsPoint(shapePath, NULL, tl, NO);
			BOOL trc = CGPathContainsPoint(shapePath, NULL, tr, NO);
			BOOL brc = CGPathContainsPoint(shapePath, NULL, br, NO);
			BOOL blc = CGPathContainsPoint(shapePath, NULL, bl, NO);
			
			if (tlc) gridDescription[x][y][0] = tl;
			else {
				if (trc)      gridDescription[x][y][0] = [self nearestPointInPathFrom:tl direction:tr withPath:shapePath];
				else if (blc) gridDescription[x][y][0] = [self nearestPointInPathFrom:tl direction:bl withPath:shapePath];
				else if (brc) gridDescription[x][y][0] = [self nearestPointInPathFrom:tl direction:br withPath:shapePath];
				else {
					gridDescription[x][y][0] = gridDescription[x][y][1] = gridDescription[x][y][2] = gridDescription[x][y][3] = CGPointZero;
					continue;
				}
			}
			if (trc) gridDescription[x][y][1] = tr;
			else {
				if (tlc)      gridDescription[x][y][1] = [self nearestPointInPathFrom:tr direction:tl withPath:shapePath];
				else if (brc) gridDescription[x][y][1] = [self nearestPointInPathFrom:tr direction:br withPath:shapePath];
				else if (blc) gridDescription[x][y][1] = [self nearestPointInPathFrom:tr direction:bl withPath:shapePath];
				else [NSException raise:@"Error when computing grid description" format:@"No points in path, but first point placed!"];
			}
			if (brc) gridDescription[x][y][2] = br;
			else {
				if (blc)      gridDescription[x][y][2] = [self nearestPointInPathFrom:br direction:bl withPath:shapePath];
				else if (trc) gridDescription[x][y][2] = [self nearestPointInPathFrom:br direction:tr withPath:shapePath];
				else if (tlc) gridDescription[x][y][2] = [self nearestPointInPathFrom:br direction:tl withPath:shapePath];
				else [NSException raise:@"Error when computing grid description" format:@"No points in path, but first point placed!"];
			}
			if (blc) gridDescription[x][y][3] = bl;
			else {
				if (brc)      gridDescription[x][y][3] = [self nearestPointInPathFrom:bl direction:br withPath:shapePath];
				else if (tlc) gridDescription[x][y][3] = [self nearestPointInPathFrom:bl direction:tl withPath:shapePath];
				else if (trc) gridDescription[x][y][3] = [self nearestPointInPathFrom:bl direction:tr withPath:shapePath];
				else [NSException raise:@"Error when computing grid description" format:@"No points in path, but first point placed!"];
			}
			/* Bringing everything back to orgini 0 */
			gridDescription[x][y][0].x -= curRect.origin.x; gridDescription[x][y][0].y -= curRect.origin.y;
			gridDescription[x][y][1].x -= curRect.origin.x; gridDescription[x][y][1].y -= curRect.origin.y;
			gridDescription[x][y][2].x -= curRect.origin.x; gridDescription[x][y][2].y -= curRect.origin.y;
			gridDescription[x][y][3].x -= curRect.origin.x; gridDescription[x][y][3].y -= curRect.origin.y;
			self.totalArea += [self areaAtGridX:x gridY:y];
		}
	}
}

- (void)computeMetadata
{
	/* We assume gameProgress.settings.gridSize and [self.annotation coordinate] won't change once this method has been called */
	if (metedataComputed) return;
	NSDLog(@"Computing metadata");
	metedataComputed = YES;
	
	gameRect = [self.gameProgress.settings.gameShape gameRectFrom:self.bounds];
	baseRect = [self.map convertRegion:MKCoordinateRegionMakeWithDistance([self.annotation coordinate], self.gameProgress.settings.gridSize, self.gameProgress.settings.gridSize) toRectToView:self];
	
	xSize = (int)(gameRect.size.width /baseRect.size.width) + 1;
	ySize = (int)(gameRect.size.height/baseRect.size.height) + 1;
	
	xStart = gameRect.origin.x + ((baseRect.origin.x - gameRect.origin.x)-((CGFloat)((int)(baseRect.origin.x - gameRect.origin.x)/baseRect.size.width )*baseRect.size.width));
	yStart = gameRect.origin.y + ((baseRect.origin.y - gameRect.origin.y)-((CGFloat)((int)(baseRect.origin.y - gameRect.origin.y)/baseRect.size.height)*baseRect.size.height));
	
	[self computeGridDescription];
}

- (void)drawRect:(CGRect)r
{
	CGContextRef c = UIGraphicsGetCurrentContext();
	
	[self computeMetadata];
	
	CGContextSaveGState(c);
	
	CGContextAddPath(c, [self.gameProgress.settings.gameShape pathForDrawingIn:r]);
	CGContextClip(c);
	
	CGContextSetStrokeColorWithColor(c, [[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor]);
	for (CGFloat x = xStart; x <= gameRect.size.width+gameRect.origin.x; x+=baseRect.size.width) {
		CGContextMoveToPoint(c, x, gameRect.origin.y);
		CGContextAddLineToPoint(c, x, gameRect.origin.y+gameRect.size.height);
	}
	for (CGFloat y = yStart; y <= gameRect.size.height+gameRect.origin.y; y+=baseRect.size.height) {
		CGContextMoveToPoint(c, gameRect.origin.x, y);
		CGContextAddLineToPoint(c, gameRect.origin.x+gameRect.size.width, y);
	}
	CGContextStrokePath(c);
	
	CGContextRestoreGState(c);
	
	[self.gameProgress.settings.gameShape drawIn:self.bounds context:c];
}

- (void)setCurHeading:(CGFloat)h
{
	curUserLocationView.heading = h;
}

- (void)setCurUserLocation:(CGPoint)p withPrecision:(CGFloat)precision
{
	[UIView animateWithDuration:.5 animations:^{
		self->curUserLocationView.precision = precision;
		self->curUserLocationView.center = p;
	}];
}

- (NSUInteger)numberOfHorizontalPixels
{
	[self computeMetadata];
	return xSize;
}

- (NSUInteger)numberOfVerticalPixels
{
	[self computeMetadata];
	return ySize;
}

/* Don't forget to free the return of this function!!! */
- (CGPoint *)gridPixelsAtPoint:(CGPoint)p withPrecision:(CGFloat)precision nGridPixelsFound:(NSUInteger *)n
{
	return [self gridPixelsBetweenPoint:p withPrecision:precision andPoint:p withPrecision:precision nGridPixelsFound:n];
}

- (CGPoint *)gridPixelsBetweenPoint:(CGPoint)p withPrecision:(CGFloat)precision andPoint:(CGPoint)lastPoint withPrecision:(CGFloat)lastPrecision nGridPixelsFound:(NSUInteger *)n
{
	NSUInteger curHitsNumber = 13;
	CGPoint *hits = mallocTable(curHitsNumber, sizeof(CGPoint));
	[self computeMetadata];
	
	*n = 0;
	if (CGPathContainsPoint([self.gameProgress.settings.gameShape pathForDrawingIn:self.bounds], NULL, p, NO)) {
		NSUInteger xP = (int)(p.x + (self.bounds.origin.x-gameRect.origin.x))/baseRect.size.width;
		NSUInteger yP = (int)(p.y + (self.bounds.origin.y-gameRect.origin.y))/baseRect.size.height;
		hits[(*n)++] = CGPointMake(xP, yP);
	}
	
	CGMutablePathRef pathToCheck = CGPathCreateMutable();
	CGPathAddEllipseInRect(pathToCheck, NULL, CGRectMake(p.x - precision/2., p.y - precision/2., precision, precision));
	CGPathAddEllipseInRect(pathToCheck, NULL, CGRectMake(lastPoint.x - lastPrecision/2., lastPoint.y - lastPrecision/2., precision, precision));
	CGPathMoveToPoint(pathToCheck, NULL, p.x+precision/2., p.y);
	CGPathAddLineToPoint(pathToCheck, NULL, lastPoint.x+lastPrecision/2., lastPoint.y);
	CGPathAddLineToPoint(pathToCheck, NULL, lastPoint.x-lastPrecision/2., lastPoint.y);
	CGPathAddLineToPoint(pathToCheck, NULL, p.x-precision/2., p.y);
	CGPathCloseSubpath(pathToCheck);
	
	for (NSUInteger x = 0; x<xSize; x++) {
		for (NSUInteger y = 0; y<ySize; y++) {
			BOOL foundHit = NO;
			CGRect curGridRect = [self rectFromGridPixelAtX:x andY:y];
			for (NSUInteger i = 0; i<4 && !foundHit; i++) {
				CGPoint curPoint = gridDescription[x][y][i];
				curPoint.x += curGridRect.origin.x;
				curPoint.y += curGridRect.origin.y;
				if (CGPathContainsPoint(pathToCheck, NULL, curPoint, NO)) {
					hits[(*n)++] = CGPointMake(x, y);
					if (*n >= curHitsNumber) {
						curHitsNumber += 9;
						hits = realloc(hits, curHitsNumber*sizeof(CGPoint));
						if (!hits) [NSException raise:@"Memory full" format:@"Cannot allocate %lu bytes", curHitsNumber*sizeof(CGPoint)];
					}
					foundHit = YES;
				}
			}
		}
	}
	CGPathRelease(pathToCheck);
	
	NSDLog(@"Hits #: %lu", (unsigned long)*n);
	
	return hits;
}

- (CGFloat)areaOfTriangleWithPoint1:(CGPoint)p1 point2:(CGPoint)p2 point3:(CGPoint)p3
{
	CGFloat dx = (p1.x - p2.x);
	CGFloat dy = (p1.y - p2.y);
	
	if (dx == 0.) {
		return ABS(p2.y - p1.y)*ABS(p3.x - p1.x) / 2.;
	}
	
	CGFloat a = -dy/dx;
	CGFloat b = -a*p1.x - p1.y;
	
	return (sqrt(dx*dx + dy*dy)*(ABS(a*p3.x + p3.y + b)/sqrt(a*a + 1.)))/2.;
}

- (CGFloat)areaAtGridX:(NSUInteger)x gridY:(NSUInteger)y
{
	CGPoint *points = gridDescription[x][y];
	return ([self areaOfTriangleWithPoint1:points[0] point2:points[1] point3:points[3]] +
			  [self areaOfTriangleWithPoint1:points[1] point2:points[2] point3:points[3]]);
}

- (CGRect)rectFromGridPixelAtX:(NSUInteger)x andY:(NSUInteger)y
{
	[self computeMetadata];
	
	return CGRectMake(xStart + baseRect.size.width*x, yStart + baseRect.size.height*y, baseRect.size.width, baseRect.size.height);
}

- (void)addSquareVisitedAtGridX:(NSUInteger)x gridY:(NSUInteger)y
{
	if (self.gameProgress.progress[x][y] > 1) return;
	
	VSOFilledSquareView *v = [[VSOFilledSquareView alloc] initWithFrame:[self rectFromGridPixelAtX:x andY:y]];
	v.clippingPath = [self.gameProgress.settings.gameShape pathForDrawingIn:self.bounds];
	v.alpha = 0.;
	[self addSubview:v];
	[UIView animateWithDuration:.5 animations:^{
		v.alpha = .7;
	}];
}

- (void)dealloc
{
	NSDLog(@"Deallocing a VSOGridAnnotationView");
	if (gridDescription != NULL) free3DTable((void***)gridDescription, xSize, ySize);
}

@end
