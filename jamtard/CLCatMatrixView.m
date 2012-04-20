//
//  CLCatMatrixView.m
//  jamtard
//
//  Created by Leon Szpilewski on 4/14/12.
//  Copyright (c) 2012 Clawfield. All rights reserved.
//

#import "CLCatMatrixView.h"

@implementation CLCatMatrixView {
	NSImage *m_catImage;
}

@synthesize catRects = m_catRects;

- (BOOL) isOpaque {
	return NO;
}


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		m_catImage = [NSImage imageNamed: @"cat4.png"];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
	
	for (NSValue *val in m_catRects) {
		NSRect r = [val rectValue];
		
		[m_catImage drawInRect: r
					  fromRect: NSZeroRect 
					 operation: NSCompositeSourceOver
					  fraction: 1.0];
	}
}

@end
