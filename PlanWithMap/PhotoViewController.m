//
//  PhotoViewController.m
//  PlanWithMap
//
//  Created by Christine on 2014/3/12.
//  Copyright (c) 2014年 Christine. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController ()

@end

@implementation PhotoViewController

@synthesize photoImageView, pageController, imageArray, pageIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    pageController.backgroundColor = [UIColor blackColor];
    pageController.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageController.currentPageIndicatorTintColor = [UIColor whiteColor];
    pageController.numberOfPages = [imageArray count];
    pageController.currentPage = pageIndex;
    [self showImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showImage
{
    photoImageView.image = [imageArray objectAtIndex:pageController.currentPage];
}

-(IBAction)handleSwipe:(UISwipeGestureRecognizer *)sender
{
    switch (sender.direction) {
        case UISwipeGestureRecognizerDirectionLeft:
            if (pageController.currentPage < [imageArray count])
            {
                pageController.currentPage ++;
                [self showImage];
            }
            break;

        case UISwipeGestureRecognizerDirectionRight:
            if (pageController.currentPage > 0)
            {
                pageController.currentPage --;
                [self showImage];
            }
            break;
        default:
            break;
    }

}

@end
