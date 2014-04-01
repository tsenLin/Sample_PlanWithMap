//
//  MapViewController.m
//  PlanWithMap
//
//  Created by Christine on 2014/2/19.
//  Copyright (c) 2014年 Christine. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

enum {
    WDASSETURL_PENDINGREADS = 2,
    WDASSETURL_FINISHED = 1,
    WDASSETURL_ALLFINISHED = 0
};

@synthesize localSearch, foundPlaces, mapView, pinTableView, addButton, deleteButton;
@synthesize managedObjectContext, EdittedAnnotation;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate* appDelegate = [AppDelegate sharedAppDelegate];
    managedObjectContext = appDelegate.managedObjectContext;
    dateLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_TW"];
    
    mapView.showsUserLocation = YES;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated
{
    
}


-(void)viewWillAppear:(BOOL)animated
{
    if(EdittedAnnotation == nil)
    {
        mapView.showsUserLocation = NO;
        
        [self.mapView removeAnnotations:[self.mapView annotations]];
        [self getAllAnnotationFromDB];
        [pinTableView reloadData];
        
        mapView.showsUserLocation = YES;
    }
    else
    {
        mapView.showsUserLocation = NO;
        
        [mapView addAnnotation:EdittedAnnotation];
        [self addToAnnotationTableList:EdittedAnnotation];
        
        EdittedAnnotation = nil;
        
        [pinTableView reloadData];
        
        mapView.showsUserLocation = YES;
    }
}

-(void)getAllAnnotationFromDB
{
    NSEntityDescription *annotaionDataEntity = [NSEntityDescription entityForName:@"AnnotationData" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSError *error = nil;
    
    [request setEntity:annotaionDataEntity];
    //NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    //NSArray *sortArray = [[NSArray alloc] initWithObjects:sort, nil];
    //[request setSortDescriptors:sortArray];
    
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:request error:&error];
    
    if (!fetchResults || error)
    {
        NSLog(@"[ERROR] COREDATA: Fetch request raised an error - %@", [error description]);
        return;
    }
    
    //[self DeleteAllAnnotationData:fetchResults];
    if ([fetchResults count] > 0)
    {
        for (AnnotationData *annotationData in fetchResults)
        {
            [self loadOutAnnotations:annotationData];
        }
        [self creatAnnotationTableList];
    }
}


-(void)loadOutAnnotations:(AnnotationData *)annotaionData
{
    CLLocationCoordinate2D newPinCoordinate;
    newPinCoordinate.latitude = [[annotaionData latitude] doubleValue];
    newPinCoordinate.longitude = [[annotaionData longitude] doubleValue];
    
    myAnnotation *newAnnotation = [[myAnnotation alloc] initWithCoordinate:newPinCoordinate];
    
    [newAnnotation setLocationImageURL:[annotaionData locationImageURL]];
    [newAnnotation setTitle:[annotaionData locationName]];
    [newAnnotation setSubtitle:[annotaionData locationAddr]];
    [newAnnotation setAnnotationType:(myAnnotationType)[[annotaionData annotationType] intValue]];
    if ([annotaionData date] == nil)
        [newAnnotation setDate:@"0000/00/00 XXX"];
    else
        [newAnnotation setDate:[annotaionData date]];
    [mapView addAnnotation:newAnnotation];
    
}


