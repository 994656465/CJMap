
//
//  CJMapHeader.h
//  CJMap
//
//  Created by mac on 2020/6/11.
//  Copyright © 2020 SmartPig. All rights reserved.
//

#ifndef CJMapHeader_h
#define CJMapHeader_h
#define MapKey @"59fbec5493ff4382ab51c94f26fdfdc5"

#define kIsiPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size)||CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size)||CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size): NO)


//  颜色宏
#define WT_RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define WT_RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]
#define WT_RGBA(r,g,b,a) (r)/255.0f, (g)/255.0f, (b)/255.0f, (a)
#define WT_RGBColor(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define CJRandomColor [UIColor colorWithRed:arc4random_uniform(256) / 255.0 green:arc4random_uniform(256) / 255.0 blue:arc4random_uniform(256) / 255.0 alpha:1]



//  高度
#define STATUSHEIGHT       ((kIsiPhoneX)?44.0f:20.0f)
#define NAVBARHEIGHT       ((kIsiPhoneX)?88.0f:64.0f)
#define TABBARHEIGHT       ((kIsiPhoneX)?83.0f:49.0f)
#define TABBARSAFEAREAHEIGHT  ((kIsiPhoneX)?34.0f:0.0f)
#define kUIScreenWidth       [UIScreen mainScreen].bounds.size.width
#define kUIScreenHeigth      [UIScreen mainScreen].bounds.size.height
#endif /* CJMapHeader_h */
