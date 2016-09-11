//
//  VSOSendScoresViewCtrl.h
//  GPS Body Paint
//
//  Created by François Lamboley on 7/24/09.
//  Copyright 2009 VSO-Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol VSOSendScoresViewCtrlDelegate;

@interface VSOSendScoresViewCtrl : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *webView;
	
	id <VSOSendScoresViewCtrlDelegate> delegate;
}
@property(nonatomic, assign) id <VSOSendScoresViewCtrlDelegate> delegate;
- (IBAction)done:(id)sender;

@end

@protocol VSOSendScoresViewCtrlDelegate

- (NSUInteger)score;
- (CLLocationCoordinate2D)scoreCoords;
- (void)highScoresDone:(VSOSendScoresViewCtrl *)ctrl;

@end
