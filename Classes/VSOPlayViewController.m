//
//  VSOPlayViewController.m
//  GPS Body Paint
//
//  Created by François Lamboley on 7/15/09.
//  Copyright VSO-Software 2009. All rights reserved.
//

#import "VSOSendScoresViewCtrl.h"
#import "VSOPlayViewController.h"
#import "VSOPlayView.h"
#import "VSOUtils.h"

#import "Constants.h"

@implementation VSOPlayViewController

@synthesize delegate;
@synthesize coordinate; /* Getter overridden */
@synthesize gameProgress;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		coordinateForAnnotation.latitude = 43.580212;
		coordinateForAnnotation.latitude = 40.792651;
		coordinateForAnnotation.longitude = 1.29724;
		coordinateForAnnotation.longitude = -73.959167;
/*		coordinate.latitude = 43.580212 + ((CGFloat)rand()/RAND_MAX)*9;
		coordinate.longitude = 1.29724 + ((CGFloat)rand()/RAND_MAX)*9;*/

		locationManager = [CLLocationManager new];
		locationManager.delegate = self;
		
		warnForMapLoadingErrors = [[NSUserDefaults standardUserDefaults] boolForKey:VSO_WARN_ON_MAP_LOADING_FAILURE];
		
		mapFirstCenterDone = NO;
		mapLocked = NO;
		mapMoving = NO;
	}
	return self;
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (CLLocationCoordinate2D)coordinate
{
	if (mapLocked) return [mapView region].center;
	return coordinateForAnnotation;
}

- (CLLocationDistance)mapWidth
{
	MKCoordinateRegion r = [mapView region];
	CLLocation *l = [[CLLocation alloc] initWithLatitude:r.center.latitude longitude:r.center.longitude];
	CLLocation *l2 = [[CLLocation alloc] initWithLatitude:r.center.latitude+r.span.latitudeDelta longitude:r.center.longitude];
	
	return [l getDistanceFrom:l2];
}

- (MKAnnotationView *)mapView:(MKMapView *)mpV viewForAnnotation:(id <MKAnnotation>)annotation
{
	if ([annotation isKindOfClass:[self class]]) {
		// Try to dequeue an existing grid view first.
		gridAnnotationView = (VSOGridAnnotationView *)[mpV dequeueReusableAnnotationViewWithIdentifier:@"GridAnnotation"];
		
		if (!gridAnnotationView) gridAnnotationView = [[VSOGridAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"GridAnnotation"];
		else                     gridAnnotationView.annotation = annotation;
		
		CGFloat delta = 0.;
		gridAnnotationView.frame = CGRectMake(mpV.frame.origin.x - delta, mpV.frame.origin.y - delta,
														  mpV.frame.size.width + 2*delta, mpV.frame.size.height + 2*delta);
		gameProgress.gridPlayGame = gridAnnotationView;
		gridAnnotationView.gameProgress = gameProgress;
		gridAnnotationView.map = mpV;
		[gameProgress gameDidStartWithLocation:[mapView convertCoordinate:coordinateForAnnotation toPointToView:mapView]
												diameter:[mapView convertRegion:MKCoordinateRegionMakeWithDistance(coordinateForAnnotation, gameProgress.settings.userLocationDiameter, gameProgress.settings.userLocationDiameter) toRectToView:mapView].size.width];

		return gridAnnotationView;
	}
	
	return nil;
}

- (void)showViewLoadingMap:(NSTimer *)t
{
	[timerShowLoadingMap invalidate];
	timerShowLoadingMap = nil;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:VSO_ANIM_TIME_SHOW_VIEW_LOADING_MAP];
	viewLoadingMap.alpha = 1.;
	[UIView commitAnimations];
}

