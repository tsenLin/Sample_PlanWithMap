//
//  myAnnotation.h
//  myAnnotation
//
//  Created by Christine on 2014/2/6.
//  Copyright (c) 2014年 Christine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MapKit/MapKit.h>

typedef enum {
    myAnnotationTypeHotel = 0,
    myAnnotationTypeAirport = 1,
    myAnnotationTypeBus = 2,
    myAnnotationTypeTrain = 3,
    myAnnotationTypeSight = 4,
    myAnnotationTypeShop = 5,
    myAnnotationTypeRestaurant = 6,
    myAnnotationTypeNonDecided = 99
    
    
}myAnnotationType;


@interface myAnnotation : NSObject <MKAnnotation>
{
    CLLocationCoordinate2D coordinate;
    NSString *locationImageURL;
    UIImage *locatioinImage;
    NSString *title;
    NSString *subtitle;
    NSString *date;
    myAnnotationType annotationType;
    NSConditionLock* albumReadLock;
    
}

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) NSString *locationImageURL;
@property (nonatomic) UIImage *locationImage;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic) NSString *date;
@property (nonatomic) myAnnotationType annotationType;

-initWithCoordinate:(CLLocationCoordinate2D)inCoor;
-(NSString *)typeNumToString:(myAnnotationType)type;
-(myAnnotationType)typeStringToNum:(NSString *)type;
-(UIImage *)getTypeImage:(myAnnotationType)type;
-(void)getLocationPhoto;
@end
