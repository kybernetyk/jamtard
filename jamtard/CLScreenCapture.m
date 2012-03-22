//
//  CLScreenCapture.m
//  jamtard
//
//  Created by Leon Szpilewski on 3/21/12.
//  Copyright (c) 2012 Clawfield. All rights reserved.
//

#import "CLScreenCapture.h"

@implementation CLScreenCapture {
	NSArray *m_windowList;
}

- (id) init {
	self = [super init];
	if (!self) return nil;
	
	[self updateWindowList];
	
	return self;
}

-(void)updateWindowList {
	CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionAll, kCGNullWindowID);
	NSArray *arr = (__bridge NSArray*)windowList;
	
	m_windowList = [NSArray arrayWithArray: arr];
	CFRelease(windowList);
}

-(NSImage *) captureWindowWithTitle: (NSString *) title {
	if (!m_windowList)
		[self updateWindowList];
	
	for (NSDictionary *elm in m_windowList) {
		if ([[[elm objectForKey: @"kCGWindowName"] lowercaseString] isEqualToString: [title lowercaseString]]) {
			CGImageRef windowImage = CGWindowListCreateImage(CGRectNull, 
															 kCGWindowListOptionIncludingWindow, 
															 [[elm objectForKey: @"kCGWindowNumber"] integerValue], 
															 kCGWindowImageDefault);
			NSImage *img =  [[NSImage alloc] initWithCGImage: windowImage 
												size: NSMakeSize(CGImageGetWidth(windowImage), CGImageGetHeight(windowImage))];
			CGImageRelease(windowImage);
			return img;
		}
	}
	return nil;
	
}

-(NSImage *) captureScreenhot {
	CGImageRef screenShot = CGWindowListCreateImage(CGRectInfinite, kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageDefault);
	NSImage *img =  [[NSImage alloc] initWithCGImage: screenShot 
												size: NSMakeSize(CGImageGetWidth(screenShot), CGImageGetHeight(screenShot))];
	
	CGImageRelease(screenShot);
	return img;
}


@end