#pragma mark  SearchBar

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)startSearch:(NSString *)searchString
{
    if (localSearch)
    {
        [localSearch cancel];
    }
    
    
    MKCoordinateRegion newRegion = mapView.region;
    
    newRegion.span.latitudeDelta = 0.112872;
    newRegion.span.longitudeDelta = 0.109863;
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    
    request.naturalLanguageQuery = searchString;
    request.region = newRegion;
    
    MKLocalSearchCompletionHandler completionHandler = ^(MKLocalSearchResponse *response, NSError *error)
    {
        if (error != nil)
        {
            NSString *errorStr = [[error userInfo] valueForKey:NSLocalizedDescriptionKey];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not find places" message:errorStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            foundPlaces = [response mapItems];
            self.searchResult = [[NSMutableArray alloc] init];
            
            [mapView setRegion: response.boundingRegion];
            
            for (MKMapItem *item in foundPlaces)
            {
                
                NSString *address = [[NSString alloc] init];
                if (item.placemark.subThoroughfare)
                {
                    address = [[address stringByAppendingString: item.placemark.subThoroughfare] stringByAppendingString:@","];
                }
                if (item.placemark.thoroughfare)
                {
                    address = [[address stringByAppendingString: item.placemark.thoroughfare] stringByAppendingString:@","];
                }
                if (item.placemark.locality)
                {
                    address = [[address stringByAppendingString: item.placemark.locality] stringByAppendingString:@","];
                }
                if (item.placemark.administrativeArea)
                {
                    address = [[address stringByAppendingString: item.placemark.administrativeArea] stringByAppendingString:@","];
                }
                if (item.placemark.country)
                {
                    address = [address stringByAppendingString: item.placemark.country];
                }
                
                if ([address length] > 0 && [[address substringFromIndex:([address length] - 1)] isEqualToString:@","])
                    address = [address substringToIndex:([address length] - 1)];
                
                [self.searchResult addObject:[self AddNewAnnotationToMap:item.placemark.location.coordinate.latitude andLongitude:item.placemark.location.coordinate.longitude andTitle:item.name andSubtitle:address andType:nonAddToDB]];
            }
            
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    };
    
    if (localSearch != nil)
    {
        localSearch = nil;
    }
    localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    
    [localSearch startWithCompletionHandler:completionHandler];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    NSString *causeStr = nil;
    
    if ([CLLocationManager locationServicesEnabled] == NO)
    {
        causeStr = @"device";
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        causeStr = @"app";
    }
    else
    {
        [self startSearch:searchBar.text];
    }
    
    if (causeStr != nil)
    {
        NSString *alertMessage = [NSString stringWithFormat:@"You currently have location services disabled for this %@. Please refer to \"Settings\" app to turn on Location Services.", causeStr];
        
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }
}


#pragma mapView


- (IBAction)AddPinLongPressGesture:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateChanged)
    {
        return;
    }
    else
    {
        CGPoint touchPoint = [sender locationInView:mapView];
        
        CLLocationCoordinate2D newPinCoordinate = [mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        
        [self AddNewAnnotationToMap:newPinCoordinate.latitude andLongitude:newPinCoordinate.longitude andTitle:@"newAnnotation" andSubtitle:nil andType:nonAddToDB];
    }
}

- (IBAction)AddAnnotation:(id)sender
{
    if (EdittedAnnotation != nil)
    {
        EdittedAnnotation.annotationType = myAnnotationTypeNonDecided;
        [mapView removeAnnotation:EdittedAnnotation];
        [mapView addAnnotation:EdittedAnnotation];
        [self AddNewAnnotationToDB:EdittedAnnotation];
        [self addToAnnotationTableList:EdittedAnnotation];
        addButton.hidden = YES;
    }
    else
    {
        myAnnotation *newAnnotation = [[myAnnotation alloc] init];
        newAnnotation.title = [mapView.userLocation title];
        newAnnotation.subtitle = [mapView.userLocation subtitle];
        newAnnotation.coordinate = mapView.userLocation.location.coordinate;
        newAnnotation.date = @"0000/00/00 XXX";
        newAnnotation.annotationType = myAnnotationTypeNonDecided;
    
        [mapView addAnnotation:newAnnotation];
        [self AddNewAnnotationToDB:newAnnotation];
        [self addToAnnotationTableList:newAnnotation];
        addButton.hidden = YES;
    }
    
    [pinTableView reloadData];
}



- (IBAction)DeleteAnnotation:(id)sender
{
    [mapView removeAnnotation:EdittedAnnotation];
    if (EdittedAnnotation.annotationType != nonAddToDB)
    {
        [self removeFromAnnotationTableList:EdittedAnnotation];
        //[tableSectionOrder removeObject:EdittedAnnotation];
        [self deleteAnnotationDetail:EdittedAnnotation];
        [pinTableView reloadData];
    }
    EdittedAnnotation = nil;
    
}


