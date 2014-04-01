//
//  DetailViewController.m
//  myAnnotation
//
//  Created by Christine on 2014/2/18.
//  Copyright (c) 2014年 Christine. All rights reserved.
//


#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

@synthesize inputAnnotation, fetchAnnotation, editButton, pinImageView, pinTitle, pinSubtitle, dateText, pinTypeText, infoText, imageColView;
@synthesize managedObjectContext;

// NSConditionLock values
enum {
    WDASSETURL_PENDINGREADS = 2,
    WDASSETURL_FINISHED = 1,
    WDASSETURL_ALLFINISHED = 0
};



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
    
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    managedObjectContext = appDelegate.managedObjectContext;
    
    imageColView.allowsSelection = YES;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [infoText setReturnKeyType:UIReturnKeyDone];
    
    [self pinImageViewSetting];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self queryAnnotationData];
    
    [self initPinInfo];
    [self setDatePickerInit];
    [self setPinTypePickerInit];
    
    //[self DeleteAllLocationPhoto];
    [self loadLocationPhoto];
    [self.imageColView reloadData];
    
    if (self.pinTitle.enabled == YES)
        [self toggleEdit:self];
}


- (void)initPinInfo
{
    imageArray = [[NSMutableArray alloc]init];
    
    if ([inputAnnotation.locationImageURL length] == 0)
        pinImageView.image = [inputAnnotation getTypeImage:inputAnnotation.annotationType];
    else
    {
        [inputAnnotation getLocationPhoto];
        pinImageView.image = inputAnnotation.locationImage;
    }
    [pinImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    pinTitle.text = inputAnnotation.title;
    pinSubtitle.text = inputAnnotation.subtitle;
    
    pinTypeText.text = [inputAnnotation typeNumToString:inputAnnotation.annotationType];
    
    if (![fetchAnnotation.date isEqualToString:@"0000/00/00 XXX"])
        dateText.text = fetchAnnotation.date;
    
    if (fetchAnnotation.information != NULL)
        infoText.text = fetchAnnotation.information;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    if([self isMovingFromParentViewController])
    {
        if ([self.navigationController.topViewController isKindOfClass:[MapViewController class]])
        {
            [self toggleEdit:self];
            MapViewController *mapView = (MapViewController *)self.navigationController.topViewController;
            
            mapView.EdittedAnnotation = inputAnnotation;
            NSLog(@"back to map ");
        }
        else
            if ([self.navigationController.topViewController isKindOfClass:[CalendarViewController class]])
            {
                [self toggleEdit:self];
            }
    }
}

-(void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item
{
    NSLog(@"navigationBar didPopItem %@", item);
}

- (void)pinImageViewSetting
{
    pinImageView.userInteractionEnabled = NO;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pinImageViewTapAction)];
    //[tapRecognizer setDelegate:self];
    tapRecognizer.numberOfTapsRequired = 1;
    [pinImageView addGestureRecognizer:tapRecognizer];
}

- (void)pinImageViewTapAction
{
    imagePicker1 = [[UIImagePickerController alloc]init];
    
    imagePicker1.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker1.delegate = self;
    
    [self presentViewController:imagePicker1 animated:YES completion:nil];
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range  replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }
    return YES;
}

- (IBAction)toggleEdit:(id)sender
{
    bool endEdit = NO;
    for (id subview in self.view.subviews)
    {
        if ([subview isKindOfClass:[UITextField class]])
        {
            UITextField *textField = (UITextField *)subview;
            BOOL isEnabled = textField.enabled;
            textField.enabled = !isEnabled;
            if (isEnabled)
            {
                // Disable
                textField.borderStyle = UITextBorderStyleNone;
                editButton.title = @"Edit";
                endEdit = YES;
                
            }
            else
            {
                // Enable
                textField.borderStyle = UITextBorderStyleRoundedRect;
                editButton.title = @"Done";
                endEdit = NO;
            }
        }
    }
    
    if (endEdit == NO)
    {
        [pinImageView.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
        [pinImageView.layer setBorderWidth: 0.3];
        pinImageView.userInteractionEnabled = YES;
        
        [infoText.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
        [infoText.layer setBorderWidth: 0.3];
        infoText.editable = YES;
        
    }
    else
    {
        inputAnnotation.title = pinTitle.text;
        inputAnnotation.subtitle = pinSubtitle.text;
        
        [self updateAnnotationDetail];
        
        [pinImageView.layer setBorderColor: [[UIColor clearColor] CGColor]];
        [pinImageView.layer setBorderWidth: 0.3];
        pinImageView.userInteractionEnabled = NO;
        
        [infoText.layer setBorderColor: [[UIColor clearColor] CGColor]];
        [infoText.layer setBorderWidth: 0.5];
        infoText.editable = NO;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark pinTypePicker

-(void)setPinTypePickerInit
{
    pinTypeArray = [[NSArray alloc] initWithObjects:@"Hotel", @"Airport", @"Bus Station", @"Train Station", @"Sight", @"Shop", @"Restaurant", nil];
    
    pinTypePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 43, 320, 200)];
    
    pinTypePicker.delegate = self;
    pinTypePicker.dataSource = self;
    [pinTypePicker setShowsSelectionIndicator:YES];
    
    pinTypeText.inputView = pinTypePicker;
    [pinTypeText addTarget:self action:@selector(typePickerShow) forControlEvents:UIControlEventAllTouchEvents];
    
    // Create done button in UIPickerView
    
    pinTypePickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    pinTypePickerToolbar.barStyle = UIBarStyleBlackTranslucent;
    [pinTypePickerToolbar sizeToFit];
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(typePickerDoneClicked)];
    
    [barItems addObject:doneBtn];
    
    [pinTypePickerToolbar setItems:barItems animated:YES];
    
    pinTypeText.inputAccessoryView = pinTypePickerToolbar;
    
}

-(void)typePickerShow

{
    pinTypePickerToolbar.hidden = NO;
    pinTypePicker.hidden = NO;
    if (inputAnnotation.annotationType != myAnnotationTypeNonDecided)
        [pinTypePicker selectRow:[inputAnnotation annotationType] inComponent:0 animated:NO];
    else
    {
        pinTypeText.text = [pinTypeArray objectAtIndex:0];
        [pinTypePicker selectRow:0 inComponent:0 animated:NO];
    }
    
}

-(void)typePickerDoneClicked
{
    [pinTypeText resignFirstResponder];
    pinTypePickerToolbar.hidden = YES;
    pinTypePicker.hidden = YES;
    inputAnnotation.annotationType = [inputAnnotation typeStringToNum:pinTypeText.text];
    
    if ([inputAnnotation.locationImageURL length] == 0)
        pinImageView.image = [inputAnnotation getTypeImage:inputAnnotation.annotationType];
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [pinTypeArray count];
}


- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [pinTypeArray objectAtIndex:row];
}



- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    pinTypeText.text = [pinTypeArray objectAtIndex:row];
}



#pragma mark datePicker

-(void)setDatePickerInit
{
    
    datePicker = [[UIDatePicker alloc]init];
    
    dateLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_TW"];
    datePicker.locale = dateLocale;
    datePicker.calendar = [dateLocale objectForKey:NSLocaleCalendar];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    
    dateText.inputView = datePicker;
    [dateText addTarget:self action:@selector(datePickerShow) forControlEvents:UIControlEventAllTouchEvents];
    
    
    datePickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    datePickerToolbar.barStyle = UIBarStyleBlackTranslucent;
    [datePickerToolbar sizeToFit];
    
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(datePickerDoneClicked)];
    
    [barItems addObject:doneBtn];
    
    [datePickerToolbar setItems:barItems animated:YES];
    
    dateText.inputAccessoryView = datePickerToolbar;
    
}

-(void)datePickerShow

{
    datePickerToolbar.hidden = NO;
    datePicker.hidden = NO;
    if (![inputAnnotation.date isEqualToString:@"0000/00/00 XXX"])
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy/MM/dd E HH:mm"];
        [formatter setLocale:dateLocale];
        datePicker.date = [formatter dateFromString:dateText.text];
    }
    
}

-(void)datePickerDoneClicked

{
    if ([self.view endEditing:NO]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy/MM/dd E HH:mm"];
        [formatter setLocale:dateLocale];
        
        dateText.text = [NSString stringWithFormat:@"%@",[formatter stringFromDate:datePicker.date]];
        inputAnnotation.date = dateText.text;
        
        NSDate *date = [[NSDate alloc]init];
        date = [formatter dateFromString:inputAnnotation.date];
    }
    
    [dateText resignFirstResponder];
    datePickerToolbar.hidden = YES;
    datePicker.hidden = YES;
    
}


#pragma mark pinTableView dataSource methods

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([imageArray count] == 0)
        return 1;
    else
        return [imageArray count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"PinAlbumCell";
    PinAlbumCell *cell = (PinAlbumCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    if(cell == nil)
        cell = [[PinAlbumCell alloc]init];
    
    if ([imageArray count])
    {
        UIImageView *cellImageView = cell.imageView;
        cellImageView.image = [imageArray objectAtIndex:indexPath.row];
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed:@"picture-50.png"];
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self viewImageSingleTap:indexPath];
}


#pragma mark - Page View Controller Data Source

-(void)viewImageSingleTap:(NSIndexPath *)indexPath
{
    if ([imageArray count] > 0)
    {
        PhotoViewController *photoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoViewController"];
        
        photoViewController.imageArray = [[NSArray alloc] initWithArray:(NSArray *)imageArray];
        photoViewController.pageIndex = (int)indexPath.row;
        
        [self.navigationController pushViewController:photoViewController animated:YES];
    }
}


#pragma mark - image Picker Controller Data Source