- (void)mapViewWillStartLoadingMap:(MKMapView *)mpV
{
	NSDLog(@"mapViewWillStartLoadingMap:");
	buttonLockMap.enabled = NO;
	if (timerShowLoadingMap != nil) return;
	timerShowLoadingMap = [NSTimer scheduledTimerWithTimeInterval:3. target:self selector:@selector(showViewLoadingMap:) userInfo:NULL repeats:NO];
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mpV
{
	NSDLog(@"mapViewDidFinishLoadingMap:");
	[timerShowLoadingMap invalidate];
	timerShowLoadingMap = nil;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:VSO_ANIM_TIME_SHOW_VIEW_LOADING_MAP];
	viewLoadingMap.alpha = 0.;
	[UIView commitAnimations];
	
	buttonLockMap.enabled = YES;
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == [alertView cancelButtonIndex]) [self stopPlaying:nil];
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
	
	[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"cannot get map", nil) message:NSLocalizedString(@"cannot get map, please check network", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"stop playing", nil) otherButtonTitles:NSLocalizedString(@"play anyway", nil), nil] show];
}

- (void)showViewGettingLocation
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:VSO_ANIM_TIME_SHOW_VIEW_LOADING_MAP];
	viewGettingLocation.alpha = 1.;
	[UIView commitAnimations];
}

- (void)removeGettingLocationMsgAnimated
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:VSO_ANIM_TIME_HIDE_GETTING_LOC_MSG];
	viewGettingLocation.alpha = 0.;
	[UIView commitAnimations];
}

- (void)mapViewDidReceiveTouch:(MKMapView *)mpV
{
	userMovedMap = YES;
}

- (void)mapView:(MKMapView *)mpV regionWillChangeAnimated:(BOOL)animated
{
	NSDLog(@"mapView:regionWillChangeAnimated:");
	mapMoving = YES;
	buttonLockMap.enabled = NO;
}

- (void)mapView:(MKMapView *)mpV regionDidChangeAnimated:(BOOL)animated
{
	NSDLog(@"mapView:regionDidChangeAnimated:");
	mapMoving = NO;
	buttonLockMap.enabled = YES;
	
	NSDLog(@"Map width: %g meters", [self mapWidth]);
/*	NSUInteger w = (NSUInteger)([self mapWidth] + 0.5);
	[labelScale setText:[NSString stringWithFormat:NSLocalizedString(@"n m format", nil), w/4]];
	if (w > VSO_MAX_MAP_SPAN_FOR_PLAYGROUND) [labelScale setTextColor:[UIColor redColor]];
	else                                     [labelScale setTextColor:[UIColor whiteColor]];*/
	if (mapFirstCenterDone) viewShapePreview.hidden = NO;
}

