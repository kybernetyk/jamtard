//
//  CLAppDelegate.m
//  jamtard
//
//  Created by Leon Szpilewski on 3/21/12.
//  Copyright (c) 2012 Clawfield. All rights reserved.
//

#import "CLAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation CLAppDelegate {
	NSTimer *m_captureTimer;
	CLScreenCapture *m_screenCap;
	
	NSWindow *m_overlayWindow;
	CIDetector *m_detector;
	NSImage *m_catImage;
}

@synthesize window = m_window;
@synthesize imageView = m_imageView;
@synthesize spinner = m_spinner;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[self.imageView setImage: [NSImage imageNamed: @"robot.jpg"]];
	//const char *kommando = [[NSString stringWithFormat: @"open %@", g_browserPath] cStringUsingEncoding: NSUTF8StringEncoding];
	//system(kommando);
	
	int windowLevel = CGShieldingWindowLevel();
	NSRect windowRect = [[NSScreen mainScreen] frame];
	m_overlayWindow = [[NSWindow alloc] initWithContentRect:windowRect
														  styleMask:NSBorderlessWindowMask
															backing:NSBackingStoreBuffered
															  defer:NO
															 screen:[NSScreen mainScreen]];

	[m_overlayWindow setReleasedWhenClosed:YES];
	[m_overlayWindow setLevel:windowLevel];
	[m_overlayWindow setBackgroundColor:[NSColor colorWithCalibratedRed:0.0
																green:0.0
																 blue:0.0
																alpha:0.0]];
	[m_overlayWindow setOpaque:NO];
	[m_overlayWindow setIgnoresMouseEvents: YES];

	[m_overlayWindow makeKeyAndOrderFront:nil];
	
	m_catImage = [NSImage imageNamed: @"cat.png"];

	m_detector = [CIDetector detectorOfType:CIDetectorTypeFace
											  context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];

	m_screenCap = [[CLScreenCapture alloc] init];
}

- (void) handleCaptureTimer: (NSTimer *) timer {
	//NSImage *img = [m_screenCap captureWindowWithTitle: @"mozilla firefox start page"];
	NSImage *img = [m_screenCap captureScreenhotBelowWindow: m_overlayWindow];

	CIImage *image = [CIImage imageWithData: [img TIFFRepresentation]];
	NSArray* features = [m_detector featuresInImage:image];

	//	NSLog(@"features: %@", features);
	NSMutableArray *rects = [NSMutableArray array];
	
	for(CIFaceFeature* faceFeature in features) {
		CGRect r = faceFeature.bounds;
		//	NSLog(@"rect: %@", [NSValue valueWithRect: r]);
		[rects addObject: [NSValue valueWithRect: r]];
		if (faceFeature.hasLeftEyePosition) {
			
		}
		if (faceFeature.hasRightEyePosition) {
			
		}
		if (faceFeature.hasMouthPosition) {
			
		}
	}
	//	[self.imageView setRects: [NSArray arrayWithArray: rects]];
//	[m_overlayWindow.contentView lockFocus];
	[[m_overlayWindow contentView] setSubviews: [NSArray array]];
	
	
	for(CIFaceFeature* faceFeature in features) {
		CGRect r = faceFeature.bounds;
		CLImageView *iv = [[CLImageView alloc] initWithFrame: r];
		[iv setImage: m_catImage];
		[[m_overlayWindow contentView] addSubview: iv];
	}
	[[m_overlayWindow contentView] setNeedsDisplay: YES];
//	[m_overlayWindow.contentView unlockFocus];
	//	[self.imageView setImage: img];
	
	//CLImageView *iv = (CLImageView*)[self.window contentView];
	//	[iv setImage: img];
}


- (void) singleShot:(id)sender {
	[self handleCaptureTimer: nil];
}

- (void) findWindow:(id)sender {
	[m_screenCap updateWindowList];
}

- (void) startBot:(id)sender {
	[self.spinner startAnimation: nil];
	m_captureTimer = [NSTimer 
					  scheduledTimerWithTimeInterval: 1.0/60.0
					  target: self
					  selector: @selector(handleCaptureTimer:) 
					  userInfo: nil
					  repeats: YES];
}

- (void) stopBot:(id)sender {
	[self.spinner stopAnimation: nil];
	[m_captureTimer invalidate];
	m_captureTimer = nil;
}


@end