- (IBAction)AddPhoto:(id)sender
{
    imagePicker2 = [[UIImagePickerController alloc]init];
    
    imagePicker2.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker2.delegate = self;
    
    [self presentViewController:imagePicker2 animated:YES completion:nil];
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (picker == imagePicker1)
    {
        pinImageView.image = (UIImage*)[info valueForKey:UIImagePickerControllerOriginalImage];
        inputAnnotation.locationImageURL = [[info valueForKey:UIImagePickerControllerReferenceURL] absoluteString];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    else if (picker == imagePicker2)
    {
        [imageArray addObject:(UIImage*)[info valueForKey:UIImagePickerControllerOriginalImage]];
        NSString *imageURL = [[info valueForKey:UIImagePickerControllerReferenceURL] absoluteString];
        
        [self AddLocationPhoto:imageURL];
        
        [self.imageColView reloadData];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}


-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)getAllImageWithURL:(NSArray *)imageURLs
{
    ALAssetsLibrary *libraryAlberm = [[ALAssetsLibrary alloc] init];
    __block int end = 0;
    
    for (LocationImageData *locationImageData in imageURLs)
    {
        NSURL *imageURL = [NSURL URLWithString:[locationImageData imageURL]];
        [libraryAlberm assetForURL:imageURL resultBlock:^(ALAsset *asset) {
            
            [albumReadLock lock];
            
            [imageArray addObject:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]]];
            
            end ++;
            if (end == [imageURLs count])
                [albumReadLock unlockWithCondition:WDASSETURL_ALLFINISHED];
            else
                [albumReadLock unlockWithCondition:WDASSETURL_FINISHED];
            
        } failureBlock:^(NSError *error) {
            NSLog(@"error : %@", error);
            [albumReadLock lock];
            [albumReadLock unlockWithCondition:WDASSETURL_ALLFINISHED];
        }];
    }
    
    [self.imageColView reloadData];
    
    // this method *cannot* be called on the main thread as ALAssetLibrary needs to run some code on the main thread and this will deadlock your app if you block the main thread...
}



#pragma mark Database

-(void)queryAnnotationData
{
    NSEntityDescription *annotaionDataEntity = [NSEntityDescription entityForName:@"AnnotationData" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSError *error = nil;
    
    [request setEntity:annotaionDataEntity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"abs(latitude - %f) < 0.0001 AND abs(longitude - %f) < 0.0001", inputAnnotation.coordinate.latitude, inputAnnotation.coordinate.longitude];
    [request setPredicate:predicate];
    
    fetchAnnotation = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    
    if (fetchAnnotation == nil || error)
    {
        NSLog(@"[ERROR] COREDATA: Fetch update request raised an error - %@", [error description]);
        return;
    }
    NSLog(@"update success  %@", fetchAnnotation.locationName);
    
}

-(void)loadLocationPhoto
{
    NSSet *set = fetchAnnotation.own;
    NSArray *fetchImages = [set allObjects];
    NSLog(@"load photos begin count %lu ", (unsigned long)[fetchImages count]);
    
    if ([fetchImages count] > 0)
    {
        NSLog(@"load photos begin count %lu ", (unsigned long)[fetchImages count]);
        albumReadLock = [[NSConditionLock alloc] initWithCondition:WDASSETURL_PENDINGREADS];
        [self performSelectorInBackground:@selector(getAllImageWithURL:) withObject:fetchImages];
        [albumReadLock lockWhenCondition:WDASSETURL_ALLFINISHED];
        [albumReadLock unlock];
    }
    
}

-(void)AddLocationPhoto:(NSString *)addImageURL
{
    LocationImageData *locationImageData = [NSEntityDescription insertNewObjectForEntityForName:@"LocationImageData" inManagedObjectContext:managedObjectContext];
    
    [locationImageData setImageURL:addImageURL];
    
    NSError *error = nil;
    
    [fetchAnnotation addOwnObject:locationImageData];
    
    [managedObjectContext save:&error];
    
    if (error)
    {
        NSLog(@"[ERROR] COREDATA: Save raised an error - %@", [error description]);
        return;
    }
    
    NSLog(@"[SUCCESS] COREDATA: Insert new location image to database!");
    
}

-(void)DeleteAllLocationPhoto
{
    NSSet *set = fetchAnnotation.own;
    NSArray *fetchImageDatas = [set allObjects];
    
    for(LocationImageData *LocationImageData in fetchImageDatas)
    {
        [managedObjectContext deleteObject:LocationImageData];
    }
    
    NSError *error = nil;
    [managedObjectContext save:&error];
    
    if (error)
    {
        NSLog(@"[ERROR] COREDATA: Delete All LocationImageData raised an error - %@", [error description]);
        return;
    }
    
    NSLog(@"[SUCCESS] COREDATA: Delete all LocationImageData in database!");
}

-(void)updateAnnotationDetail
{
    NSError *error = nil;
    
    fetchAnnotation.locationImageURL = inputAnnotation.locationImageURL;
    fetchAnnotation.locationName = inputAnnotation.title;
    fetchAnnotation.locationAddr = inputAnnotation.subtitle;
    fetchAnnotation.date = inputAnnotation.date;
    fetchAnnotation.annotationType = [NSNumber numberWithInt:inputAnnotation.annotationType];
    fetchAnnotation.information = infoText.text;
    
    [managedObjectContext save:&error];
    if (error)
    {
        NSLog(@"[ERROR] COREDATA: update annotation detail raised an error - %@", [error description]);
        return;
    }
}

@end
