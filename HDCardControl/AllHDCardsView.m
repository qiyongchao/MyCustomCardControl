//
//  AllHDCardsView.m
//  HDCardControl
//
//  Created by qiyongchao on 16/4/11.
//  Copyright © 2016年 qiyongchao. All rights reserved.
//

#import "AllHDCardsView.h"
#import "UIViewExt.h"

#define SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)  // 获取屏幕宽度、高度
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define RandomColor() [UIColor colorWithRed:arc4random() % 255 / 255.0 green:arc4random() % 255 / 255.0 blue:arc4random() % 255 / 255.0 alpha:1]

static const NSInteger kVisibleCardCount = 3;

static const NSInteger kMarginX = 20;
static const NSInteger kMarginY = 20;

static const NSInteger kSpaceX = 20;
static const NSInteger kSpaceY = 20;

static const float kAspectRatio = 0.75;//宽高比

static const float kDeleteRatio = 0.2;//当到达边缘0.2的时候，删除card


@interface AllHDCardsView()<UIDynamicAnimatorDelegate>

@property (nonatomic, strong) NSMutableArray *visibleCards;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) CGPoint touchBeganPoint;
@property (nonatomic, assign) CGPoint cardBeganPoint;


// UIDynamicAnimators
@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;//手指按住的力
@property (strong, nonatomic) UIGravityBehavior *gravityBehavior;//重力

@end

@implementation AllHDCardsView

+ (id)cardsView {
    AllHDCardsView *cardsView = [[[NSBundle mainBundle]loadNibNamed:@"AllHDCardsView" owner:self options:nil]lastObject];
    return cardsView;
}

- (void)resetCardsView {
    [self initCards];
}

- (void)setDataSource:(id<AllHDCardsViewDataSource>)dataSource {
    _dataSource = dataSource;
    [self initCards];
}

- (void)initCards {
    
    for (UIView *cardView in _visibleCards) {
        [cardView removeFromSuperview];
    }
    
    _currentIndex = 0;
    _visibleCards = [NSMutableArray array];
    
    for (int i=kVisibleCardCount-1; i>=0; i--) {
        UIView *cardView = [self nextCardView];
        if (!cardView) continue;
        cardView.frame = [self cardFrameWithIndex:i];
        [self insertSubview:cardView atIndex:0];
        [_visibleCards insertObject:cardView atIndex:0];
    }
    
    self.currentIndex = _visibleCards.count;
    self.topView = [_visibleCards lastObject];
    
}

#pragma mark - UIPanGestureRecognizer
- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint translation = [recognizer translationInView:self];
    CGPoint location = [recognizer locationInView:self];
    
    UIView *cardView = recognizer.view;
    
    if (self.topView != cardView) {
        return;
    }

    EHDCardViewEvent cardEvent = kCardViewEventMoving;

    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _cardBeganPoint = cardView.frame.origin;
        _touchBeganPoint = location;
    }

    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint movedPoint = CGPointMake(translation.x+_cardBeganPoint.x,
                                         translation.y+_cardBeganPoint.y);
        
        cardView.origin = movedPoint;
    }
    
    if(recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        [self.animator removeAllBehaviors];
        if (cardView.center.x < self.width * kDeleteRatio) {
            cardEvent = kCardViewEventMoveLeft;
        } else if (cardView.center.x > self.width * (1-kDeleteRatio)) {
            cardEvent = kCardViewEventMoveRight;
        } else if (cardView.center.y < self.height * kDeleteRatio) {
            cardEvent = kCardViewEventMoveTop;
        } else if (cardView.center.x > self.height * (1-kDeleteRatio)) {
            cardEvent = kCardViewEventMoveBottom;
        } else {
            cardEvent = kCardViewEventCancel;
        }
        
    }
    [self cardView:cardView event:cardEvent];
    [self.delegate cardView:self event:cardEvent];
    
}

- (UIView *)nextCardView {
    
    self.currentIndex++;
    
    UIView *nextView = nil;
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(nextViewForAllHDCardsView:cardIndex:)]) {
        nextView = [self.dataSource nextViewForAllHDCardsView:self cardIndex:self.currentIndex];
    }
    
    if (nextView) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [nextView addGestureRecognizer:pan];
    }
    
    nextView.backgroundColor = RandomColor();
    
    return nextView;
}

- (void)reloadAnimation {
    
    for (int i=0; i<_visibleCards.count; i++) {
        
        UIView *view = _visibleCards[i];
        
        if (i == _visibleCards.count-1) {
            
            [_visibleCards removeObject:view];
            [view removeFromSuperview];
            
            UIView *nextView = [self nextCardView];
            [_visibleCards insertObject:nextView atIndex:0];
            [self insertSubview:nextView atIndex:0];
            nextView.frame = [self cardFrameWithIndex:0];
            
        } else {
            
            [UIView animateWithDuration:0.2 delay:(_visibleCards.count-1-i)*0.1 options:UIViewAnimationOptionLayoutSubviews animations:^{
                
                view.frame = [self cardFrameWithIndex:i+1];
                
            } completion:nil];
            
        }
        
    }
    
    self.topView = [_visibleCards lastObject];
    
}

- (void)cardView:(UIView *)cardView event:(EHDCardViewEvent)event {
        
    if (event == kCardViewEventMoving) {
        
    } else if (event == kCardViewEventMoveLeft) {
        [self autoChangeCardToLeft];
    } else if (event == kCardViewEventMoveRight) {
        [self autoChangeCardToRight];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            cardView.origin = _cardBeganPoint;
        }];
    }
}

- (IBAction)autoChangeCardToRight {
    [UIView animateWithDuration:0.3 animations:^{
        CGAffineTransform translation = CGAffineTransformMakeTranslation(self.width/1.2f, 20);
        self.topView.transform = CGAffineTransformRotate(translation, M_PI_4/2.0f);
        
    } completion:^(BOOL finished) {
        [self reloadAnimation];
    }];
}

- (IBAction)autoChangeCardToLeft {
    [UIView animateWithDuration:0.3 animations:^{
        CGAffineTransform translation = CGAffineTransformMakeTranslation(-self.width/1.2f, 20);
        self.topView.transform = CGAffineTransformRotate(translation, -M_PI_4/2.0f);
        
    } completion:^(BOOL finished) {
        [self reloadAnimation];
    }];
}

//根据index获取位置
- (CGRect)cardFrameWithIndex:(NSInteger)index {
    
    float x = kMarginX+(kVisibleCardCount-1-index)*kSpaceX;
    float y = kMarginY+kSpaceY*index;
    float w = (self.width-x*2);
    float h = w/kAspectRatio;
    
    return CGRectMake(x, y, w, h);
    
}

@end
