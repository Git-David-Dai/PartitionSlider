//
//  PartionSlider.m
//  PartitionSlider
//
//  Created by Ming on 2018/3/21.
//  Copyright © 2018年 David.Dai. All rights reserved.
//
#import "PartionSlider.h"

static CGFloat const SliderBarViewHeight     = 2;
static CGFloat const SliderEdgeWidth         = 8;
static CGFloat const SliderTouchAnimationDuration = 0.06;

@interface PartionSlider()
@property (nonatomic, strong) NSMutableArray <UIView *> *titleLabelArray;
@property (nonatomic, strong) NSArray *titleArray;

@property (nonatomic, strong) UIView  *slider;
@property (nonatomic, strong) NSMutableArray <UIView *> *markViewArray;
@property (nonatomic, strong) UIView  *barView;

@property (nonatomic, assign) CGFloat barViewWidth;
@property (nonatomic, assign) CGFloat barViewHeight;
@property (nonatomic, assign) CGFloat markViewPadding;

@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSInteger indexBeforeDrag;
@end

@implementation PartionSlider

- (instancetype)init
{
    if(self = [super initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)]){
        self.titleArray = @[@"first",@"second",@"third",@"fourth"];
        [self initSublayout];
    }
    return self;
}

- (instancetype)initWithDelegate:(id<PartionSliderDelegate>)delegate {
    self = [self init];
    self.delegate = delegate;
    return self;
}

- (void)initSublayout
{
    self.barViewHeight = SliderBarViewHeight;
    self.barViewWidth  = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) - SliderBarViewPadding * 2 - SliderViewPadding * 2;
    
    self.barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.barViewWidth, self.barViewHeight)];
    self.barView.userInteractionEnabled = NO;
    self.barView.backgroundColor     = colorWithRGBA(000000, 0.1);
    self.barView.layer.borderColor   = colorWithRGBA(000000, 0.1).CGColor;
    self.barView.layer.borderWidth   = 1;
    self.barView.layer.cornerRadius  = self.barViewHeight / 2;
    self.barView.layer.masksToBounds = YES;
    [self addSubview:self.barView];
    
    CGFloat markViewWith = 1;
    self.markViewPadding = (self.barViewWidth - markViewWith * self.titleArray.count) / (self.titleArray.count - 1);
    self.markViewArray   = [NSMutableArray array];
    [self drawMarkView];
    
    self.titleLabelArray = [NSMutableArray array];
    [self drawTitleLabel];
    
    self.slider = [[UIView alloc] init];
    self.slider.backgroundColor = [UIColor blackColor];
    self.slider.layer.masksToBounds = YES;
    self.slider.layer.cornerRadius  = 20.0/2;
    self.slider.userInteractionEnabled = NO;
    [self addSubview:self.slider];
    
    self.currentIndex = 0;
    [self updateTilteLabel];
    [self relayout];
}

#pragma mark - Layout
- (void)drawMarkView {
    for (UIView *markView in self.markViewArray) {
        if(markView.superview){
            [markView removeFromSuperview];
        }
    }
    [self.markViewArray removeAllObjects];
    
    for (int i = 0; i < self.titleArray.count; i++) {
        UIView *markView = [[UIView alloc] init];
        markView.userInteractionEnabled = NO;
        markView.backgroundColor = colorWithRGBA(000000, 0.3);
        [self addSubview:markView];
        [self.markViewArray addObject:markView];
    }
}

- (void)drawTitleLabel {
    for (UIView *label in self.titleLabelArray) {
        if(label.superview){
            [label removeFromSuperview];
        }
    }
    [self.titleLabelArray removeAllObjects];
    
    for (int i = 0; i < self.titleArray.count; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.textColor = colorWithRGBA(000000, 0.5);
        label.font = [UIFont systemFontOfSize:10 weight:UIFontWeightRegular];
        label.userInteractionEnabled = NO;
        label.textAlignment = NSTextAlignmentCenter;
        
        NSString *text = [self.titleArray objectAtIndex:i];
        label.text = [text uppercaseString];
        
        [self addSubview:label];
        [self.titleLabelArray addObject:label];
    }
}

