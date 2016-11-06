/*
 * VSOPlayViewController.m
 * GPS Body Paint
 *
 * Created by François Lamboley on 7/15/09.
 * Copyright VSO-Software 2009. All rights reserved.
 */

#import "VSOPlayViewController.h"
#import "VSOUtils.h"

#import "Constants.h"



@implementation VSOPlayViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder]) {
		coordinateForAnnotation.latitude = 43.580212;
		coordinateForAnnotation.latitude = 40.792651;
		coordinateForAnnotation.longitude = 1.29724;
		coordinateForAnnotation.longitude = -73.959167;
/*		coordinate.latitude = 43.580212 + ((CGFloat)rand()/RAND_MAX)*9;
		coordinate.longitude = 1.29724 + ((CGFloat)rand()/RAND_MAX)*9;*/
		
		locationManager = [CLLocationManager new];
		locationManager.delegate = self;
		
		warnForMapLoadingErrors = [NSUserDefaults.standardUserDefaults boolForKey:VSO_WARN_ON_MAP_LOADING_FAILURE];
		
		mapFirstCenterDone = NO;
		mapLocked = NO;
		mapMoving = NO;
	}
	return self;
}

- (void)dealloc
{
	NSDLog(@"Deallocing a VSOPlayViewController");
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	/* Let's disable the auto-lock of the phone */
	UIApplication.sharedApplication.idleTimerDisabled = YES;
	
	self.gameProgress.delegate = self;
	
	self.viewGameOver.alpha = 0.;
	
	self.imageArrowTop.alpha = 0.;
	self.imageArrowDown.alpha = 0.;
	self.imageArrowLeft.alpha = 0.;
	self.imageArrowRight.alpha = 0.;
	
	self.viewLoadingMap.alpha = 0.;
	[self.labelPercentFilled setText:NSLocalizedString(@"NA", nil)];
	[self.labelPlayingTime setText:NSLocalizedString(@"NA", nil)];
	[self.labelGPSAccuracy setText:NSLocalizedString(@"NA", nil)];
	
	NSString *playingOrRemainingTitle;
	UIFont *font;
	if (self.gameProgress.settings.playingMode == VSOPlayingModeFillIn) {
		font = [self.labelPlayingTimeTitle font];
		playingOrRemainingTitle = NSLocalizedString(@"playing time", @"Playing time label title in the game view");
		
		self.labelGoal.hidden = NO;
		self.labelGoalPercentage.hidden = NO;
		[self.labelGoalPercentage setText:[NSString stringWithFormat:NSLocalizedString(@"percent complete format", @"Here, there is only a %d with the percent sign (%% for %) following"), self.gameProgress.settings.playingFillPercentToDo]];
	} else {
		font = self.labelGoal.font;
		playingOrRemainingTitle = NSLocalizedString(@"remaining time", @"Remaining time label title in the game view");
		
		self.labelGoal.hidden = YES;
		self.labelGoalPercentage.hidden = YES;
	}
	self.labelPlayingTime.font = font;
	self.labelPlayingTimeTitle.font = font;
	self.labelPlayingTimeTitle.text = playingOrRemainingTitle;
	
#ifndef SIMULATOR_CODE
	[locationManager requestWhenInUseAuthorization];
	[locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
	[locationManager startUpdatingLocation];
	[locationManager startUpdatingHeading];
#else
	srandom((unsigned int)time(NULL));
//	[self refreshFalseLocation:nil];
	t = [NSTimer scheduledTimerWithTimeInterval:3.3 target:self selector:@selector(refreshFalseLocation:) userInfo:nil repeats:YES];
#endif
	
	self.mapView.delegate = self;
	self.mapView.mapType = MKMapTypeSatellite;
	self.viewShapePreview.gameShape = self.gameProgress.settings.gameShape;
	
	[self refreshTimes:nil];
	timerRefreshTimes = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(refreshTimes:) userInfo:nil repeats:YES];
}

#pragma mark - Actions

