//
//  ViewController.m
//  MaxAlertView
//
//  Created by Jalen on 2017/2/27.
//  Copyright © 2017年 Jalen. All rights reserved.
//

#import "ViewController.h"
#import "MaxAlertView.h"

#define KSCREEN_WIDTH   [UIScreen mainScreen].bounds.size.width
#define KSCREEN_HEIGHT  [UIScreen mainScreen].bounds.size.height

@interface ViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic ,strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"Usering MaxAlertView";
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
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    cell.textLabel.text = @[@"Title",
                            @"Title with message",
                            @"Cancel button",
                            @"Cancel & Confirm",
                            @"Cancel & Confirm & ContentView",
                            @"Cancel block with OK"][indexPath.section];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [UIView new];
    
    UILabel *tipsLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, KSCREEN_WIDTH - 20, 30)];
    tipsLab.textColor = [UIColor lightGrayColor];
    tipsLab.font = [UIFont systemFontOfSize:12];
    tipsLab.numberOfLines = 2;
    tipsLab.text = @[@"show a title",
                     @"show title & message",
                     @"show title & message , at the same time show a cancel button",
                     @"show title & message , at the same time show a cancel button & confirm button",
                     @"show title & message , at the same time show a cancel button & confirm button , contentView",
                     @"show title & message , at the same time show a cancel block with OK"][section];
    [headerView addSubview:tipsLab];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        [MaxAlertView showAlertWithTitle:@"AlertView show Title"];
    }else if (indexPath.section == 1) {
        [MaxAlertView showAlertWithTitle:@"Title" message:@"AlertView show Title with message"];
    }else if (indexPath.section == 2) {
        [MaxAlertView showAlertWithTitle:@"Title" message:@"AlertView show Title with message" cancelTitle:@"cancel" completion:^(BOOL cancelled) {
            NSLog(@"cancel");
        }];
    }else if (indexPath.section == 3) {
        [MaxAlertView showAlertWithTitle:@"Title" message:@"AlertView show Title with message" cancelTitle:@"cancel" otherTitle:@"confirm" completion:^(BOOL cancelled) {
            if (cancelled) {
                NSLog(@"cancel");
            }else {
                NSLog(@"confirm");
            }
        }];
    }else if (indexPath.section == 4) {
        [MaxAlertView showAlertWithTitle:@"Title" message:@"AlertView show Title with message" cancelTitle:@"cancel" otherTitle:@"confirm" contentView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wode_ydy"]] completion:^(BOOL cancelled) {
            if (cancelled) {
                NSLog(@"cancel");
            }else {
                NSLog(@"confirm");
            }
        }];
    }else if (indexPath.section == 5) {
        [MaxAlertView showAlertWithTitle:@"Title" message:@"AlertView show Title with message" completion:^(BOOL cancelled) {
            if (cancelled) {
                NSLog(@"ok");
            }
        }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
