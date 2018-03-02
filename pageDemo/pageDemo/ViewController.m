//
//  ViewController.m
//  pageDemo
//
//  Created by zjht_macos on 2018/2/28.
//  Copyright © 2018年 zjht_macos. All rights reserved.
//

#import "ViewController.h"
#import "HL_PageView.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()

@property (nonatomic, strong) NSArray *childViewControllersArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setUpUI];
}


- (void)setUpUI {
    HL_PageView *pageView = [[HL_PageView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64) superController:self titles:@[
                                                                                                                                                @"全部0",@"粉丝福利1",@"自驾游2",@"亲子互动3",@"投资理财4",@"演讲交流5",@"电影KTV6",@"摄影7",@"美食8",@"同城交友9",
                                                                                                                                                @"约炮10",@"有偿服务11",@"商业贷款12",@"裸贷们13",@"存金宝14",@"大染缸15",@"一点红16",@"碧螺春17",@"兴趣推荐18",@"还有更多吗19"] childControllers:self.childViewControllersArr];
    pageView.titleNorColor = [UIColor blueColor];
    pageView.titleSelColor = [UIColor purpleColor];
    [self.view addSubview:pageView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)childViewControllersArr {
    if (_childViewControllersArr != nil) {
        return _childViewControllersArr;
    }
    NSMutableArray *vcArr = [NSMutableArray array];
    for (int i = 0; i < 20; ++i) {
        UIViewController *vc = [UIViewController new];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(160, 160,30 , 30)];
        label.text = [NSString stringWithFormat:@"%d",i];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:26];
        [vc.view addSubview:label];
        vc.view.backgroundColor = [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
        [vcArr addObject:vc];
    }
    _childViewControllersArr = vcArr.copy;
    return _childViewControllersArr;
}


@end

