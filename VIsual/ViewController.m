//
//  ViewController.m
//  VIsual
//
//  Created by Jacob Rosenthal on 11/25/15.
//  Copyright © 2015 Augmentous. All rights reserved.
//

#import "ViewController.h"
#import "ScannerTableViewController.h"

@interface ViewController ()

@property (strong, nonatomic)CBPeripheral *selectedPeripheral;

@end

@implementation ViewController

@synthesize selectedPeripheral;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)scanButton:(id)sender {
    ScannerTableViewController *scannerTableViewController = [[ScannerTableViewController alloc] initWithCompletion:^(CBPeripheral *peripheral){
        selectedPeripheral = peripheral;
    }];
    scannerTableViewController.services = @[[CBUUID UUIDWithString:@"180D"]];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:scannerTableViewController];
    
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:navController animated:YES completion:nil];
}


@end