-(myPinAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    myPinAnnotationView *annotationView = nil;
    
    myAnnotation *theAnnotation = (myAnnotation *)annotation;
    NSString *identifier = nil;
    
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    switch (theAnnotation.annotationType) {
        case myAnnotationTypeHotel:
            identifier = @"Hotel";
            break;
        case myAnnotationTypeAirport:
            identifier = @"Airport";
            break;
        case myAnnotationTypeBus:
            identifier = @"Bus Station";
            break;
        case myAnnotationTypeTrain:
            identifier = @"Train Station";
            break;
        case myAnnotationTypeSight:
            identifier = @"Sight";
            break;
        case myAnnotationTypeShop:
            identifier = @"Shop";
            break;
        case myAnnotationTypeRestaurant:
            identifier = @"Restaurant";
            break;
        case myAnnotationTypeNonDecided:
            identifier = @"NonDecided";
            break;
        default:
            break;
    }
    
    myPinAnnotationView *newAnnotationView = (myPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (newAnnotationView == nil)
    {
        newAnnotationView = [[myPinAnnotationView alloc]initWithAnnotation:theAnnotation reuseIdentifier:identifier];
    }
    else
    {
        [newAnnotationView reloadLocationImage:theAnnotation];
    }
    
    
    annotationView = newAnnotationView;
    
    [annotationView setEnabled:YES];
    [annotationView setCanShowCallout:YES];
    annotationView.animatesDrop = YES;
    [annotationView setDraggable:YES];
    
    if ([identifier length])
    {
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        annotationView.rightCalloutAccessoryView = rightButton;
    }
    
    return annotationView;
}


-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view isKindOfClass:[myPinAnnotationView class]])
    {
        EdittedAnnotation = (myAnnotation *)view.annotation;
        deleteButton.hidden = NO;
        if (EdittedAnnotation.annotationType == nonAddToDB)
            addButton.hidden = NO;
        else
            addButton.hidden = YES;
    }
    else
    {
        addButton.hidden = NO;
    }
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    //EdittedAnnotation = nil;
    addButton.hidden = YES;
    deleteButton.hidden = YES;
}


-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    DetailViewController *detailView = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    
    detailView.inputAnnotation = (myAnnotation *)view.annotation;
    EdittedAnnotation = (myAnnotation *)view.annotation;
    
    [self.mapView removeAnnotation:EdittedAnnotation];
    if (EdittedAnnotation.annotationType != nonAddToDB)
        [self removeFromAnnotationTableList:EdittedAnnotation];
    
    [self.navigationController pushViewController:detailView animated:YES];
    
    //[self addChildViewController:detailView]; //didn't work????
    
}


-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    myAnnotation *theAnnotation = (myAnnotation *)view.annotation;
    if(newState == MKAnnotationViewDragStateStarting && theAnnotation.annotationType != nonAddToDB)
    {
        dragedAnnotation = [self queryAnnotationDetail:theAnnotation];
    }
    
    if(newState == MKAnnotationViewDragStateEnding && theAnnotation.annotationType != nonAddToDB)
    {
        [self updateAnnotationCoordinate:theAnnotation andFetchAnnotation:dragedAnnotation];
    }
}

-(myAnnotation *)AddNewAnnotationToMap:(double)latitude andLongitude:(double)longitude andTitle:(NSString *)title andSubtitle:(NSString *)subtitle andType:(myAnnotationType)annotationType
{
    CLLocationCoordinate2D newPinCoordinate;
    newPinCoordinate.latitude = latitude;
	newPinCoordinate.longitude = longitude;
    
    myAnnotation *newAnnotation = [[myAnnotation alloc] initWithCoordinate:newPinCoordinate];
    
	[newAnnotation setTitle:title];
	[newAnnotation setSubtitle:subtitle];
    [newAnnotation setDate:@"0000/00/00 XXX"];
	[newAnnotation setAnnotationType:annotationType];
    
	[mapView addAnnotation:newAnnotation];
    
    return newAnnotation;
}


#pragma mark user location

- (IBAction)getUserLocatioin:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]])
        mapView.showsUserLocation = YES;
    
    float spanX = 0.00725;
    float spanY = 0.00725;
    MKCoordinateRegion region;
    region.center.latitude = mapView.userLocation.coordinate.latitude;
    region.center.longitude = mapView.userLocation.coordinate.longitude;
    region.span.latitudeDelta = spanX;
    region.span.longitudeDelta = spanY;
    
    [mapView setRegion:region animated:YES];
    
}

/*
 -(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
 {
 [self.mapView setCenterCoordinate:userLocation.coordinate animated:YES];
 //NSLog(@"mapview didUpdateUserLocation");
 }*/


#pragma mark pinTableView dataSource methods

