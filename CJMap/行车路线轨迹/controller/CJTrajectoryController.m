//
//  CJTrajectoryController.m
//  CJMap
//
//  Created by mac on 2020/6/11.
//  Copyright © 2020 SmartPig. All rights reserved.
//

#import "CJTrajectoryController.h"
#import "MANaviRoute.h"
#import "CommonUtility.h"
#define mapCenterOffset -10
#define routeLineWidth 5
#define lineStrategy  5
#define lineColor WT_RGBCOLOR(2, 201, 100)
static const NSInteger RoutePlanningPaddingEdge = 60;
static const NSString *RoutePlanningViewControllerStartTitle = @"起点";
static const NSString *RoutePlanningViewControllerDestinationTitle = @"终点";
@interface CJTrajectoryController ()<MAMapViewDelegate,AMapSearchDelegate,AMapNaviDriveManagerDelegate,AMapNaviDriveViewDelegate>
@property (strong, nonatomic) MAMapView *mapView;  //地图
@property (strong, nonatomic) AMapSearchAPI *search;  // 地图内的搜索API类
@property (strong, nonatomic) AMapRoute *route;  //路径规划信息
@property (strong, nonatomic) MANaviRoute * naviRoute;  //用于显示当前路线方案.
@property (assign, nonatomic) CLLocationCoordinate2D startCoordinate; //起始点经纬度
@property (assign, nonatomic) CLLocationCoordinate2D destinationCoordinate; //终点经纬度
@property (assign, nonatomic) NSUInteger totalRouteNums;  //总共规划的线路的条数
@property (assign, nonatomic) NSUInteger currentRouteIndex; //当前显示线路的索引值，从0开始
@property (strong, nonatomic) MAPointAnnotation *startAnnotation; // 初始位置大头针
@property (strong, nonatomic) MAPointAnnotation *destinationAnnotation;// 终点位置位置大头针
@property (assign, nonatomic) CLLocationCoordinate2D annotationDesCoordinate; //选中的大头针

@end

@implementation CJTrajectoryController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self initMapView];
     [self setUpData];
    [self addDefaultAnnotations];
       
     [self searchRoutePlanningDrive];  //驾车路线开始规划
}
//初始化地图,和搜索API
- (void)initMapView {
    self.mapView = [[MAMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    ///如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    [self.view addSubview:self.mapView];
    [self.view sendSubviewToBack:self.mapView];
    self.search = [[AMapSearchAPI alloc] init];
     self.search.delegate = self;

}
//初始化坐标数据
- (void)setUpData {
    //40.128435  116.60964  39.989631  116.481018  31.239600569585626  121.49975259796143
    
//  合肥  117.3415856298828  31.764618304158148
//    navi.origin = [AMapGeoPoint locationWithLatitude:40.128435
//                                           longitude:116.609645];
    self.startCoordinate = [self currectGpsWithLocation:CLLocationCoordinate2DMake(39.904413129820476, 116.39747132275389 )];
    self.destinationCoordinate = [self currectGpsWithLocation:CLLocationCoordinate2DMake(31.23958374257369 ,121.50012721035765)];

    
}
#pragma mark --地图纠偏
-(CLLocationCoordinate2D)currectGpsWithLocation:(CLLocationCoordinate2D)coor{
    CLLocationCoordinate2D gcjPt = [JZLocationConverter wgs84ToGcj02:coor];
    NSLog(@"%lf,%lf",gcjPt.latitude,gcjPt.longitude);
    return gcjPt;
}
//初始化或者规划失败后，设置view和数据为默认值
- (void)resetSearchResultAndXibViewsToDefault {
    self.totalRouteNums = 0;
    self.currentRouteIndex = 0;
    [self.naviRoute removeFromMapView];
}

//在地图上添加起始和终点的标注点
- (void)addDefaultAnnotations {
    MAPointAnnotation *startAnnotation = [[MAPointAnnotation alloc] init];
    startAnnotation.coordinate = self.startCoordinate;
    startAnnotation.title = (NSString *)RoutePlanningViewControllerStartTitle;
    startAnnotation.subtitle = [NSString stringWithFormat:@"{%f, %f}", self.startCoordinate.latitude, self.startCoordinate.longitude];
    self.startAnnotation = startAnnotation;
    
    MAPointAnnotation *destinationAnnotation = [[MAPointAnnotation alloc] init];
    destinationAnnotation.coordinate = self.destinationCoordinate;
    destinationAnnotation.title = (NSString *)RoutePlanningViewControllerDestinationTitle;
    destinationAnnotation.subtitle = [NSString stringWithFormat:@"{%f, %f}", self.destinationCoordinate.latitude, self.destinationCoordinate.longitude];
    self.destinationAnnotation = destinationAnnotation;
    [self.mapView addAnnotation:startAnnotation];
    [self.mapView addAnnotation:destinationAnnotation];
}
//驾车路线开始规划
- (void)searchRoutePlanningDrive {

    AMapDrivingRouteSearchRequest *navi = [[AMapDrivingRouteSearchRequest alloc] init];
       navi.requireExtension = YES;
       navi.strategy = 5; //驾车导航策略,5-多策略（同时使用速度优先、费用优先、距离优先三个策略）
       
       /* 出发点. */
       navi.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude
                                              longitude:self.startCoordinate.longitude];
       /* 目的地. */
       navi.destination = [AMapGeoPoint locationWithLatitude:self.destinationCoordinate.latitude
                                                   longitude:self.destinationCoordinate.longitude];
       
       [self.search AMapDrivingRouteSearch:navi];
}


#pragma mark - AMapSearchDelegate

//当路径规划搜索请求发生错误时，会调用代理的此方法
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
    [self resetSearchResultAndXibViewsToDefault];
}

