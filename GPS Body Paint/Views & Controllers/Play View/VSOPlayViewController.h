/*
 * VSOPlayViewController.h
 * GPS Body Paint
 *
 * Created by François Lamboley on 7/15/09.
 * Copyright VSO-Software 2009. All rights reserved.
 */

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

#import "VSOGridAnnotationView.h"
#import "VSOGameProgress.h"
#import "VSOShapeView.h"

#define SIMULATOR_CODE
#undef SIMULATOR_CODE



@class VSOPlayViewController;
@protocol VSOPlayViewControllerDelegate

- (void)playViewControllerDidFinish:(VSOPlayViewController *)controller;

@end



@interface VSOPlayViewController : UIViewController <MKMapViewDelegate, MKAnnotation, CLLocationManagerDelegate, VSOGameProgressDelegate> {
	VSOGridAnnotationView *gridAnnotationView;
	NSTimer *timerShowLoadingMap;
	
	NSTimeInterval playingTime;
	
	CLLocationManager *locationManager;
	CLLocationCoordinate2D lastCoordinate;
	CLLocationCoordinate2D coordinateForAnnotation;
	NSDate *lastGPSRefresh;
	
	NSTimer *timerRefreshTimes;
	
	BOOL userMovedMap, mapFirstCenterDone;
	BOOL mapLocked, mapMoving, warnForMapLoadingErrors;
#ifdef SIMULATOR_CODE
	NSTimer *t;
	CLLocation *currentLocation;
#endif
}

@property(nonatomic, retain) IBOutlet MKMapView *mapView;
@property(nonatomic, retain) IBOutlet VSOShapeView *viewShapePreview;

//@property(nonatomic, retain) IBOutlet UIView *viewMapScale;
//@property(nonatomic, retain) IBOutlet UILabel *labelScale;

//@property(nonatomic, retain) IBOutlet UIView *viewPlayInfos;

@property(nonatomic, retain) IBOutlet UILabel *labelPlayingTime;
@property(nonatomic, retain) IBOutlet UILabel *labelPlayingTimeTitle;
@property(nonatomic, retain) IBOutlet UILabel *labelPercentFilled;
@property(nonatomic, retain) IBOutlet UILabel *labelGoal;
@property(nonatomic, retain) IBOutlet UILabel *labelGoalPercentage;

@property(nonatomic, retain) IBOutlet UILabel *labelGPSAccuracy;

@property(nonatomic, retain) IBOutlet UIView *viewGettingLocation;
@property(nonatomic, retain) IBOutlet UIView *viewLoadingMap;
@property(nonatomic, retain) IBOutlet UIView *viewGameOver;

@property(nonatomic, retain) IBOutlet UIButton *buttonLockMap;
@property(nonatomic, retain) IBOutlet UIButton *buttonCenterMap;
@property(nonatomic, retain) IBOutlet UIImageView *imageArrowTop, *imageArrowRight, *imageArrowDown, *imageArrowLeft;

@property(nonatomic, retain) IBOutlet UILabel *wonLabelPlayingTime;
@property(nonatomic, retain) IBOutlet UILabel *wonLabelFilledPercent;
@property(nonatomic, retain) IBOutlet UILabel *wonLabelFilledSquareMeters;

@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic, weak) id <VSOPlayViewControllerDelegate> delegate;
@property(nonatomic, retain) VSOGameProgress *gameProgress;

- (IBAction)centerMapToCurrentUserLocation:(id)sender;

- (IBAction)lockMapStopPlayingButtonAction:(id)sender;
- (IBAction)stopPlaying:(id)sender;

@end
