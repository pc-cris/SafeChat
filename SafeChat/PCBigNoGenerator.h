//
//  PCBigNoGenerator.h
//  BigNoGenerator
//
//  Created by Cristina Pocol on 16/05/2017.
//  Copyright © 2017 Cristina Pocol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BigInteger.h"

@interface PCBigNoGenerator : NSObject

+ (PCBigNoGenerator *)sharedInstance;
+ (void)setSharedInstance:(PCBigNoGenerator *)sharedInstance;
+ (void)resetSharedInstance;
- (NSString*)generateRandomDigitNumberWithSize:(NSUInteger)size;
- (BigInteger*)generateRandomNumberOfRandomSize;
- (NSDictionary*)generateKeysAndExposePublicKeysOrUsePregenerated:(BOOL)usePregenerated;

@end
