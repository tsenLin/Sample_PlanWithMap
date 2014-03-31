//
//  myCalendarDayView.h
//  PlanWithMap
//
//  Created by Christine on 2014/3/23.
//  Copyright (c) 2014年 Christine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define PI 3.14159265358979323846
#define dayViewWidth 46
#define dayViewHight 46


@interface myCalendarDayView : UIButton

@property (nonatomic, copy) NSDateComponents *day;

- (void)daySelected;
- (void)dayUnselected;
@end