- (IBAction)centerMapToCurrentUserLocation:(id)sender
{
	MKCoordinateRegion r = MKCoordinateRegionMakeWithDistance(coordinateForAnnotation, self.gameProgress.settings.playgroundSize, self.gameProgress.settings.playgroundSize);
	[self.mapView setRegion:r animated:YES];
}

- (IBAction)lockMapStopPlayingButtonAction:(id)sender
{
	if (!mapLocked) [self lockMap:sender];
	else            [self stopPlaying:sender];
}

- (IBAction)stopPlaying:(id)sender
{
	[self finishGame];
	
	self.mapView.delegate = nil;
	[self.mapView removeAnnotation:self];
	[self.delegate playViewControllerDidFinish:self];
}

#pragma mark - Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
	if (signbit(newHeading.headingAccuracy)) return;
	
	[self.gameProgress setCurrentHeading:newHeading.trueHeading];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
	CLLocation *newLocation = locations.lastObject;
	lastCoordinate = newLocation.coordinate;
	NSDLog(@"did get location: %g, %g. Horizontal accuracy: %g", lastCoordinate.latitude, lastCoordinate.longitude, newLocation.horizontalAccuracy);
	
	/* Negative accuracy means no location found */
	if (signbit(newLocation.horizontalAccuracy)) return;
/*	if (newLocation.horizontalAccuracy > gameProgress.settings.playgroundSize) return;*/
	
	lastGPSRefresh = [NSDate dateWithTimeIntervalSinceNow:0.];
	[self.labelGPSAccuracy setText:[NSString stringWithFormat:NSLocalizedString(@"n m format", @"Format for \"10 m\""), (NSUInteger)([newLocation horizontalAccuracy] + 0.5)]];
	
	if ([NSUserDefaults.standardUserDefaults boolForKey:VSO_UDK_FIRST_LAUNCH]) {
		UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"play info", nil) message:NSLocalizedString(@"lock map when ready msg", nil) preferredStyle:UIAlertControllerStyleAlert];
		[alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:NULL]];
		[self presentViewController:alertController animated:YES completion:NULL];
		
		[NSUserDefaults.standardUserDefaults setBool:NO forKey:VSO_UDK_FIRST_LAUNCH];
	}
	
	if (!mapLocked) {
		coordinateForAnnotation = lastCoordinate;
		
		if (!userMovedMap) [self centerMapToCurrentUserLocation:self];
		
		mapFirstCenterDone = YES;
		[self removeGettingLocationMsgAnimated];
	} else {
		[self.gameProgress playerMovedTo:[self.mapView convertCoordinate:lastCoordinate toPointToView:self.mapView]
										diameter:[self.mapView convertRegion:MKCoordinateRegionMakeWithDistance(lastCoordinate, self.gameProgress.settings.userLocationDiameter, self.gameProgress.settings.userLocationDiameter) toRectToView:self.mapView].size.width];
		NSString *passtr = [NSString stringWithFormat:NSLocalizedString(@"percent complete format from float", @"Here, there is only a %.0f with the percent sign (%% for %) following"), self.gameProgress.percentDone];
		[self.labelPercentFilled setText:passtr];
		[self.wonLabelFilledPercent setText:passtr];
		
		/* Showing arrows if user outside of map */
		MKCoordinateRegion r = self.mapView.region;
		[UIView animateWithDuration:VSO_ANIM_TIME_SHOW_ARROWS animations:^{
			if (lastCoordinate.latitude < r.center.latitude-r.span.latitudeDelta/2.) self.imageArrowDown.alpha = 1.;
			else                                                                     self.imageArrowDown.alpha = 0.;
			if (lastCoordinate.latitude > r.center.latitude+r.span.latitudeDelta/2.) self.imageArrowTop.alpha = 1.;
			else                                                                     self.imageArrowTop.alpha = 0.;
			if (lastCoordinate.longitude < r.center.longitude-r.span.longitudeDelta/2.) self.imageArrowLeft.alpha = 1.;
			else                                                                        self.imageArrowLeft.alpha = 0.;
			if (lastCoordinate.longitude > r.center.longitude+r.span.longitudeDelta/2.) self.imageArrowRight.alpha = 1.;
			else                                                                        self.imageArrowRight.alpha = 0.;
		}];
	}
}

