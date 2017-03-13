//
//  MaxAlertView.m
//  MaxAlertView
//
//  Created by Jalen on 2017/2/27.
//  Copyright © 2017年 Jalen. All rights reserved.
//

#import "MaxAlertView.h"

#pragma mark - MaxAlertView Queue
@interface MaxAlertViewQueue : NSObject

@property (nonatomic) NSMutableArray *alertViews;

+ (MaxAlertViewQueue *)sharedInstance;

- (void)add:(MaxAlertView *)alertView;
- (void)remove:(MaxAlertView *)alertView;

@end




static const CGFloat AlertViewWidth = 270.0;
static const CGFloat AlertViewContentMargin = 9;
static const CGFloat AlertViewVerticalElementSpace = 20;
static const CGFloat AlertViewButtonHeight = 44;

@interface MaxAlertView ()

@property (nonatomic) UIWindow * mainWindow;
@property (nonatomic) UIWindow * alertWindow;
@property (nonatomic) UIView   * backgroundView;
@property (nonatomic) UIView   * alertView;
@property (nonatomic) UILabel  * titleLabel;
@property (nonatomic) UIView   * contentView;
@property (nonatomic) UILabel  * messageLabel;
@property (nonatomic) UIButton * cancelButton;
@property (nonatomic) UIButton * otherButton;
@property (nonatomic) UITapGestureRecognizer *tap;
@property (nonatomic, strong) void (^completion)(BOOL cancelled);

@end



#pragma mark - MaxAlertView
@implementation MaxAlertView

#pragma mark - window layer
- (UIWindow *)windowWithLevel:(UIWindowLevel)windowLevel {
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in windows) {
        if (window.windowLevel == windowLevel) {
            return window;
        }
    }
    return nil;
}

#pragma mark - initAlert
- (id)initAlertWithTitle:(NSString *)title
                 message:(NSString *)message
             cancelTitle:(NSString *)cancelTitle
              otherTitle:(NSString *)otherTitle
             contentView:(UIView *)contentView
              completion:(void(^) (BOOL cancelled))completion
{
    self = [super init];
    if (self) {
        _mainWindow = [self windowWithLevel:UIWindowLevelNormal];
        _alertWindow = [self windowWithLevel:UIWindowLevelAlert];
        if (!_alertWindow) {
            _alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            _alertWindow.windowLevel = UIWindowLevelAlert;
        }
        self.frame = _alertWindow.bounds;
        
        _backgroundView = [[UIView alloc] initWithFrame:_alertWindow.bounds];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
        _backgroundView.alpha = 0;
        [self addSubview:_backgroundView];
        
        _alertView = [[UIView alloc] init];
        _alertView.backgroundColor = [UIColor whiteColor];
        _alertView.layer.cornerRadius = 8.0;
        _alertView.clipsToBounds = YES;
        [self addSubview:_alertView];
        
        // Title
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(AlertViewContentMargin,
                                                                AlertViewVerticalElementSpace,
                                                                AlertViewWidth - AlertViewContentMargin * 2,
                                                                44)];
        _titleLabel.text = title;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.numberOfLines = 0;
        _titleLabel.frame = [self adjustLabelFrameHeight:self.titleLabel];
        [_alertView addSubview:_titleLabel];
        
        CGFloat messageLabelY = _titleLabel.frame.origin.y + _titleLabel.frame.size.height + AlertViewVerticalElementSpace;
        
        // Optional Content View
        if (contentView) {
            _contentView = contentView;
            _contentView.frame = CGRectMake(0,
                                            messageLabelY,
                                            _contentView.frame.size.width,
                                            _contentView.frame.size.height);
            _contentView.center = CGPointMake(AlertViewWidth/2, _contentView.center.y);
            [_alertView addSubview:_contentView];
            messageLabelY += contentView.frame.size.height + AlertViewVerticalElementSpace;
        }
        
        // Message
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(AlertViewContentMargin,
                                                                  (title == nil ? messageLabelY - 10 : messageLabelY),
                                                                  AlertViewWidth - AlertViewContentMargin * 2,
                                                                  44)];
        _messageLabel.text = message;
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.textColor = [UIColor lightGrayColor];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.font = [UIFont systemFontOfSize:15];
        _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _messageLabel.numberOfLines = 0;
        _messageLabel.frame = [self adjustLabelFrameHeight:self.messageLabel];
        [_alertView addSubview:_messageLabel];
        
        // Line
        CALayer *lineLayer = [CALayer layer];
        lineLayer.backgroundColor = [[UIColor colorWithWhite:0.25 alpha:0.3] CGColor];
        lineLayer.frame = CGRectMake(0, _messageLabel.frame.origin.y + _messageLabel.frame.size.height + AlertViewVerticalElementSpace + (title == nil ? 10 : 0), AlertViewWidth, 0.5);
        [_alertView.layer addSublayer:lineLayer];
        
        // Buttons
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (cancelTitle) {
            [_cancelButton setTitle:cancelTitle forState:UIControlStateNormal];
        }
        _cancelButton.backgroundColor = [UIColor clearColor];
        [_cancelButton setTitleColor:otherTitle == nil ? [UIColor redColor] : [UIColor lightGrayColor] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat buttonsY = lineLayer.frame.origin.y + lineLayer.frame.size.height;
        if (otherTitle) {
            _cancelButton.titleLabel.font = [UIFont systemFontOfSize:17];
            _cancelButton.frame = CGRectMake(0, buttonsY, AlertViewWidth/2, AlertViewButtonHeight);
            
            _otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_otherButton setTitle:otherTitle forState:UIControlStateNormal];
            _otherButton.backgroundColor = [UIColor clearColor];
            _otherButton.titleLabel.font = [UIFont systemFontOfSize:17];
            [_otherButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [_otherButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
            _otherButton.frame = CGRectMake(_cancelButton.frame.size.width, buttonsY, AlertViewWidth/2, 44);
            [self.alertView addSubview:_otherButton];
            
            CALayer *lineLayer = [CALayer layer];
            lineLayer.backgroundColor = [[UIColor colorWithWhite:0.25 alpha:0.3] CGColor];
            lineLayer.frame = CGRectMake(_otherButton.frame.origin.x, _otherButton.frame.origin.y, 0.5, AlertViewButtonHeight);
            [_alertView.layer addSublayer:lineLayer];
            
        } else {
            _cancelButton.titleLabel.font = [UIFont systemFontOfSize:17];
            _cancelButton.frame = CGRectMake(0, buttonsY, AlertViewWidth, AlertViewButtonHeight);
        }
        
        [_alertView addSubview:_cancelButton];
        
        _alertView.bounds = CGRectMake(0, 0, AlertViewWidth, 150);
        
        if (completion) {
            _completion = completion;
        }
        
        //[self setupGestures];
        [self resizeViews];
        
        _alertView.center = CGPointMake(CGRectGetMidX(_alertWindow.bounds), CGRectGetMidY(_alertWindow.bounds));
    }
    return self;
}

