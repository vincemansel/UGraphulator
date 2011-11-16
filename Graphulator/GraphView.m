//
//  GraphView.m
//  Graphulator
//
//  Created by Vince Mansel on 11/8/11.
//  Copyright (c) 2011 Wave Ocean Software. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@implementation GraphView

@synthesize delegate;

- (void)setup
{
    self.contentMode = UIViewContentModeRedraw;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

#define DEFAULT_SCALE 32

- (CGFloat)graphScale
{
    if (!(graphScale >= MIN_SCALE && graphScale <= MAX_SCALE)) graphScale = DEFAULT_SCALE;
    return graphScale;
}

- (void)setGraphScale:(CGFloat)newScale
{
    if (newScale < MIN_SCALE) newScale = MIN_SCALE;
    if (newScale > MAX_SCALE) newScale = MAX_SCALE;
    graphScale = round(newScale);
    [self setNeedsDisplay];
}

- (CGPoint)origin
{
    return origin;
}

#define AXIS_FONT_SIZE 30

- (void)setOrigin:(CGPoint)newOrigin
{
    BOOL originChanged = NO;
    
    if ((newOrigin.x >= (self.bounds.origin.x - self.bounds.size.width/2)) &&
         (newOrigin.x < (self.bounds.origin.x + self.bounds.size.width/2 - AXIS_FONT_SIZE))) {
        origin.x = newOrigin.x;
        originChanged = YES;
    }
    if ((newOrigin.y >= (self.bounds.origin.y - self.bounds.size.height/2)) &&
        (newOrigin.y < (self.bounds.origin.y + self.bounds.size.height/2 - AXIS_FONT_SIZE))) {
        origin.y = newOrigin.y;
        originChanged = YES;
    }

    if (originChanged)
        [self setNeedsDisplay];
}

// Pinch is handled in GraphViewController.m

-(void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    if ((recognizer.state == UIGestureRecognizerStateChanged) ||
        (recognizer.state == UIGestureRecognizerStateEnded)) {
        CGPoint translation = [recognizer translationInView:self];
        self.origin = CGPointMake(self.origin.x+translation.x, self.origin.y+translation.y);
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

-(void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized)
    {
        self.origin = CGPointMake(0, 0);
    }
}

- (void)drawRect:(CGRect)rect
{
    CGPoint midPoint;
//    midPoint.x = self.bounds.origin.x + self.bounds.size.width/2;
//    midPoint.y = self.bounds.origin.y + self.bounds.size.height/2;
    
    midPoint.x = self.bounds.origin.x + self.bounds.size.width/2 + self.origin.x;
    midPoint.y = self.bounds.origin.y + self.bounds.size.height/2 + self.origin.y;
    
//    NSLog(@"Width:Height=%g:%g", self.bounds.size.width, self.bounds.size.height);
//    NSLog(@"drawRect: > bounds.origin.x:y=%g:%g", self.bounds.origin.x, self.bounds.origin.y);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 2.0);
    [[UIColor blueColor] setStroke]; 
    
    [AxesDrawer drawAxesInRect:self.bounds originAtPoint:midPoint scale:graphScale];
    
    CGFloat widthInPoints = self.bounds.size.width / graphScale;
    
    NSLog(@"drawRect: > widthInPoints = %g", widthInPoints);
    
//    NSLog(@"GraphView.m > drawRect: Pixels per Point=%g", self.contentScaleFactor);
//    NSLog(@"GraphView.m > drawRect: midPoint=%g:%g", midPoint.x, midPoint.y);
    
    CGFloat widthInPixel = self.bounds.size.width * self.contentScaleFactor;
    CGFloat heightInPixel = self.bounds.size.height * self.contentScaleFactor;
    CGFloat halfPixelWidth = widthInPixel/2;
    CGFloat halfPixelHeight = heightInPixel/2;
    
    int dataRangeBoundary; //self.contentScaleFactor;
    int xAxisBoundary;
    
    dataRangeBoundary = halfPixelWidth;
    xAxisBoundary = dataRangeBoundary/graphScale;
    
    CGFloat xIncrement = (graphScale / (dataRangeBoundary / xAxisBoundary));
    int xMove = 2/self.contentScaleFactor;
    
    CGContextSetLineWidth(context, 1.0);
    [[UIColor blackColor] setStroke];
    CGContextBeginPath(context);
    
    CGPoint p;
    p.x = self.origin.x;
    CGFloat yC = [self.delegate yValueForGraphView:self forX:0];
    p.y = (halfPixelHeight/self.contentScaleFactor) - (yC * graphScale) + self.origin.y;
    CGContextMoveToPoint(context, p.x, p.y);
    
    for (int x = xMove; x <= dataRangeBoundary * xMove; x += xMove) {
        p.x = x * xIncrement + self.origin.x;
        yC = [self.delegate yValueForGraphView:self forX:(CGFloat)x];
        p.y = (halfPixelHeight/self.contentScaleFactor) - (yC * graphScale) + self.origin.y;
        CGContextAddLineToPoint(context, p.x, p.y);
    }
    CGContextStrokePath(context);
//    NSLog(@" ");
}

- (void)dealloc
{
    [super dealloc];
}

@end