- (void)locationManager:(CLLocationManager *)manager
		 didFailWithError:(NSError *)error
{
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"cannot get location", nil) message:NSLocalizedString(@"cannot get location. aborting play", nil) preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		[self stopPlaying:self];
	}]];
	[self presentViewController:alertController animated:YES completion:NULL];
}

#pragma mark - MKAnnotation

- (CLLocationCoordinate2D)coordinate
{
	if (mapLocked) return self.mapView.region.center;
	return coordinateForAnnotation;
}

#pragma mark - Map View Delegate

- (MKAnnotationView *)mapView:(MKMapView *)mpV viewForAnnotation:(id <MKAnnotation>)annotation
{
	if ([annotation isKindOfClass:self.class]) {
		/* Try to dequeue an existing grid view first. */
		gridAnnotationView = (VSOGridAnnotationView *)[mpV dequeueReusableAnnotationViewWithIdentifier:@"GridAnnotation"];
		
		if (gridAnnotationView == nil) gridAnnotationView = [[VSOGridAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"GridAnnotation"];
		else                           gridAnnotationView.annotation = annotation;
		
		CGFloat delta = 0.;
		gridAnnotationView.frame = CGRectMake(mpV.frame.origin.x - delta, mpV.frame.origin.y - delta,
														  mpV.frame.size.width + 2*delta, mpV.frame.size.height + 2*delta);
		self.gameProgress.gridPlayGame = gridAnnotationView;
		gridAnnotationView.gameProgress = self.gameProgress;
		gridAnnotationView.map = mpV;
		[self.gameProgress gameDidStartWithLocation:[self.mapView convertCoordinate:coordinateForAnnotation toPointToView:self.mapView]
													  diameter:[self.mapView convertRegion:MKCoordinateRegionMakeWithDistance(coordinateForAnnotation, self.gameProgress.settings.userLocationDiameter, self.gameProgress.settings.userLocationDiameter) toRectToView:self.mapView].size.width];
		
		return gridAnnotationView;
	}
	
	return nil;
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mpV
{
	NSDLog(@"mapViewWillStartLoadingMap:");
	self.buttonLockMap.enabled = NO;
	if (timerShowLoadingMap != nil) return;
	timerShowLoadingMap = [NSTimer scheduledTimerWithTimeInterval:3. target:self selector:@selector(showViewLoadingMap:) userInfo:NULL repeats:NO];
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mpV
{
	NSDLog(@"mapViewDidFinishLoadingMap:");
	[timerShowLoadingMap invalidate];
	timerShowLoadingMap = nil;
	
	[UIView animateWithDuration:VSO_ANIM_TIME_SHOW_VIEW_LOADING_MAP animations:^{
		self.viewLoadingMap.alpha = 0.;
	}];
	
	self.buttonLockMap.enabled = YES;
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mpV withError:(NSError *)error
{
	NSDLog(@"mapViewDidFailLoadingMap:withError:");
	if (mapMoving || !warnForMapLoadingErrors) {
		if (!mapMoving) [self mapViewDidFinishLoadingMap:mpV];
		return;
	}
	
	warnForMapLoadingErrors = NO;
	[timerShowLoadingMap invalidate];
	timerShowLoadingMap = nil;
	
	UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"cannot get map", nil) message:NSLocalizedString(@"cannot get map, please check network", nil) preferredStyle:UIAlertControllerStyleAlert];
	[alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"play anyway", nil) style:UIAlertActionStyleDefault handler:NULL]];
	[alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"stop playing", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
		[self stopPlaying:nil];
	}]];
	[self presentViewController:alertController animated:YES completion:NULL];
}

/* VSO Specific. NOT in original Map View Delegate... */
- (void)mapViewDidReceiveTouch:(MKMapView *)mpV
{
	userMovedMap = YES;
}

