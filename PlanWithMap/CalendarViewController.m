//
//  CalendarControllerViewViewController.m
//  PlanWithMap
//
//  Created by Christine on 2014/3/23.
//  Copyright (c) 2014年 Christine. All rights reserved.
//

#import "CalendarViewController.h"

@interface DetailSegue : UIStoryboardSegue
@end

@implementation DetailSegue

- (void)perform
{
    CalendarViewController *sourceViewController = self.sourceViewController;
    DetailViewController *destinationViewController = self.destinationViewController;
    
    [sourceViewController.navigationController pushViewController:destinationViewController animated:YES];
}

@end


@interface CalendarViewController ()

@property (nonatomic, strong) DetailSegue *detailSegue;
@property (nonatomic, strong) DetailViewController *detailViewController;

@end

@implementation CalendarViewController



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
    
    NSDate *today = [NSDate date];
    
    self.month = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSCalendarCalendarUnit fromDate:today];
    selectedDate = self.month;
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self createDayViewsAndTable];
    [self getScheduleInMonth];
    [self getScheduleOnDay];
    [self.scheduleTableView reloadData];
    
    
    self.detailViewController = [[self storyboard] instantiateViewControllerWithIdentifier:@"DetailViewController"];
    
    self.detailSegue = [[DetailSegue alloc] initWithIdentifier:@"calendarToDetail" source:self destination:self.detailViewController];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self getScheduleInMonth];
    [self getScheduleOnDay];
    [self.scheduleTableView reloadData];
}


-(void)createDayViewsAndTable
{
    NSInteger const numberOfDaysPerWeek = 7;
    [self updateMonthLabelMonth];
    
    NSDateComponents *day = [[NSDateComponents alloc] init];
    day.calendar = self.month.calendar;
    day.day = 1;
    day.month = self.month.month;
    day.year = self.month.year;
    
    NSDate *firstDate = [day.calendar dateFromComponents:day];
    day = [self.month.calendar components:NSCalendarCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit fromDate:firstDate];
    
    NSInteger numberOfDaysInMonth = [day.calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:[day date]].length;
    NSInteger numberOfWeeksInMonth = 0;
    NSInteger startColumn = day.weekday - day.calendar.firstWeekday;
    if (startColumn < 0) {
        startColumn += numberOfDaysPerWeek;
    }
    
    
    CGPoint nextDayViewOrigin = CGPointZero;
    nextDayViewOrigin.x = startX + startColumn * dayViewWidth;
    nextDayViewOrigin.y = startY;
    
    do {
        for (NSInteger i = startColumn; i < numberOfDaysPerWeek; i++)
        {
            if (day.month == self.month.month)
            {
                
                myCalendarDayView *dayView = [[myCalendarDayView alloc]initWithFrame:CGRectMake(nextDayViewOrigin.x, nextDayViewOrigin.y, dayViewWidth, dayViewHight)];
                [dayView addTarget:self action:@selector(updateDaySelectionStates:) forControlEvents:UIControlEventTouchUpInside];
                
                dayView.day = day;
                
                [self.view addSubview:dayView];
                
                if (day.day == selectedDate.day)
                    [self updateDaySelectionStates:dayView];
                
                day.day = day.day + 1;
                
                nextDayViewOrigin.x = nextDayViewOrigin.x + dayViewWidth;
                
            }
            if (day.day > numberOfDaysInMonth)
                break;
        }
        nextDayViewOrigin.x = startX;
        nextDayViewOrigin.y = nextDayViewOrigin.y + dayViewHight;
        startColumn = 0;
        numberOfWeeksInMonth ++;
    } while (day.day <= numberOfDaysInMonth);
    
    
    // scheduleTableView
    
    self.scheduleTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, (startY + numberOfWeeksInMonth * dayViewHight), 320, 519 - ((startY + numberOfWeeksInMonth * dayViewHight))) style:UITableViewStylePlain];
    
    self.scheduleTableView.delegate = self;
    self.scheduleTableView.dataSource = self;
    
    self.scheduleTableView.contentInset = UIEdgeInsetsZero;
    
    [self.view addSubview:self.scheduleTableView];
}

- (void)removeDayViewsAndTable
{
    for (id subview in self.view.subviews)
    {
        if ([subview isKindOfClass:[myCalendarDayView class]])
            [subview removeFromSuperview];
        else
            if ([subview isKindOfClass:[UITableView class]])
                [subview removeFromSuperview];
    }
    
    
}

- (void)updateMonthLabelMonth
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM yyyy";
    
    NSDate *date = [self.month.calendar dateFromComponents:self.month];
    self.monthLabel.text = [formatter stringFromDate:date];
}

-(void)updateDaySelectionStates:(myCalendarDayView *)selectedDay
{
    selectedDate.day = selectedDay.day.day;
    selectedDate.month = selectedDay.day.month;
    selectedDate.year = selectedDay.day.year;
    
    for (id subview in self.view.subviews)
    {
        if ([subview isKindOfClass:[myCalendarDayView class]])
        {
            myCalendarDayView *dayView = subview;
            if (dayView.day.day == selectedDate.day)
                [dayView daySelected];
            else
                [dayView dayUnselected];
        }
    }
    
    [self getScheduleOnDay];
    [self.scheduleTableView reloadData];
    [self setEditing:NO animated:YES];
}

- (IBAction)backMonth:(id)sender
{
    if (self.month.month == 1)
    {
        self.month.year --;
        self.month.month = 12;
    }
    else
        self.month.month --;
    
    [self removeDayViewsAndTable];
    [self createDayViewsAndTable];
    [self getScheduleInMonth];
    [self getScheduleOnDay];
}

