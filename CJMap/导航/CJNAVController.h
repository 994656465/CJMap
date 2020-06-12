//
//  CJNAVController.h
//  CJMap
//
//  Created by mac on 2020/6/11.
//  Copyright © 2020 SmartPig. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CJNAVController : UIViewController
//导航起点
@property (nonatomic,strong)AMapNaviPoint *startPoint;
//导航终点
@property (nonatomic,strong) AMapNaviPoint *endPoint;
@end

NS_ASSUME_NONNULL_END
