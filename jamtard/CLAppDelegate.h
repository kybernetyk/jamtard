//
//  CLAppDelegate.h
//  jamtard
//
//  Created by Leon Szpilewski on 3/21/12.
//  Copyright (c) 2012 Clawfield. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CLImageView.h"

@interface CLAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet CLImageView *imageView;
@end
