//
//  ViewController.m
//  PartitionSlider
//
//  Created by Ming on 2018/3/21.
//  Copyright © 2018年 David.Dai. All rights reserved.
//

#import "ViewController.h"
#import "PartionSlider.h"
@interface ViewController ()<PartionSliderDelegate>
@property (nonatomic, strong) PartionSlider *slider;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.slider = [[PartionSlider alloc]initWithDelegate:self];
    [self.view addSubview:self.slider];
    [self.slider makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(SliderViewPadding);
        make.right.equalTo(self.view).offset(-SliderViewPadding);
        make.bottom.equalTo(self.view).offset(-50);
        make.height.equalTo(@(60));
    }];
}

- (void)didPratitionSliderChangeToIndex:(NSInteger)index {
    NSLog(@"select to index:%ld",(long)index);
}

@end