- (void)updateTilteLabel {
    for(int i = 0 ; i < self.titleLabelArray.count; i++) {
        UILabel *label = (UILabel *)[self.titleLabelArray objectAtIndex:i];
        if(self.currentIndex == i) {
            label.textColor = colorWithRGBA(000000, 0.5);
            label.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        }
        else {
            label.textColor = colorWithRGBA(000000, 0.5);
            label.font = [UIFont systemFontOfSize:10 weight:UIFontWeightRegular];
        }
    }
}

- (void)relayout {
    [self.barView remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(SliderBarViewPadding);
        make.right.equalTo(self).offset(-SliderBarViewPadding);
        make.centerY.equalTo(self);
        make.height.equalTo(@(self.barViewHeight));
    }];
    
    UIView *firstMarkView = [self.markViewArray objectAtIndex:0];
    [firstMarkView remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.barView);
        make.width.equalTo(@1);
        make.centerY.equalTo(self.barView);
        make.height.equalTo(@8);
    }];
    
    UIView *firstTitleLabel = [self.titleLabelArray objectAtIndex:0];
    [firstTitleLabel remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(firstMarkView);
        make.bottom.equalTo(self.barView.top).offset(-20);
    }];
    
    for (int i = 1; i < self.titleArray.count; i++) {
        UIView *previousMarkView = self.markViewArray[i-1];
        UIView *markView = self.markViewArray[i];
        [markView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.barView);
            make.left.equalTo(previousMarkView.mas_right).offset(self.markViewPadding);
            make.width.equalTo(@1);
            make.height.equalTo(@8);
        }];
        
        UIView *titleLabel  = self.titleLabelArray[i];
        [titleLabel remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(markView);
            make.bottom.equalTo(self.barView.top).offset(-20);
        }];
    }
    
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.slider.frame = [self sliderFrameForCurrentIndex];
}

- (CGRect)sliderFrameForCurrentIndex {
    UIView *currentMarkView = self.markViewArray[self.currentIndex];
    CGPoint markCenter = currentMarkView.center;
    return CGRectMake(markCenter.x - 10, markCenter.y - 10, 20, 20);
}

#pragma mark - Interface
- (void)selectToIndex:(NSInteger)index {
    [self updateCurrentIndex:index animated:NO];
    [self updateTilteLabel];
}

- (void)updatePartitionTitle:(NSArray<NSString *> *)titleArray {
    if(!titleArray.count){
        return;
    }
    
    self.titleArray      = titleArray;
    
    CGFloat markViewWith = 1;
    self.markViewPadding = (self.barViewWidth - markViewWith * self.titleArray.count) / (self.titleArray.count - 1);
    
    [self drawMarkView];
    [self drawTitleLabel];
    [self updateTilteLabel];
    [self relayout];
}

- (void)updateLayout {
    [self updateTilteLabel];
    [self relayout];
}