//路径规划搜索完成回调.
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response {
    
    if (response.route == nil){
        [self resetSearchResultAndXibViewsToDefault];
        return;
    }
    
    self.route = response.route;
    
    self.totalRouteNums = self.route.paths.count;
    self.currentRouteIndex = 0;

    
    [self presentCurrentRouteCourse];
}

//在地图上显示当前选择的路径
- (void)presentCurrentRouteCourse {
    
    if (self.totalRouteNums <= 0) {
        return;
    }
    
    [self.naviRoute removeFromMapView];  //清空地图上已有的路线
    
    NSLog(@"%@", [NSString stringWithFormat:@"共%u条路线，当前显示第%u条",(unsigned)self.totalRouteNums,(unsigned)self.currentRouteIndex + 1]);  //提示信息
    
    MANaviAnnotationType type = MANaviAnnotationTypeDrive; //驾车类型
    
    AMapGeoPoint *startPoint = [AMapGeoPoint locationWithLatitude:self.startAnnotation.coordinate.latitude longitude:self.startAnnotation.coordinate.longitude]; //起点
    
    AMapGeoPoint *endPoint = [AMapGeoPoint locationWithLatitude:self.destinationAnnotation.coordinate.latitude longitude:self.destinationAnnotation.coordinate.longitude];  //终点
    
    //根据已经规划的路径，起点，终点，规划类型，是否显示实时路况，生成显示方案
    self.naviRoute = [MANaviRoute naviRouteForPath:self.route.paths[self.currentRouteIndex] withNaviType:type showTraffic:NO startPoint:startPoint endPoint:endPoint];
    
    [self.naviRoute addToMapView:self.mapView];  //显示到地图上
    
    UIEdgeInsets edgePaddingRect = UIEdgeInsetsMake(RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, RoutePlanningPaddingEdge, RoutePlanningPaddingEdge);
    
    //缩放地图使其适应polylines的展示
    [self.mapView setVisibleMapRect:[CommonUtility mapRectForOverlays:self.naviRoute.routePolylines]
                        edgePadding:edgePaddingRect
                           animated:NO];
}

#pragma mark - MAMapViewDelegate

//地图上覆盖物的渲染，可以设置路径线路的宽度，颜色等
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay {
    
    //虚线，如需要步行的
    if ([overlay isKindOfClass:[LineDashPolyline class]]) {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:((LineDashPolyline *)overlay).polyline];
        polylineRenderer.lineWidth = routeLineWidth;
        polylineRenderer.lineDashType = kMALineDashTypeDot;
        polylineRenderer.strokeColor = lineColor;
        
        return polylineRenderer;
    }
    
    //showTraffic为NO时，不需要带实时路况，路径为单一颜色，比如驾车线路目前为blueColor
    if ([overlay isKindOfClass:[MANaviPolyline class]]) {
        MANaviPolyline *naviPolyline = (MANaviPolyline *)overlay;
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:naviPolyline.polyline];
        
        polylineRenderer.lineWidth = routeLineWidth;
        
        if (naviPolyline.type == MANaviAnnotationTypeWalking) {
            polylineRenderer.strokeColor = self.naviRoute.walkingColor;
        } else if (naviPolyline.type == MANaviAnnotationTypeRailway) {
            polylineRenderer.strokeColor = self.naviRoute.railwayColor;
        } else {
            polylineRenderer.strokeColor = lineColor;
        }
        
        return polylineRenderer;
    }
    

    return nil;
}

