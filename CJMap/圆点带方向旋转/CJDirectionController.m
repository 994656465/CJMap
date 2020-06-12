//
//  CJDirectionController.m
//  CJMap
//
//  Created by mac on 2020/6/11.
//  Copyright © 2020 SmartPig. All rights reserved.
//

#import "CJDirectionController.h"

@interface CJDirectionController ()<MAMapViewDelegate>
@property (strong, nonatomic) MAMapView *mapView;  //地图
@property (nonatomic, strong)  MAAnnotationView * userLocationAnnotationView;

@end

@implementation CJDirectionController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
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
    [self.view addSubview:self.mapView];
    

}
#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    MAAnnotationView *view = views[0];
    
    // 放到该方法中用以保证userlocation的annotationView已经添加到地图上了。
    if ([view.annotation isKindOfClass:[MAUserLocation class]])
    {
        MAUserLocationRepresentation *pre = [[MAUserLocationRepresentation alloc] init];
        pre.showsAccuracyRing = NO;
        pre.image = [UIImage imageNamed:@"addOil_currentLocation"];
        [self.mapView updateUserLocationRepresentation:pre];
        view.calloutOffset = CGPointMake(0, 0);
        view.canShowCallout = NO;
        self.userLocationAnnotationView = view;
    }
}

/**
 * @brief 位置或者设备方向更新后，会调用此函数
 * @param mapView 地图View
 * @param userLocation 用户定位信息(包括位置与设备方向等数据)
 * @param updatingLocation 标示是否是location数据更新, YES:location数据更新 NO:heading数据更新
 */
 - (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    // 让定位箭头随着方向旋转
    if (!updatingLocation && self.userLocationAnnotationView != nil) {
        [UIView animateWithDuration:0.1 animations:^{
            double degree = userLocation.heading.trueHeading - self.mapView.rotationDegree;
            self.userLocationAnnotationView.transform = CGAffineTransformMakeRotation(degree * M_PI / 180.f);
        }];
    }
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