#pragma mark - show AlertView
- (void)show {
    [[MaxAlertViewQueue sharedInstance] add:self];
}


- (void)_show {
    [self.alertWindow addSubview:self];
    [self.alertWindow makeKeyAndVisible];
    self.visible = YES;
    [self showBackgroundView];
    [self showAlertAnimation];
}

- (void)showBackgroundView {
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.mainWindow.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        [self.mainWindow tintColorDidChange];
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.backgroundView.alpha = 1;
    }];
}

#pragma mark - hide AlertView
- (void)hide {
    [self removeFromSuperview];
}

- (void)dismiss:(id)sender {
    self.visible = NO;
    
    if ([[[MaxAlertViewQueue sharedInstance] alertViews] count] == 1) {
        [self dismissAlertAnimation];
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            self.mainWindow.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            [self.mainWindow tintColorDidChange];
        }
        [UIView animateWithDuration:0.2 animations:^{
            self.backgroundView.alpha = 0;
            //[self.mainWindow makeKeyAndVisible];
        }];
    }
    
    
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alertView.alpha = 0;
    } completion:^(BOOL finished) {
        [[MaxAlertViewQueue sharedInstance] remove:self];
        [self removeFromSuperview];
    }];
    
    BOOL cancelled;
    if (sender == self.cancelButton || sender == self.tap) {
        cancelled = YES;
    }else {
        cancelled = NO;
    }
    if (self.completion) {
        self.completion(cancelled);
    }
}

#pragma mark - set backgroundColor for button
- (void)setBackgroundColorForButton:(id)sender {
    [sender setBackgroundColor:[UIColor colorWithRed:94/255.0 green:196/255.0 blue:221/255.0 alpha:1.0]];
}

- (void)clearBackgroundColorForButton:(id)sender {
    [sender setBackgroundColor:[UIColor clearColor]];
}

#pragma mark - public
+ (MaxAlertView *)showAlertWithTitle:(NSString *)title
{
    return [MaxAlertView showAlertWithTitle:title message:nil cancelTitle:NSLocalizedString(@"Ok", nil) completion:nil];
}

+ (MaxAlertView *)showAlertWithTitle:(NSString *)title
                             message:(NSString *)message
{
    return [MaxAlertView showAlertWithTitle:title message:message cancelTitle:NSLocalizedString(@"Ok", nil) completion:nil];
}

+ (MaxAlertView *)showAlertWithTitle:(NSString *)title
                             message:(NSString *)message
                          completion:(void(^) (BOOL cancelled))completion
{
    return [MaxAlertView showAlertWithTitle:title message:message cancelTitle:NSLocalizedString(@"Ok", nil) completion:completion];
}