- (void)refreshTimes:(NSTimer *)t
{
	NSUInteger i, h, m, s;
	if (mapLocked) {
		playingTime = -[[gameProgress startDate] timeIntervalSinceNow];
		
		i = (NSUInteger)playingTime;
		h = i/3600, m = (i-h*3600)/60, s = i-h*3600-m*60;
		NSString *tasstr = [NSString stringWithFormat:@"%02d:%02d:%02d", h, m, s];
		[wonLabelPlayingTime setText:tasstr];
		
		if (gameProgress.settings.playingMode == VSOPlayingModeTimeLimit) i = MAX(0, gameProgress.settings.playingTime - playingTime);
		
		h = i/3600, m = (i-h*3600)/60, s = i-h*3600-m*60;
		tasstr = [NSString stringWithFormat:@"%02d:%02d:%02d", h, m, s];
		[labelPlayingTime setText:tasstr];
	}
	
	if (lastGPSRefresh) {
		i = (NSUInteger)(-[lastGPSRefresh timeIntervalSinceNow]);
		if (mapLocked && i > VSO_TIME_BEFORE_SHOWING_GETTING_LOC_MSG) [self showViewGettingLocation];
	}
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
	if (signbit(newHeading.headingAccuracy)) return;
	
	[gameProgress setCurrentHeading:newHeading.trueHeading];
}

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateToLocation:(CLLocation *)newLocation
			  fromLocation:(CLLocation *)oldLocation
{
	lastCoordinate = newLocation.coordinate;
	NSDLog(@"did get location: %g, %g. Horizontal accuracy: %g", lastCoordinate.latitude, lastCoordinate.longitude, [newLocation horizontalAccuracy]);
	
	/* Negative accuracy means no location found */
	if (signbit([newLocation horizontalAccuracy])) return;
/*	if ([newLocation horizontalAccuracy] > gameProgress.settings.playgroundSize) return;*/
	
	lastGPSRefresh = [NSDate dateWithTimeIntervalSinceNow:0.];
	[labelGPSAccuracy setText:[NSString stringWithFormat:NSLocalizedString(@"n m format", @"Format for \"10 m\""), (NSUInteger)([newLocation horizontalAccuracy] + 0.5)]];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:VSO_UDK_FIRST_LAUNCH]) {
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"play info", nil) message:NSLocalizedString(@"lock map when ready msg", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"ok", nil), nil] show];
		
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:VSO_UDK_FIRST_LAUNCH];
	}
	
	if (!mapLocked) {
		coordinateForAnnotation = lastCoordinate;
		
		if (!mapFirstCenterDone) [self centerMapToCurrentUserLocation:self];
		else if (!userMovedMap) [mapView setCenterCoordinate:coordinateForAnnotation animated:YES];
		
		mapFirstCenterDone = YES;
		[self removeGettingLocationMsgAnimated];
	} else {
		[gameProgress playerMovedTo:[mapView convertCoordinate:lastCoordinate toPointToView:mapView]
								 diameter:[mapView convertRegion:MKCoordinateRegionMakeWithDistance(lastCoordinate, gameProgress.settings.userLocationDiameter, gameProgress.settings.userLocationDiameter) toRectToView:mapView].size.width];
		NSString *passtr = [NSString stringWithFormat:NSLocalizedString(@"percent complete format from float", @"Here, there is only a %.0f with the percent sign (%% for %) following"), [gameProgress percentDone]];
		[labelPercentFilled setText:passtr];
		[wonLabelFilledPercent setText:passtr];
		
		/* Showing arrows if user outside of map */
		MKCoordinateRegion r = [mapView region];
		[UIView beginAnimations:nil context:(__bridge void * _Nullable)(viewGettingLocation)];
		[UIView setAnimationDuration:VSO_ANIM_TIME_SHOW_ARROWS];
		if (lastCoordinate.latitude < r.center.latitude-r.span.latitudeDelta/2.) imageArrowDown.alpha = 1.;
		else                                                                     imageArrowDown.alpha = 0.;
		if (lastCoordinate.latitude > r.center.latitude+r.span.latitudeDelta/2.) imageArrowTop.alpha = 1.;
		else                                                                     imageArrowTop.alpha = 0.;
		if (lastCoordinate.longitude < r.center.longitude-r.span.longitudeDelta/2.) imageArrowLeft.alpha = 1.;
		else                                                                        imageArrowLeft.alpha = 0.;
		if (lastCoordinate.longitude > r.center.longitude+r.span.longitudeDelta/2.) imageArrowRight.alpha = 1.;
		else                                                                        imageArrowRight.alpha = 0.;
		[UIView commitAnimations];
	}
}

- (void)locationManager:(CLLocationManager *)manager
		 didFailWithError:(NSError *)error
{
	[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"cannot get location", nil) message:NSLocalizedString(@"cannot get location. aborting play", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"ok", nil), nil] show];
	[self stopPlaying:self];
}

#ifdef SIMULATOR_CODE
/* Simulator code (location generation) */

