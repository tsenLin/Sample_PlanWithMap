//
//  myPinAnnotationView.m
//  myPinAnnotation
//
//  Created by Christine on 2014/2/6.
//  Copyright (c) 2014年 Christine. All rights reserved.
//

#import "myPinAnnotationView.h"

#define photoHeight 40
#define photoWidth  37
#define photoBorder 2

#define iconHight 26
#define iconWidth 26
#define iconBorder 2


@implementation myPinAnnotationView

//@synthesize imageView;



-(id)initWithAnnotation:(id)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    myAnnotation *newAnnotation = (myAnnotation*)annotation;
    
    self = [super initWithAnnotation:newAnnotation reuseIdentifier:reuseIdentifier];
    
    if ([newAnnotation annotationType] != nonAddToDB)
    {
        self.frame = CGRectMake(0, 0, iconWidth, iconHight);
        self.backgroundColor = [UIColor clearColor];
        //[self setCenterOffset:CGPointMake(-9, -3)];
        //[self setCalloutOffset:CGPointMake(-2, 3)];
        
        UIImageView *leftIconView;
        
        if ([newAnnotation.locationImageURL length] == 0)
        {
            if ([newAnnotation annotationType] != myAnnotationTypeNonDecided)
            {
                leftIconView = [[UIImageView alloc]initWithImage:[newAnnotation getTypeImage:newAnnotation.annotationType]];
                leftIconView.frame = CGRectMake(photoBorder, photoBorder, photoWidth - 2 * photoBorder, photoWidth - 2 * photoBorder);
                [leftIconView setContentMode:UIViewContentModeScaleAspectFit];
                self.leftCalloutAccessoryView = leftIconView;
            }
        }
        else
        {
            [newAnnotation getLocationPhoto];
            leftIconView = [[UIImageView alloc] initWithImage:[newAnnotation locationImage]];
            leftIconView.frame = CGRectMake(photoBorder, photoBorder, photoWidth - 2 * photoBorder, photoWidth - 2 * photoBorder);
            [leftIconView setContentMode:UIViewContentModeScaleAspectFit];
            self.leftCalloutAccessoryView = leftIconView;
        }
        
        if ([newAnnotation annotationType] == myAnnotationTypeHotel)
        {
            //imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin_green.ico"]];
            //[super setImage:[UIImage imageNamed:@"pin_green.ico"]];
            
            self.pinColor = MKPinAnnotationColorPurple;
        }
        else if ([newAnnotation annotationType] == myAnnotationTypeAirport)
        {
            //imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin_blue.ico"]];
            //image = [UIImage imageNamed:@"pin_blue.ico"];
            //[super setImage:[UIImage imageNamed:@"pin_blue.ico"]];
            
            self.pinColor = MKPinAnnotationColorPurple;
        }
        else if ([newAnnotation annotationType] == myAnnotationTypeBus)
        {
            //imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin_blue.ico"]];
            //image = [UIImage imageNamed:@"pin_blue.ico"];
            //[super setImage:[UIImage imageNamed:@"pin_blue.ico"]];
            
            self.pinColor = MKPinAnnotationColorPurple;
        }
        else if ([newAnnotation annotationType] == myAnnotationTypeTrain)
        {
            //imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin_blue.ico"]];
            //image = [UIImage imageNamed:@"pin_blue.ico"];
            //[super setImage:[UIImage imageNamed:@"pin_blue.ico"]];
            
            self.pinColor = MKPinAnnotationColorPurple;
        }
        else if ([newAnnotation annotationType] == myAnnotationTypeSight)
        {
            //imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin_blue.ico"]];
            //image = [UIImage imageNamed:@"pin_blue.ico"];
            //[super setImage:[UIImage imageNamed:@"pin_blue.ico"]];
            
            self.pinColor = MKPinAnnotationColorGreen;
        }
        
        else if ([newAnnotation annotationType] == myAnnotationTypeShop)
        {
            //imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin_blue.ico"]];
            //image = [UIImage imageNamed:@"pin_blue.ico"];
            //[super setImage:[UIImage imageNamed:@"pin_blue.ico"]];
            
            self.pinColor = MKPinAnnotationColorGreen;
        }
        else if ([newAnnotation annotationType] == myAnnotationTypeRestaurant)
        {
            //imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin_blue.ico"]];
            //image = [UIImage imageNamed:@"pin_blue.ico"];
            //[super setImage:[UIImage imageNamed:@"pin_blue.ico"]];
            
            self.pinColor = MKPinAnnotationColorGreen;
            
        }
        
        //imageView.frame = CGRectMake(iconBorder, iconBorder, iconWidth - 2 * iconBorder, iconWidth - 2 * iconBorder);
        //[imageView setContentMode:UIViewContentModeScaleAspectFit];
        //[self addSubview:imageView];
    }
    
    return self;
}

-(void)reloadLocationImage:(id)annotation
{
    myAnnotation *updateAnnotation = (myAnnotation*)annotation;
    
    UIImageView *leftIconView;
    
    if ([updateAnnotation.locationImageURL length] == 0)
    {
        if ([updateAnnotation annotationType] != myAnnotationTypeNonDecided)
        {
            leftIconView = [[UIImageView alloc]initWithImage:[updateAnnotation getTypeImage:updateAnnotation.annotationType]];
            leftIconView.frame = CGRectMake(photoBorder, photoBorder, photoWidth - 2 * photoBorder, photoWidth - 2 * photoBorder);
            [leftIconView setContentMode:UIViewContentModeScaleAspectFit];
            self.leftCalloutAccessoryView = leftIconView;
        }
    }
    else
    {
        [updateAnnotation getLocationPhoto];
        leftIconView = [[UIImageView alloc] initWithImage:[updateAnnotation locationImage]];
        leftIconView.frame = CGRectMake(photoBorder, photoBorder, photoWidth - 2 * photoBorder, photoWidth - 2 * photoBorder);
        [leftIconView setContentMode:UIViewContentModeScaleAspectFit];
        self.leftCalloutAccessoryView = leftIconView;
    }
    
}

@end
