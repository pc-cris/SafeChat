//
//  PCLookUpASCIITable.h
//  BigNoGenerator
//
//  Created by Cristina Pocol on 12/06/2017.
//  Copyright © 2017 Cristina Pocol. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCLookUpASCIITable : NSObject

+ (PCLookUpASCIITable *)sharedInstance;
+ (void)setSharedInstance:(PCLookUpASCIITable *)sharedInstance;
+ (void)resetSharedInstance;
- (NSString*)PCASCIIValueForKey:(NSString*)key;
- (NSString*)PCTextValueForKey:(NSString*)key;

@end
