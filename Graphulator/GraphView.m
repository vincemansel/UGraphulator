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
    //if (!(graphScale >= MIN_SCALE && graphScale <= MAX_SCALE)) graphScale = DEFAULT_SCALE;
    return graphScale;
}

- (void)setGraphScale:(CGFloat)newScale
{
    if (newScale < MIN_SCALE) newScale = MIN_SCALE;
    if (newScale > MAX_SCALE) newScale = MAX_SCALE;
    graphScale = newScale;
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


- (void)handlePinch:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        self.graphScale *= gesture.scale;
//        if (gesture.scale > 1)
//            if (self.graphScale + 1 <= MAX_SCALE)
//                self.graphScale += 1;
//        else
//            if (self.graphScale - 1 >= MIN_SCALE)
//                self.graphScale -= 1;
        gesture.scale = 1;
    }
}


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
    
//    CGFloat widthInPoints = self.bounds.size.width / graphScale;
    
//    NSLog(@"drawRect: > widthInPoints = %g :: graphScale = %g", widthInPoints, graphScale);
    
//    NSLog(@"GraphView.m > drawRect: Pixels per Point=%g", self.contentScaleFactor);
//    NSLog(@"GraphView.m > drawRect: midPoint=%g:%g", midPoint.x, midPoint.y);
    
    CGFloat widthInPixels = self.bounds.size.width * self.contentScaleFactor;
    CGFloat heightInPixels = self.bounds.size.height * self.contentScaleFactor;
    CGFloat halfPixelWidth = widthInPixels/2;
    CGFloat halfPixelHeight = heightInPixels/2;
    
    int xMove = 8/self.contentScaleFactor;
    
//    NSLog(@"halfPixelWidth = %g", halfPixelWidth);
    
    CGContextSetLineWidth(context, 1.0);
    [[UIColor blackColor] setStroke];
    CGContextBeginPath(context);
    
    // Draw from midPoint out in both +/- directions
    
    CGPoint p;
    p.x = midPoint.x;
    CGFloat xVal = 0;
    CGFloat yVal = [self.delegate yValueForGraphView:self forX:xVal];
    p.y = (halfPixelHeight/self.contentScaleFactor) - (yVal * graphScale) + self.origin.y;
    CGContextMoveToPoint(context, p.x, p.y);
    
    for (int x = xMove; x <= halfPixelWidth * xMove; x += xMove) {
        p.x = midPoint.x + x;
        xVal = (CGFloat)x / graphScale;
        yVal = [self.delegate yValueForGraphView:self forX:(CGFloat)xVal];
        p.y = (halfPixelHeight/self.contentScaleFactor) - (yVal * graphScale) + self.origin.y;
        
        //NSLog(@"x = %d, p.x = %g, xVal = %g, yC = %g, p.y = %g", x, p.x, xVal, yVal, p.y);
        CGContextAddLineToPoint(context, p.x, p.y);
    }
    CGContextStrokePath(context);
    
    CGContextBeginPath(context);
    p.x = midPoint.x;
    xVal = 0;
    yVal = [self.delegate yValueForGraphView:self forX:xVal];
    p.y = (halfPixelHeight/self.contentScaleFactor) - (yVal * graphScale) + self.origin.y;
    CGContextMoveToPoint(context, p.x, p.y);
    
    for (int x = -xMove; x >= -halfPixelWidth * xMove; x -= xMove) {
        p.x = midPoint.x + x;
        CGFloat xVal = x / graphScale;
        yVal = [self.delegate yValueForGraphView:self forX:(CGFloat)xVal];
        p.y = (halfPixelHeight/self.contentScaleFactor) - (yVal * graphScale) + self.origin.y;
        //NSLog(@"x = %d, p.x = %g, xVal = %g, yC = %g, p.y = %g", x, p.x, xVal, yVal, p.y);
        CGContextAddLineToPoint(context, p.x, p.y);
    }
    CGContextStrokePath(context);
    //NSLog(@" ");
}

- (void)dealloc
{
    [super dealloc];
}

@end
