//
//  EncryptionManager.m
//  SafeChat
//
//  Created by Cristina Pocol on 17/06/2017.
//  Copyright © 2017 Cristina Pocol. All rights reserved.
//

#import "EncryptionManager.h"

static EncryptionManager *instance   = nil;
static dispatch_once_t once_token   = 0;

@implementation EncryptionManager

#pragma mark -
#pragma mark Singleton methods

+ (EncryptionManager*)sharedInstance {
    
    dispatch_once(&once_token, ^{
        if (instance == nil) {
            instance = [[EncryptionManager alloc] init];
        }
    });
    return instance;
}

+ (void)setSharedInstance:(EncryptionManager *)sharedInstance {
    
    once_token = 0;
    instance = sharedInstance;
}

+ (void)resetSharedInstance {
    
    once_token  = 0; // resets the once_token so dispatch_once will run again
    instance    = nil;
}

+ (id)allocWithZone:(NSZone*)zone {
    
    @synchronized(self) {
        if (instance == nil) {
            instance = [super allocWithZone:zone];
            return instance;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    
    return self;
}

- (instancetype)init {
    
    self = [super init];
    if (!self) {
        return nil;
    }
    instance = self;
    return instance;
}

#pragma mark -
#pragma mark - Firebase methods

- (NSDictionary*)getReceiverPublicKeys:(NSString*)username {
    
    NSDictionary *publicKeys = [NSDictionary new];
    //get them from Firebase db
    
    return publicKeys;
}

- (BOOL)setUserPublicKeys:(NSDictionary*)keys user:(NSString*)user {
    
    //send to firebase
    //send them to firebase server
    //With Firebase, the key is a URL and the value is arbitrary data that could be a number, string, boolean or object.
    //let ref = FIRDatabase.database().reference(withPath: "user-public-keys") -> json root
    //it will look like:
    
    // The root of the tree
    //    {
    //        // grocery-items
    //        "grocery-items": {
    //
    //            // grocery-items/milk
    //            "milk": {
    //
    //                // grocery-items/milk/name
    //                "name": "Milk",
    //
    //                // grocery-items/milk/addedByUser
    //                "addedByUser": "David"
    //            },
    //
    //            "pizza": {
    //                "name": "Pizza",
    //                "addedByUser": "Alice"
    //            },
    //        }
    //    }
    //https://www.raywenderlich.com/139322/firebase-tutorial-getting-started-2
    //    let groceryItemRef = self.ref.child(text.lowercased()) - create a new child node -> we will use the username of the current user for this
    //
    //    // 4
    //    groceryItemRef.setValue(groceryItem.toAnyObject()) -  set the dictionary directly to save it to the db
    
    
    //refHandle = [_postRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
    //    NSDictionary *postDict = snapshot.value;
    //    // ...
    //}];

    return YES;
}

#pragma mark -
#pragma mark - Facade methods

- (NSDictionary*)generateKeysUsePregenerated:(BOOL)usePregenerated {
    
    return [[PCBigNoGenerator sharedInstance] generateKeysAndExposePublicKeysOrUsePregenerated:usePregenerated];
}

- (NSDictionary*)encryptText:(NSString*)text usingGeneratedKeys:(NSDictionary*)keys {
    
    return [[PCEncryptor sharedInstance] encryptMessage:text usingKeys:keys];
}

- (NSString*)decryptText:(NSDictionary*)text {
    
    return [[PCDecryptor sharedInstance] decryptMessage:text];
}

@end
