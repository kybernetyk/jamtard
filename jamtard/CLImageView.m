//
//  CLImageView.m
//  jamtard
//
//  Created by Leon Szpilewski on 3/21/12.
//  Copyright (c) 2012 Clawfield. All rights reserved.
//

#import "CLImageView.h"

@implementation CLImageView {

}
@synthesize image = m_image;

- (void) setImage:(NSImage *)image {
	m_image = image;
	[self setNeedsDisplay: YES];
}


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[self.image drawInRect: [self bounds] fromRect: NSZeroRect operation: NSCompositeSourceOver fraction: 1.0];
    // Drawing code here.
}

@end
