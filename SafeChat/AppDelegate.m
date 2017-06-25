//
//  AppDelegate.m
//  SafeChat
//
//  Created by Cristina Pocol on 05/01/2017.
//  Copyright © 2017 Cristina Pocol. All rights reserved.
//

#import "AppDelegate.h"
#import <SendBirdSDK/SendBirdSDK.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Reachability.h"

@import Firebase;

@interface AppDelegate ()

@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) Reachability *internetReachability;


@end

@implementation AppDelegate

+ (nonnull NSURLCache *)imageCache {
    static dispatch_once_t p = 0;
    __strong static NSURLCache *_sharedObject = nil;
    
    dispatch_once(&p, ^{
        _sharedObject = [NSURLCache sharedURLCache];
    });
    
    return _sharedObject;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:42.0/255.0 green:172.0/255.0 blue:77.0/255.0 alpha:1.0]}];
    
    //[SBDMain initWithApplicationId:@"501B61B5-D7FA-4E33-BE3E-6D5F58C98367"]; -> old id; expires 5th july
    
    [SBDMain initWithApplicationId:@"C3009943-A739-4022-A229-EB76CCF0D2E8"]; // -> new id; expires 19th July
    
    [SBDMain setLogLevel:SBDLogLevelDebug];
    [FIRApp configure];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (audioSession != nil) {
        NSError *error = nil;
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
        
        if (error != nil) {
            NSLog(@"Set Audio Session error: %@", error);
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    //Change the host name here to change the server you want to monitor.
    NSString *remoteHostName = @"www.apple.com";
    
    self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
    [self.hostReachability startNotifier];
    
    self.internetReachability = [Reachability reachabilityForInternetConnection];
    [self.internetReachability startNotifier];
    
    return YES;
}

- (void) reachabilityChanged:(NSNotification *)note {
    
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self checkInternetConnection:curReach];
}

- (void)checkInternetConnection:(Reachability*)reachability {
    
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    BOOL connectionRequired = [reachability connectionRequired];
    BOOL displayAlert = NO;
    
    switch (netStatus)
    {
        case NotReachable: {
            displayAlert = YES;
            break;
        }
            
        case ReachableViaWWAN: {
        case ReachableViaWiFi:
            break;
        }
    }
    
    if (displayAlert) {
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"No Internet"
                                    message:@"In order to use this application, an Internet connection is required. Please connect your device either to a WiFi or a 4G network."
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                   }];
        
        [alert addAction:okAction];
        UIViewController *presenter = [[self window] rootViewController];
        while ([presenter presentedViewController]) {
            presenter = [presenter presentedViewController];
        }
        
        [presenter presentViewController:alert animated:YES completion:^{
        }];
    }

}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"SafeChat"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

#pragma mark - Push Notifications 

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"Device token: %@", deviceToken.description);
    [SBDMain registerDevicePushToken:deviceToken unique:YES completionHandler:^(SBDPushTokenRegistrationStatus status, SBDError * _Nullable error) {
        if (error == nil) {
            if (status == SBDPushTokenRegistrationStatusPending) {
                NSLog(@"Push registration is pending.");
            }
            else {
                NSLog(@"APNS Token is registered.");
            }
        }
        else {
            NSLog(@"APNS registration failed.");
        }
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (userInfo[@"sendbird"] != nil) {
        NSDictionary *sendBirdPayload = userInfo[@"sendbird"];
        NSString *channel = sendBirdPayload[@"channel"][@"channel_url"];
        NSString *channelType = sendBirdPayload[@"channel_type"];
        if ([channelType isEqualToString:@"group_messaging"]) {
            self.receivedPushChannelUrl = channel;
        }
    }
    
}


@end
