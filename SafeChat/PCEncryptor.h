//
//  PCEncryptor.h
//  BigNoGenerator
//
//  Created by Cristina Pocol on 16/05/2017.
//  Copyright © 2017 Cristina Pocol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BigInteger.h"
#import "PCBigNoGenerator.h"
#import "PCConstantsAndKeys.h"
#import "PCLookUpASCIITable.h"


@interface PCEncryptor : NSObject

+ (PCEncryptor *)sharedInstance;
+ (void)setSharedInstance:(PCEncryptor *)sharedInstance;
+ (void)resetSharedInstance;
+ (NSDictionary*)encryptMessage:(NSString*)message forUsername:(NSString*)username;

@end
