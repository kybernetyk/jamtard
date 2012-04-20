//
//  CLAppDelegate.m
//  jamtard
//
//  Created by Leon Szpilewski on 3/21/12.
//  Copyright (c) 2012 Clawfield. All rights reserved.
//

#import "CLAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "CLCatMatrixView.h"

#ifdef OPENCV
#import <opencv/cv.h>
#import "NSImage+OpenCV.h"
#endif
 
#import <Cocoa/Cocoa.h>

//+ (CGImageRef)resizeCGImage:(CGImageRef)image toWidth:(int)width andHeight:(int)height {
CGImageRef resizeCGImage(CGImageRef image, int width, int height) {
	// create context, keeping original image properties
	CGColorSpaceRef colorspace = CGImageGetColorSpace(image);
	CGContextRef context = CGBitmapContextCreate(NULL, width, height,
												 CGImageGetBitsPerComponent(image),
												 CGImageGetBytesPerRow(image),
												 colorspace,
												 CGImageGetAlphaInfo(image));
	CGColorSpaceRelease(colorspace);

	if(context == NULL)
	return nil;

	// draw image to context (resizing it)
	CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
	// extract resulting image from context
	CGImageRef imgRef = CGBitmapContextCreateImage(context);
	CGContextRelease(context);

	return imgRef;
}

#ifdef OPENCV
NSImage* opencvImageToNSImage(IplImage *img){
	char *d = img->imageData; // Get a pointer to the IplImage image data.
	
	NSString *COLORSPACE;
	if(img->nChannels == 1){
		COLORSPACE = NSDeviceWhiteColorSpace;
	}
	else{
		COLORSPACE = NSDeviceRGBColorSpace;
	}
	
	NSBitmapImageRep *bmp = [[NSBitmapImageRep alloc]  
							 initWithBitmapDataPlanes:NULL 
							 pixelsWide:img->width 
							 pixelsHigh:img->height 
							 bitsPerSample:img->depth 
							 samplesPerPixel:img->nChannels
							 hasAlpha:NO 
							 isPlanar:NO 
							 colorSpaceName:COLORSPACE 
							 bytesPerRow:img->widthStep bitsPerPixel:0];
	
	// Move the IplImage data into the NSBitmapImageRep. widthStep is  
	//	used in the inner for loop due to the
		//   difference between actual bytes in the former and pixel  
		//	locations in the latter.
		// Assignment to colors[] is reversed because that's how an IplImage  
		//		stores the data.
		int x, y;
	unsigned long colors[3];
	for(y=0; y<img->height; y++){
		for(x=0; x<img->width; x++){
			if(img->nChannels > 1){
				colors[2] = (unsigned int) d[(y * img->widthStep) + (x*3)]; // x*3 due to difference between pixel coords and actual byte layout.
				colors[1] = (unsigned int) d[(y * img->widthStep) + (x*3)+1];
				colors[0] = (unsigned int) d[(y * img->widthStep) + (x*3)+2];
			}
			else{
				colors[0] = (unsigned int)d[(y * img->width) + x];
				//NSLog(@"colors[0] = %d", colors[0]);
			}
			[bmp setPixel:colors atX:x y:y];
		}
	}
	
	NSData *tif = [bmp TIFFRepresentation];
	NSImage *im = [[NSImage alloc] initWithData:tif];
	
	return im;
}

IplImage *CreateIplImageFromUIImage (CGImageRef imageRef) {
// Getting CGImage from UIImage
	int width = CGImageGetWidth(imageRef);
	int height = CGImageGetHeight(imageRef);

	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	// Creating temporal IplImage for drawing
	IplImage *iplimage = cvCreateImage(
									   cvSize(width, height), IPL_DEPTH_8U, 4
									   );
	// Creating CGContext for temporal IplImage
	CGContextRef contextRef = CGBitmapContextCreate(
													iplimage->imageData, iplimage->width, iplimage->height,
													iplimage->depth, iplimage->widthStep,
													colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault
													);
	// Drawing CGImage to CGContext
	CGContextDrawImage(
					   contextRef,
					   CGRectMake(0, 0, width, height),
					   imageRef
					   );
	CGContextRelease(contextRef);
	CGColorSpaceRelease(colorSpace);

	// Creating result IplImage
	IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
	cvCvtColor(iplimage, ret, CV_RGBA2BGR);
	cvReleaseImage(&iplimage);

	return ret;
}
#endif

@implementation CLAppDelegate {
	NSTimer *m_captureTimer;
	CLScreenCapture *m_screenCap;
	
	NSWindow *m_overlayWindow;
	CIDetector *m_detector;
	
	CLCatMatrixView *m_catMatrixView;
	NSImage *m_catImage;
	id me;
#ifdef OPENCV
	CvHaarClassifierCascade *m_cascade;
	CvMemStorage *m_storage;
#endif
}

@synthesize window = m_window;
@synthesize imageView = m_imageView;
@synthesize spinner = m_spinner;

