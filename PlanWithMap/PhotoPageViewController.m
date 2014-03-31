//
//  PhotoPageViewController.m
//  PlanWithMap
//
//  Created by Christine on 2014/3/3.
//  Copyright (c) 2014年 Christine. All rights reserved.
//

#import "PhotoPageViewController.h"

@interface PhotoPageViewController ()

@end

@implementation PhotoPageViewController
@synthesize pageIndex, titleText, image;
@synthesize imageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    NSLog(@"page init");
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    imageView.image = image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backToDetail:(id)sender {
}
@end
