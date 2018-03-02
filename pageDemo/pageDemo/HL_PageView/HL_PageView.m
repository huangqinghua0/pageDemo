//
//  HL_PageView.m
//  pageDemo
//
//  Created by zjht_macos on 2018/3/1.
//  Copyright © 2018年 zjht_macos. All rights reserved.
//

#import "HL_PageView.h"

@interface HL_PageView ()<UIPageViewControllerDelegate
, UIPageViewControllerDataSource , UIScrollViewDelegate>
{
    
    CGFloat _previousItemoffset;
    CGRect _previousItemFrame;
    //    BOOL _isClickItem;
    CGFloat _pageWidth , _pageHeight;
    CGFloat _norRed , _norGreen , _norBlue;
    CGFloat _selRed , _selGreen , _selBlue;
    UIColor *_titleNorColor , *_titleSelColor;
}

@property (nonatomic, strong) UIPageViewController *pageViewController;

@property (nonatomic, strong) UIScrollView *itemScrollView;

@property (nonatomic, strong) NSArray *titles;

@property (nonatomic, strong) NSArray *childControllers;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, assign) NSInteger willSelctedIndex;//拖拽时的下一个index

@property (nonatomic, strong) UIView *selLine;

@property (nonatomic, strong) UIButton *selectedButton;

@property (nonatomic, weak) UIScrollView *pageVcScrollView;

@property (nonatomic, assign) BOOL isClickItem;

@end
@implementation HL_PageView

