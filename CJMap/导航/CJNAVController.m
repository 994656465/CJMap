//
//  CJNAVController.m
//  CJMap
//
//  Created by mac on 2020/6/11.
//  Copyright © 2020 SmartPig. All rights reserved.
//

#import "CJNAVController.h"
#import "MoreMenuView.h"
#import "SpeechSynthesizer.h"

@interface CJNAVController ()<AMapNaviDriveManagerDelegate,MoreMenuViewDelegate,AMapNaviDriveViewDelegate>
//驾车导航管理员
@property (nonatomic,strong)AMapNaviDriveManager *driveManager;
//驾车导航视图
@property (nonatomic,strong)AMapNaviDriveView *driveView;

@property (nonatomic, strong) MoreMenuView *moreMenu;//导航页面菜单选项
@end

@implementation CJNAVController
- (void)dealloc
{
    [[AMapNaviDriveManager sharedInstance] stopNavi];
    [[AMapNaviDriveManager sharedInstance] removeDataRepresentative:self.driveView];
    [[AMapNaviDriveManager sharedInstance] setDelegate:nil];
    
    BOOL success = [AMapNaviDriveManager destroyInstance];
    NSLog(@"单例是否销毁成功 : %d",success);
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initDriveManager];
    self.driveView = [[AMapNaviDriveView alloc] init];
    self.driveView.delegate = self;
    [self.view addSubview:self.driveView];
    [self.driveManager addDataRepresentative:self.driveView];
     [self.driveManager calculateDriveRouteWithStartPoints:@[self.startPoint] endPoints:@[self.endPoint]wayPoints:nil drivingStrategy:AMapNaviDrivingStrategyMultipleDefault];
    [self.driveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.top.mas_equalTo(NAVBARHEIGHT);
        make.bottom.mas_equalTo(0);
    }];
}
#pragma mark --初始化导航管理类对象
- (void)initDriveManager
{
    if (self.driveManager == nil)
    {
        self.driveManager = [AMapNaviDriveManager sharedInstance];
        self.driveManager.delegate = self;
    }
}

#pragma mark --初始化导航菜单键
- (void)initMoreMenu
{
    if (self.moreMenu == nil)
    {
        self.moreMenu = [[MoreMenuView alloc] init];
        self.moreMenu.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.moreMenu.delegate = self;
    }
}
#pragma mark --行车导航回调
-(void)driveManagerOnCalculateRouteSuccess:(AMapNaviDriveManager *)driveManager{
    [self initMoreMenu];
    //将driveView添加为导航数据的Representative，使其可以接收到导航诱导数据
    [self.driveManager addDataRepresentative:self.driveView];
    [driveManager startGPSNavi];
}
/**
 * @brief 驾车路径规划失败后的回调函数. 从5.3.0版本起,算路失败后导航SDK只对外通知算路失败,SDK内部不再执行停止导航的相关逻辑.因此,当算路失败后,不会收到 driveManager:updateNaviMode: 回调; AMapDriveManager.naviMode 不会切换到 AMapNaviModeNone 状态, 而是会保持在 AMapNaviModeGPS or AMapNaviModeEmulator 状态.
 * @param driveManager 驾车导航管理类
 * @param error 错误信息,error.code参照 AMapNaviCalcRouteState
 */
- (void)driveManager:(AMapNaviDriveManager *)driveManager onCalculateRouteFailure:(NSError *)error{
    NSLog(@"驾车路径规划失败%@",error);
}



-(void)driveViewCloseButtonClicked:(AMapNaviDriveView *)driveView{
    self.navigationController.navigationBar.hidden = NO;
    [self.driveManager stopNavi];
    [driveView removeFromSuperview];
    //停止语音
    [[SpeechSynthesizer sharedSpeechSynthesizer] stopSpeak];
}
- (BOOL)driveManagerIsNaviSoundPlaying:(AMapNaviDriveManager *)driveManager
{
    return [[SpeechSynthesizer sharedSpeechSynthesizer] isSpeaking];
}
- (void)driveManager:(AMapNaviDriveManager *)driveManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType
{
    NSLog(@"playNaviSoundString:{%ld:%@}", (long)soundStringType, soundString);

    [[SpeechSynthesizer sharedSpeechSynthesizer] speakString:soundString];
}
// 设置
- (void)driveViewMoreButtonClicked:(AMapNaviDriveView *)driveView
{
    
    //配置MoreMenu状态
    [self.moreMenu setTrackingMode:self.driveView.trackingMode];
//    [self.moreMenu setShowNightType:self.driveView.mapViewModeType];
    self.moreMenu.mapViewModeType =self.driveView.mapViewModeType;
    [self.moreMenu setFrame:self.view.bounds];
    [self.view addSubview:self.moreMenu];
}
- (void)driveViewTrunIndicatorViewTapped:(AMapNaviDriveView *)driveView
{
    if (self.driveView.showMode == AMapNaviDriveViewShowModeCarPositionLocked)
    {
        [self.driveView setShowMode:AMapNaviDriveViewShowModeNormal];
    }
    else if (self.driveView.showMode == AMapNaviDriveViewShowModeNormal)
    {
        [self.driveView setShowMode:AMapNaviDriveViewShowModeOverview];
    }
    else if (self.driveView.showMode == AMapNaviDriveViewShowModeOverview)
    {
        [self.driveView setShowMode:AMapNaviDriveViewShowModeCarPositionLocked];
    }
}
- (void)driveView:(AMapNaviDriveView *)driveView didChangeShowMode:(AMapNaviDriveViewShowMode)showMode
{
    NSLog(@"didChangeShowMode:%ld", (long)showMode);
}
#pragma mark - MoreMenu Delegate

- (void)moreMenuViewFinishButtonClicked
{
    [self.moreMenu removeFromSuperview];
}

- (void)moreMenuViewNightTypeChangeTo:(BOOL)isShowNightType
{
    if (isShowNightType) {
        self.driveView.mapViewModeType = AMapNaviViewMapModeTypeNight;
    }else{
        self.driveView.mapViewModeType = AMapNaviViewMapModeTypeDay;
    }

}

- (void)moreMenuViewTrackingModeChangeTo:(AMapNaviViewTrackingMode)trackingMode
{
    [self.driveView setTrackingMode:trackingMode];
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
