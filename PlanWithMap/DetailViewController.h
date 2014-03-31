//
//  DetailViewController.h
//  myAnnotation
//
//  Created by Christine on 2014/2/18.
//  Copyright (c) 2014年 Christine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "AppDelegate.h"
#import "MapViewController.h"
#import "myAnnotation.h"
#import "myPinAnnotationView.h"
#import "PinAlbumCell.h"
#import "PhotoViewController.h"
#import "CalendarViewController.h"


@interface DetailViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UINavigationBarDelegate, UIImagePickerControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
{
    NSManagedObjectContext *managedObjectContext;
    myAnnotation *inputAnnotation;
    ALAssetsLibrary *library;
    NSMutableArray *imageArray;
    NSConditionLock* albumReadLock;
    NSArray *pinTypeArray;
    UIPickerView *pinTypePicker ;
    UIToolbar *pinTypePickerToolbar;
    UIDatePicker *datePicker ;
    UIToolbar *datePickerToolbar;
    NSLocale *dateLocale;
    UIImagePickerController *imagePicker1;
    UIImagePickerController *imagePicker2;
}


@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) myAnnotation *inputAnnotation;
@property (nonatomic) AnnotationData *fetchAnnotation;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIImageView *pinImageView;
@property (weak, nonatomic) IBOutlet UITextField *pinTitle;
@property (weak, nonatomic) IBOutlet UITextField *pinSubtitle;
@property (weak, nonatomic) IBOutlet UITextField *pinTypeText;
@property (weak, nonatomic) IBOutlet UITextField *dateText;
@property (weak, nonatomic) IBOutlet UITextView *infoText;
@property (weak, nonatomic) IBOutlet UICollectionView *imageColView;

- (IBAction)AddPhoto:(id)sender;
-(void)viewImageSingleTap:(NSIndexPath *)indexPath;
- (IBAction)toggleEdit:(id)sender;

@end
