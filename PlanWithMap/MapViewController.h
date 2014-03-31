//
//  MapViewController.h
//  PlanWithMap
//
//  Created by Christine on 2014/2/19.
//  Copyright (c) 2014年 Christine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#import "AppDelegate.h"
#import "myAnnotation.h"
#import "myPinAnnotationView.h"
#import "DetailViewController.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UISearchBarDelegate>
{
    NSManagedObjectContext *managedObjectContext;
    NSMutableDictionary *tableSectionDist;
    NSMutableArray *tableSectionOrder;
    myAnnotation *EdittedAnnotation;
    AnnotationData *dragedAnnotation;
    NSLocale *dateLocale;
}

@property (strong, nonatomic) IBOutlet MKLocalSearch *localSearch;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *pinTableView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) myAnnotation *EdittedAnnotation;
@property (nonatomic, strong) NSArray *foundPlaces;
@property (nonatomic, strong) NSMutableArray *searchResult;

- (IBAction)AddPinLongPressGesture:(UILongPressGestureRecognizer *)sender;
- (IBAction)DeleteAnnotation:(id)sender;
- (IBAction)AddAnnotation:(id)sender;
- (IBAction)getUserLocatioin:(id)sender;


//-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;
//-(void)DeleteAllAnnotationData:(NSArray *)fetchResults;
@end
