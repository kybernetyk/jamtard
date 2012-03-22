//
//  CLAppDelegate.m
//  jamtard
//
//  Created by Leon Szpilewski on 3/21/12.
//  Copyright (c) 2012 Clawfield. All rights reserved.
//

#import "CLAppDelegate.h"

@implementation CLAppDelegate {
	NSTimer *m_captureTimer;
	CLScreenCapture *m_screenCap;
}

@synthesize window = m_window;
@synthesize imageView = m_imageView;
@synthesize spinner = m_spinner;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[self.imageView setImage: [NSImage imageNamed: @"robot.jpg"]];
	//const char *kommando = [[NSString stringWithFormat: @"open %@", g_browserPath] cStringUsingEncoding: NSUTF8StringEncoding];
	//system(kommando);
	
	m_screenCap = [[CLScreenCapture alloc] init];
}

- (void) handleCaptureTimer: (NSTimer *) timer {
	//NSImage *img = [m_screenCap captureWindowWithTitle: @"mozilla firefox start page"];
	NSImage *img = [m_screenCap captureScreenhot];
	[self.imageView setImage: img];
	
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
					  scheduledTimerWithTimeInterval: 1.0/30.0
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
