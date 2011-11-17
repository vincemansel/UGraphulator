//
//  GraphViewController.h
//  Graphulator
//
//  Created by Vince Mansel on 11/8/11.
//  Copyright (c) 2011 Wave Ocean Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"

@interface GraphViewController : UIViewController <GraphViewDelegate, UISplitViewControllerDelegate>
{
    NSInteger dataWidth;
    NSInteger dataResolution;
    GraphView *graphView;
    NSDictionary *graphData;
}

@property (nonatomic) NSInteger dataWidth, dataResolution;
@property (retain) IBOutlet GraphView *graphView;
@property (retain, nonatomic) NSDictionary *graphData;

//- (IBAction)zoomPressed:(UIButton *)sender;

@end
