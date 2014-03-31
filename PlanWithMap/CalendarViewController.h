//
//  CalendarControllerViewViewController.h
//  PlanWithMap
//
//  Created by Christine on 2014/3/23.
//  Copyright (c) 2014年 Christine. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "myCalendarDayView.h"

#import "AppDelegate.h"
#import "myAnnotation.h"
#import "myPinAnnotationView.h"
#import "DetailViewController.h"

#define startX 0
#define startY 133

@interface CalendarViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSManagedObjectContext *managedObjectContext;
    NSMutableArray *scheduleOfMonth;
    NSMutableArray *scheduleOfDay;
    NSDateComponents *selectedDate;
}

@property (weak, nonatomic) IBOutlet UILabel *monthLabel;

@property (nonatomic, copy) NSDateComponents *month;
@property (nonatomic, strong) myAnnotation *selectedAnnotation;
@property (nonatomic, strong) UITableView *scheduleTableView;


- (IBAction)backMonth:(id)sender;
- (IBAction)forwardMonth:(id)sender;

@end
