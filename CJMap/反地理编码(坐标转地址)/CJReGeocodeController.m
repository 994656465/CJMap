//
//  CJReGeocodeController.m
//  CJMap
//
//  Created by mac on 2020/6/12.
//  Copyright © 2020 SmartPig. All rights reserved.
//

#import "CJReGeocodeController.h"

@interface CJReGeocodeController ()<MAMapViewDelegate,AMapSearchDelegate>
@property (nonatomic, strong)  MAMapView * mapView;
@property (nonatomic, strong)   UILabel * label;
@property (nonatomic, strong)  AMapSearchAPI * search;
@property (nonatomic, strong)  UILabel * address;

@end

@implementation CJReGeocodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    UILabel * label = [[UILabel alloc]init];
    label.backgroundColor = [UIColor whiteColor];

    label.textColor = [UIColor blackColor];
    label.layer.borderColor = [UIColor blackColor].CGColor;
    label.layer.borderWidth = 1.5;
    label.font = [UIFont systemFontOfSize:14];
    self.label = label;
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(-TABBARSAFEAREAHEIGHT);
    }];
    UILabel * address = [[UILabel alloc]init];
    address.backgroundColor = [UIColor whiteColor];
    address.textColor = [UIColor blackColor];
    address.layer.borderColor = [UIColor blackColor].CGColor;
    address.layer.borderWidth = 1.5;
    address.font = [UIFont systemFontOfSize:14];
    self.address = address;
    [self.view addSubview:address];
    [address mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(label.mas_top);
    }];
}

/**
 * @brief 单击地图回调，返回经纬度
 * @param mapView 地图View
 * @param coordinate 经纬度
 */
-(void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate{
    self.label.text = [NSString stringWithFormat:@"latitude=%f----longitude=%f",coordinate.latitude,coordinate.longitude];
    
//           MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
//            [annotation setCoordinate:CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)];
//            [annotation setSubtitle:@""];
//            [mapView addAnnotation:annotation];
    
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];

    regeo.location                    = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeo.requireExtension            = YES;
    [self.search AMapReGoecodeSearch:regeo];
}

/* 成功逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode != nil)
    {
        
 
        self.address.text =  response.regeocode.formattedAddress;
        MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
        [annotation setCoordinate:CLLocationCoordinate2DMake(request.location.latitude, request.location.longitude)];
        [annotation setTitle:response.regeocode.formattedAddress];
        [self.mapView addAnnotation:annotation];
    }
}
/*
 当检索失败时
 */
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorPurple;
        return annotationView;
    }
    return nil;
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
