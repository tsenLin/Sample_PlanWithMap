//
//  myCalendarDayView.m
//  PlanWithMap
//
//  Created by Christine on 2014/3/23.
//  Copyright (c) 2014年 Christine. All rights reserved.
//

#import "myCalendarDayView.h"

@implementation myCalendarDayView

@synthesize day;


- (id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    
    //NSLog(@"draw day button start");
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 0.5);//线条颜色
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 46,0);
    CGContextStrokePath(context);
    
    if (self.selected == NO)
    {
        [self setTitle:[NSString stringWithFormat:@"%ld", (long)self.day.day] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
    }
    else if (self.selected == YES)
    {
        [self setTitle:[NSString stringWithFormat:@"%ld", (long)self.day.day] forState:UIControlStateSelected];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self setBackgroundImage:[UIImage imageNamed:@"sun-red-circle.png"] forState:(UIControlStateSelected)];
        //NSLog(@"draw day button yes");
    }
    
    //NSLog(@"draw day button end");
}

- (void)daySelected
{
    self.selected = YES;
    
    [self setTitle:[NSString stringWithFormat:@"%ld", (long)self.day.day] forState:UIControlStateSelected];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self setBackgroundImage:[UIImage imageNamed:@"sun-red-circle.png"] forState:(UIControlStateSelected)];
    //NSLog(@"daySelected %u, seleted %hhd", self.state, self.selected);
}

- (void)dayUnselected
{
    self.selected = NO;
    
    [self setTitle:[NSString stringWithFormat:@"%ld", (long)self.day.day] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self setBackgroundImage:nil forState:(UIControlStateSelected)];
    //NSLog(@"dayUNselected %u, seleted %hhd", self.state, self.selected);
}


@end
