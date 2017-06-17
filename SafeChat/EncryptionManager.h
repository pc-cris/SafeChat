//
//  EncryptionManager.h
//  SafeChat
//
//  Created by Cristina Pocol on 17/06/2017.
//  Copyright © 2017 Cristina Pocol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCBigNoGenerator.h"
#import "PCEncryptor.h"
#import "PCDecryptor.h"

@interface EncryptionManager : NSObject

+ (EncryptionManager *)sharedInstance;
+ (void)setSharedInstance:(EncryptionManager *)sharedInstance;
+ (void)resetSharedInstance;


@end
