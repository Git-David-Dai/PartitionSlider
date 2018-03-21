//
//  PartionSlider.h
//  PartitionSlider
//
//  Created by Ming on 2018/3/21.
//  Copyright © 2018年 David.Dai. All rights reserved.
//
#define colorWithRGBA(rgbValue, alphaValue) \
[UIColor colorWithRed:((float)((0x##rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((0x##rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((float)(0x##rgbValue & 0xFF)) / 255.0 alpha:alphaValue]
#define MAS_SHORTHAND

#import "Masonry.h"
#import <UIKit/UIKit.h>

static CGFloat const SliderBarViewPadding    = 20;
static CGFloat const SliderViewPadding       = 22;
static CGFloat const SliderTouchHeight       = 50;

@protocol PartionSliderDelegate <NSObject>
- (void)didPratitionSliderChangeToIndex:(NSInteger)index;
@end

@interface PartionSlider : UIControl
@property (nonatomic, weak) id <PartionSliderDelegate> delegate;
@property (nonatomic, readonly) NSInteger currentIndex;

- (instancetype)initWithDelegate:(id<PartionSliderDelegate>)delegate;
- (void)updateLayout;
- (void)updatePartitionTitle:(NSArray <NSString *>*)titleArray;
- (void)selectToIndex:(NSInteger)index;
@end
