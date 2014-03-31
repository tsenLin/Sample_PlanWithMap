//
//  PhotoViewController.h
//  PlanWithMap
//
//  Created by Christine on 2014/3/12.
//  Copyright (c) 2014年 Christine. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "DetailViewController.h"

@interface PhotoViewController : UIViewController

@property (weak, nonatomic) DetailViewController *delegate;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageController;
@property (nonatomic) NSArray *imageArray;
@property (nonatomic) int pageIndex;


-(void)showImage;
-(IBAction)handleSwipe:(UISwipeGestureRecognizer *)sender;
@end
