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
#import <StoreKit/StoreKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "CoolButton.h"

@interface SettingsViewController () < SKProductsRequestDelegate,GADBannerViewDelegate>

//@property (weak, nonatomic) IBOutlet ADBannerView *adBanner;
@property (weak, nonatomic) IBOutlet UISegmentedControl *numberOfCardsSegmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *lblTimerMessage;
@property(nonatomic, strong) IBOutlet GADBannerView *bannerView;
@property (weak, nonatomic) IBOutlet CoolButton *startButton;


@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic) int secondsElapsed;

@property (nonatomic) BOOL pauseTimeCounting;

@property (nonatomic, strong) SKProductsRequest *request;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Advertising removed"] == NO) {
        self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        self.bannerView.frame = CGRectMake(self.view.bounds.size.width / 2 - 160, self.view.bounds.size.height - 50, 320, 50);
        self.bannerView.rootViewController = self;
        self.bannerView.adUnitID = @"ca-app-pub-9490228623239882/9885825550";
        [self.view addSubview:self.bannerView];
        [self.bannerView loadRequest:[GADRequest request]];
        self.bannerView.delegate = self;
    }
    
    self.startButton.hue = 28.f/360.f;
    self.startButton.saturation = 64.f/100.f;
    self.startButton.brightness = 96.f/100.f;
    
    self.removeAdsButton.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkUserDefaults) name:@"PurchaseValueChanged" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(printError:) name:@"Purchase failed" object:nil];
    [self setNeedsStatusBarAppearanceUpdate];
    NSLog(NSLocalizedString(@"Hello World", @"hello message"));
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)printError:(NSNotification *)notification {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle: NSLocalizedString(@"Error!", @"error title")
                                                                        message:notification.object
                                                                 preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle: NSLocalizedString(@"Dismiss", @"Dismiss message")
                                                          style: UIAlertActionStyleDestructive
                                                        handler:nil];
    
    [controller addAction: alertAction];
    [self presentViewController: controller animated:YES completion:nil];
}

- (void)checkUserDefaults {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Advertising removed"] == NO) {
        self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        self.bannerView.frame = CGRectMake(self.view.bounds.size.width / 2 - 160, self.view.bounds.size.height - 50, 320, 50);
        self.bannerView.rootViewController = self;
        self.bannerView.adUnitID = @"ca-app-pub-9490228623239882/9885825550";
        [self.view addSubview:self.bannerView];
        [self.bannerView loadRequest:[GADRequest request]];
        self.bannerView.delegate = self;
    } else {
        [self.bannerView removeFromSuperview];
        [self.removeAdsButton removeFromSuperview];
    }
}

- (void)validateProductIdentifiers:(NSArray *)productIdentifiers
{
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
                                          initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
    
    self.request = productsRequest;
    productsRequest.delegate = self;
    [productsRequest start];
}

// SKProductsRequestDelegate protocol method
- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response
{
    //self.products = response.products;
    
    SKProduct *product = [response.products firstObject];
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    payment.quantity = 1;
    
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:response.products.firstObject.priceLocale];
    NSString *formattedPrice = [numberFormatter stringFromNumber:response.products.firstObject.price];
    
    //[self displayStoreUI]; // Custom method
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error NS_AVAILABLE_IOS(3_0) {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle: NSLocalizedString(@"Error!", @"error title")
                                                                        message:error.localizedDescription
                                                                 preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle: NSLocalizedString(@"Dismiss", @"Dismiss message")
                                                          style: UIAlertActionStyleDestructive
                                                        handler:nil];
    
    [controller addAction: alertAction];
    [self presentViewController: controller animated:YES completion:nil];
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

#pragma mark - GADBannerViewDelegate

// Called when an ad request loaded an ad.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    self.removeAdsButton.hidden = NO;
}

// Called when an ad request failed.
- (void)adView:(GADBannerView *)adView didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, error.localizedDescription);
    self.removeAdsButton.hidden = YES;
}

// Called just before presenting the user a full screen view, such as a browser, in response to
// clicking on an ad.
- (void)adViewWillPresentScreen:(GADBannerView *)adView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

// Called just before dismissing a full screen view.
- (void)adViewWillDismissScreen:(GADBannerView *)adView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

// Called just after dismissing a full screen view.
- (void)adViewDidDismissScreen:(GADBannerView *)adView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.removeAdsButton.hidden = YES;
}

// Called just before the application will background or terminate because the user clicked on an ad
// that will launch another application (such as the App Store).
- (void)adViewWillLeaveApplication:(GADBannerView *)adView {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (IBAction)removeAdPressed:(id)sender {
    GADRequest *request = [GADRequest request];
    [self.bannerView loadRequest:request];
    
    [self validateProductIdentifiers:@[@"Remove.Ads"]];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
