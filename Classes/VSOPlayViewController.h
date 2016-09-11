//
//  VSOPlayViewController.h
//  GPS Body Paint
//
//  Created by François Lamboley on 7/15/09.
//  Copyright VSO-Software 2009. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>

#import "VSOSendScoresViewCtrl.h"
#import "VSOGridAnnotationView.h"
#import "VSOGameProgress.h"
#import "VSOShapeView.h"

#define SIMULATOR_CODE
#undef SIMULATOR_CODE

@protocol VSOPlayViewControllerDelegate;

@interface VSOPlayViewController : UIViewController <MKMapViewDelegate, MKAnnotation, CLLocationManagerDelegate, VSOGameProgressDelegate, VSOSendScoresViewCtrlDelegate> {
	IBOutlet MKMapView *mapView;
	IBOutlet VSOShapeView *viewShapePreview;
	
/*	IBOutlet UIView *viewMapScale;
	IBOutlet UILabel *labelScale;*/
	
/*	IBOutlet UIView *viewPlayInfos;*/
	IBOutlet UILabel *labelPlayingTime;
	IBOutlet UILabel *labelPlayingTimeTitle;
	IBOutlet UILabel *labelPercentFilled;
	IBOutlet UILabel *labelGoal;
	IBOutlet UILabel *labelGoalPercentage;
	
	IBOutlet UILabel *labelGPSAccuracy;
	
	IBOutlet UIView *viewGettingLocation;
	IBOutlet UIView *viewLoadingMap;
	IBOutlet UIView *viewGameOver;
	
	IBOutlet UIButton *buttonLockMap;
	IBOutlet UIButton *buttonCenterMap;
	IBOutlet UIImageView *imageArrowTop, *imageArrowRight, *imageArrowDown, *imageArrowLeft;
	VSOGridAnnotationView *gridAnnotationView;
	NSTimer *timerShowLoadingMap;
	
	NSTimeInterval playingTime;
	IBOutlet UILabel *wonLabelPlayingTime;
	IBOutlet UILabel *wonLabelFilledPercent;
	IBOutlet UILabel *wonLabelFilledSquareMeters;
	
	CLLocationManager *locationManager;
	CLLocationCoordinate2D lastCoordinate;
	CLLocationCoordinate2D coordinateForAnnotation;
	NSDate *lastGPSRefresh;
	
	VSOGameProgress *gameProgress;
	NSTimer *timerRefreshTimes;
	
	BOOL userMovedMap, mapFirstCenterDone;
	BOOL mapLocked, mapMoving, warnForMapLoadingErrors;
	__weak id <VSOPlayViewControllerDelegate> delegate;
#ifdef SIMULATOR_CODE
	NSTimer *t;
	CLLocation *currentLocation;
#endif
}
@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic, weak) id <VSOPlayViewControllerDelegate> delegate;
@property(nonatomic, retain) VSOGameProgress *gameProgress;
- (IBAction)centerMapToCurrentUserLocation:(id)sender;

- (IBAction)lockMapStopPlayingButtonAction:(id)sender;
- (IBAction)stopPlaying:(id)sender;
- (IBAction)sendScoresToGeocade:(id)sender;

@end

@protocol VSOPlayViewControllerDelegate

- (void)playViewControllerDidFinish:(VSOPlayViewController *)controller;

@end
