//
//  CJGeocodingController.m
//  CJMap
//
//  Created by mac on 2020/6/11.
//  Copyright © 2020 SmartPig. All rights reserved.
//

#import "CJGeocodingController.h"
#import "GeocodeAnnotation.h"
#import "CommonUtility.h"
@interface CJGeocodingController ()<MAMapViewDelegate,AMapSearchDelegate,UITextFieldDelegate>
@property (nonatomic, strong)  MAMapView * mapView;
@property (nonatomic, strong)  AMapSearchAPI * search;
@property (nonatomic, strong)  UITextField *    textField ;
@property (nonatomic, strong)  UILabel * label ;

@end

@implementation CJGeocodingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.mapView = [[MAMapView alloc] init];
       self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
       self.mapView.delegate = self;
       [self.view addSubview:self.mapView];
       
       self.search = [[AMapSearchAPI alloc] init];
       self.search.delegate = self;
    
    UITextField *    textField= [[UITextField alloc]init];
    self.textField = textField;
    textField.delegate = self;
    textField.layer.borderColor = [UIColor blackColor].CGColor;
    textField.layer.borderWidth = 1.5;
    textField.placeholder = @"请输入地址";
    textField.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    [self.view addSubview:textField];
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(NAVBARHEIGHT + 10);
        make.height.mas_equalTo(30);
    }];
    
    UILabel * label = [[UILabel alloc]init];
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
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(textField.mas_bottom);
        make.bottom.mas_equalTo(label.mas_top);
    }];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField endEditing:YES];
      return YES;;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
    geo.address = textField.text;
    [self.search AMapGeocodeSearch:geo];
}
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    if (response.geocodes.count == 0)
    {
        return;
    }
   
    NSMutableArray *annotations = [NSMutableArray array];
    
    [response.geocodes enumerateObjectsUsingBlock:^(AMapGeocode *obj, NSUInteger idx, BOOL *stop) {
        GeocodeAnnotation *geocodeAnnotation = [[GeocodeAnnotation alloc] initWithGeocode:obj];
        
        [annotations addObject:geocodeAnnotation];
        
        self.label.text = [NSString stringWithFormat:@"latitude=%f----longitude=%f",geocodeAnnotation.coordinate.latitude,geocodeAnnotation.coordinate.longitude];
    }];

    
    
    if (annotations.count == 1)
    {
        GeocodeAnnotation *geocodeAnnotation = annotations.firstObject;
        [self.mapView setCenterCoordinate:[geocodeAnnotation coordinate] animated:YES];
    }
    else
    {
        [self.mapView setVisibleMapRect:[CommonUtility minMapRectForAnnotations:annotations]
                               animated:YES];
    }
    
    [self.mapView addAnnotations:annotations];
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
