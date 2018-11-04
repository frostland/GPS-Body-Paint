/*
 * VSOGameProgress.m
 * GPS Body Paint
 *
 * Created by François Lamboley on 7/16/09.
 * Copyright 2009 VSO-Software. All rights reserved.
 */

#import "VSOGameProgress.h"
#import "VSOUtils.h"

#import "GPS_Body_Paint-Swift.h"



@interface VSOGameProgress ()

@property(nonatomic, assign) CGFloat **progress;
@property(nonatomic, assign) CGFloat doneArea;
@property(nonatomic, retain) NSDate *startDate;

@end


@implementation VSOGameProgress

- (id)initWithSettings:(Settings *)s
{
	if ((self = [super init]) != nil) {
		timeLimitTimer = nil;
		self.settings = s;
		self.progress = NULL;
		self.doneArea = 0.;
		
		gameOver = NO;
	}
	
	return self;
}

- (void)gameDidStartWithLocation:(CGPoint)p diameter:(CGFloat)d
{
	NSUInteger xSize = self.gridPlayGame.numberOfHorizontalPixels;
	NSUInteger ySize = self.gridPlayGame.numberOfVerticalPixels;
	/* Creating grid from settings */
	NSDLog(@"Allocation of progress table (size %lu:%lu)", (unsigned long)xSize, (unsigned long)ySize);
	if (xSize == ySize && xSize == 0) [NSException raise:@"Invalid Size" format:@"Got size %lux%lu which is invalid.", (unsigned long)xSize, (unsigned long)ySize];
	self.progress = (CGFloat **)malloc2DTable(xSize, ySize, sizeof(CGFloat));
	
	for (unsigned int i = 0; i<xSize; i++)
		for (unsigned int j = 0; j<ySize; j++)
			self.progress[i][j] = 0;
	
	self.doneArea = 0.;
	self.startDate = [NSDate dateWithTimeIntervalSinceNow:0];
	if (self.settings.playingMode == VSOPlayingModeTimeLimit)
		timeLimitTimer = [NSTimer scheduledTimerWithTimeInterval:self.settings.playingTime + 1. target:self selector:@selector(finishGame:) userInfo:NULL repeats:NO];
	
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
	[self.delegate gameDidFinish:YES];
}

- (void)playerMovedTo:(CGPoint)p diameter:(CGFloat)d
{
	if (!self.startDate/* The gameDidStart function was not called */ || gameOver) return;
	
	NSUInteger nPixels;
	CGPoint *gridPixel = [self.gridPlayGame gridPixelsBetweenPoint:p withPrecision:d andPoint:lastPoint withPrecision:d nGridPixelsFound:&nPixels];
	[self.gridPlayGame setCurUserLocation:p withPrecision:d];
	
	for (NSUInteger i = 0; i<nPixels; i++) {
		int x = (int)gridPixel[i].x;
		int y = (int)gridPixel[i].y;
		
		if (x >= [self.gridPlayGame numberOfHorizontalPixels]) continue;
		if (y >= [self.gridPlayGame numberOfVerticalPixels]) continue;
		
		if (self.progress[x][y] == 0) self.doneArea += [self.gridPlayGame areaAtGridX:x gridY:y];
		self.progress[x][y]++;
		
		[self.gridPlayGame addSquareVisitedAtGridX:x gridY:y];
	}
	
	lastPoint = p;
	free(gridPixel);
	
	switch (self.settings.playingMode) {
		case VSOPlayingModeFillIn:
			if (self.percentDone >= self.settings.playingFillPercentToDo) gameOver = YES;
			break;
			
		case VSOPlayingModeTimeLimit:
			if (-self.startDate.timeIntervalSinceNow >= self.settings.playingTime) gameOver = YES;
			break;
			
		default: [NSException raise:@"Unknown playing mode" format:@"The playing mode %lu is not valid", (unsigned long)self.settings.playingMode];
	}
	if (gameOver) [self.delegate gameDidFinish:YES];
}

- (void)setCurrentHeading:(CGFloat)h
{
	[self.gridPlayGame setCurHeading:h];
}

- (CGFloat)percentDone
{
	return (self.doneArea/self.gridPlayGame.totalArea)*100.;
}

- (CGFloat)totalArea
{
	return self.gridPlayGame.totalArea;
}

- (void)dealloc
{
	NSDLog(@"Deallocing a VSOGameProgress");
	
	free2DTable((void **)self.progress, self.gridPlayGame.numberOfHorizontalPixels);
	self.progress = NULL;
	
	[timeLimitTimer invalidate];
	timeLimitTimer = nil;
}

@end
