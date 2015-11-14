//
//  SettingsViewController.m
//  Durak
//
//  Created by Александр Карцев on 11/13/15.
//  Copyright © 2015 Alex Kartsev. All rights reserved.
//

#import "SettingsViewController.h"
#import "ViewController.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *numberOfCardsSegmentedControl;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startPressed:(id)sender {
    [self performSegueWithIdentifier:@"startPressed" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"startPressed"]) {
        ViewController *vc = (ViewController *)segue.destinationViewController;
        if (self.numberOfCardsSegmentedControl.selectedSegmentIndex == 0) {
            vc.amount = DurakGameCardAmount36;
        } else {
            vc.amount = DurakGameCardAmount52;
        }
    }
}

@end
