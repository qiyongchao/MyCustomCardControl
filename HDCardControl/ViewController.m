//
//  ViewController.m
//  HDCardControl
//
//  Created by qiyongchao on 16/4/11.
//  Copyright © 2016年 qiyongchao. All rights reserved.
//

#import "ViewController.h"
#import "AllHDCardsView.h"

@interface ViewController ()<AllHDCardsViewDataSource>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    AllHDCardsView *cardsView = [AllHDCardsView cardsView];
    cardsView.frame = self.view.bounds;
    cardsView.dataSource = self;
    [self.view addSubview:cardsView];
}

- (UIView *)nextViewForAllHDCardsView:(AllHDCardsView *)cardsView cardIndex:(NSInteger)index {
    UIView *view = [[UIView alloc]init];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 20)];
    label.font = [UIFont systemFontOfSize:20];
    label.text = [NSString stringWithFormat:@"%ld",(long)index];
    [view addSubview:label];
    return view;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
