//
//  VSOGameProgress.m
//  GPS Body Paint
//
//  Created by François Lamboley on 7/16/09.
//  Copyright 2009 VSO-Software. All rights reserved.
//

#import "VSOGameProgress.h"
#import "VSOUtils.h"

@implementation VSOGameProgress

@synthesize doneArea;
@synthesize gridPlayGame;
@synthesize startDate;
@synthesize settings;
@synthesize progress;
@synthesize delegate;

- (id)initWithSettings:(VSOSettings *)s
{
	if ((self = [super init]) != nil) {
		timeLimitTimer = nil;
		self.settings = s;
		progress = NULL;
		doneArea = 0.;
		
		gameOver = NO;
	}
	
	return self;
}

- (void)gameDidStartWithLocation:(CGPoint)p diameter:(CGFloat)d
{
	NSUInteger xSize = [gridPlayGame numberOfHorizontalPixels];
	NSUInteger ySize = [gridPlayGame numberOfVerticalPixels];
	/* Creating grid from settings */
	NSDLog(@"Progress table of size %d:%d allocation", xSize, ySize);
	/* The test below was here to force a crash when a certain bug occurs */
	if (xSize == ySize && xSize == 0) *(char*)NULL = 0;
	progress = (CGFloat **)malloc2DTable(xSize, ySize, sizeof(CGFloat));
	
	for (unsigned int i = 0; i<xSize; i++)
		for (unsigned int j = 0; j<ySize; j++)
			progress[i][j] = 0;
	
	doneArea = 0.;
	startDate = [NSDate dateWithTimeIntervalSinceNow:0];
	if (settings.playingMode == VSOPlayingModeTimeLimit)
		timeLimitTimer = [NSTimer scheduledTimerWithTimeInterval:settings.playingTime + 1. target:self selector:@selector(finishGame:) userInfo:NULL repeats:NO];
	
	lastPoint = p;
	[self playerMovedTo:p diameter:d];
}

- (void)gameDidFinish
{
	[timeLimitTimer invalidate];
	timeLimitTimer = nil;
}

- (void)finishGame:(NSTimer *)t
{
	gameOver = YES;
	[delegate gameDidFinish:YES];
}

- (void)playerMovedTo:(CGPoint)p diameter:(CGFloat)d
{
	if (!startDate/* The gameDidStart function was not called */ || gameOver) return;
	
	NSUInteger nPixels;
	CGPoint *gridPixel = [gridPlayGame gridPixelsBetweenPoint:p withPrecision:d andPoint:lastPoint withPrecision:d nGridPixelsFound:&nPixels];
	[gridPlayGame setCurUserLocation:p withPrecision:d];
	
	for (NSUInteger i = 0; i<nPixels; i++) {
		int x = (int)gridPixel[i].x;
		int y = (int)gridPixel[i].y;
		
		if (x >= [gridPlayGame numberOfHorizontalPixels]) continue;
		if (y >= [gridPlayGame numberOfVerticalPixels]) continue;
		
		if (progress[x][y] == 0) doneArea += [gridPlayGame areaAtGridX:x gridY:y];
		progress[x][y]++;
		
		[gridPlayGame addSquareVisitedAtGridX:x gridY:y];
	}
	
	lastPoint = p;
	free(gridPixel);
	
	switch (settings.playingMode) {
		case VSOPlayingModeFillIn:
			if ([self percentDone] >= settings.playingFillPercentToDo) gameOver = YES;
			break;
		case VSOPlayingModeTimeLimit:
			if (-[startDate timeIntervalSinceNow] >= settings.playingTime) gameOver = YES;
			break;
		default: [NSException raise:@"Unknown playing mode" format:@"The playing mode %d is not valid", settings.playingMode];
	}
	if (gameOver) [delegate gameDidFinish:YES];
}

- (void)setCurrentHeading:(CGFloat)h
{
	[gridPlayGame setCurHeading:h];
}

- (CGFloat)percentDone
{
	return (doneArea/[gridPlayGame totalArea])*100.;
}

- (CGFloat)totalArea
{
	return [gridPlayGame totalArea];
}

- (void)dealloc
{
	NSDLog(@"Deallocing a VSOGameProgress");
	
	free2DTable((void **)progress, [gridPlayGame numberOfHorizontalPixels]);
	progress = NULL;
	
	[timeLimitTimer invalidate];
	timeLimitTimer = nil;
}

@end
