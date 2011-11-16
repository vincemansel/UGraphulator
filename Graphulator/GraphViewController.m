//
//  GraphViewController.m
//  Graphulator
//
//  Created by Vince Mansel on 11/8/11.
//  Copyright (c) 2011 Wave Ocean Software. All rights reserved.
//

#import "GraphViewController.h"

@implementation GraphViewController

//@synthesize scale, dataWidth, dataResolution;
@synthesize dataWidth, dataResolution;
@synthesize graphView;
@synthesize graphData;

- (void)updateUI
{
    [self.graphView setNeedsDisplay];
}

- (void)setGraphData:(NSArray *)newGraphData
{
    graphData = newGraphData;
    [self updateUI];
}

- (CGFloat)yValueForGraphView:(GraphView *)requestor
                         forX:(CGFloat)x
{
    CGFloat indexSpan = dataWidth * dataResolution;
    CGFloat index = 0;
    if (self.graphView.graphScale <= self.dataResolution) {
        index = ((indexSpan/2) - ((indexSpan/2)/self.graphView.graphScale)) + (x * (self.dataResolution/self.graphView.graphScale));
        if (x > 0 && self.graphView.graphScale != 16) index -= 1;
    }
    else if (self.graphView.graphScale >= 32) {
        index = ((indexSpan/2) - ((indexSpan/2)/self.graphView.graphScale)) + x;
    }
    
    CGFloat result = [[graphData objectAtIndex:(NSInteger)index] doubleValue];
    
//    if (index == 2560)
//        NSLog(@"GraphViewController.m : yValueForGraphView: x = %g, index = %g, result = %g", x, index, result);
    return result;
}

- (void)zoomPressed:(NSString *)zoom
{
    //NSLog(@"Zoom Pressed: %@", sender.titleLabel.text);
    
    //NSString *zoom= sender.titleLabel.text;
    
    if ([zoom isEqual:@"Zoom In"]) {
        if (self.graphView.graphScale + 1 <= MAX_SCALE)
            self.graphView.graphScale += 1;
    }
    else if ([zoom isEqual:@"Zoom Out"]) {
        if (self.graphView.graphScale - 1 >= MIN_SCALE)
            self.graphView.graphScale -= 1;
    }
}

- (void)handlePinch:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        self.graphView.graphScale *= gesture.scale;
        if (gesture.scale > 1)
            [self zoomPressed:@"Zoom In"];
        else
            [self zoomPressed:@"Zoom Out"];
        gesture.scale = 1;
    }
}

- (void)releaseOutlets
{
    self.graphView = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.graphView.delegate = self;
    self.graphView.graphScale = 32;
    UIGestureRecognizer *pinchgr = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.graphView addGestureRecognizer:pinchgr];
    [pinchgr release];
    
    UIGestureRecognizer *pangr = [[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(handlePan:)];
    [self.graphView addGestureRecognizer:pangr];
    [pangr release];
    
    UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(handleTap:)];
    tapgr.numberOfTapsRequired = 2;
    [self.graphView addGestureRecognizer:tapgr];
    [tapgr release];

    [self updateUI];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self releaseOutlets];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = aViewController.title;
    self.navigationItem.rightBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)button
{
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)dealloc
{
    [self releaseOutlets];
    [self.graphData release];
    [super dealloc];
}

@end
