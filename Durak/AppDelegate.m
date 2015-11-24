//
//  AppDelegate.m
//  Durak
//
//  Created by Александр Карцев on 11/12/15.
//  Copyright © 2015 Alex Kartsev. All rights reserved.
//

#import "AppDelegate.h"
#import <StoreKit/StoreKit.h>
#import "iRate.h"

@interface AppDelegate () <SKPaymentTransactionObserver>

@end

@implementation AppDelegate

+(void)initialize {
    [iRate sharedInstance].previewMode = NO;
    
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    return YES;
}

- (void)paymentQueue:(SKPaymentQueue *)queue
 updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    if ([transactions firstObject].transactionState == SKPaymentTransactionStatePurchased) {
        [self provideContent];
        [queue finishTransaction:[transactions firstObject]];
    } else if ([transactions firstObject].transactionState == SKPaymentTransactionStateFailed) {
        /*SKErrorUnknown,
         SKErrorClientInvalid,               // client is not allowed to issue the request, etc.
         SKErrorPaymentCancelled,            // user cancelled the request, etc.
         SKErrorPaymentInvalid,              // purchase identifier was invalid, etc.
         SKErrorPaymentNotAllowed,           // this device is not allowed to make the payment
         SKErrorStoreProductNotAvailable,*/
        if ([transactions firstObject].error.code != SKErrorPaymentCancelled) {
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"Purchase failed" object:[transactions firstObject].error.localizedDescription];
        }
        [queue finishTransaction:[transactions firstObject]];
    } else if ([transactions firstObject].transactionState == SKPaymentTransactionStateRestored) {
        [self provideContent];
        [queue finishTransaction:[transactions firstObject]];
    } else if ([transactions firstObject].transactionState == SKPaymentTransactionStateDeferred) {
        
    } else if ([transactions firstObject].transactionState == SKPaymentTransactionStatePurchasing) {

    }
}

- (void)provideContent {
    [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"Advertising removed"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PurchaseValueChanged" object:nil];
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
