//
//  GraphView.h
//  Graphulator
//
//  Created by Vince Mansel on 11/8/11.
//  Copyright (c) 2011 Wave Ocean Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MIN_SCALE 1.0
#define MAX_SCALE 1600.0

@class GraphView;

@protocol GraphViewDelegate
- (CGFloat)yValueForGraphView:(GraphView *)requestor
                         forX:(CGFloat)x;           // depends on graphScale
@end

@interface GraphView : UIView
{
    CGFloat graphScale;
    CGPoint origin;
    id <GraphViewDelegate> delegate;
}

@property (nonatomic) CGFloat graphScale;
@property (nonatomic) CGPoint origin;
@property (assign) id <GraphViewDelegate> delegate;

@end