#pragma mark - Tarck
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super beginTrackingWithTouch:touch withEvent:event];
    
    self.indexBeforeDrag = self.currentIndex;
    CGPoint point = [touch locationInView:self];
    if (!CGRectContainsPoint(self.slider.frame, point)) {
        [self handleTapAtPoint:point];
        return NO;
    }
    
    [UIView animateWithDuration:SliderTouchAnimationDuration animations:^{
        self.slider.transform = CGAffineTransformMakeScale(1.3, 1.3);
    }];
    
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];
    
    CGPoint point = [touch locationInView:self];
    CGPoint previousPoint = [touch previousLocationInView:self];
    
    CGPoint movement = [self movementWithVector:CGVectorMake(point.x - previousPoint.x, point.y - previousPoint.y)];
    if (!CGPointEqualToPoint(movement, CGPointZero)) {
        CGPoint center = self.slider.center;
        center.x += movement.x;
        center.y += movement.y;
        self.slider.center = center;
        
        [self updateCurrentIndex];
    }
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    
    [self.markViewArray enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint markCenter = obj.center;
        CGRect markArea = CGRectMake(markCenter.x - self.markViewPadding / 2.0,
                                     markCenter.y - self.markViewPadding / 2.0,
                                     self.markViewPadding,
                                     self.markViewPadding);
        if (CGRectContainsPoint(markArea, [touch locationInView:self])) {
            self.currentIndex = idx;
            *stop = YES;
        }
    }];
    
    [UIView animateWithDuration:SliderTouchAnimationDuration animations:^{
        self.slider.transform = CGAffineTransformIdentity;
        self.slider.frame     = [self sliderFrameForCurrentIndex];
    }];
    
    [self updateTilteLabel];
    [self trackEndCancelHandler];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [super cancelTrackingWithEvent:event];
    
    [UIView animateWithDuration:SliderTouchAnimationDuration animations:^{
        self.slider.transform = CGAffineTransformIdentity;
        self.slider.frame     = [self sliderFrameForCurrentIndex];
    }];
    
    [self trackEndCancelHandler];
}

#pragma mark - Unit
- (CGPoint)movementWithVector:(CGVector)vector {
    CGFloat sliderCenterX = self.slider.center.x;
    CGPoint movement = CGPointZero;
    if (vector.dx < 0) {
        CGFloat firstMarkCenterX = self.markViewArray.firstObject.center.x;
        if (sliderCenterX > firstMarkCenterX  - SliderEdgeWidth) {
            movement.x = MAX(firstMarkCenterX - SliderEdgeWidth - sliderCenterX, vector.dx);
        }
    } else {
        CGFloat lastMarkCenterX = self.markViewArray.lastObject.center.x;
        if (sliderCenterX < lastMarkCenterX  + SliderEdgeWidth) {
            movement.x = MIN(lastMarkCenterX + SliderEdgeWidth - sliderCenterX, vector.dx);
        }
    }
    return movement;
}

- (void)updateCurrentIndex {
    CGPoint sliderCenter = self.slider.center;
    [self.markViewArray enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint markCenter = obj.center;
        CGRect markArea = CGRectMake(markCenter.x - SliderEdgeWidth,
                                     markCenter.y - SliderEdgeWidth,
                                     SliderEdgeWidth * 2,
                                     SliderEdgeWidth * 2);
        if (CGRectContainsPoint(markArea, sliderCenter)) {
            self.currentIndex = idx;
            *stop = YES;
        }
    }];
}

- (void)handleTapAtPoint:(CGPoint)point {
    [self.markViewArray enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint markCenter = obj.center;
        CGRect markArea = CGRectMake(markCenter.x - (self.markViewPadding + SliderEdgeWidth) / 2.0,
                                     markCenter.y - SliderTouchHeight,
                                     self.markViewPadding + SliderEdgeWidth,
                                     SliderTouchHeight);
        if (CGRectContainsPoint(markArea, point)) {
            self.currentIndex = idx;
            *stop = YES;
        }
    }];
    
    self.slider.transform = CGAffineTransformIdentity;
    self.slider.frame = [self sliderFrameForCurrentIndex];
    [self trackEndCancelHandler];
}

- (void)trackEndCancelHandler {
    if (self.indexBeforeDrag != self.currentIndex) {
        [self updateTilteLabel];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didPratitionSliderChangeToIndex:)]) {
            [self.delegate didPratitionSliderChangeToIndex:self.currentIndex];
        }
    }
}

- (void)updateCurrentIndex:(NSInteger)currentIndex animated:(BOOL)animated {
    [UIView animateWithDuration:animated ? 0.15 : 0 animations:^{
        self.currentIndex = currentIndex;
        self.slider.frame = [self sliderFrameForCurrentIndex];
    }];
}
@end
