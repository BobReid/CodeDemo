//
//  CDZoomView.m
//  CodeDemo
//
// 
// Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
// Inc. ("Apple") in consideration of your agreement to the following
// terms, and your use, installation, modification or redistribution of
// this Apple software constitutes acceptance of these terms.  If you do
// not agree with these terms, please do not use, install, modify or
// redistribute this Apple software.
// 
// In consideration of your agreement to abide by the following terms, and
// subject to these terms, Apple grants you a personal, non-exclusive
// license, under Apple's copyrights in this original Apple software (the
// "Apple Software"), to use, reproduce, modify and redistribute the Apple
// Software, with or without modifications, in source and/or binary forms;
// provided that if you redistribute the Apple Software in its entirety and
// without modifications, you must retain this notice and the following
// text and disclaimers in all such redistributions of the Apple Software.
// Neither the name, trademarks, service marks or logos of Apple Inc. may
// be used to endorse or promote products derived from the Apple Software
// without specific prior written permission from Apple.  Except as
// expressly stated in this notice, no other rights or licenses, express or
// implied, are granted by Apple herein, including but not limited to any
// patent rights that may be infringed by your derivative works or by other
// works in which the Apple Software may be incorporated.
// 
// The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
// MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
// THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
// OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
// 
// IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
// OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
// MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
// AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
// STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
// 
// Copyright (C) 2012 Apple Inc. All Rights Reserved.
// 
//
//  Modified By: Bob Reid - Oct 31, 2013
//  Modified From: ImageScrollView.m
//
//  This view was largly adapted from an Apple Inc. demo on zooming
//  Modified the code to work with arbitrary views and not just a predefined set of images
//  The code demo is available at https://developer.apple.com/library/ios/samplecode/PhotoScroller/Introduction/Intro.html
//

#import "CDZoomView.h"

@interface CDZoomView () <UIScrollViewDelegate>
{
    CGPoint _pointToCenterTo;
    CGFloat _scaleToResizeTo;
}

@end

@implementation CDZoomView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setShowsHorizontalScrollIndicator:NO];
        [self setShowsVerticalScrollIndicator:NO];
        [self setBouncesZoom:YES];
        [self setDecelerationRate:UIScrollViewDecelerationRateFast];
        [self setDelegate:self];
    }
    return self;
}

- (void)setViewToZoom:(UIView *)viewToZoom
{
    [self.viewToZoom removeFromSuperview];
    
    [self willChangeValueForKey:@"viewToZoom"];
    _viewToZoom = viewToZoom;
    [self didChangeValueForKey:@"viewToZoom"];
    
    [self addSubview:self.viewToZoom];
    [self setContentSize:viewToZoom.bounds.size];
    [self setZoomScale:1.0f];
    [self configureMinMaxZoomScales];
    [self setZoomScale:self.minimumZoomScale];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize scrollSize = [self bounds].size;
    CGRect frame = [self.viewToZoom frame];
    frame.origin.x = 0;
    frame.origin.y = 0;
    
    if(frame.size.width < scrollSize.width)
        frame.origin.x = (scrollSize.width - frame.size.width) / 2.0f;
    
    if(frame.size.height < scrollSize.height)
        frame.origin.y = (scrollSize.height - frame.size.height) / 2.0f;
    
    [self.viewToZoom setFrame:frame];
}

- (void)setFrame:(CGRect)frame
{
    BOOL sizeChanging = CGSizeEqualToSize(frame.size, self.frame.size);
    
    if(sizeChanging)
        [self prepareToResize];
    
    [super setFrame:frame];
    
    if(sizeChanging)
        [self recoverFromResizing];
}



- (void)configureMinMaxZoomScales
{
    CGSize scrollSize = self.bounds.size;
    CGSize contentSize = self.viewToZoom.bounds.size;
    
    CGFloat xScale = scrollSize.width / contentSize.width;
    CGFloat yScale = scrollSize.height / contentSize.height;
    
    BOOL imageIsPortrait = contentSize.height > contentSize.width;
    BOOL viewIsPortrait = scrollSize.height > scrollSize.width;
    
    CGFloat minScale = imageIsPortrait == viewIsPortrait ? xScale : MIN(xScale, yScale);
    CGFloat maxScale = 1.0f / [[UIScreen mainScreen] scale];
    if(minScale > maxScale)
        minScale = maxScale;
    
    [self setMinimumZoomScale:minScale];
    [self setMaximumZoomScale:maxScale];
}

- (void)prepareToResize
{
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _pointToCenterTo = [self convertPoint:boundsCenter toView:self.viewToZoom];
    
    _scaleToResizeTo = [self zoomScale];
    
    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (_scaleToResizeTo <= [self minimumZoomScale] + FLT_EPSILON)
        _scaleToResizeTo = 0;
}

- (void)recoverFromResizing
{
    [self configureMinMaxZoomScales];
    
    // Step 1: restore zoom scale, first making sure it is within the allowable range.
    CGFloat maxZoomScale = MAX([self minimumZoomScale], _scaleToResizeTo);
    [self setZoomScale:MIN([self maximumZoomScale], maxZoomScale)];
    
    // Step 2: restore center point, first making sure it is within the allowable range.
    
    // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:_pointToCenterTo fromView:self.viewToZoom];
    
    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                                 boundsCenter.y - self.bounds.size.height / 2.0);
    
    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    
    CGFloat realMaxOffset = MIN(maxOffset.x, offset.x);
    offset.x = MAX(minOffset.x, realMaxOffset);
    
    realMaxOffset = MIN(maxOffset.y, offset.y);
    offset.y = MAX(minOffset.y, realMaxOffset);
    
    self.contentOffset = offset;
}

- (CGPoint)maximumContentOffset
{
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset
{
    return CGPointZero;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [self viewToZoom];
}


@end
