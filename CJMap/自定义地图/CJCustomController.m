//
//  CJCustomController.m
//  CJMap
//
//  Created by mac on 2020/6/19.
//  Copyright © 2020 SmartPig. All rights reserved.
//

#import "CJCustomController.h"

@interface CJCustomController ()<MAMapViewDelegate>
@property (strong, nonatomic) MAMapView *mapView;  //地图

@end

@implementation CJCustomController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    // Do any additional setup after loading the view.
    
        [self initMapView];
}
//初始化地图,和搜索API
- (void)initMapView {
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    //  不支持旋转
    self.mapView.rotateEnabled = NO;
    //倾斜收拾
    self.mapView.rotateCameraEnabled = NO;
//    表示不显示比例尺
    self.mapView.showsScale= NO;
    ///如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
  
    //  自定义地图样式
    NSString *path =   [[NSBundle mainBundle] pathForResource:@"style" ofType:@"data"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSString *extrapath = [[NSBundle mainBundle] pathForResource:@"style_extra" ofType:@"data"];
    NSData *extradata = [NSData dataWithContentsOfFile:extrapath];
    MAMapCustomStyleOptions *options = [[MAMapCustomStyleOptions alloc] init];
//    options.styleId = @"74dcfe3a9ed7a2b181e7af11aea1ea9d";
    options.styleData = data;
    options.styleExtraData = extradata;
    [self.mapView setCustomMapStyleOptions:options];
    [self.mapView setCustomMapStyleEnabled:YES];

    [self.view addSubview:self.mapView];
    

}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
