//
//  VSOGameProgress.h
//  GPS Body Paint
//
//  Created by François Lamboley on 7/16/09.
//  Copyright 2009 VSO-Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VSOSettings.h"

@protocol VSOGridPlayGame <NSObject>

- (NSUInteger)numberOfHorizontalPixels;
- (NSUInteger)numberOfVerticalPixels;
/* Don't forget to free the return of this function!!! */
- (CGPoint *)gridPixelsAtPoint:(CGPoint)p withPrecision:(CGFloat)precision nGridPixelsFound:(NSUInteger *)i;
- (CGPoint *)gridPixelsBetweenPoint:(CGPoint)p withPrecision:(CGFloat)d andPoint:(CGPoint)lastPoint withPrecision:(CGFloat)d nGridPixelsFound:(NSUInteger *)i;

- (CGFloat)totalArea;
- (CGFloat)areaAtGridX:(NSUInteger)x gridY:(NSUInteger)y;

/* If h == -1., heading is undefined */
- (void)setCurHeading:(CGFloat)h;
/* p and precision are in the receiver's coordinate system */
- (void)setCurUserLocation:(CGPoint)p withPrecision:(CGFloat)precision;
- (void)addSquareVisitedAtGridX:(NSUInteger)x gridY:(NSUInteger)y;

@end

@protocol VSOGameProgressDelegate;

@interface VSOGameProgress : NSObject {
	VSOSettings *settings;
	id <VSOGridPlayGame> gridPlayGame;
	__weak id <VSOGameProgressDelegate> delegate;
	NSTimer *timeLimitTimer;
	
	BOOL gameOver;
	CGPoint lastPoint;
	CGFloat doneArea;
	NSDate *startDate;
	CGFloat **progress;
}
@property(readonly) CGFloat doneArea;
@property(nonatomic, readonly) NSDate *startDate;
@property(nonatomic, retain) id <VSOGridPlayGame> gridPlayGame;
@property(nonatomic, retain) VSOSettings *settings;
@property(nonatomic, readonly) CGFloat **progress;
@property(nonatomic, weak) id <VSOGameProgressDelegate> delegate;
- (id)initWithSettings:(VSOSettings *)s;

- (void)gameDidStartWithLocation:(CGPoint)p diameter:(CGFloat)d;
- (void)playerMovedTo:(CGPoint)p diameter:(CGFloat)d;
- (void)setCurrentHeading:(CGFloat)h;
- (void)gameDidFinish;

- (CGFloat)percentDone;
- (CGFloat)totalArea; /* In pixel/m^2 */

@end

@protocol VSOGameProgressDelegate

- (void)gameDidFinish:(BOOL)win;

@end