- (void)mapView:(MKMapView *)mpV regionWillChangeAnimated:(BOOL)animated
{
	NSDLog(@"mapView:regionWillChangeAnimated:");
	mapMoving = YES;
	self.buttonLockMap.enabled = NO;
}

- (void)mapView:(MKMapView *)mpV regionDidChangeAnimated:(BOOL)animated
{
	NSDLog(@"mapView:regionDidChangeAnimated:");
	mapMoving = NO;
	self.buttonLockMap.enabled = YES;
	
	NSDLog(@"Map width: %g meters", [self mapWidth]);
/*	NSUInteger w = (NSUInteger)(self.mapWidth + 0.5);
	self.labelScale.text = [NSString stringWithFormat:NSLocalizedString(@"n m format", nil), w/4];
	if (w > VSO_MAX_MAP_SPAN_FOR_PLAYGROUND) [self.labelScale setTextColor:UIColor.redColor];
	else                                     [self.labelScale setTextColor:UIColor.whiteColor];*/
	if (mapFirstCenterDone) self.viewShapePreview.hidden = NO;
}

#pragma mark - VSOGameProgressDelegate

/* Called by the game progress controller */
- (void)gameDidFinish:(BOOL)win
{
	[self finishGame];
	
	CGFloat k = 1./[self.mapView convertRegion:MKCoordinateRegionMakeWithDistance(coordinateForAnnotation, 1., 1.) toRectToView:self.mapView].size.width;
	[self.wonLabelFilledSquareMeters setText:[NSString stringWithFormat:NSLocalizedString(@"n square meters format", @"Format for \"10 square meters\""), (NSUInteger)(sqrt(self.gameProgress.doneArea)*k)]];
	
	[UIView animateWithDuration:VSO_ANIM_TIME_SHOW_GAME_OVER animations:^{
		self.viewGameOver.alpha = 1.;
	}];
}

#pragma mark - Private

- (void)showViewLoadingMap:(NSTimer *)t
{
	[timerShowLoadingMap invalidate];
	timerShowLoadingMap = nil;
	
	[UIView animateWithDuration:VSO_ANIM_TIME_SHOW_VIEW_LOADING_MAP animations:^{
		self.viewLoadingMap.alpha = 1.;
	}];
}

- (void)showViewGettingLocation
{
	[UIView animateWithDuration:VSO_ANIM_TIME_SHOW_VIEW_LOADING_MAP animations:^{
		self.viewGettingLocation.alpha = 1.;
	}];
}

- (void)removeGettingLocationMsgAnimated
{
	[UIView animateWithDuration:VSO_ANIM_TIME_SHOW_VIEW_LOADING_MAP animations:^{
		self.viewGettingLocation.alpha = 0.;
	}];
}

- (void)lockMap:(id)lockButton
{
	mapLocked = YES;
	/* If the current region of the map is too big, we decrease it */
	if (self.mapWidth > VSO_MAX_MAP_SPAN_FOR_PLAYGROUND) [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(self.mapView.region.center, VSO_MAX_MAP_SPAN_FOR_PLAYGROUND, VSO_MAX_MAP_SPAN_FOR_PLAYGROUND)];
	
	self.mapView.zoomEnabled = NO;
	self.mapView.scrollEnabled = NO;
	self.mapView.showsUserLocation = NO;
	[self.mapView addAnnotation:self];
	
	[self.buttonCenterMap removeFromSuperview]; self.buttonCenterMap = nil;
	[self.viewShapePreview removeFromSuperview]; self.viewShapePreview = nil;
/*	[self.viewMapScale removeFromSuperview]; self.viewMapScale = nil; self.labelScale = nil;
	self.viewPlayInfos.hidden = NO;*/
	
	[self.labelPercentFilled setText:[NSString stringWithFormat:NSLocalizedString(@"percent complete format", nil), 0]];
	[self.wonLabelFilledPercent setText:[NSString stringWithFormat:NSLocalizedString(@"percent complete format", nil), 0]];
	[lockButton setTitle:NSLocalizedString(@"stop playing", @"Stop playing button title") forState:UIControlStateNormal];
}

