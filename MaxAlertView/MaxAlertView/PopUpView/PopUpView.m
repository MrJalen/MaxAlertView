//
//  PopUpView.m
//  MaxAlertView
//
//  Created by Jalen on 2017/3/13.
//  Copyright © 2017年 Jalen. All rights reserved.
//

#import "PopUpView.h"

@implementation TitleConfiguration
@end

@implementation MessageConfiguration
@end

@interface PopUpViewBtnModel : NSObject

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, assign) JLPopUpBtnStyle btnStyle;
@property (nonatomic, copy) buttonAction actionHandler;
@end

@implementation PopUpViewBtnModel
@end

@interface PopUpView () <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *messageLabel;
@property (nonatomic, strong) TitleConfiguration *title_Configuration;
@property (nonatomic, strong) MessageConfiguration *msg_configuration;

@property (nonatomic, strong) NSMutableArray<UITextField *> *textFields;
@property (nonatomic, strong) NSMutableArray<PopUpViewBtnModel *> *buttonModels;
@property (nonatomic, assign) JLPopUpViewStyle popUpViewStyle;

@end

#define rgb_a(r, g, b, a)       [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define kScreenWidth         [UIScreen mainScreen].bounds.size.width
#define kScreenHeight        [UIScreen mainScreen].bounds.size.height
#define kTextFieldViewBottom 15.0
#define kColorHex(rgbValue, alphaValue)		[UIColor colorWithRed:((float)(((rgbValue) & 0xFF0000) >> 16))/255.0 \
green:((float)(((rgbValue) & 0x00FF00) >> 8))/255.0 \
blue:((float)((rgbValue) & 0x0000FF))/255.0 \
alpha:(alphaValue)]

//Modifiable
#define kButtonHeight                 50.0
#define kTextFieldHeight              33.0
#define kLineHeight                   0.6
#define kBtnStyleDefaultTextColor     kColorHex(0x0a7af3, 1.0)  // system alert blue
#define kBtnStyleCancelTextColor      kColorHex(0x555555, 1.0)  // black
#define kBtnStyleDestructiveTextColor kColorHex(0xff4141, 1.0)  // red

@implementation PopUpView {
    CGFloat _contentWidth;
    CGFloat _contentHeight;
    
    // As a result of the actionSheet cancel button needs to be added separately, so here to record its subscript
    NSInteger _cancelBtnIndex;
    
    // Due to the particularity of the actionSheet style, the "cancel" button allows you to add only once
    BOOL _hasAddCancelBtnForOnce;
    
    // 0 default, 1 YES, 2 NO
    NSNumber *_canHideByClickBgView;
}


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
        self.backgroundColor = rgb_a(0, 0, 0, 0.5);
        self.alpha = 0;
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickBackGroundHide:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        [self initializeUI];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message {
    
    return [self initWithTitleConfiguration:^(TitleConfiguration *titleConf) {
        titleConf.text = title;
    } messageConfiguration:^(MessageConfiguration *msgConf) {
        msgConf.text = message;
    }];
}

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSArray <NSString *>*)otherButtonTitles
              actionWithIndex:(void(^)(NSInteger index))action {
    
    PopUpView *popUpView = [self initWithTitleConfiguration:^(TitleConfiguration *titleConf) {
        titleConf.text = title;
    } messageConfiguration:^(MessageConfiguration *msgConf) {
        msgConf.text = message;
    }];
    
    if (otherButtonTitles && otherButtonTitles.count) {
        for (int i = 0; i < otherButtonTitles.count; i ++) {
            NSString *btnTitle = otherButtonTitles[i];
            if (btnTitle && btnTitle.length) {
                [popUpView addBtnWithTitle:btnTitle type:JLPopUpBtnStyleDefault handler:^{
                    if (action) action(i+1);
                }];
            }
        }
    }
    
    if (cancelButtonTitle && cancelButtonTitle.length) {
        [popUpView addBtnWithTitle:cancelButtonTitle type:JLPopUpBtnStyleCancel handler:^{
            if (action) action(0);
        }];
    }
    return popUpView;
}

