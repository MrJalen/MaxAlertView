//
//  ActionSheetViewController.m
//  MaxAlertView
//
//  Created by Jalen on 2017/3/13.
//  Copyright © 2017年 Jalen. All rights reserved.
//

#import "ActionSheetViewController.h"
#import "Header.h"
#import "PopUpView.h"

@interface ActionSheetViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic ,strong) UITableView *tableView;

@end

@implementation ActionSheetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Usering ActionSheetPopUpView";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createTableView];
}

- (void)createTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KSCREEN_WIDTH, KSCREEN_HEIGHT) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    cell.textLabel.text = @[@"Cancel & Confirm",
                            @"Cancel & Confirm & More button action style",
                            @"The free style",
                            @"Log in or Sing in"][indexPath.section];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 2 ? 70 : 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [UIView new];
    
    UILabel *tipsLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, KSCREEN_WIDTH - 30, section == 2 ? 50 : 30)];
    tipsLab.textColor = [UIColor lightGrayColor];
    tipsLab.font = [UIFont systemFontOfSize:12];
    tipsLab.numberOfLines = 0;
    tipsLab.text = @[@"show title & message , at the same time show a cancel button & confirm button",
                     @"show title & More button action style",
                     @"The ways to create the title and the message of the text, font size, font color, text on the bottom margin customizing, adapted to your requirements at any time",
                     @"Log in or Sing in"][section];
    [headerView addSubview:tipsLab];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        PopUpView *popUpView = [[PopUpView alloc] initWithTitle:@"Title" message:@"AlertPopUpView show Title with message"];
        
        [popUpView addBtnWithTitle:@"cancel" type:JLPopUpBtnStyleCancel handler:^{
            NSLog(@"cancel");
        }];
        
        [popUpView addBtnWithTitle:@"confirm" type:JLPopUpBtnStyleDefault handler:^{
            NSLog(@"confirm");
        }];
        
        [popUpView showInView:self.view preferredStyle:JLPopUpViewStyleActionSheet];
    }else if (indexPath.section == 1) {
        PopUpView *popUpView = [[PopUpView alloc] initWithTitle:@"Title" message:@"AlertPopUpView show Title with More button action style" cancelButtonTitle:@"cancel" otherButtonTitles:@[@"one style", @"two style", @"confirm"] actionWithIndex:^(NSInteger index) {
            if (index == 0) {
                NSLog(@"cancel");
            }else if (index == 1) {
                NSLog(@"one style");
            }else if (index == 2) {
                NSLog(@"two style");
            }else {
                NSLog(@"confirm");
            }
        }];
        
        [popUpView addBtnWithTitle:@"separate add style" type:JLPopUpBtnStyleDestructive handler:^{
            NSLog(@"separate add style");
        }];
        
        [popUpView showInView:self.view preferredStyle:JLPopUpViewStyleActionSheet];
    }else if (indexPath.section == 2) {
        PopUpView *popUpView = [[PopUpView alloc] initWithTitleConfiguration:^(TitleConfiguration *configuration) {
            configuration.text = @"Title";
            configuration.textColor = [UIColor redColor];
        } messageConfiguration:^(MessageConfiguration *configuration) {
            configuration.text = @"The ways to create the title and the message of the text, font size, font color, text on the bottom margin customizing, adapted to your requirements at any time";
            configuration.fontSize = 15.0;
            configuration.textColor = [UIColor purpleColor];
            configuration.bottom = 25.0;
        }];
        
        [popUpView addBtnWithTitle:@"cancel" type:JLPopUpBtnStyleCancel handler:^{
            NSLog(@"cancel");
        }];
        
        [popUpView addBtnWithTitle:@"I know" type:JLPopUpBtnStyleDestructive handler:^{
            NSLog(@"I know");
        }];
        
        [popUpView addBtnWithTitle:@"confirm" type:JLPopUpBtnStyleDefault handler:^{
            NSLog(@"confirm");
        }];
        [popUpView showInView:self.view preferredStyle:JLPopUpViewStyleActionSheet];
    }else {
        PopUpView *popUpView = [[PopUpView alloc] initWithTitle:@"Title" message:@"Log in or Sing in"];
        __weak typeof(PopUpView) *weakPopUpView = popUpView;
        
        [popUpView addTextFieldWithPlaceholder:@"account/phone number/email" text:nil secureEntry:NO];
        [popUpView addTextFieldWithPlaceholder:@"password" text:nil secureEntry:YES];
        [popUpView addTextFieldWithPlaceholder:@"password again" text:nil secureEntry:YES];
        
        [popUpView addBtnWithTitle:@"cancel" type:JLPopUpBtnStyleCancel handler:^{
            NSLog(@"cancel");
        }];
        
        [popUpView addBtnWithTitle:@"confirm" type:JLPopUpBtnStyleDefault handler:^{
            NSLog(@"confirm");
            for (int i = 0; i < weakPopUpView.textFieldArray.count; i ++) {
                UITextField *tf = weakPopUpView.textFieldArray[i];
                NSLog(@"第%d个输入框的文字是：%@", i, tf.text);
            }
        }];
        [popUpView showInView:self.view preferredStyle:JLPopUpViewStyleActionSheet];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
