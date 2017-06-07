//
//  FLAnimatedImageView+ImageCache.h
//  SafeChat
//
//  Created by Cristina Pocol on 01/05/2017.
//  Copyright © 2017 Cristina Pocol. All rights reserved.
//

#import <FLAnimatedImage/FLAnimatedImage.h>

@interface FLAnimatedImageView (ImageCache)

- (void)setAnimatedImageWithURL:(NSURL * _Nonnull)url success:(nullable void (^)(FLAnimatedImage * _Nullable image))success failure:(nullable void (^)(NSError * _Nullable error))failure;
+ (nullable NSData *)cachedImageForURL:(NSURL * _Nonnull)url;


@end