- (instancetype)initWithTitleConfiguration:(void (^)(TitleConfiguration *configuration))titleConfiguration
                      messageConfiguration:(void (^)(MessageConfiguration *configuration))msgConfiguration {

    if (self = [self init]) {
        if (titleConfiguration) {
            titleConfiguration(_title_Configuration);
            if (!_title_Configuration.text || !_title_Configuration.text.length) _title_Configuration = nil;
        }else {
            _title_Configuration = nil;
        }
        
        if (msgConfiguration) {
            msgConfiguration(_msg_configuration);
            if (!_msg_configuration.text || !_msg_configuration.text.length) _msg_configuration = nil;
        }else {
            _msg_configuration = nil;
        }
    }
    return self;
}


- (void)initializeUI {
    [self valueInitialize];
    [self setUpContentView];
    [self setUpTitleLabel];
    [self setUpMessageLabel];
}

#pragma mark - Initialize the correlation value
- (void)valueInitialize {
    _canHideByClickBgView = @(0);
    _contentWidth = 265;
    _textFieldFontSize = 15.0;
    _btnStyleDefaultTextColor = kBtnStyleDefaultTextColor;
    _btnStyleCancelTextColor = kBtnStyleCancelTextColor;
    _btnStyleDestructiveTextColor = kBtnStyleDestructiveTextColor;
    _textFieldHeight = kTextFieldHeight;
    _buttonHeight = kButtonHeight;
    _lineHeight = kLineHeight;
    _textFields = [NSMutableArray array];
    _buttonModels = [NSMutableArray array];
    
    _title_Configuration = [TitleConfiguration new];
    _title_Configuration.fontSize = 18.0;
    _title_Configuration.textColor = kColorHex(0x000000, 1.0);
    _title_Configuration.top = 15;
    
    _msg_configuration = [MessageConfiguration new];
    _msg_configuration.fontSize = 14.0;
    _msg_configuration.textColor = kColorHex(0x333333, 1.0);
    _msg_configuration.top = 10;
    _msg_configuration.bottom = 15;
}

- (void)setUpContentView {
    UIView *contentView = [UIView new];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.masksToBounds = YES;
    contentView.layer.cornerRadius = 8.0 * (kScreenHeight/568.0);
    contentView.clipsToBounds = YES;
    [self addSubview:contentView];
    _contentView = contentView;
}

- (void)setUpTitleLabel {
    UILabel *titleLabel = [UILabel new];
    titleLabel.numberOfLines = 0;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [_contentView addSubview:titleLabel];
    _titleLabel = titleLabel;
}

- (void)setUpMessageLabel {
    UILabel *messageLabel = [UILabel new];
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [_contentView addSubview:messageLabel];
    _messageLabel = messageLabel;
}

- (void)addBtnWithTitle:(NSString *)title type:(JLPopUpBtnStyle)style handler:(buttonAction)handler {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = 10 + _buttonModels.count;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[self colorWithBtnStyle:style] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:17];
    [button addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(setBackgroundColorForButton:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(clearBackgroundColorForButton:) forControlEvents:UIControlEventTouchDragExit];
    [_contentView addSubview:button];
    
    PopUpViewBtnModel *btnModel = [PopUpViewBtnModel new];
    btnModel.button = button;
    btnModel.btnStyle = style;
    btnModel.actionHandler = handler;
    [_buttonModels addObject:btnModel];
}


- (void)addTextFieldWithPlaceholder:(NSString *)placeholder text:(NSString *)text secureEntry:(BOOL)secureEntry {
    UITextField *tf = [[UITextField alloc] init];
    tf.text = text;
    tf.placeholder = placeholder;
    tf.textColor = kColorHex(0x333333, 1.0);
    tf.font = [UIFont systemFontOfSize:_textFieldFontSize];
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    tf.secureTextEntry = secureEntry;
    [_textFields addObject:tf];
}

