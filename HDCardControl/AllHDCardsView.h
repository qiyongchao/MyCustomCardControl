//
//  AllHDCardsView.h
//  HDCardControl
//
//  Created by qiyongchao on 16/4/11.
//  Copyright © 2016年 qiyongchao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AllHDCardsView;

typedef NS_ENUM(NSInteger, EHDCardViewEvent) {
    kCardViewEventCancel,
    kCardViewEventMoveLeft,
    kCardViewEventMoveRight,
    kCardViewEventMoveTop,
    kCardViewEventMoveBottom,
    kCardViewEventMoving
};

@protocol AllHDCardsViewDataSource <NSObject>

- (UIView *)nextViewForAllHDCardsView:(AllHDCardsView *)cardsView cardIndex:(NSInteger)index;
@end

@protocol AllHDCardsViewDelegate <NSObject>

- (void)cardView:(UIView *)cardView event:(EHDCardViewEvent)event;

@end


@interface AllHDCardsView : UIView
@property (nonatomic, assign) id<AllHDCardsViewDataSource> dataSource;
@property (nonatomic, assign) id<AllHDCardsViewDelegate> delegate;
+ (id)cardsView;
- (void)resetCardsView;
@end
