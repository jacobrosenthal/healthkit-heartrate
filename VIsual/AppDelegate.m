//
//  AppDelegate.m
//  VIsual
//
//  Created by Jacob Rosenthal on 11/25/15.
//  Copyright © 2015 Augmentous. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (void)requestHealthStorePermissionsWithCompletion:(void(^)(BOOL success, NSError *error))completion {
    
    if (![HKHealthStore isHealthDataAvailable]) {
        NSError *error = [NSError errorWithDomain:@"SomeDomainHere" code:42 userInfo:@{@"Message": @"HealthKit not supported on current device"}];
        completion(NO, error);
        return;
    }
    

    NSSet *readTypes = [NSSet setWithArray:@[
                                             [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate]
                                             ]];
    
    NSSet *writeTypes = [NSSet setWithArray:@[
                                             [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate]
                                             ]];
    
    [[AppDelegate healthStore] requestAuthorizationToShareTypes:writeTypes readTypes:readTypes completion:completion];
}

+ (void)storeHeartBeatsAtMinute:(double)beats
                      startDate:(NSDate *)startDate endDate:(NSDate *)endDate
                     completion:(void (^)(NSError *error))completion
{
    HKUnit *count = [HKUnit unitFromString:@"count/min"];
    HKQuantityType *rateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKQuantity *rateQuantity = [HKQuantity quantityWithUnit:count
                                                doubleValue:(double)beats];

    HKQuantitySample *rateSample = [HKQuantitySample quantitySampleWithType:rateType
                                                                   quantity:rateQuantity
                                                                  startDate:startDate
                                                                    endDate:endDate];
    
    [[AppDelegate healthStore] saveObject:rateSample withCompletion:^(BOOL success, NSError *error) {
        if(completion) {
            completion(error);
        }
    }];
}

+(HKHealthStore*)healthStore {
    static HKHealthStore* __store = nil;
    
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        
        //apparently iPad dosn't support health kit?
        if ([HKHealthStore isHealthDataAvailable]) {
            __store = [[HKHealthStore alloc] init];
        }
    });
    
    return __store;
}

-(void)startObservingHR
{
    NSLog(@"%@ - startObservingHR", [self class]);

    HKSampleType *readHRType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];

    NSPredicate *pred = [HKQuery predicateForSamplesWithStartDate:[NSDate date] endDate:nil options:HKQueryOptionStrictStartDate];
    
    HKObserverQuery *query = [[HKObserverQuery alloc] initWithSampleType:readHRType predicate:pred updateHandler:^(HKObserverQuery * _Nonnull query, HKObserverQueryCompletionHandler  _Nonnull completionHandler, NSError * _Nullable error) {
        
        completionHandler();

        if (error != nil) {
            NSLog(@"error: %@", error);
        }
        
        if (!error) {
            NSLog(@"fetch latest result");
            
            NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];

            HKSampleQuery *query2 = [[HKSampleQuery alloc] initWithSampleType:readHRType predicate:pred limit:1 sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery * _Nonnull query2, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
                if (error != nil) {
                    NSLog(@"error: %@", error);
                }
        
                if (!error) {
                    
                    if(results.count>0){
                        
                        HKQuantitySample *sample = [results objectAtIndex:0];
                        HKQuantity *quantity = sample.quantity;
                        HKUnit *count = [HKUnit unitFromString:@"count/min"];
                        uint8_t rate = [quantity doubleValueForUnit:count];
                        
                        NSLog(@"%hhd", rate);
                    }
                }
        
            }];
            [[AppDelegate healthStore] executeQuery:query2];

        }
        
    }];

    [[AppDelegate healthStore] executeQuery:query];
    [[AppDelegate healthStore] enableBackgroundDeliveryForType:readHRType frequency:HKUpdateFrequencyImmediate withCompletion:^(BOOL success, NSError * _Nullable error) {

        NSLog(@"enableBackgroundDeliveryForType - success: %@", success ? @"YES" : @"NO");
        if (error != nil) {
            NSLog(@"error: %@", error);
        }

        
    } ];

}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [AppDelegate requestHealthStorePermissionsWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            [self startObservingHR];
        } else {
            NSLog(@"Error setting up health kit: %@", error);
        }
    }];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
