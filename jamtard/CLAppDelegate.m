//
//  CLAppDelegate.m
//  jamtard
//
//  Created by Leon Szpilewski on 3/21/12.
//  Copyright (c) 2012 Clawfield. All rights reserved.
//

#import "CLAppDelegate.h"

@implementation CLAppDelegate

@synthesize window = m_window;
@synthesize imageView = m_imageView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[self.imageView setImage: [NSImage imageNamed: @"robot.jpg"]];
}

@end
