//
//  CLScreenCapture.h
//  jamtard
//
//  Created by Leon Szpilewski on 3/21/12.
//  Copyright (c) 2012 Clawfield. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLScreenCapture : NSObject
-(void)updateWindowList;
-(NSImage *) captureWindowWithTitle: (NSString *) title;
-(NSImage *) captureScreenhot;
-(NSImage *) captureScreenhotBelowWindow: (NSWindow *) window;
-(CGImageRef) captureCGScreenhotBelowWindow: (NSWindow *) window;
@end
