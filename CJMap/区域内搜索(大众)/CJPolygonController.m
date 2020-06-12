//
//  CJPolygonController.m
//  CJMap
//
//  Created by mac on 2020/6/11.
//  Copyright © 2020 SmartPig. All rights reserved.
//

#import "CJPolygonController.h"
#import "UIView+MJExtension.h"
#import "CJSearchPOIPointAnnotation.h"
#import "CJNAVController.h"

#define mapCenterOffset -10

@interface CJPolygonController ()<MAMapViewDelegate,AMapSearchDelegate>
@property (strong, nonatomic) MAMapView *mapView;  //地图
@property (strong, nonatomic) AMapSearchAPI *search;  // 地图内的搜索API类
@property (nonatomic)   CLLocationCoordinate2D leftTop;
@property (nonatomic)   CLLocationCoordinate2D rightBtm;
@property (nonatomic, strong)  NSMutableArray * searchResultArr;
@property (assign, nonatomic) CLLocationCoordinate2D annotationDesCoordinate;//选中的大头针经纬度
@property (nonatomic, assign)  CLLocationCoordinate2D  currentLocation;

@end

@implementation CJPolygonController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self initMapView];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor= [UIColor redColor];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50,50));
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(NAVBARHEIGHT);
    }];
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
    self.mapView.zoomLevel = 14;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    [self.view addSubview:self.mapView];
    self.search = [[AMapSearchAPI alloc] init];
     self.search.delegate = self;

}
//  MARK:delegate
//地图上的起始点，终点，拐点的标注，可以自定义图标展示等,只要有标注点需要显示，该回调就会被调用
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
      //  自己的位置
    if ([annotation isKindOfClass:[MAUserLocation class]]) {


       return nil;

    }else  if ([annotation isKindOfClass:[CJSearchPOIPointAnnotation class]] )
     {
          
         static NSString *tipIdentifier = @"ZZOilAnnotation";
         NSLog(@"annotation.title----%@",annotation.title);
         MAAnnotationView *poiAnnotationView = (MAAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:tipIdentifier];
         if (poiAnnotationView == nil)
         {
             poiAnnotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:tipIdentifier];
         }
         poiAnnotationView.canShowCallout= YES; //设置气泡可以弹出，默认为NO
         poiAnnotationView.selected = YES;  //设置标注动画显示，默认为NO
         poiAnnotationView.image = [UIImage imageNamed:@"map_local_oil1"];
         poiAnnotationView.centerOffset= CGPointMake(0, mapCenterOffset);
         [poiAnnotationView setSelected:YES animated:NO];
         
         //        点击大头针显示的右边视图
         UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
         rightButton.backgroundColor = [UIColor redColor];
         [rightButton setTitle:@"导航" forState:UIControlStateNormal];
         [rightButton addTarget:self action:@selector(navBtnClick) forControlEvents:UIControlEventTouchUpInside];
         poiAnnotationView.rightCalloutAccessoryView = rightButton;
         return poiAnnotationView;
     }
    
      return nil;

}

/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    [self.mapView removeAnnotations:self.searchResultArr];
    [self.searchResultArr removeAllObjects];
    if (response.pois.count == 0)
    {
        return;
    }
    
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 这里使用了自定义的坐标是为了区分系统坐标

      CJSearchPOIPointAnnotation *annotation = [[CJSearchPOIPointAnnotation alloc] init];
        [annotation setCoordinate:CLLocationCoordinate2DMake(obj.location.latitude, obj.location.longitude)];
        [annotation setTitle:[NSString stringWithFormat:@"%@", obj.name]];
//        [annotation setSubtitle:[NSString stringWithFormat:@"%zd米",obj.distance]];
        [annotation setSubtitle:@""];
        [self.searchResultArr addObject:annotation];
    }];
    // 向地图窗口添加一组标注
       [self.mapView addAnnotations:self.searchResultArr];
}
/**
 * @brief 地图区域改变完成后会调用此接口
 * @param mapView 地图View
 * @param animated 是否动画
 */
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
  CLLocationCoordinate2D leftTop  =   [mapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:self.view];
    self.leftTop = leftTop;
    CLLocationCoordinate2D rightBtm  =   [mapView convertPoint:CGPointMake(self.mapView.mj_w, self.mapView.mj_h) toCoordinateFromView:self.view];
    self.rightBtm = rightBtm;

}

/**
 * @brief 当选中一个annotation view时，调用此接口. 注意如果已经是选中状态，再次点击不会触发此回调。取消选中需调用-(void)deselectAnnotation:animated:
 * @param mapView 地图View
 * @param view 选中的annotation view
 */
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{
    NSLog(@"点击");
    self.annotationDesCoordinate = view.annotation.coordinate;
}
// 定位当前位置失败
- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error
{
    //定位错误
    NSLog(@"%s, amapLocationManager = %@, error = %@", __func__, [manager class], error);

}
// 定位当前位置成功
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location
{
    //定位结果
    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
    self.currentLocation = location.coordinate;


}

//  按钮click
-(void)buttonClick{
    NSLog(@"click");
    NSArray *points = [NSArray arrayWithObjects:
                       [AMapGeoPoint locationWithLatitude:self.leftTop.latitude longitude:self.leftTop.longitude],
                       [AMapGeoPoint locationWithLatitude:self.rightBtm.latitude longitude:self.rightBtm.longitude],
                       nil];
    AMapGeoPolygon *polygon = [AMapGeoPolygon polygonWithPoints:points];

    AMapPOIPolygonSearchRequest *request = [[AMapPOIPolygonSearchRequest alloc] init];

    request.polygon             = polygon;
    request.keywords            = @"餐饮";
    request.requireExtension    = YES;
    [self.search AMapPOIPolygonSearch:request];
}
-(void)navBtnClick{
    NSLog(@"点击导航");
    CJNAVController *  navVC = [[CJNAVController alloc]init];
    navVC.startPoint =  [AMapNaviPoint locationWithLatitude:self.currentLocation.latitude longitude:self.currentLocation.longitude];
    navVC.endPoint = [AMapNaviPoint locationWithLatitude:self.annotationDesCoordinate.latitude longitude:self.annotationDesCoordinate.longitude];
    [self.navigationController pushViewController:navVC animated:YES];
    
}
-(NSMutableArray *)searchResultArr{
    if (!_searchResultArr) {
        _searchResultArr = [NSMutableArray array];
    }
    return _searchResultArr;
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
