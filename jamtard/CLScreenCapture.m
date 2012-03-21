//
//  CLScreenCapture.m
//  jamtard
//
//  Created by Leon Szpilewski on 3/21/12.
//  Copyright (c) 2012 Clawfield. All rights reserved.
//

#define StopwatchStart() AbsoluteTime start = UpTime()
#define Profile(img) CFRelease(CGDataProviderCopyData(CGImageGetDataProvider(img)))
#define StopwatchEnd(caption) do { Duration time = AbsoluteDeltaToDuration(UpTime(), start); double timef = time < 0 ? time / -1000000.0 : time / 1000.0; NSLog(@"%s Time Taken: %f seconds", caption, timef); } while(0)


#import "CLScreenCapture.h"

@implementation CLScreenCapture {
	CGWindowListOption listOptions;
	CGWindowListOption singleWindowListOptions;
	CGWindowImageOption imageOptions;
	CGRect imageBounds;
	
	NSArray *m_windowList;
}

- (id) init {
	self = [super init];
	if (!self) return nil;
	
	[self updateWindowList];
	
	return self;
}

-(void)updateWindowList
{
	// Ask the window server for the list of windows.
	//	StopwatchStart();
	CFArrayRef windowList = CGWindowListCopyWindowInfo(listOptions, kCGNullWindowID);
	//	StopwatchEnd("Create Window List");
	
	NSArray *arr = (__bridge NSArray*)windowList;
	
//	for (id elm in arr) {
//		NSLog(@"%@", arr);
//	}
	
	m_windowList = [NSArray arrayWithArray: arr];
	
	// Copy the returned list, further pruned, to another list. This also adds some bookkeeping
	// information to the list as well as 
	//NSMutableArray *prunedWindowList = [NSMutableArray array];
	//WindowListApplierData data = {prunedWindowList, 0};
	//CFArrayApplyFunction(windowList, CFRangeMake(0, CFArrayGetCount(windowList)), &WindowListApplierFunction, &data);
	CFRelease(windowList);
	
	// Set the new window list
	//[arrayController setContent:prunedWindowList];
}

-(NSImage *) captureWindowWithTitle: (NSString *) title {
	if (!m_windowList)
		[self updateWindowList];
	
	for (NSDictionary *elm in m_windowList) {
		if ([[[elm objectForKey: @"kCGWindowName"] lowercaseString] isEqualToString: [title lowercaseString]]) {
			NSLog(@"found the biatch: %@", elm);
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
	//	StopwatchStart();
	CGImageRef screenShot = CGWindowListCreateImage(CGRectInfinite, kCGWindowListOptionOnScreenOnly, kCGNullWindowID, kCGWindowImageDefault);
	//	Profile(screenShot);
	//	StopwatchEnd("Screenshot");
	//	[self setOutputImage:screenShot];
	NSImage *img =  [[NSImage alloc] initWithCGImage: screenShot 
												size: NSMakeSize(CGImageGetWidth(screenShot), CGImageGetHeight(screenShot))];
	
	CGImageRelease(screenShot);
	return img;
}


@end