#pragma mark - configure && Layout TitleLabel
- (void)configureAndLayoutTitleLabel {
    if (_title_Configuration) {
        CGFloat left_padding = 25;
        CGFloat labelWidth = _contentWidth-left_padding-left_padding;
        _titleLabel.text = _title_Configuration.text;
        _titleLabel.textColor = _title_Configuration.textColor;
        _titleLabel.font = [UIFont systemFontOfSize:_title_Configuration.fontSize];
        [self fixTopAndBottomValues];
        CGFloat top = _title_Configuration.top;
        CGSize titleSize = [_titleLabel.text boundingRectWithSize:CGSizeMake(labelWidth, 250) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : _titleLabel.font} context:nil].size;
        _titleLabel.frame = CGRectMake(left_padding, top, labelWidth, titleSize.height);
    }
}

#pragma mark - configure && Layout MsgLabel
- (void)configureAndLayoutMsgLabel {
    if (_msg_configuration) {
        CGFloat left_padding = 25;
        CGFloat labelWidth = _contentWidth-left_padding-left_padding;
        _messageLabel.text = _msg_configuration.text;
        _messageLabel.textColor = _msg_configuration.textColor;
        _messageLabel.font = [UIFont systemFontOfSize:_msg_configuration.fontSize];
        [self fixTopAndBottomValues];
        CGFloat top = CGRectGetMaxY(_titleLabel.frame) + _title_Configuration.bottom + _msg_configuration.top;
        CGSize msgSize = [_messageLabel.text boundingRectWithSize:CGSizeMake(labelWidth, 250) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : _messageLabel.font} context:nil].size;
        _messageLabel.frame = CGRectMake(left_padding, top, labelWidth, msgSize.height);
    }
}

- (void)layoutTextFields {
    if (!_textFields.count) return;
    if (_popUpViewStyle == JLPopUpViewStyleAlert) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboard_willShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboard_willHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    
    _textFieldArray = _textFields.copy;
    CGFloat tfPadding = 20;
    UIView *textFieldBgView = [UIView new];
    textFieldBgView.layer.masksToBounds = YES;
    textFieldBgView.layer.cornerRadius = 4;
    textFieldBgView.layer.borderWidth = 0.8;
    textFieldBgView.layer.borderColor = [UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1].CGColor;
    [_contentView addSubview:textFieldBgView];
    CGFloat baseTop = [self getTitleAndMsgLabelBaseHeight];
    for (int i = 0; i < _textFields.count; i ++) {
        // Horizontal Line
        if (i >= 1) {
            CALayer *lineLayer = [CALayer layer];
            lineLayer.backgroundColor = [UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1].CGColor;
            CGFloat top = _textFieldHeight +(_textFieldHeight+_lineHeight)*(i-1);
            lineLayer.frame = CGRectMake(0, top, _contentWidth-2*tfPadding, _lineHeight);
            [textFieldBgView.layer addSublayer:lineLayer];
        }
        
        UITextField *tf = _textFields[i];
        tf.frame = CGRectMake(5, (_textFieldHeight+_lineHeight)*i, _contentWidth-2*tfPadding-10, _textFieldHeight);
        [textFieldBgView addSubview:tf];
    }
    UITextField *lastTf = _textFields.lastObject;
    textFieldBgView.frame = CGRectMake(tfPadding, baseTop, _contentWidth-2*tfPadding, CGRectGetMaxY(lastTf.frame));
    
    _contentView.frame = CGRectMake(10, kScreenHeight, _contentWidth, CGRectGetMaxY(textFieldBgView.frame)+kTextFieldViewBottom);
    _contentHeight = CGRectGetMaxY(textFieldBgView.frame)+kTextFieldViewBottom;
}

- (void)layoutButtons {
    if (_popUpViewStyle == JLPopUpViewStyleAlert) {
        [self layoutBtnsForAlert];
    }else if (_popUpViewStyle == JLPopUpViewStyleActionSheet) {
        [self layoutBtnsForActionSheet];
    }
}

