//
//  NSImage+OpenCV.h
//  jamtard
//
//  Created by Leon Szpilewski on 4/13/12.
//  Copyright (c) 2012 Clawfield. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifdef OPENCV
#import <opencv/cv.h>

@interface NSImage (OpenCV)
+ (NSImage *)imageWithCVImage:(IplImage *)cvImage;
- (CGContextRef)createARGBBitmapContext;
- (IplImage *)cvImage;
- (IplImage *)cvGrayscaleImage;
@end

#endif