//地图上的起始点，终点，拐点的标注，可以自定义图标展示等,只要有标注点需要显示，该回调就会被调用
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    
    
    
    
    //  自己的位置
    if ([annotation isKindOfClass:[MAUserLocation class]]) {

       return nil;

    }else{
           //标注的view的初始化和复用

                 static NSString *routePlanningCellIdentifier = @"RoutePlanningCellIdentifier";
                 
                 MAAnnotationView *poiAnnotationView = (MAAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:routePlanningCellIdentifier];
                 
                 if (poiAnnotationView == nil) {
                     poiAnnotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:routePlanningCellIdentifier];
                 }
         
                 poiAnnotationView.canShowCallout = YES;
                 poiAnnotationView.image = nil;
                    //起点，终点的图标标注
                     if ([[annotation title] isEqualToString:(NSString*)RoutePlanningViewControllerStartTitle]) {
                         poiAnnotationView.image = [UIImage imageNamed:@"map_local_startLocation"];  //起点
                         annotation.subtitle = @"";
                         annotation.title = @"起点";
                     }else if([[annotation title] isEqualToString:(NSString*)RoutePlanningViewControllerDestinationTitle]){
                         poiAnnotationView.image = [UIImage imageNamed:@"map_local_endLocation"];  //终点
                         annotation.subtitle = @"";
                         annotation.title = @"终点";
                         
                     }
                 poiAnnotationView.centerOffset= CGPointMake(0, mapCenterOffset);


                 return poiAnnotationView;
     }
    
      return nil;

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




//  MARK:点击事件

-(void)navBtnClick{
    NSLog(@"点击导航");
//    self.navigationController.navigationBar.hidden = YES;
//    NSLog(@"%lf---%lf",distinateCoor.latitude,distinateCoor.longitude);
    //初始化起点和终点
//    self.startPoint = [AMapNaviPoint locationWithLatitude:self.startAnnotation.coordinate.latitude longitude:self.startAnnotation.coordinate.longitude];
//    self.endPoint   = [AMapNaviPoint locationWithLatitude:self.annotationDesCoordinate.latitude longitude:self.annotationDesCoordinate.longitude];
//
//    [self initDriveManager];
//    self.driveView = [[AMapNaviDriveView alloc] init];
//    self.driveView.frame = self.view.frame;
//    self.driveView.delegate = self;
//    [self.view addSubview:self.driveView];
//    [self.driveManager addDataRepresentative:self.driveView];
    
    

//    AMapNaviVehicleInfo *info = [[AMapNaviVehicleInfo alloc] init];
//    info.vehicleId = @"京N66Y66"; //设置车牌号
//    info.type = 1;              //设置车辆类型,0:小车; 1:货车. 默认0(小车).
//    info.size = 4;              //设置货车的类型(大小)
//    info.width = 3;             //设置货车的宽度,范围:(0,5],单位：米
//    info.height = 3.9;          //设置货车的高度,范围:(0,10],单位：米
//    info.length = 15;           //设置货车的长度,范围:(0,25],单位：米
//    info.load = 50;             //设置货车的总重，即车重+核定载重,范围:(0,100],单位：吨
//    info.weight = 45;           //设置货车的核定载重,范围:(0,100),单位：吨
//    info.axisNums = 6;          //设置货车的轴数（用来计算过路费及限重）
//    [[AMapNaviDriveManager sharedInstance] setVehicleInfo:info];
//    [self.driveManager setVehicleInfo:info];
//    [self.driveManager calculateDriveRouteWithStartPoints:@[self.startPoint] endPoints:@[self.endPoint]wayPoints:nil drivingStrategy:AMapNaviDrivingStrategyMultipleDefault];
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