- (void)layoutBtnsForAlert {
    if (_buttonModels.count == 2) {
        // Horizontal Line
        CALayer *lineLayer = [CALayer layer];
        lineLayer.backgroundColor = [kColorHex(0xdbdbdb, 1.0) CGColor];
        CGFloat top = [self getTitleAndMsgLabelBaseHeight];
        if (_textFields.count) {
            NSInteger tfCount = _textFields.count;
            top += (tfCount*_textFieldHeight + (tfCount-1)*_lineHeight + kTextFieldViewBottom);
        }
        lineLayer.frame = CGRectMake(0, top, _contentWidth, _lineHeight);
        [_contentView.layer addSublayer:lineLayer];
        
        // Vertical Line
        CALayer *lineLayer2 = [CALayer layer];
        lineLayer2.backgroundColor = [kColorHex(0xdbdbdb, 1.0) CGColor];
        lineLayer2.frame = CGRectMake(_contentWidth/2.0, top+_lineHeight, _lineHeight, _buttonHeight);
        [_contentView.layer addSublayer:lineLayer2];
        
        for (int i = 0; i < _buttonModels.count; i ++) {
            PopUpViewBtnModel *btnModel = _buttonModels[i];
            UIButton *button = btnModel.button;
            [button setTitleColor:[self colorWithBtnStyle:btnModel.btnStyle] forState:UIControlStateNormal];
            button.frame = CGRectMake(_contentWidth/2.0*i, top+_lineHeight, _contentWidth/2.0, _buttonHeight);
        }
        _contentView.frame = CGRectMake(10, kScreenHeight, _contentWidth, top+_lineHeight+_buttonHeight);
        _contentHeight = _contentView.frame.size.height;
    }else if (_buttonModels.count == 1 || _buttonModels.count >= 3) {
        CGFloat baseTop = [self getTitleAndMsgLabelBaseHeight];
        if (_textFields.count) {
            NSInteger tfCount = _textFields.count;
            baseTop += (tfCount*_textFieldHeight + (tfCount-1)*_lineHeight + kTextFieldViewBottom);
        }
        
        //To ensure that the "cancel" button at the bottom
        NSInteger offset = 0;
        // Used to calculate the number of the cancel button and total height
        NSInteger nonCancelBtnCount = 0;
        for (int i = 0; i < _buttonModels.count; i ++) {
            PopUpViewBtnModel *btnModel = _buttonModels[i];
            if (btnModel.btnStyle == JLPopUpBtnStyleCancel) {
                offset --;
                continue;
            }
            nonCancelBtnCount ++;
            CGFloat top = baseTop;
            NSInteger index = i + offset;
            
            // Horizontal Line
            CALayer *lineLayer = [CALayer layer];
            lineLayer.backgroundColor = [kColorHex(0xdbdbdb, 1.0) CGColor];
            top += ((_lineHeight+_buttonHeight)*index);
            lineLayer.frame = CGRectMake(0, top, _contentWidth, _lineHeight);
            [_contentView.layer addSublayer:lineLayer];
            
            UIButton *button = btnModel.button;
            [button setTitleColor:[self colorWithBtnStyle:btnModel.btnStyle] forState:UIControlStateNormal];
            button.frame = CGRectMake(0, top+_lineHeight, _contentWidth, _buttonHeight);
        }
        
        //The animation of the cancel button
        CGFloat baseTop2 = baseTop + (_lineHeight+_buttonHeight) * nonCancelBtnCount;
        NSInteger index = 0;
        for (int i = 0; i < _buttonModels.count; i ++) {
            PopUpViewBtnModel *btnModel = _buttonModels[i];
            if (btnModel.btnStyle == JLPopUpBtnStyleCancel) {
                CGFloat top = baseTop2;
                
                // Horizontal Line
                CALayer *lineLayer = [CALayer layer];
                lineLayer.backgroundColor = [kColorHex(0xdbdbdb, 1.0) CGColor];
                top += ((_lineHeight+_buttonHeight)*index);
                lineLayer.frame = CGRectMake(0, top, _contentWidth, _lineHeight);
                [_contentView.layer addSublayer:lineLayer];
                
                UIButton *button = btnModel.button;
                [button setTitleColor:[self colorWithBtnStyle:btnModel.btnStyle] forState:UIControlStateNormal];
                button.frame = CGRectMake(0, top+_lineHeight, _contentWidth, _buttonHeight);
                index ++;
            }
        }
        _contentView.frame = CGRectMake(10, kScreenHeight, _contentWidth, baseTop+(_lineHeight+_buttonHeight)*_buttonModels.count);
        _contentHeight = _contentView.frame.size.height;
    }
}

