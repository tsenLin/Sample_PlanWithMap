//
//  PinAlbumCell.m
//  PlanWithMap
//
//  Created by Christine on 2014/2/22.
//  Copyright (c) 2014年 Christine. All rights reserved.
//

#import "PinAlbumCell.h"

@implementation PinAlbumCell
@synthesize imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

/*
 AnnotationData
 LocationImageData
 @property (nonatomic, retain) NSNumber * annotationType;
 @property (nonatomic, retain) NSDate * date;
 @property (nonatomic, retain) NSString * image;
 @property (nonatomic, retain) NSString * information;
 @property (nonatomic, retain) NSNumber * latitude;
 @property (nonatomic, retain) NSString * locationAddr;
 @property (nonatomic, retain) NSString * locationName;
 @property (nonatomic, retain) NSNumber * longitude;
 @property (nonatomic, retain) NSSet *own;
 
 @property (nonatomic, retain) NSString * imageURL;
 @property (nonatomic, retain) AnnotationData *belongto;

 */
