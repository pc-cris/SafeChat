//
//  PCDecryptor.h
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

@interface PCDecryptor : NSObject

+ (PCDecryptor *)sharedInstance;
+ (void)setSharedInstance:(PCDecryptor *)sharedInstance;
+ (void)resetSharedInstance;
+ (NSString*)decryptMessage:(NSDictionary*)message fromUser:(NSString*)username;

@end