- (void)layoutBtnsForActionSheet {
    CGFloat baseTop = [self getTitleAndMsgLabelBaseHeight];
    if (_textFields.count) {
        NSInteger tfCount = _textFields.count;
        baseTop += (tfCount*_textFieldHeight + (tfCount-1)*_lineHeight + kTextFieldViewBottom);
    }
    
    //To ensure that the "cancel" button at the bottom
    NSInteger offset = 0;
    _cancelBtnIndex = 0;
    for (int i = 0; i < _buttonModels.count; i ++) {
        PopUpViewBtnModel *btnModel = _buttonModels[i];
        if (btnModel.btnStyle == JLPopUpBtnStyleCancel) {
            if (_hasAddCancelBtnForOnce) {
                NSAssert(!_hasAddCancelBtnForOnce, @"PopUpView：在ActionSheet样式时，请不要添加两个以上的取消按钮");
                return;
            }else {
                _hasAddCancelBtnForOnce = YES;
            }
            
            offset = -1;
            _cancelBtnIndex = i;
            continue;
        }
        
        CGFloat top = baseTop;
        NSInteger index = i + offset;
        // Horizontal Line
        CALayer *lineLayer = [CALayer layer];
        lineLayer.backgroundColor = [kColorHex(0xdbdbdb, 1.0) CGColor];
        top += ((_lineHeight+_buttonHeight)*index);
        lineLayer.frame = CGRectMake(0, top, _contentWidth, _lineHeight);
        [_contentView.layer addSublayer:lineLayer];
        
        UIButton *button = btnModel.button;
        [button setTitleColor:[self colorWithBtnStyle:btnModel.btnStyle] forState:UIControlStateNormal];
        button.frame = CGRectMake(0, top+_lineHeight, _contentWidth, _buttonHeight);
    }
    
    //calculate contentView frame
    if (_hasAddCancelBtnForOnce) {
        _contentView.frame = CGRectMake(10, kScreenHeight, _contentWidth, baseTop+(_lineHeight+_buttonHeight)*(_buttonModels.count-1));
    }else {
        _contentView.frame = CGRectMake(10, kScreenHeight, _contentWidth, baseTop+(_lineHeight+_buttonHeight)*_buttonModels.count);
    }
    
    //The animation of the cancel button
    if (_hasAddCancelBtnForOnce) {
        PopUpViewBtnModel *cancelBtnModel = _buttonModels[_cancelBtnIndex];
        UIButton *button = cancelBtnModel.button;
        [button setTitleColor:[self colorWithBtnStyle:cancelBtnModel.btnStyle] forState:UIControlStateNormal];
        CGFloat cancelBtnTop = kScreenHeight + _contentView.bounds.size.height + 10 + _buttonHeight + 10;
        button.frame = CGRectMake(10, cancelBtnTop, _contentWidth, _buttonHeight);
        button.layer.masksToBounds = YES;
        button.backgroundColor = [UIColor whiteColor];
        button.layer.cornerRadius = _contentView.layer.cornerRadius;
        [button removeFromSuperview];
        [self addSubview:button];
    }
}