- (void)refreshFalseLocation:(NSTimer *)t
{
	CGFloat md = 0.00003*4;
	coordinateForAnnotation.latitude += (((CGFloat)random() / RAND_MAX) * (md*2.)) - md;
	coordinateForAnnotation.longitude += (((CGFloat)random() / RAND_MAX) * (md*2.)) - md;
	
	CLLocation *newLoc = [[CLLocation alloc] initWithCoordinate:coordinateForAnnotation altitude:0 horizontalAccuracy:((CGFloat)random() / RAND_MAX)*9 + 3 verticalAccuracy:-1 timestamp:[NSDate dateWithTimeIntervalSinceNow:0]];
	[self locationManager:nil didUpdateToLocation:[[newLoc copy] autorelease] fromLocation:[[currentLocation copy] autorelease]];
	
	[currentLocation release];
	currentLocation = newLoc;
}
#endif

- (IBAction)centerMapToCurrentUserLocation:(id)sender
{
	MKCoordinateRegion r = MKCoordinateRegionMakeWithDistance(coordinateForAnnotation, gameProgress.settings.playgroundSize, gameProgress.settings.playgroundSize);
	[mapView setRegion:r animated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];

	gameProgress.delegate = self;
	
	imageArrowTop.alpha = 0.;
	imageArrowDown.alpha = 0.;
	imageArrowLeft.alpha = 0.;
	imageArrowRight.alpha = 0.;
	
	viewLoadingMap.alpha = 0.;
	[self.view addSubview:viewLoadingMap];
	[self.view addSubview:viewGettingLocation];
	[labelPercentFilled setText:NSLocalizedString(@"NA", nil)];
	[labelPlayingTime setText:NSLocalizedString(@"NA", nil)];
	[labelGPSAccuracy setText:NSLocalizedString(@"NA", nil)];
	
	NSString *playingOrRemainingTitle;
	UIFont *font;
	if (gameProgress.settings.playingMode == VSOPlayingModeFillIn) {
		font = [labelPlayingTimeTitle font];
		playingOrRemainingTitle = NSLocalizedString(@"playing time", @"Playing time label title in the game view");
		
		labelGoal.hidden = NO;
		labelGoalPercentage.hidden = NO;
		[labelGoalPercentage setText:[NSString stringWithFormat:NSLocalizedString(@"percent complete format", @"Here, there is only a %d with the percent sign (%% for %) following"), gameProgress.settings.playingFillPercentToDo]];
	} else {
		font = [labelGoal font];
		playingOrRemainingTitle = NSLocalizedString(@"remaining time", @"Remainting time label title in the game view");
		
		labelGoal.hidden = YES;
		labelGoalPercentage.hidden = YES;
	}
	CGRect f = labelPlayingTimeTitle.frame;
	CGSize s = [playingOrRemainingTitle sizeWithFont:font];
	f.size.width = s.width;
	[labelPlayingTime setFont:font];
	[labelPlayingTime setCenter:CGPointMake(labelPlayingTime.center.x - (labelPlayingTimeTitle.frame.size.width-s.width), labelPlayingTime.center.y)];
	[labelPlayingTimeTitle setFrame:f];
	[labelPlayingTimeTitle setFont:font];
	[labelPlayingTimeTitle setText:playingOrRemainingTitle];
	
#ifndef SIMULATOR_CODE
	[locationManager requestWhenInUseAuthorization];
	[locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
	[locationManager startUpdatingLocation];
	[locationManager startUpdatingHeading];
#else
	srandom(time(NULL));
/*	[self refreshFalseLocation:nil];*/
	t = [[NSTimer scheduledTimerWithTimeInterval:3.3 target:self selector:@selector(refreshFalseLocation:) userInfo:nil repeats:YES] retain];
#endif
	
	mapView.delegate = self;
	mapView.mapType = MKMapTypeSatellite;
	viewShapePreview.gameShape = gameProgress.settings.gameShape;
	
	[self refreshTimes:nil];
	timerRefreshTimes = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(refreshTimes:) userInfo:nil repeats:YES];
}

