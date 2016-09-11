//
//  VSOSendScoresViewCtrl.m
//  GPS Body Paint
//
//  Created by François Lamboley on 7/24/09.
//  Copyright 2009 VSO-Software. All rights reserved.
//

#import "VSOSendScoresViewCtrl.h"

#define GEOCADE_GPS_BODY_PAINT_TOKEN @"51460djgsdp30ajsjb9shvfsd38an"
#define GEOCADE_GPS_BODY_PAINT_GAME_ID 51460
#ifndef DISTRIBUTION
#define GEOCADE_API_SERVER_ADDRESS @"staging.geocade.com"
#else
#define GEOCADE_API_SERVER_ADDRESS @"iphone10.geocade.com"
#endif
#define GEOCADE_API_SUBMIT_SCORE GEOCADE_API_SERVER_ADDRESS@"/scores/submitScore"

@implementation VSOSendScoresViewCtrl

@synthesize delegate;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
	}
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	webView.delegate = self,
	[webView loadHTMLString:[NSString stringWithFormat:@"<center><h1>%@&hellip;</h1></center>", NSLocalizedString(@"submitting score", nil)]
						 baseURL:nil];
	
	NSString *uid = [[UIDevice currentDevice] uniqueIdentifier];
	NSUInteger score = [self.delegate score];
	CGFloat lat = [self.delegate scoreCoords].latitude;
	CGFloat lng = [self.delegate scoreCoords].longitude;
	int md = 13, remainder, checksum;
	remainder =  (score +  GEOCADE_GPS_BODY_PAINT_GAME_ID) % md;
	checksum = (remainder + 7)  * (int)abs(lat) * (int)abs(lng);
	if (lat == 0 && lng == 0) checksum = (remainder + 7)  * 42 * 71;
	
	NSString *urlString = [NSString stringWithFormat:@"http://%@?token=%@&gid=%i&lat=%f&lng=%f&uid=%@&total=%i&cid=%i",
	 GEOCADE_API_SUBMIT_SCORE, GEOCADE_GPS_BODY_PAINT_TOKEN, GEOCADE_GPS_BODY_PAINT_GAME_ID, lat, lng, uid, score, checksum];
	
	// Split fully formed url (urlString) into server/path (base) and parameters (body)
	NSArray *urlList = [urlString componentsSeparatedByString:@"?"];
	NSString *urlBase = [urlList objectAtIndex:0];
	NSString *urlBody = [urlList objectAtIndex:1];
	
	NSData *myRequestData = [NSData dataWithBytes:[urlBody UTF8String] length:[urlBody length]];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlBase]];
	
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:myRequestData];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
	[webView loadRequest:request];
	
	[super viewDidLoad];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error
{
	if ([error code] != -999)
		[webView loadHTMLString:[NSString stringWithFormat:@"<center><h1>%@</h1></center>", NSLocalizedString(@"cannot contact high score server", nil)] baseURL:nil];
}
	
- (void)didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (IBAction)done:(id)sender
{
	[self.delegate highScoresDone:self];	
}

- (void)viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc
{
	[webView release];
	[super dealloc];
}


@end
