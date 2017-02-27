//
//  MaxAlertView.h
//  MaxAlertView
//
//  Created by Jalen on 2017/2/27.
//  Copyright © 2017年 Jalen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MaxAlertView : UIView

@property (nonatomic, getter = isVisible) BOOL visible;

+ (MaxAlertView *)showAlertWithTitle:(NSString *)title;

+ (MaxAlertView *)showAlertWithTitle:(NSString *)title
                             message:(NSString *)message;

+ (MaxAlertView *)showAlertWithTitle:(NSString *)title
                             message:(NSString *)message
                          completion:(void(^) (BOOL cancelled))completion;

+ (MaxAlertView *)showAlertWithTitle:(NSString *)title
                             message:(NSString *)message
                         cancelTitle:(NSString *)cancelTitle
                          completion:(void(^) (BOOL cancelled))completion;

+ (MaxAlertView *)showAlertWithTitle:(NSString *)title
                             message:(NSString *)message
                         cancelTitle:(NSString *)cancelTitle
                          otherTitle:(NSString *)otherTitle
                          completion:(void(^) (BOOL cancelled))completion;

+ (MaxAlertView *)showAlertWithTitle:(NSString *)title
                             message:(NSString *)message
                         cancelTitle:(NSString *)cancelTitle
                          otherTitle:(NSString *)otherTitle
                         contentView:(UIView *)view
                          completion:(void(^) (BOOL cancelled))completion;

@end