#ifdef OPENCV
- (void)initOpenCV {
	const char *cascade_location = "/usr/local/Cellar/opencv/2.3.1a/share/opencv/haarcascades/haarcascade_frontalface_default.xml";
	
	m_cascade = (CvHaarClassifierCascade*)cvLoad( cascade_location, 0, 0, 0 );
    m_storage = cvCreateMemStorage(0);
}
#endif

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[self.imageView setImage: [NSImage imageNamed: @"robot.jpg"]];
	//const char *kommando = [[NSString stringWithFormat: @"open %@", g_browserPath] cStringUsingEncoding: NSUTF8StringEncoding];
	//system(kommando);
	
	int windowLevel = CGShieldingWindowLevel();
	//	NSRect windowRect = [[NSScreen mainScreen] frame];
	
	// Create transparent window.
	NSRect screensFrame = [[NSScreen mainScreen] frame];
	for (NSScreen *thisScreen in [NSScreen screens]) {
		screensFrame = NSUnionRect(screensFrame, [thisScreen frame]);
	}
	NSLog(@"screens frame: %@", [NSValue valueWithRect: screensFrame]);
	m_overlayWindow = [[NSWindow alloc] initWithContentRect:screensFrame
														  styleMask:NSBorderlessWindowMask
															backing:NSBackingStoreBuffered
															  defer:NO
															 screen:[NSScreen mainScreen]];
	m_catMatrixView = [[CLCatMatrixView alloc] initWithFrame: [[m_overlayWindow contentView] frame]];
	[m_overlayWindow setContentView: m_catMatrixView];


	[m_overlayWindow setReleasedWhenClosed:YES];
	[m_overlayWindow setLevel:windowLevel];
	[m_overlayWindow setBackgroundColor:[NSColor colorWithCalibratedRed:0.0
																green:0.0
																 blue:0.0
																alpha:0.0]];
	[m_overlayWindow setOpaque:NO];
	[m_overlayWindow setIgnoresMouseEvents: YES];

	[m_overlayWindow makeKeyAndOrderFront:nil];
	
	
	m_detector = [CIDetector detectorOfType:CIDetectorTypeFace
											  context:nil options:
				  [NSDictionary dictionaryWithObject:CIDetectorAccuracyLow forKey:CIDetectorAccuracy]];

	m_screenCap = [[CLScreenCapture alloc] init];
	m_catImage = [NSImage imageNamed: @"cat4.png"];
	me = self;
	
#ifdef OPENCV
	[self initOpenCV];
#endif
}
#define SCALE_FACTOR 1.0
- (void) handleCaptureTimer: (NSTimer *) timer {
	//NSImage *img = [m_screenCap captureWindowWithTitle: @"mozilla firefox start page"];
	//NSImage *img = [m_screenCap captureScreenhotBelowWindow: m_overlayWindow];
	
	CGImageRef image = [m_screenCap captureCGScreenhotBelowWindow: m_overlayWindow];
	
	//	CGImageRef image = resizeCGImage(img, CGImageGetWidth(img)*SCALE_FACTOR, CGImageGetHeight(img)*SCALE_FACTOR);
	//	CGImageRelease(img);
	
	CIImage *iimage = [CIImage imageWithCGImage: image];
	//CIImage *_iimage = [CIImage imageWithData: [img TIFFRepresentation]];
	
//	CIFilter *scaleFilter = [CIFilter filterWithName:@"CILanczosScaleTransform"];
//	[scaleFilter setValue:_iimage forKey:@"inputImage"];
//	[scaleFilter setValue:[NSNumber numberWithFloat:SCALE_FACTOR] forKey:@"inputScale"];
//	[scaleFilter setValue:[NSNumber numberWithFloat:1.0] forKey:@"inputAspectRatio"];
//	CIImage *iimage = [scaleFilter valueForKey:@"outputImage"];
	
	NSArray* features = [m_detector featuresInImage:iimage];

	//	NSLog(@"features: %@", features);
	NSMutableArray *rects = [NSMutableArray array];
	
	[[m_overlayWindow contentView] setSubviews: [NSArray array]];
	
	
	for(CIFaceFeature* faceFeature in features) {
		CGRect r = faceFeature.bounds;
		r.origin.x *= 1.0/SCALE_FACTOR;
		r.origin.y *= 1.0/SCALE_FACTOR;
		r.size.width *= 1.0/SCALE_FACTOR;
		r.size.height *= 1.0/SCALE_FACTOR;
		float xdiff = r.size.width;
		float ydiff = r.size.height;
		r.size.width *= 1.6;
		r.size.height *= 1.6;
		xdiff = r.size.width - xdiff;
		ydiff = r.size.height - ydiff;
		r.origin.x -= xdiff/2.0;
		r.origin.y -= ydiff/4.0;
		[rects addObject: [NSValue valueWithRect: r]];
		

		
//		CLImageView *iv = [[CLImageView alloc] initWithFrame: r];
//		[iv setImage: m_catImage];
//		[[m_overlayWindow contentView] addSubview: iv];

	}
			NSLog(@"rects: %@", rects);
	[m_overlayWindow.contentView setCatRects: rects];
	[m_overlayWindow.contentView setNeedsDisplay: YES];
//	[m_overlayWindow.contentView unlockFocus];
	//	[self.imageView setImage: img];
	
	//CLImageView *iv = (CLImageView*)[self.window contentView];
	//	[iv setImage: img];
//	CGImageRelease(image);
}