- (CLLocationDistance)mapWidth
{
	MKCoordinateRegion r = self.mapView.region;
	CLLocation *l = [[CLLocation alloc] initWithLatitude:r.center.latitude longitude:r.center.longitude];
	CLLocation *l2 = [[CLLocation alloc] initWithLatitude:r.center.latitude+r.span.latitudeDelta longitude:r.center.longitude];
	
	return [l distanceFromLocation:l2];
}

- (void)refreshTimes:(NSTimer *)t
{
	NSUInteger i, h, m, s;
	if (mapLocked) {
		playingTime = -self.gameProgress.startDate.timeIntervalSinceNow;
		
		i = (NSUInteger)playingTime;
		h = i/3600, m = (i-h*3600)/60, s = i-h*3600-m*60;
		NSString *tasstr = [NSString stringWithFormat:@"%02lu:%02lu:%02lu", (unsigned long)h, (unsigned long)m, (unsigned long)s];
		[self.wonLabelPlayingTime setText:tasstr];
		
		if (self.gameProgress.settings.playingMode == VSOPlayingModeTimeLimit) i = MAX(0, self.gameProgress.settings.playingTime - playingTime);
		
		h = i/3600, m = (i-h*3600)/60, s = i-h*3600-m*60;
		tasstr = [NSString stringWithFormat:@"%02lu:%02lu:%02lu", (unsigned long)h, (unsigned long)m, (unsigned long)s];
		[self.labelPlayingTime setText:tasstr];
	}
	
	if (lastGPSRefresh) {
		i = (NSUInteger)(-lastGPSRefresh.timeIntervalSinceNow);
		if (mapLocked && i > VSO_TIME_BEFORE_SHOWING_GETTING_LOC_MSG) [self showViewGettingLocation];
	}
}

- (void)finishGame
{
	UIApplication.sharedApplication.idleTimerDisabled = NO;
	
	[self.gameProgress gameDidFinish];
	
#ifdef SIMULATOR_CODE
	[t invalidate];
	t = nil;
#endif
	[locationManager stopUpdatingLocation];
	[locationManager stopUpdatingHeading];
	[timerRefreshTimes invalidate];
	timerRefreshTimes = nil;
	
	[timerShowLoadingMap invalidate];
	timerShowLoadingMap = nil;
}

- (NSUInteger)score
{
	CGFloat k = 1./[self.mapView convertRegion:MKCoordinateRegionMakeWithDistance(coordinateForAnnotation, 1., 1.) toRectToView:self.mapView].size.width;
	CGFloat area = sqrt(self.gameProgress.doneArea)*k;
	CGFloat scoreMultiplier = 1. + (CGFloat)[NSUserDefaults.standardUserDefaults integerForKey:VSO_UDK_LEVEL_PAINTING_SIZE]/2.;
	
	return (NSUInteger)(100*((area/log10(playingTime+1.5))*scoreMultiplier) + 0.5);
}

#ifdef SIMULATOR_CODE
/* Simulator code (location generation) */

- (void)refreshFalseLocation:(NSTimer *)t
{
	CGFloat md = 0.00003*4;
	coordinateForAnnotation.latitude += (((CGFloat)random() / RAND_MAX) * (md*2.)) - md;
	coordinateForAnnotation.longitude += (((CGFloat)random() / RAND_MAX) * (md*2.)) - md;
	
	CLLocation *newLoc = [[CLLocation alloc] initWithCoordinate:coordinateForAnnotation altitude:0 horizontalAccuracy:((CGFloat)random() / RAND_MAX)*9 + 3 verticalAccuracy:-1 timestamp:[NSDate dateWithTimeIntervalSinceNow:0]];
	[self locationManager:locationManager didUpdateLocations:@[newLoc]];
	
	currentLocation = newLoc;
}
#endif

@end