+ (MaxAlertView *)showAlertWithTitle:(NSString *)title
                             message:(NSString *)message
                         cancelTitle:(NSString *)cancelTitle
                          completion:(void(^) (BOOL cancelled))completion
{
    MaxAlertView *alertView = [[MaxAlertView alloc] initAlertWithTitle:title
                                                               message:message
                                                           cancelTitle:cancelTitle
                                                            otherTitle:nil
                                                           contentView:nil
                                                            completion:completion];
    [alertView show];
    return alertView;
}

+ (MaxAlertView *)showAlertWithTitle:(NSString *)title
                             message:(NSString *)message
                         cancelTitle:(NSString *)cancelTitle
                          otherTitle:(NSString *)otherTitle
                          completion:(void(^) (BOOL cancelled))completion
{
    MaxAlertView *alertView = [[MaxAlertView alloc] initAlertWithTitle:title
                                                               message:message
                                                           cancelTitle:cancelTitle
                                                            otherTitle:otherTitle
                                                           contentView:nil
                                                            completion:completion];
    [alertView show];
    return alertView;
}

+ (MaxAlertView *)showAlertWithTitle:(NSString *)title
                             message:(NSString *)message
                         cancelTitle:(NSString *)cancelTitle
                          otherTitle:(NSString *)otherTitle
                         contentView:(UIView *)view
                          completion:(void(^) (BOOL cancelled))completion
{
    MaxAlertView *alertView = [[MaxAlertView alloc] initAlertWithTitle:title
                                                               message:message
                                                           cancelTitle:cancelTitle
                                                            otherTitle:otherTitle
                                                           contentView:view
                                                            completion:completion];
    [alertView show];
    return alertView;
}

#pragma mark - gestures
- (void)setupGestures {
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
    [self.tap setNumberOfTapsRequired:1];
    [self.backgroundView setUserInteractionEnabled:YES];
    [self.backgroundView setMultipleTouchEnabled:NO];
    [self.backgroundView addGestureRecognizer:self.tap];
}

#pragma mark -
- (CGRect)adjustLabelFrameHeight:(UILabel *)label {
    CGFloat height;
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CGSize size = [label.text sizeWithFont:label.font
                             constrainedToSize:CGSizeMake(label.frame.size.width, FLT_MAX)
                                 lineBreakMode:NSLineBreakByWordWrapping];
        
        height = size.height;
#pragma clang diagnostic pop
    } else {
        NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
        context.minimumScaleFactor = 1.0;
        CGRect bounds = [label.text boundingRectWithSize:CGSizeMake(label.frame.size.width, FLT_MAX)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName:label.font}
                                                 context:context];
        height = bounds.size.height;
    }
    
    return CGRectMake(label.frame.origin.x, label.frame.origin.y, label.frame.size.width, height);
}

#pragma mark - resize MaxAlertView frame
- (void)resizeViews {
    CGFloat totalHeight = 0;
    for (UIView *view in [self.alertView subviews]) {
        if ([view class] != [UIButton class]) {
            totalHeight += view.frame.size.height + AlertViewVerticalElementSpace;
        }
    }
    totalHeight += AlertViewButtonHeight;
    totalHeight += AlertViewVerticalElementSpace;
    
    self.alertView.frame = CGRectMake(self.alertView.frame.origin.x,
                                      self.alertView.frame.origin.y,
                                      self.alertView.frame.size.width,
                                      totalHeight);
}

#pragma mark - show Animation
- (void)showAlertAnimation {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)]];
    animation.keyTimes = @[ @0, @0.5, @1 ];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = .3;
    
    [self.alertView.layer addAnimation:animation forKey:@"showAlert"];
}

#pragma mark - dismiss Animation
- (void)dismissAlertAnimation {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95, 0.95, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1)]];
    animation.keyTimes = @[ @0, @0.5, @1 ];
    animation.fillMode = kCAFillModeRemoved;
    animation.duration = .2;
    
    [self.alertView.layer addAnimation:animation forKey:@"dismissAlert"];
}

@end




@implementation MaxAlertViewQueue

+ (instancetype)sharedInstance {
    static MaxAlertViewQueue *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[MaxAlertViewQueue alloc] init];
        _sharedInstance.alertViews = [NSMutableArray array];
    });
    
    return _sharedInstance;
}

- (void)add:(MaxAlertView *)alertView {
    [self.alertViews addObject:alertView];
    [alertView _show];
    for (MaxAlertView *av in self.alertViews) {
        if (av != alertView) {
            [av hide];
        }
    }
}

- (void)remove:(MaxAlertView *)alertView {
    [self.alertViews removeObject:alertView];
    MaxAlertView *last = [self.alertViews lastObject];
    if (last) {
        [last _show];
    }
}


@end