-(void)creatAnnotationTableList
{
    NSArray *sortedArray = [[mapView annotations] mutableCopy];
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sorter count:1];
    sortedArray = [sortedArray sortedArrayUsingDescriptors:sortDescriptors];
    
    tableSectionDist = [[NSMutableDictionary alloc] init];
    
    for (myAnnotation *annotation in sortedArray)
    {
        NSString *dateKey = [[annotation date] substringToIndex:14];
        
        if ([tableSectionDist objectForKey:dateKey] != nil)
        {
            NSMutableArray *dateArray = [tableSectionDist objectForKey:dateKey];
            [dateArray addObject:annotation];
            [tableSectionDist setObject:dateArray forKey:dateKey];
        }
        else
        {
            NSMutableArray *dateArray = [[NSMutableArray alloc] initWithObjects:annotation, nil];
            [tableSectionDist setObject:dateArray forKey:dateKey];
        }
    }
    
    tableSectionOrder = [[NSMutableArray alloc] initWithArray:[tableSectionDist allKeys]];
    [tableSectionOrder sortUsingSelector:@selector(caseInsensitiveCompare:)];
}


-(void)addToAnnotationTableList:(myAnnotation *)newAnnotation
{
    NSString *dictKey = [[newAnnotation date] substringToIndex:14];
    
    NSMutableArray *tempArray;
    if ([tableSectionDist objectForKey:dictKey])
    {
        tempArray = (NSMutableArray *)[tableSectionDist objectForKey:dictKey];
        [tempArray addObject:newAnnotation];
        
        if (![dictKey isEqualToString:@"0000/00/00 XXX"])
        {
            NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
            NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sorter, nil];
            [tempArray sortUsingDescriptors:sortDescriptors];
            [tableSectionDist setObject:tempArray forKey:dictKey];
        }
        
    }
    else
    {
        tempArray = [[NSMutableArray alloc] initWithObjects:newAnnotation, nil];
        [tableSectionDist setObject:tempArray forKey:dictKey];
        
        [tableSectionOrder addObject:dictKey];
        [tableSectionOrder sortUsingSelector:@selector(caseInsensitiveCompare:)];
        
    }
}