- (void)fixTopAndBottomValues {
    if (_title_Configuration) {
        if (_msg_configuration) {
            if (_msg_configuration.bottom == 0) {
                _msg_configuration.bottom = 15.0;
            }
        }else {
            if (_title_Configuration.bottom == 0) {
                _title_Configuration.bottom = 15.0;
            }
        }
    }else {
        if (_msg_configuration) {
            if (_msg_configuration.top < 15.0) {
                _msg_configuration.top = 15.0;
            }
            if (_msg_configuration.bottom == 0) {
                _msg_configuration.bottom = 15.0;
            }
        }else {
        }
    }
}

- (CGFloat)getTitleAndMsgLabelBaseHeight {
    CGFloat height = 0;
    if (_msg_configuration) {
        height = CGRectGetMaxY(_messageLabel.frame) + _msg_configuration.bottom;
    }else {
        if (_title_Configuration) {
            height = CGRectGetMaxY(_titleLabel.frame) + _title_Configuration.bottom;
        }else {
            height = 15.0;
        }
    }
    return height;
}

- (UIColor *)colorWithBtnStyle:(JLPopUpBtnStyle)style {
    if (style == JLPopUpBtnStyleDefault) {
        return _btnStyleDefaultTextColor;
    }else if (style == JLPopUpBtnStyleCancel) {
        return _btnStyleCancelTextColor;
    }else if (style == JLPopUpBtnStyleDestructive) {
        return _btnStyleDestructiveTextColor;
    }
    return nil;
}

- (void)showInWindowWithPreferredStyle:(JLPopUpViewStyle)preferredStyle {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [self showInView:window preferredStyle:preferredStyle];
}

- (void)showInView:(UIView *)view preferredStyle:(JLPopUpViewStyle)preferredStyle {
    _popUpViewStyle = preferredStyle;
    if (preferredStyle == JLPopUpViewStyleAlert) {
        _contentWidth = 265;
        [view addSubview:self];
        _contentView.center = self.center;
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 1.0;
        }];
        [self showAlertAnimation];
    }else if (preferredStyle == JLPopUpViewStyleActionSheet) {
        _contentWidth = kScreenWidth - 10 - 10;
        [view addSubview:self];
        [UIView animateWithDuration:0.6 delay:0.0 usingSpringWithDamping:0.85 initialSpringVelocity:0.5
                            options:UIViewAnimationOptionCurveEaseIn animations:^{
                                CGRect rect = _contentView.frame;
                                CGFloat offset = _hasAddCancelBtnForOnce ? _buttonHeight+10 : 0;
                                rect.origin.y = kScreenHeight - rect.size.height - 10 - offset;
                                _contentView.frame = rect;
                                
                                //The animation of the cancel button
                                if (_hasAddCancelBtnForOnce) {
                                    PopUpViewBtnModel *cancelBtnModel = _buttonModels[_cancelBtnIndex];
                                    UIButton *button = cancelBtnModel.button;
                                    CGRect rect = button.frame;
                                    rect.origin.y = kScreenHeight - rect.size.height - 10;
                                    button.frame = rect;
                                }
                                
                                self.alpha = 1.0;
                            } completion:nil];
    }
}

- (void)didMoveToSuperview {
    if (self.superview) {
        [self configureAndLayoutTitleLabel];
        [self configureAndLayoutMsgLabel];
        [self layoutTextFields];
        [self layoutButtons];
    }
}

- (void)showAlertAnimation {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)]];
    animation.keyTimes = @[ @0, @0.5, @1 ];
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = .3;
    
    [_contentView.layer addAnimation:animation forKey:@"showAlert"];
}

- (void)dismissAlertAnimation {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95, 0.95, 1)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1)]];
    animation.keyTimes = @[ @0, @0.5, @1 ];
    animation.fillMode = kCAFillModeRemoved;
    animation.duration = .2;
    
    [_contentView.layer addAnimation:animation forKey:@"dismissAlert"];
}

