//
//  myPinAnnotationView.h
//  myPinAnnotation
//
//  Created by Christine on 2014/2/6.
//  Copyright (c) 2014年 Christine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "myAnnotation.h"

enum {
    nonAddToDB = 98
};

@interface myPinAnnotationView : MKPinAnnotationView

-(void)reloadLocationImage:(id)annotation;


@end
