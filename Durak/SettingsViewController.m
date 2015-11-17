//
//  SettingsViewController.m
//  Durak
//
//  Created by Александр Карцев on 11/13/15.
//  Copyright © 2015 Alex Kartsev. All rights reserved.
//

#import "SettingsViewController.h"
#import "ViewController.h"
#import <iAd/iAd.h>

@interface SettingsViewController () <ADBannerViewDelegate>

@property (weak, nonatomic) IBOutlet ADBannerView *adBanner;
@property (weak, nonatomic) IBOutlet UISegmentedControl *numberOfCardsSegmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *lblTimerMessage;


@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic) int secondsElapsed;

@property (nonatomic) BOOL pauseTimeCounting;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.adBanner.delegate = self;
    self.adBanner.alpha = 0.0;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showTimerMessage) userInfo:nil repeats:YES];
    
    self.secondsElapsed = 0;
}

-(void)showTimerMessage{
    if (!self.pauseTimeCounting) {
        self.secondsElapsed++;
        
        self.lblTimerMessage.text = [NSString stringWithFormat:@"You've been viewing this view for %d seconds", self.secondsElapsed];
    }
    else{
        self.lblTimerMessage.text = @"Paused to show ad...";
    }
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

- (IBAction)unwindToSettingsVC:(UIStoryboardSegue *)segue {
    
}

#pragma mark - AdBannerViewDelegate method implementation

-(void)bannerViewWillLoadAd:(ADBannerView *)banner{
    NSLog(@"Ad Banner will load ad.");
}


-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    NSLog(@"Ad Banner did load ad.");
    
    // Show the ad banner.
    [UIView animateWithDuration:0.5 animations:^{
        self.adBanner.alpha = 1.0;
    }];
}


-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{
    NSLog(@"Ad Banner action is about to begin.");
    
    self.pauseTimeCounting = YES;
    
    return YES;
}


-(void)bannerViewActionDidFinish:(ADBannerView *)banner{
    NSLog(@"Ad Banner action did finish");
    
    self.pauseTimeCounting = NO;
}


-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"Unable to show ads. Error: %@", [error localizedDescription]);
    
    // Hide the ad banner.
    [UIView animateWithDuration:0.5 animations:^{
        self.adBanner.alpha = 0.0;
    }];
}


@end
