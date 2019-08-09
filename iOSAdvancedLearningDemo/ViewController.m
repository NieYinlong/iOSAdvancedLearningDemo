//
//  ViewController.m
//  进阶学习demo
//
//  Created by nyl on 2019/8/6.
//  Copyright © 2019 nieyinlong. All rights reserved.
//

#import "ViewController.h"

NSString * const controllerKey = @"controllerKey";
NSString * const titleKey = @"titleKey";

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"nyl_identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleSubtitle) reuseIdentifier:identifier];
    }
    cell.textLabel.text = [self.dataArr[indexPath.row] valueForKey:titleKey];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *vcStr = [self.dataArr[indexPath.row] valueForKey:controllerKey];
    UIViewController *VC = [NSClassFromString(vcStr) new];
    [self.navigationController pushViewController:VC animated:YES];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStyleGrouped)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (NSArray *)dataArr {
    if (!_dataArr) {
        _dataArr = @[
                     @{controllerKey : @"MessageForwardVC", titleKey : @"消息转发"},
                     @{controllerKey : @"MultithreadingVC", titleKey : @"多线程"}
                     ];
    }
    return _dataArr;
}


@end
