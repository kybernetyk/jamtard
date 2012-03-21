//
//  CLAppDelegate.h
//  jamtard
//
//  Created by Leon Szpilewski on 3/21/12.
//  Copyright (c) 2012 Clawfield. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CLImageView.h"
#import "CLScreenCapture.h"

@interface CLAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet CLImageView *imageView;
@property (assign) IBOutlet NSProgressIndicator *spinner;

- (IBAction) findWindow:(id)sender;

- (IBAction) startBot:(id)sender;
- (IBAction) stopBot:(id)sender;
@end
