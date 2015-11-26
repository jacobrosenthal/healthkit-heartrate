//
//  AppDelegate.h
//  VIsual
//
//  Created by Jacob Rosenthal on 11/25/15.
//  Copyright © 2015 Augmentous. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSHealthKitManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+(HKHealthStore*)healthStore;
    
+ (void)requestHealthStorePermissionsWithCompletion:(void(^)(BOOL success, NSError *error))completion;

+ (void)storeHeartBeatsAtMinute:(double)beats startDate:(NSDate *)startDate endDate:(NSDate *)endDate completion:(void (^)(NSError *error))completion;

@end

