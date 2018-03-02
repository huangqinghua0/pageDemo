//
//  HL_PageView.h
//  pageDemo
//
//  Created by zjht_macos on 2018/3/1.
//  Copyright © 2018年 zjht_macos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HL_PageView : UIView

///标签未选中的颜色  默认gray
@property (nonatomic, strong) UIColor *titleNorColor;
///标签选中的颜色 默认black
@property (nonatomic, strong) UIColor *titleSelColor;

/**
 创建pageView

 @param frame frame值
 @param superController 父控制器
 @param titles 标签数组
 @param childControllers 自控制器
 @return 返回pageView
 */
- (instancetype)initWithFrame:(CGRect)frame
                        superController:(UIViewController *)superController
                        titles:(NSArray *)titles
                        childControllers:(NSArray *)childControllers;
@end
