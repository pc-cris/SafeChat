//
//  AppDelegate.h
//  SafeChat
//
//  Created by Cristina Pocol on 05/01/2017.
//  Copyright © 2017 Cristina Pocol. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;
@property (strong, nonatomic, nullable) NSString *receivedPushChannelUrl;

- (void)saveContext;

+ (nonnull NSURLCache *)imageCache;



@end