- (void)hide {
    if (_popUpViewStyle == JLPopUpViewStyleAlert) {
        [self dismissAlertAnimation];
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 0;
        }];
        [UIView animateWithDuration:0.2 animations:^{
            _contentView.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }else if(_popUpViewStyle == JLPopUpViewStyleActionSheet) {
        [UIView animateWithDuration:0.24 delay:0.08 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.alpha = 0.0;
            
            CGRect rect = _contentView.frame;
            rect.origin.y = kScreenHeight;
            _contentView.frame = rect;
            if (_hasAddCancelBtnForOnce) {
                PopUpViewBtnModel *cancelBtnModel = _buttonModels[_cancelBtnIndex];
                UIButton *button = cancelBtnModel.button;
                CGRect rect = button.frame;
                rect.origin.y = kScreenHeight + 10 + _buttonHeight + 10;
                button.frame = rect;
            }
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}

- (void)btnAction:(UIButton *)sender {
    NSInteger index = sender.tag - 10;
    
    PopUpViewBtnModel *model = _buttonModels[index];
    buttonAction handler = model.actionHandler;
    if (handler) handler();
    [self hide];
}

- (void)clickBackGroundHide:(UITapGestureRecognizer *)tap {
    if (_canHideByClickBgView.integerValue == 0) {
        // Users do not have set the value of a 'self.canClickBackgroundHide', according to the default processing
        if (_popUpViewStyle == JLPopUpViewStyleAlert) {
            
        }else if (_popUpViewStyle == JLPopUpViewStyleActionSheet) {
            [self hide];
        }
    }else if (_canHideByClickBgView.integerValue == 1) {
        // YES
        [self hide];
    }else if (_canHideByClickBgView.integerValue == 2) {
        // NO
    }
}

- (void)setBackgroundColorForButton:(id)sender {
    [sender setBackgroundColor:kColorHex(0xcccccc, 0.8)];
}

- (void)clearBackgroundColorForButton:(UIButton *)sender {
    NSInteger index = sender.tag - 10;
    if (index == _cancelBtnIndex) {
        [sender setBackgroundColor:[UIColor whiteColor]];
    }else {
        [sender setBackgroundColor:[UIColor clearColor]];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(_contentView.frame, point)) {
        return NO;
    }
    return YES;
}

#pragma mark - Setters
- (void)setCanClickBackgroundHide:(BOOL)canClickBackgroundHide {
    _canHideByClickBgView = canClickBackgroundHide ? @(1) : @(2);
}

#pragma mark - Notifications
- (void)keyboard_willShow:(NSNotification *)ntf {
    NSDictionary * userInfo = [ntf userInfo];
    CGFloat duration = [userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];
    CGRect kbRect = [userInfo[@"UIKeyboardBoundsUserInfoKey"] CGRectValue];
    CGFloat kb_minY = kScreenHeight - CGRectGetHeight(kbRect);
    
    CGRect beginUserInfo = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey]   CGRectValue];
    if (beginUserInfo.size.height <= 0) {
        //!!!搜狗输入法弹出时会发出三次UIKeyboardWillShowNotification的通知,和官方输入法相比,有效的一次为UIKeyboardFrameBeginUserInfoKey.size.height都大于零时.
        return;
    }
    
    //+5 Let input box is higher than the height of the keyboard 5 again
    CGFloat contentView_maxY = CGRectGetMaxY(_contentView.frame)+(5);
    CGFloat offset = contentView_maxY - kb_minY;
    if (offset > 0) {
        [UIView animateWithDuration:duration animations:^{
            CGRect rect = _contentView.frame;
            rect.origin.y -= offset;
            _contentView.frame = rect;
        }];
    }
}

- (void)keyboard_willHide:(NSNotification *)ntf {
    NSDictionary * userInfo = [ntf userInfo];
    CGFloat duration = [userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];
    [UIView animateWithDuration:duration animations:^{
        _contentView.center = self.center;
    }];
}

#pragma mark - Destruction of notification
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
