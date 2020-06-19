//
//  ViewController.m
//  CJMap
//
//  Created by mac on 2020/6/11.
//  Copyright © 2020 SmartPig. All rights reserved.
//

#import "ViewController.h"
#import "CJLocationController.h"
#import "CJTrajectoryController.h"
#import "CJLocalImageController.h"
#import "CJDirectionController.h"
#import "CJPolygonController.h"
#import "CJGeocodingController.h"
#import "CJReGeocodeController.h"
#import "CJCustomController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)  NSArray * arr ;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.arr = @[@"当前位置",@"自定义圆点图",@"圆点带方向旋转",@"驾车路线轨迹",@"区域内搜索(大众)",@"地理编码(地址转坐标)",@"反地理编码(坐标转地址)",@"自定义地图样式"];
    UITableView * tableveiw = [[UITableView alloc]init];
    tableveiw.delegate = self;
    tableveiw.dataSource = self;
    [self.view addSubview:tableveiw];
    [tableveiw mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-TABBARSAFEAREAHEIGHT);
    }];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arr.count   ;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * cellIdentifier = @"cellID";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = self.arr[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
        {
            CJLocationController * locationVC = [[CJLocationController alloc]init];
            locationVC.title =self.arr[indexPath.row];
            [self.navigationController pushViewController:locationVC animated:YES];
        }
            break;
               case 1:
            {
                CJLocalImageController * locationVC = [[CJLocalImageController alloc]init];
                locationVC.title =self.arr[indexPath.row];
                [self.navigationController pushViewController:locationVC animated:YES];
            }
                break;
           case 2:
        {
            CJDirectionController * locationVC = [[CJDirectionController alloc]init];
            locationVC.title =self.arr[indexPath.row];
            [self.navigationController pushViewController:locationVC animated:YES];
        }
        break;
               case 3:
            {
                CJTrajectoryController * locationVC = [[CJTrajectoryController alloc]init];
                locationVC.title =self.arr[indexPath.row];
                [self.navigationController pushViewController:locationVC animated:YES];
            }
                break;
               case 4:
            {
                CJPolygonController * locationVC = [[CJPolygonController alloc]init];
                locationVC.title =self.arr[indexPath.row];
                [self.navigationController pushViewController:locationVC animated:YES];
            }
                break;

               case 5:
            {
                CJGeocodingController * locationVC = [[CJGeocodingController alloc]init];
                locationVC.title =self.arr[indexPath.row];
                [self.navigationController pushViewController:locationVC animated:YES];
            }
                break;
               case 6:
            {
                CJReGeocodeController * locationVC = [[CJReGeocodeController alloc]init];
                locationVC.title =self.arr[indexPath.row];
                [self.navigationController pushViewController:locationVC animated:YES];
            }
                break;
               case 7:
            {
                CJCustomController * locationVC = [[CJCustomController alloc]init];
                locationVC.title =self.arr[indexPath.row];
                [self.navigationController pushViewController:locationVC animated:YES];
            }
                break;

        default:
            break;
    }
}

@end

