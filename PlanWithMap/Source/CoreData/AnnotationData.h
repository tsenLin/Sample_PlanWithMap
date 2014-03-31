//
//  AnnotationData.h
//  PlanWithMap
//
//  Created by Christine on 2014/3/15.
//  Copyright (c) 2014年 Christine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LocationImageData;

@interface AnnotationData : NSManagedObject

@property (nonatomic, retain) NSNumber * annotationType;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * locationImageURL;
@property (nonatomic, retain) NSString * information;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * locationAddr;
@property (nonatomic, retain) NSString * locationName;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSSet *own;
@end

@interface AnnotationData (CoreDataGeneratedAccessors)

- (void)addOwnObject:(LocationImageData *)value;
- (void)removeOwnObject:(LocationImageData *)value;
- (void)addOwn:(NSSet *)values;
- (void)removeOwn:(NSSet *)values;

@end
