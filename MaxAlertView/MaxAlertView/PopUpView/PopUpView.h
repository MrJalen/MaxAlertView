//
//  PopUpView.h
//  MaxAlertView
//
//  Created by Jalen on 2017/3/13.
//  Copyright © 2017年 Jalen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JLPopUpBtnStyle) {
    JLPopUpBtnStyleDefault = 0,
    JLPopUpBtnStyleCancel = 1,
    JLPopUpBtnStyleDestructive = 2,
};

typedef NS_ENUM(NSUInteger, JLPopUpViewStyle) {
    JLPopUpViewStyleAlert = 0,
    JLPopUpViewStyleActionSheet = 1
};


// Title custom
@interface TitleConfiguration : NSObject

@property (nonatomic, copy) NSString *text;

// default 18
@property (nonatomic, assign) CGFloat fontSize;

// default 0x000000
@property (nonatomic, strong) UIColor *textColor;

// default 15
@property (nonatomic, assign) CGFloat top;

// default 0
@property (nonatomic, assign) CGFloat bottom;

@end


// message custom
@interface MessageConfiguration : NSObject

@property (nonatomic, copy) NSString *text;

// default 16
@property (nonatomic, assign) CGFloat fontSize;

// default 0x333333
@property (nonatomic, strong) UIColor *textColor;

// default 10
@property (nonatomic, assign) CGFloat top;

// default 15
@property (nonatomic, assign) CGFloat bottom;

@end

typedef void(^buttonAction) (void);

@interface PopUpView : UIView

// you can get textField's text from this property
@property (nonatomic, strong, readonly) NSArray<UITextField *> *textFieldArray;

// customize property

// default 50.0
@property (nonatomic, assign) CGFloat buttonHeight;

// default 33.0
@property (nonatomic, assign) CGFloat textFieldHeight;

// default 0.6
@property (nonatomic, assign) CGFloat lineHeight;

// default 15.0
@property (nonatomic, assign) CGFloat textFieldFontSize;

// default 0x0a7af3, system alert blue
@property (nonatomic, strong) UIColor *btnStyleDefaultTextColor;

// default 0x555555, black
@property (nonatomic, strong) UIColor *btnStyleCancelTextColor;

// default 0xff4141, red
@property (nonatomic, strong) UIColor *btnStyleDestructiveTextColor;

// default when preferredStyle is JLPopUpViewStyleAlert NO, when preferredStyle is JLPopUpViewStyleActionSheet YES
@property (nonatomic, assign) BOOL canClickBackgroundHide;


- (instancetype) initWithTitle:(NSString *)title message:(NSString *)message;

- (instancetype) initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray <NSString *>*)otherButtonTitles actionWithIndex:(void(^)(NSInteger index))action;

-(instancetype) initWithTitleConfiguration:(void (^)(TitleConfiguration *configuration))titleConfiguration messageConfiguration:(void (^)(MessageConfiguration *configuration))msgConfiguration;


- (void) addTextFieldWithPlaceholder:(NSString *)placeholder text:(NSString *)text secureEntry:(BOOL)secureEntry;
- (void) addBtnWithTitle:(NSString *)title type:(JLPopUpBtnStyle)style handler:(buttonAction)handler;

//show
- (void)showInWindowWithPreferredStyle:(JLPopUpViewStyle)preferredStyle;
- (void)showInView:(UIView *)view preferredStyle:(JLPopUpViewStyle)preferredStyle;

@end
