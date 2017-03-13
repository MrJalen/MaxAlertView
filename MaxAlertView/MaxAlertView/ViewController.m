//
//  ViewController.m
//  MaxAlertView
//
//  Created by Jalen on 2017/2/27.
//  Copyright © 2017年 Jalen. All rights reserved.
//

#import "ViewController.h"
#import "Header.h"
#import "MaxAlertViewController.h"
#import "AlertViewController.h"
#import "ActionSheetViewController.h"

@interface ViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic ,strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"Display";
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    cell.textLabel.text = @[@"Usering MaxAlertView",
                            @"Usering AlertPopUpView",
                            @"Usering ActionSheetPopUpView"][indexPath.section];
    
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
    
    UILabel *tipsLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, KSCREEN_WIDTH - 30, 30)];
    tipsLab.textColor = [UIColor lightGrayColor];
    tipsLab.font = [UIFont systemFontOfSize:12];
    tipsLab.numberOfLines = 2;
    tipsLab.text = @[@"Usering MaxAlertView，Six kinds of style with Alert",
                     @"Usering AlertPopUpView，Four kinds of style with Alert",
                     @"Usering ActionSheetPopUpView，Four kinds of style with ActionSheet"][section];
    [headerView addSubview:tipsLab];
    
    return headerView;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        //
        [self.navigationController pushViewController:[[MaxAlertViewController alloc] init] animated:YES];
    }else if (indexPath.section == 1) {
        //
        [self.navigationController pushViewController:[[AlertViewController alloc] init] animated:YES];
    }else {
        //
        [self.navigationController pushViewController:[[ActionSheetViewController alloc] init] animated:YES];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