-(void)removeFromAnnotationTableList:(myAnnotation *)removedAnnotation
{
    NSString *dictKey = [[removedAnnotation date] substringToIndex:14];
    NSMutableArray *tempArray = [tableSectionDist objectForKey:dictKey];
    
    [tempArray removeObject:removedAnnotation];
    
    if ([tempArray count] == 0)
    {
        [tableSectionDist removeObjectForKey:dictKey];
        
        [tableSectionOrder removeObject:dictKey];
        [tableSectionOrder sortUsingSelector:@selector(caseInsensitiveCompare:)];
    }
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [tableSectionOrder count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([[tableSectionOrder objectAtIndex:section] isEqualToString:@"0000/00/00 XXX"])
        return @"Date not decided";
    else
    {
        return [[tableSectionOrder objectAtIndex:section] substringToIndex:14];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *tempArray = [tableSectionDist objectForKey:[tableSectionOrder objectAtIndex:section]];
    return [tempArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    NSString *dictKey = [tableSectionOrder objectAtIndex:indexPath.section];
    NSMutableArray *tempArray = [tableSectionDist objectForKey:dictKey];
    
    myAnnotation *theAnnotation = [tempArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [theAnnotation title];
    
    if (![[theAnnotation date] isEqualToString:@"0000/00/00 XXX"])
        cell.detailTextLabel.text = [[theAnnotation date] substringFromIndex:15];
    else
        cell.detailTextLabel.text = nil;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (myAnnotation *annotation in [mapView annotations])
    {
        if ([[[[tableView cellForRowAtIndexPath:indexPath] textLabel] text]  isEqualToString:annotation.title])
        {
            [mapView setRegion:MKCoordinateRegionMake([annotation coordinate], MKCoordinateSpanMake(.01, .01)) animated:YES];
            [mapView selectAnnotation:annotation animated:YES];
            
        }
    }
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  YES;
}


#pragma mark Database

-(void)AddNewAnnotationToDB:(myAnnotation *)newAnnotation
{
    
    AnnotationData *newAnnotationData = [NSEntityDescription insertNewObjectForEntityForName:@"AnnotationData" inManagedObjectContext:managedObjectContext];
    
    [newAnnotationData setLatitude:[NSNumber numberWithDouble:newAnnotation.coordinate.latitude]];
    [newAnnotationData setLongitude:[NSNumber numberWithDouble:newAnnotation.coordinate.longitude]];
    [newAnnotationData setLocationName:newAnnotation.title];
    [newAnnotationData setLocationAddr:newAnnotation.subtitle];
    [newAnnotationData setDate:@"0000/00/00 XXX"];
    [newAnnotationData setAnnotationType:[NSNumber numberWithInteger:myAnnotationTypeNonDecided]];
    
    NSError *error = nil;
    [managedObjectContext save:&error];
    
    if (error)
    {
        NSLog(@"[ERROR] COREDATA: Save raised an error - %@", [error description]);
        return;
    }
    
    NSLog(@"[SUCCESS] COREDATA: Insert new annotation to database!");
    
}

-(void)DeleteAllAnnotationData:(NSArray *)fetchResults
{
    for(AnnotationData *annotationData in fetchResults)
    {
        [managedObjectContext deleteObject:annotationData];
    }
    
    NSError *error = nil;
    [managedObjectContext save:&error];
    
    if (error)
    {
        NSLog(@"[ERROR] COREDATA: Delete All raised an error - %@", [error description]);
        return;
    }
    
    NSLog(@"[SUCCESS] COREDATA: Delete all annotation in database!");
}

-(void)updateAnnotationDetail:(myAnnotation *)updatedAnnotation
{
    NSEntityDescription *annotaionDataEntity = [NSEntityDescription entityForName:@"AnnotationData" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSError *error = nil;
    
    [request setEntity:annotaionDataEntity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"abs(latitude - %f) < 0.0001 AND abs(longitude - %f) < 0.0001", updatedAnnotation.coordinate.latitude, updatedAnnotation.coordinate.longitude];
    [request setPredicate:predicate];
    
    AnnotationData *fetchAnnotation = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    
    if (fetchAnnotation == nil || error)
    {
        NSLog(@"[ERROR] COREDATA: Fetch update request raised an error - %@", [error description]);
        return;
    }
    
    fetchAnnotation.locationName = updatedAnnotation.title;
    fetchAnnotation.locationAddr = updatedAnnotation.subtitle;
    
    [managedObjectContext save:&error];
    
    if (error)
    {
        NSLog(@"[ERROR] COREDATA: update raised an error - %@", [error description]);
        return;
    }
}

-(AnnotationData *)queryAnnotationDetail:(myAnnotation *)updatedAnnotation
{
    NSEntityDescription *annotaionDataEntity = [NSEntityDescription entityForName:@"AnnotationData" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSError *error = nil;
    
    [request setEntity:annotaionDataEntity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"abs(latitude - %f) < 0.0001 AND abs(longitude - %f) < 0.0001", updatedAnnotation.coordinate.latitude, updatedAnnotation.coordinate.longitude];
    [request setPredicate:predicate];
    
    AnnotationData *fetchAnnotation = [[managedObjectContext executeFetchRequest:request error:&error] lastObject];
    
    if (fetchAnnotation == nil || error)
    {
        NSLog(@"[ERROR] COREDATA: Fetch update query raised an error - %@", [error description]);
        return nil;
    }
    
    return fetchAnnotation;
}

-(void)updateAnnotationCoordinate:(myAnnotation *)updatedAnnotation andFetchAnnotation:(AnnotationData *)fetchAnnotation
{
    NSError *error = nil;
    
    fetchAnnotation.latitude = [NSNumber numberWithDouble:updatedAnnotation.coordinate.latitude];
    fetchAnnotation.longitude = [NSNumber numberWithDouble:updatedAnnotation.coordinate.longitude];
    
    [managedObjectContext save:&error];
    if (error)
    {
        NSLog(@"[ERROR] COREDATA: update coordinate raised an error - %@", [error description]);
        return;
    }
}

-(void)deleteAnnotationDetail:(myAnnotation *)deletedAnnotation
{
    NSEntityDescription *annotaionDataEntity = [NSEntityDescription entityForName:@"AnnotationData" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSError *error = nil;
    
    [request setEntity:annotaionDataEntity];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"abs(latitude - %f) < 0.0001 AND abs(longitude - %f) < 0.0001", deletedAnnotation.coordinate.latitude, deletedAnnotation.coordinate.longitude];
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