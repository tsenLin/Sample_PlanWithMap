//
//  LocationImageData.h
//  PlanWithMap
//
//  Created by Christine on 2014/3/15.
//  Copyright (c) 2014年 Christine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AnnotationData;

@interface LocationImageData : NSManagedObject

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) AnnotationData *belongto;

@end