- (void)lockMap:(id)lockButton
{
	mapLocked = YES;
	/* If the current region of the map is too big, we decrease it */
	if ([self mapWidth] > VSO_MAX_MAP_SPAN_FOR_PLAYGROUND) [mapView setRegion:MKCoordinateRegionMakeWithDistance([mapView region].center, VSO_MAX_MAP_SPAN_FOR_PLAYGROUND, VSO_MAX_MAP_SPAN_FOR_PLAYGROUND)];
	
	mapView.zoomEnabled = NO;
	mapView.scrollEnabled = NO;
	mapView.showsUserLocation = NO;
	[mapView addAnnotation:self];
	
	[buttonCenterMap removeFromSuperview]; buttonCenterMap = nil;
	[viewShapePreview removeFromSuperview]; viewShapePreview = nil;
/*	[viewMapScale removeFromSuperview]; viewMapScale = nil; labelScale = nil;
	viewPlayInfos.hidden = NO;*/
	
	[labelPercentFilled setText:[NSString stringWithFormat:NSLocalizedString(@"percent complete format", nil), 0]];
	[wonLabelFilledPercent setText:[NSString stringWithFormat:NSLocalizedString(@"percent complete format", nil), 0]];
	[lockButton setTitle:NSLocalizedString(@"stop playing", @"Stop playing button title") forState:UIControlStateNormal];
}

- (IBAction)lockMapStopPlayingButtonAction:(id)sender
{
	if (!mapLocked) [self lockMap:sender];
	else            [self stopPlaying:sender];
}

- (void)doEndOfGameReleases
{
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	
	[gameProgress gameDidFinish];
	
#ifdef SIMULATOR_CODE
	[t invalidate];
	[t release];
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
	CGFloat k = 1./[mapView convertRegion:MKCoordinateRegionMakeWithDistance(coordinateForAnnotation, 1., 1.) toRectToView:mapView].size.width;
	CGFloat area = sqrt([gameProgress doneArea])*k;
	CGFloat scoreMultiplier = 1. + (CGFloat)[[NSUserDefaults standardUserDefaults] integerForKey:VSO_UDK_LEVEL_PAINTING_SIZE]/2.;
	
	return (NSUInteger)(100*((area/log10(playingTime+1.5))*scoreMultiplier) + 0.5);
}

- (CLLocationCoordinate2D)scoreCoords
{
	return lastCoordinate;
}

- (void)highScoresDone:(VSOSendScoresViewCtrl *)ctrl
{
	[self dismissModalViewControllerAnimated:YES];
}

/* Called by the game progress controller */
- (void)gameDidFinish:(BOOL)win
{
	[self doEndOfGameReleases];
	
	CGFloat k = 1./[mapView convertRegion:MKCoordinateRegionMakeWithDistance(coordinateForAnnotation, 1., 1.) toRectToView:mapView].size.width;
	[wonLabelFilledSquareMeters setText:[NSString stringWithFormat:NSLocalizedString(@"n square meters format", @"Format for \"10 square meters\""), (NSUInteger)(sqrt([gameProgress doneArea])*k)]];
	
	viewGameOver.alpha = 0.;
	[self.view addSubview:viewGameOver];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:VSO_ANIM_TIME_SHOW_GAME_OVER];
	viewGameOver.alpha = 1.;
	[UIView commitAnimations];
}

- (IBAction)stopPlaying:(id)sender
{
	[self doEndOfGameReleases];
	
	mapView.delegate = nil;
	[mapView removeAnnotation:self];
	[self.delegate playViewControllerDidFinish:self];	
}

- (IBAction)sendScoresToGeocade:(id)sender
{
	VSOSendScoresViewCtrl *scoreSender = [[VSOSendScoresViewCtrl alloc] initWithNibName:@"VSOSendScoresView" bundle:nil];
	scoreSender.delegate = self;
	scoreSender.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	
	[self presentModalViewController:scoreSender animated:YES];
	
	[sender removeFromSuperview];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
}

- (void)dealloc
{
	NSDLog(@"Deallocing a VSOPlayViewController");
}

@end
