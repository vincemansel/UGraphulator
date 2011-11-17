//
//  GraphViewController.m
//  Graphulator
//
//  Created by Vince Mansel on 11/8/11.
//  Copyright (c) 2011 Wave Ocean Software. All rights reserved.
//

#import "GraphViewController.h"

@implementation GraphViewController

@synthesize dataWidth, dataResolution;
@synthesize graphView;
@synthesize graphData;

- (void)updateUI
{
    [self.graphView setNeedsDisplay];
}

- (void)setGraphData:(NSDictionary *)newGraphData
{
    graphData = newGraphData;
    [self updateUI];
}

- (CGFloat)yValueForGraphView:(GraphView *)requestor
                         forX:(CGFloat)x
{
    //NSInteger indexSpan = dataWidth * dataResolution;
    NSInteger index = (NSInteger)(x * dataResolution);
    
    //NSLog(@"yValueForGraphView: index = %d", index);
    
    return [[graphData objectForKey:[NSNumber numberWithInteger:index]] doubleValue];
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
    self.graphView.graphScale = 30;
    
    UIGestureRecognizer *pinchgr = [[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(handlePinch:)];
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
