//
//  CalculatorViewController.m
//  Smallculator
//
//  Created by Vince Mansel on 11/1/11.
//  Copyright (c) 2011 Wave Ocean Software. All rights reserved.
//

#import "CalculatorViewController.h"

@interface CalculatorViewController()
@property (retain) CalculatorBrain *pBrain;
-(void)displayResult:(double)result;
@end;

@implementation CalculatorViewController
@synthesize pBrain;
@synthesize display;

- (GraphViewController *)graphViewController
{
    if (!graphViewController) graphViewController = [[GraphViewController alloc] init];
    return graphViewController;
}

- (void)viewDidLoad
{
    pBrain = [[CalculatorBrain alloc] init];
    self.title = @"Graphulator";
}

- (void)viewDidUnLoad
{
    self.display = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (BOOL)isfloatingPointOK:(NSString *)displayText
{
    NSRange range = [displayText rangeOfString:@"."];
    if (range.location == NSNotFound) return YES;
    else return NO;
}

- (IBAction)digitPressed:(UIButton *)sender
{
    NSString *digit = sender.titleLabel.text;
    
    if ([digit isEqual:@"Back"])
    {
        NSUInteger index = [display.text length] - 1;
        if (index > 0)
            [display setText:[display.text substringToIndex:index]];
        else
            [display setText:@"0"];
    }
    else if ([digit isEqual:@"π"])
    {
        [display setText:[NSString stringWithFormat:@"%g", M_PI]];
        userIsInTheMiddleOfTypingANumber = YES;
    }
    else if (userIsInTheMiddleOfTypingANumber)
    {
        if (([digit isEqual:@"."] && [self isfloatingPointOK:display.text]) ||
            ![digit isEqual:@"."])
            [display setText:[display.text stringByAppendingString:digit]];
    }
    else
    {
        [display setText:digit];
        userIsInTheMiddleOfTypingANumber = YES;
    }
}

- (void)variablePressed:(UIButton *)sender
{
    NSString *variable = sender.titleLabel.text;
    [pBrain setVariableAsOperand:variable];
}

- (IBAction)operationPressed:(UIButton *)sender
{   
    if (userIsInTheMiddleOfTypingANumber)
    {
        [pBrain setOperand:[display.text doubleValue]];
        userIsInTheMiddleOfTypingANumber = NO;
    }
    
    // The old version without the alloc was causing a malloc_error in CalculatorBrain
    // during a performOperation:@"C". The command [internalExpression removeObjects] was double-free on the 1st @"="
    // for the sequence "3 * = Solve 3 * = Solve + x = Solve C"
    
    NSString *operation = [[NSString alloc] initWithString:sender.titleLabel.text];
    
    double result = [pBrain performOperation:operation];
    
    if ([CalculatorBrain variablesInExpression:pBrain.expression])
        [display setText:[CalculatorBrain descriptionOfExpression:pBrain.expression]];
    else
        [self displayResult:result];    
}

- (NSString *)graphTitle
{  
    if (userIsInTheMiddleOfTypingANumber)
    {
        [pBrain setOperand:[display.text doubleValue]];
        userIsInTheMiddleOfTypingANumber = NO;
    }

    NSString * doe = [CalculatorBrain descriptionOfExpression:pBrain.expression];
    if (doe.length > 0) {
        //NSLog(@"equationDescription: Last Character = %@", [doe substringFromIndex:doe.length-2]);
        if (![[doe substringFromIndex:doe.length-2] isEqual:@"= "])
            [pBrain performOperation:@"="];
    }
    NSString * doe2 = [CalculatorBrain descriptionOfExpression:pBrain.expression];
    return doe2;
}

#define WIDTH 1600
#define RESOLUTION 40

- (NSDictionary *)expressionResult
{    
    CGFloat result;
    NSMutableDictionary *resultDictionary = [[NSMutableDictionary alloc] init];
    
    NSInteger span = WIDTH * RESOLUTION;
    NSInteger resolution = RESOLUTION;
    
    for (CGFloat x = -span/2; x <= span/2; x += 1) {
        //NSNumber *xVal = [NSNumber numberWithFloat:x/resolution]; 
        result = [CalculatorBrain evaluateExpression:pBrain.expression
                                     usingVariableValues:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [NSNumber numberWithFloat:x/resolution],@"x",
                                                          nil]];
//        NSNumber *index = [NSNumber numberWithInt:x];
//        [resultDictionary setObject:[NSNumber numberWithFloat:result] forKey:index];
        [resultDictionary setObject:[NSNumber numberWithFloat:result] forKey:[NSNumber numberWithInteger:x]];
//        NSInteger count = [resultDictionary count];
//        if (x >= -10 && x <= 10)
//            NSLog(@"CalculatorViewController.m : expressionResult: x = %g, xVal = %@, index = %@, result = %g, count = %d, rD = %g",
//                  x, xVal, index, result, count, [[resultDictionary objectForKey:index] doubleValue]);
    }
//    NSLog(@"%@", resultDictionary);
    return (NSDictionary *)resultDictionary;
}

- (IBAction)graphPressed:(UIButton *)sender
{
    self.graphViewController.dataWidth = WIDTH;
    self.graphViewController.dataResolution = RESOLUTION;
    self.graphViewController.graphData = [self expressionResult];
    self.graphViewController.title = [self graphTitle];
    if (self.graphViewController.view.window == nil) {
        [self.navigationController pushViewController:graphViewController animated:YES];
    }
}

- (void)displayResult:(double)result
{
    if (isnan(result))
        [display setText:@"Error: Negative square root not allowed"];
    else if (isinf(result))
        [display setText:@"Error: Divide by zero not allowed"];
    else
        [display setText:[NSString stringWithFormat:@"%g", result]];
}

// Sample Code Referenced: BreadcrumbViewController.m
//-(IBAction)toggleDegRadSwitch:(UISwitch *)sender
//{
//    UISwitch *degRadSwitch = (UISwitch *)sender;
//    if (degRadSwitch.isOn)
//    {
//        pBrain.degOrRad = YES;
//        [degOrRadUISwitchStatus setText:@"Deg"];
//    }
//    else
//    {
//        pBrain.degOrRad = NO;
//        [degOrRadUISwitchStatus setText:@"Rad"];
//    }
//}

- (void)dealloc {
    self.display = nil;
    [self.pBrain release];
    [self.graphViewController release];
    [super dealloc];
}

@end