#ifdef OPENCV
- (void) handleCaptureTimerOpenCV: (NSTimer *) timer {
	//NSImage *img = [m_screenCap captureWindowWithTitle: @"mozilla firefox start page"];
	CGImageRef img = [m_screenCap captureCGScreenhotBelowWindow: m_overlayWindow];
	
	
	
	//	CIImage *image = [CIImage imageWithData: [img TIFFRepresentation]];
	//	NSArray* features = [m_detector featuresInImage:image];
	
	//	NSLog(@"features: %@", features);
	[[m_overlayWindow contentView] setSubviews: [NSArray array]];

	IplImage *cvimg = CreateIplImageFromUIImage(img);
	IplImage *grey = cvCreateImage(cvSize(CGImageGetWidth(img), CGImageGetHeight(img)), 8, 1);
	IplImage *small = cvCreateImage(cvSize(CGImageGetWidth(img)/2, CGImageGetHeight(img)/2), 8, 1);

			
	cvCvtColor(cvimg, grey, CV_BGR2GRAY);
	cvResize(grey, small, CV_INTER_LINEAR);
	
	CvSeq *res = cvHaarDetectObjects(small, m_cascade, m_storage,
						1.1,  
						3, 
						CV_HAAR_DO_CANNY_PRUNING,
						cvSize(0, 0),
						cvSize(0,0));
	printf("res: %p\n", res);
	printf("total: %i\n", res->total);
	for (int i = 0; i < (res?res->total:0); i++) {
		CvRect *r = (CvRect*)cvGetSeqElem(res, i);
		printf("rect: %i, %i, %i, %i\n", r->x, r->y, r->width, r->height);
		NSRect frame = NSMakeRect(r->x*2, CGImageGetHeight(img) - r->y*2 - r->height*2, r->width*2, r->height*2);
		//		frame.origin.x *= 2;
		//frame.origin.y *= 2;
		
		NSLog(@"frame: %@", [NSValue valueWithRect: frame]);
		
		CLImageView *iv = [[CLImageView alloc] initWithFrame: frame];
		[iv setImage: m_catImage];
		[[m_overlayWindow contentView] addSubview: iv];

	}
	//NSImage *res = opencvImageToNSImage(cvimg);
	//	NSImage *res =  [[NSImage alloc] initWithCGImage: img
	//											size: NSMakeSize(CGImageGetWidth(img), CGImageGetHeight(img))];
	CGImageRelease(img);
	cvReleaseImage(&cvimg);
	cvReleaseImage(&grey);
	cvReleaseImage(&small);
	
	//[self.imageView setImage: res];
	
//	for(CIFaceFeature* faceFeature in features) {
//		CGRect r = faceFeature.bounds;
//		float xdiff = r.size.width;
//		float ydiff = r.size.height;
//		r.size.width *= 1.6;
//		r.size.height *= 1.6;
//		xdiff = r.size.width - xdiff;
//		ydiff = r.size.height - ydiff;
//		r.origin.x -= xdiff/2.0;
//		r.origin.y -= ydiff/4.0;
//		
//		
//		
//		CLImageView *iv = [[CLImageView alloc] initWithFrame: r];
//		[iv setImage: m_catImage];
//		[[m_overlayWindow contentView] addSubview: iv];
//	}
//	[[m_overlayWindow contentView] setNeedsDisplay: YES];
	//	[m_overlayWindow.contentView unlockFocus];
	//	[self.imageView setImage: img];
	
	//CLImageView *iv = (CLImageView*)[self.window contentView];
	//	[iv setImage: img];
}
#endif


- (void) singleShot:(id)sender {
	[self handleCaptureTimer: nil];
}

- (void) findWindow:(id)sender {
	[m_screenCap updateWindowList];
}

- (void) startBot:(id)sender {
	[self.spinner startAnimation: nil];
	
#ifdef OPENCV

	m_captureTimer = [NSTimer 
					  scheduledTimerWithTimeInterval: 1.0/30.0
					  target: self
					  selector: @selector(handleCaptureTimerOpenCV:) 
					  userInfo: nil
					  repeats: YES];
#else
	m_captureTimer = [NSTimer 
					  scheduledTimerWithTimeInterval: 1.0/20.0
					  target: self
					  selector: @selector(handleCaptureTimer:) 
					  userInfo: nil
					  repeats: YES];
#endif
}

- (void) stopBot:(id)sender {
	[self.spinner stopAnimation: nil];
	[m_captureTimer invalidate];
	m_captureTimer = nil;
}


@end