- (IBAction)forwardMonth:(id)sender
{
    if (self.month.month == 12)
    {
        self.month.year ++;
        self.month.month = 1;
    }
    else
        self.month.month ++;
    [self removeDayViewsAndTable];
    [self createDayViewsAndTable];
    [self getScheduleInMonth];
    [self getScheduleOnDay];
}


#pragma tableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Schedule";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [scheduleOfDay count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    AnnotationData *theAnnotation = [scheduleOfDay objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [theAnnotation locationName];
    
    cell.detailTextLabel.text = [[theAnnotation date] substringFromIndex:15];
    
    return cell;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self createAnnotation:[scheduleOfDay objectAtIndex:indexPath.row]];
    
    self.detailViewController.inputAnnotation = self.selectedAnnotation;
    self.selectedAnnotation = nil;
    
    [self.navigationController pushViewController:self.detailViewController animated:YES];
    
    //[self.detailSegue perform];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self createAnnotation:[scheduleOfDay objectAtIndex:indexPath.row]];
        
        [scheduleOfDay removeObjectAtIndex:indexPath.row];
        [self deleteScheduleOnDay];
        
        self.selectedAnnotation = nil;
        
        [self.scheduleTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
    
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if (editing)
    {
        [self.scheduleTableView setEditing:YES animated:YES];
    }
    else
    {
        [self.scheduleTableView setEditing:NO animated:YES];
    }
}


-(void)createAnnotation:(AnnotationData *)annotaionData
{
    CLLocationCoordinate2D newPinCoordinate;
    newPinCoordinate.latitude = [[annotaionData latitude] doubleValue];
    newPinCoordinate.longitude = [[annotaionData longitude] doubleValue];
    
    self.selectedAnnotation = [[myAnnotation alloc] initWithCoordinate:newPinCoordinate];
    
    [self.selectedAnnotation setLocationImageURL:[annotaionData locationImageURL]];
    [self.selectedAnnotation setTitle:[annotaionData locationName]];
    [self.selectedAnnotation setSubtitle:[annotaionData locationAddr]];
    [self.selectedAnnotation setAnnotationType:(myAnnotationType)[[annotaionData annotationType] intValue]];
    [self.selectedAnnotation setDate:[annotaionData date]];
    
}




#pragma DB

-(void)getScheduleInMonth
{
    NSEntityDescription *annotaionDataEntity = [NSEntityDescription entityForName:@"AnnotationData" inManagedObjectContext:managedObjectContext];
    NSError *error = nil;
    
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    
    NSString *likeString = [[NSString alloc] initWithFormat:@"%ld/%02ld*", (long)self.month.year, (long)self.month.month];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"date like %@", likeString];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortArray = [[NSArray alloc] initWithObjects:sort, nil];
    [request setSortDescriptors:sortArray];
    
    [request setEntity:annotaionDataEntity];
    
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (!fetchResults || error)
    {
        NSLog(@"[ERROR] COREDATA: Fetch request raised an error - %@", [error description]);
        return;
    }
    
    if ([fetchResults count] > 0)
        scheduleOfMonth = [[NSMutableArray alloc] initWithArray:fetchResults];
    else
        scheduleOfMonth = nil;
}

-(void)getScheduleOnDay
{
    scheduleOfDay = [[NSMutableArray alloc] init];
    for (AnnotationData *annotationData in scheduleOfMonth)
    {
        NSString *dataDay = [annotationData.date substringWithRange:NSMakeRange(8,2)];
        if ([dataDay isEqualToString:[NSString stringWithFormat:@"%02ld", (long)selectedDate.day]])
        {
            [scheduleOfDay addObject:annotationData];
        }
    }
    
    NSArray *sortedArray = [scheduleOfDay mutableCopy];
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sorter count:1];
    sortedArray = [sortedArray sortedArrayUsingDescriptors:sortDescriptors];
    scheduleOfDay = [sortedArray mutableCopy];
    
}


-(void)deleteScheduleOnDay
{
    NSEntityDescription *annotaionDataEntity = [NSEntityDescription entityForName:@"AnnotationData" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSError *error = nil;
    
    [request setEntity:annotaionDataEntity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"abs(latitude - %f) < 0.0001 AND abs(longitude - %f) < 0.0001", self.selectedAnnotation.coordinate.latitude, self.selectedAnnotation.coordinate.longitude];
    [request setPredicate:predicate];
    
    AnnotationData *fetchAnnotation = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    
    if (fetchAnnotation == nil || error)
    {
        NSLog(@"[ERROR] COREDATA: Fetch delete query raised an error - %@", [error description]);
        return;
    }
    
    [self DeleteAllLocationPhoto:fetchAnnotation];
    
    [managedObjectContext deleteObject:fetchAnnotation];
    
    if (fetchAnnotation == nil || error)
    {
        NSLog(@"[ERROR] COREDATA: Fetch delete request raised an error - %@", [error description]);
        return;
    }
    
    [managedObjectContext save:&error];
    if (error)
    {
        NSLog(@"[ERROR] COREDATA: delete raised an error - %@", [error description]);
        return;
    }
}


-(void)DeleteAllLocationPhoto:(AnnotationData *)fetchAnnotation
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
    
    NSLog(@"[SUCCESS] COREDATA: Delete all LocationImageData in database!  %@", fetchAnnotation.locationName);
}

@end
