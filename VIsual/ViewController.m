//
//  ViewController.m
//  VIsual
//
//  Created by Jacob Rosenthal on 11/25/15.
//  Copyright © 2015 Augmentous. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [AppDelegate healthStore];

    double beatsPerMinute = 80;
    
    //dont beleieve we have ability to save device information same way apple can
    [AppDelegate storeHeartBeatsAtMinute:beatsPerMinute startDate:[NSDate date] endDate:[NSDate date] completion:^(NSError *error) {
        if(error) {
            NSLog(@"%@", error);
        } else {
            NSString *message = [NSString stringWithFormat:@"%@ B/m have been logged!", @((int)beatsPerMinute)];
            NSLog(@"%@", message);
        }
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
