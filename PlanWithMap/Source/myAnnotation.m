//
//  myAnnotation.m
//  myAnnotation
//
//  Created by Christine on 2014/2/6.
//  Copyright (c) 2014年 Christine. All rights reserved.
//

#import "myAnnotation.h"

@implementation myAnnotation

@synthesize coordinate;
@synthesize locationImageURL;
@synthesize locationImage;
@synthesize title;
@synthesize subtitle;
@synthesize date;
@synthesize annotationType;

enum {
    WDASSETURL_PENDINGREADS = 2,
    WDASSETURL_FINISHED = 1,
    WDASSETURL_ALLFINISHED = 0
};

-init
{
    return self;
}

-initWithCoordinate: (CLLocationCoordinate2D)inCoor
{
    coordinate = inCoor;
    return self;
}

-(NSString *)typeNumToString:(myAnnotationType)type
{
    switch (type) {
        case myAnnotationTypeHotel:
            return @"Hotel";
            break;
        case myAnnotationTypeAirport:
            return @"Airport";
            break;
        case myAnnotationTypeBus:
            return @"Bus Station";
            break;
        case myAnnotationTypeTrain:
            return @"Train Station";
            break;
        case myAnnotationTypeSight:
            return @"Sight";
            break;
        case myAnnotationTypeShop:
            return @"Shop";
            break;
        case myAnnotationTypeRestaurant:
            return @"Restaurant";
            break;
        default:
            return nil;
            break;
    }
}
-(myAnnotationType)typeStringToNum:(NSString *)type
{
    if ([type isEqualToString:@"Hotel"])
        return myAnnotationTypeHotel;
    else
    {
        if ([type isEqualToString:@"Airport"])
            return myAnnotationTypeAirport;
        else
        {
            if ([type isEqualToString:@"Bus Station"])
                return myAnnotationTypeBus;
            else
            {
                if ([type isEqualToString:@"Train Station"])
                    return myAnnotationTypeTrain;
                else
                {
                    if ([type isEqualToString:@"Sight"])
                        return myAnnotationTypeSight;
                    else
                    {
                        if ([type isEqualToString:@"Shop"])
                            return myAnnotationTypeShop;
                        else
                        {
                            if ([type isEqualToString:@"Restaurant"])
                                return myAnnotationTypeRestaurant;
                            else
                                return -1;
                        }
                    }
                }
            }
        }
    }
}


-(UIImage *)getTypeImage:(myAnnotationType)type
{
    switch (type) {
        case myAnnotationTypeHotel:
            return [UIImage imageNamed:@"hotel_icon.jpg"];
            break;
        case myAnnotationTypeAirport:
            return [UIImage imageNamed:@"airport_icon.jpg"];
            break;
        case myAnnotationTypeBus:
            return [UIImage imageNamed:@"bus_icon.jpg"];
            break;
        case myAnnotationTypeTrain:
            return [UIImage imageNamed:@"train_icon.jpg"];
            break;
        case myAnnotationTypeSight:
            return [UIImage imageNamed:@"sight_icon.jpg"];
            break;
        case myAnnotationTypeShop:
            return [UIImage imageNamed:@"shop_icon.jpg"];
            break;
        case myAnnotationTypeRestaurant:
            return [UIImage imageNamed:@"restaurant_icon.jpg"];
            break;
        default:
            return nil;
            break;
    }
    
}

-(void)getLocationPhoto
{
    albumReadLock = [[NSConditionLock alloc] initWithCondition:WDASSETURL_PENDINGREADS];
    [self performSelectorInBackground:@selector(getImageWithURL) withObject:nil];
    [albumReadLock lockWhenCondition:WDASSETURL_ALLFINISHED];
    [albumReadLock unlock];
}

-(void)getImageWithURL
{
    ALAssetsLibrary *libraryAlberm = [[ALAssetsLibrary alloc] init];
    locationImage = [[UIImage alloc] init];
    
    [libraryAlberm assetForURL:[NSURL URLWithString:locationImageURL] resultBlock:^(ALAsset *asset) {
        
        [albumReadLock lock];
        
        locationImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]];
        [albumReadLock unlockWithCondition:WDASSETURL_ALLFINISHED];
        
    } failureBlock:^(NSError *error) {
        NSLog(@"error : %@", error);
        [albumReadLock lock];
        [albumReadLock unlockWithCondition:WDASSETURL_ALLFINISHED];
    }];
    
    // this method *cannot* be called on the main thread as ALAssetLibrary needs to run some code on the main thread and this will deadlock your app if you block the main thread...
}


@end
