//
//  PhotoPageViewController.h
//  PlanWithMap
//
//  Created by Christine on 2014/3/3.
//  Copyright (c) 2014年 Christine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoPageViewController : UIViewController

@property NSUInteger pageIndex;
@property NSString *titleText;
@property UIImage *image;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
- (IBAction)backToDetail:(id)sender;

@end