- (instancetype)initWithFrame:(CGRect)frame superController:(UIViewController *)superController titles:(NSArray *)titles childControllers:(NSArray *)childControllers {
    self = [super initWithFrame:frame];
    if (self) {
        self.titles = titles;
        self.childControllers = childControllers;
        _pageWidth = frame.size.width;
        _pageHeight = frame.size.height;
        [superController addChildViewController:self.pageViewController];
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI {
    [self setUpScrollViewSubViews];
    [self addSubview:self.itemScrollView];
    [self addSubview:self.pageViewController.view];
    for (UIScrollView *scrollView in self.pageViewController.view.subviews) {
        if ([scrollView isKindOfClass:[UIScrollView class]]) {
            scrollView.delegate = self;
            self.pageVcScrollView = scrollView;
        }
    }
    self.selectedIndex = 0;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    UIViewController *vc = self.childControllers[self.selectedIndex];
    [self.pageViewController setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
}

#pragma mark - UIPageViewControllerDelegate

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSInteger index = [self.childControllers indexOfObject:viewController];
    self.selectedIndex = index;
    if (index == 0 ||( index == NSNotFound)) {
        return nil;
    }
    index--;
    return self.childControllers[index];
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSInteger index = [self.childControllers indexOfObject:viewController];
    self.selectedIndex = index;
    if (index == self.childControllers.count - 1 || index == NSNotFound) {
        return nil;
    }
    index++;
    return self.childControllers[index];
}

#pragma mark - UIPageViewControllerDataSource
//前一个控制器
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    
    UIViewController *nextVC = [pendingViewControllers firstObject];
    
    NSInteger index = [self.childControllers indexOfObject:nextVC];
    
    self.willSelctedIndex = index;
    if (ABS(self.willSelctedIndex - self.selectedIndex) >= 2) {//防止不松手拖拽
        self.selectedIndex = self.selectedIndex + self.willSelctedIndex - self.selectedIndex - 1;
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    NSInteger index  = [self.childControllers indexOfObject:pageViewController.viewControllers.firstObject];
    self.selectedIndex = index;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat contentOffsetX = ABS(scrollView.contentOffset.x - _pageWidth);
    if (contentOffsetX <= 0) return;
    CGFloat redOffset = _selRed - _norRed;
    CGFloat greenOffset = _selGreen - _norGreen;
    CGFloat blueOffset = _selBlue - _norBlue;
    CGFloat prograss = contentOffsetX / _pageWidth;
    UIButton *nextBtn = self.itemScrollView.subviews[self.willSelctedIndex];
    CGFloat lineWidthOffset = nextBtn.frame.size.width - _previousItemFrame.size.width;
    CGFloat lineXOffset = nextBtn.frame.origin.x - _previousItemFrame.origin.x;
    CGRect lineFrame = _previousItemFrame;
    CGFloat x = lineFrame.origin.x;
    CGFloat width = lineFrame.size.width;
    lineFrame.origin.x =  x + prograss *lineXOffset;
    lineFrame.size.width =  width + prograss *lineWidthOffset;
    [nextBtn setTitleColor:[[UIColor alloc] initWithRed:(_norRed + redOffset*prograss)/255.0 green:(_norGreen + greenOffset*prograss)/255.0 blue:(_norBlue + blueOffset*prograss)/255.0 alpha:1] forState:UIControlStateNormal];
    [self.selectedButton setTitleColor:[[UIColor alloc] initWithRed:(_selRed - redOffset*prograss)/255.0 green:(_selGreen - greenOffset*prograss)/255.0 blue:(_selBlue - blueOffset*prograss)/255.0 alpha:1] forState:UIControlStateNormal];
    
    CGFloat centerXOffset = nextBtn.center.x - _pageWidth/2.0;
    if (nextBtn.center.x  + _pageWidth/2.0 > self.itemScrollView.contentSize.width)
        centerXOffset = self.itemScrollView.contentSize.width - _pageWidth;//向后滚
    if (centerXOffset < 0) {//往回滚
        centerXOffset = 0;
    }
    [self.itemScrollView setContentOffset:CGPointMake(_previousItemoffset + (centerXOffset - _previousItemoffset )*prograss , 0)];
    self.selLine.frame = lineFrame;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (self.willSelctedIndex != self.selectedIndex && _isClickItem) {
        self.selectedIndex = self.willSelctedIndex;
    }
    self.isClickItem = NO;
}

#pragma mark - 自定义按钮

- (void)didClickItem:(UIButton *)item {
    if (self.pageVcScrollView.isDecelerating) return;
    self.isClickItem = YES;
    NSInteger index = item.tag;
    self.willSelctedIndex = index;
    NSInteger direction = index - self.selectedIndex;
    UIViewController *vc = self.childControllers[index];
    [self.pageViewController setViewControllers:@[vc] direction:direction < 0 animated:YES completion:nil];
}

#pragma mark - 私有方法

- (void)setUpScrollViewSubViews {
    
    CGFloat speaceW = 16;
    UIButton *previousBtn = nil;
    for (int i = 0; i < self.titles.count; ++i) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        [btn setTitle:self.titles[i] forState:UIControlStateNormal];
        [btn setTitleColor:self.titleNorColor forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [btn addTarget:self action:@selector(didClickItem:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0) {
            btn.frame = CGRectMake(10, 0, [self getTextWidthWithString:self.titles[i]], 41);
        }else {
            btn.frame = CGRectMake(CGRectGetMaxX(previousBtn.frame) + speaceW, 0, [self getTextWidthWithString:self.titles[i]], 41);
        }
        previousBtn = btn;
        [self.itemScrollView addSubview:btn];
    }
    [self.itemScrollView setContentSize:CGSizeMake(CGRectGetMaxX(previousBtn.frame) + 10, 0)];
}

- (CGFloat)getTextWidthWithString:(NSString *)string {
    return [string boundingRectWithSize:CGSizeMake(MAXFLOAT, 41) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName :[UIFont systemFontOfSize:15]} context:nil].size.width;
}

- (void)getColorRGBColor:(UIColor *)color IsSelColor:(BOOL)isSelColor {
    
    CGFloat r=0,g=0,b=0,a=0;
    if ([color respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [color getRed:&r green:&g blue:&b alpha:&a];
    }else {
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        r = components[0];
        g = components[1];
        b = components[2];
        a = components[3];
    }
    if (isSelColor) {
        _selRed = r*255.0 ;_selGreen =g*255.0 ;_selBlue = b*255.0;
    }else {
        _norRed = r*255.0 ;_norGreen = g*255.0 ;_norBlue = b*255.0;
    }
}

#pragma mark - get/set

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    [self.selectedButton setTitleColor:self.titleNorColor forState:UIControlStateNormal];
    UIButton *btn = self.itemScrollView.subviews[selectedIndex];
    [btn setTitleColor:self.titleSelColor forState:UIControlStateNormal];
    self.selLine.frame = CGRectMake(btn.frame.origin.x, 41, btn.frame.size.width, 3);
    self.selectedButton = btn;
    CGFloat centerXOffset = btn.center.x - _pageWidth/2.0;
    if (btn.center.x  + _pageWidth/2.0 > self.itemScrollView.contentSize.width) centerXOffset = self.itemScrollView.contentSize.width - _pageWidth;//向后滚
    if (centerXOffset < 0) {//往回滚
        centerXOffset = 0;
    }
    [self.itemScrollView setContentOffset:CGPointMake(centerXOffset , 0)];
    _previousItemoffset = self.itemScrollView.contentOffset.x;
    _previousItemFrame = self.selLine.frame;
}

- (void)setTitleNorColor:(UIColor *)titleNorColor {
    _titleNorColor = titleNorColor;
    for (UIButton *btn in self.itemScrollView.subviews) {
        if ([btn isKindOfClass:[UIButton class]]) {
            if (btn != self.selectedButton) [btn setTitleColor:self.titleNorColor forState:UIControlStateNormal];
        }
    }
    [self getColorRGBColor:titleNorColor IsSelColor:NO];
}

- (UIColor *)titleNorColor {
    if (_titleNorColor == nil) {
        UIColor *norColor = [UIColor grayColor];
        [self getColorRGBColor:norColor IsSelColor:NO];
        self.titleNorColor = norColor;
    }
    return _titleNorColor;
}

- (void)setTitleSelColor:(UIColor *)titleSelColor {
    _titleSelColor = titleSelColor;
    [self.selectedButton setTitleColor:titleSelColor forState:UIControlStateNormal];
    [self getColorRGBColor:titleSelColor IsSelColor:YES];
}

- (UIColor *)titleSelColor {
    if (_titleSelColor == nil) {
        UIColor *selColor = [UIColor blackColor];
        [self getColorRGBColor:selColor IsSelColor:YES];
        self.titleSelColor = selColor;
    }
    return _titleSelColor;
}

- (UIScrollView *)itemScrollView {
    if (_itemScrollView != nil) {
        return _itemScrollView;
    }
    _itemScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, _pageWidth, 44)];
    _itemScrollView.showsHorizontalScrollIndicator = NO;
    return _itemScrollView;
}

- (UIView *)selLine {
    if (_selLine != nil) {
        return _selLine;
    }
    _selLine = [[UIView alloc]initWithFrame:CGRectZero];
    _selLine.backgroundColor = [UIColor redColor];
    [self.itemScrollView addSubview:_selLine];
    return _selLine;
}

- (UIPageViewController *)pageViewController {
    if (_pageViewController != nil) {
        return _pageViewController;
    }
    //    NSDictionary *option = @{UIPageViewControllerOptionInterPageSpacingKey:@20};//页边距
    _pageViewController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    _pageViewController.view.frame = CGRectMake(0, 44, _pageWidth, _pageHeight - 44);
    _pageViewController.delegate = self;
    _pageViewController.dataSource = self;
    return _pageViewController;
}

- (void)setIsClickItem:(BOOL)isClickItem {
    _isClickItem = isClickItem;
    self.pageVcScrollView.scrollEnabled = !isClickItem;
}
@end

