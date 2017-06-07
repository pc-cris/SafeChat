//
//  ChatImage.h
//  SafeChat
//
//  Created by Cristina Pocol on 02/06/2017.
//  Copyright © 2017 Cristina Pocol. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NYTPhotoViewer/NYTPhoto.h>

@interface ChatImage : NSObject <NYTPhoto>

@property (nonatomic) UIImage *image;
@property (nonatomic) NSData *imageData;
@property (nonatomic) UIImage *placeholderImage;
@property (nonatomic) NSAttributedString *attributedCaptionTitle;
@property (nonatomic) NSAttributedString *attributedCaptionSummary;
@property (nonatomic) NSAttributedString *attributedCaptionCredit;

@end
