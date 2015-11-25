#import "GSHealthKitManager.h"


@interface GSHealthKitManager ()

@property (nonatomic, retain) HKHealthStore *healthStore;
@property (nonatomic, retain) HKQueryAnchor *anchor;
@property (nonatomic, retain) HKQuery *query;
@end


@implementation GSHealthKitManager

@synthesize anchor;
@synthesize query;

+ (GSHealthKitManager *)sharedManager {
    static dispatch_once_t pred = 0;
    static GSHealthKitManager *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[GSHealthKitManager alloc] init];
        instance.healthStore = [[HKHealthStore alloc] init];
        instance.anchor = HKAnchoredObjectQueryNoAnchor;
        instance.query = nil;
    });
    return instance;
}

- (void)requestAuthorization {
    
    if ([HKHealthStore isHealthDataAvailable] == NO) {
        // If our device doesn't support HealthKit -> return.
        return;
    }
    
    NSArray *readTypes = @[[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate]];
    
    

    [self.healthStore requestAuthorizationToShareTypes:nil
                                             readTypes:[NSSet setWithArray:readTypes] completion:^(BOOL success, NSError *error) {
                                                 
                                                 
                                                 NSLog(@"requestAuthorizationToShareTypes - success: %@", success ? @"YES" : @"NO");
                                                 if (error != nil) {
                                                     NSLog(@"error: %@", error);
                                                 }
                                             }];
}

- (NSDate *)readBirthDate {
    NSError *error;

    NSDate *dateOfBirth = [self.healthStore dateOfBirthWithError:&error];   // Convenience method of HKHealthStore to get date of birth directly.
    
    if (!dateOfBirth) {
        NSLog(@"Either an error occured fetching the user's age information or none has been stored yet. In your app, try to handle this gracefully.");
    }
    
    return dateOfBirth;
}




//-(HKQuery*)enableBackground
//{
//    NSLog(@"%@ - createHeartRateStreamingQuery", [self class]);
//    
//    HKSampleType *readHRType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
//
//    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:readHRType predicate:nil limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
//
//        if (error != nil) {
//            NSLog(@"error: %@", error);
//        }
//        
//        if (!error) {
//            NSLog(@"%@", results);
//        }
//
//    }];
//    
//    [self.healthStore executeQuery:query];
//    return query;
//}



-(void)enableBackground
{
    NSLog(@"%@ - createHeartRateStreamingQuery", [self class]);
    
    if (!query && [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate]) {
        HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
        
        [self.healthStore enableBackgroundDeliveryForType:quantityType frequency:HKUpdateFrequencyImmediate withCompletion:^(BOOL success, NSError *error) {
            
            NSLog(@"enableBackgroundDeliveryForType - success: %@", success ? @"YES" : @"NO");
            if (error != nil) {
                NSLog(@"error: %@", error);
            }

        }];
        
        HKAnchoredObjectQuery * heartRateQuery = [[HKAnchoredObjectQuery alloc] initWithType:quantityType predicate:nil anchor:anchor limit:HKObjectQueryNoLimit resultsHandler:^(HKAnchoredObjectQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable sampleObjects, NSArray<HKDeletedObject *> * _Nullable deletedObjects, HKQueryAnchor * _Nullable newAnchor, NSError * _Nullable error) {
            
            if (error != nil) {
                NSLog(@"error: %@", error);
            }
            
            if (!error) {
                anchor = newAnchor;
                NSLog(@"%@", sampleObjects);
            }
            
        }];
        heartRateQuery.updateHandler = ^void(HKAnchoredObjectQuery *query, NSArray<__kindof HKSample *> * __nullable addedObjects, NSArray<HKDeletedObject *> * __nullable deletedObjects, HKQueryAnchor * __nullable newAnchor, NSError * __nullable error)
        {
            
            if (error != nil) {
                NSLog(@"error: %@", error);
            }

            if (!error) {
                anchor = newAnchor;
                NSLog(@"%@", addedObjects);
            }
            
        };
        self.query = heartRateQuery;
        [self.healthStore executeQuery:heartRateQuery];
    }

}

@end