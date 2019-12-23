//
//  FJBaiduTool.h
//  FJDrugDetection
//
//  Created by peng on 2019/4/28.
//  Copyright © 2019 peng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <AipOcrSdk/AipOcrSdk.h>

NS_ASSUME_NONNULL_BEGIN

@interface FJBaiduTool : NSObject

@property (nonatomic ,weak) id delegate;

@property (nonatomic ,strong) NSDictionary *resultDict;

@property (nonatomic ,strong) UIViewController *tempVC;

+(void)initBaiduSDK;

-(instancetype)initWith:(id)delegate;

- (void)cardOCROnlineFront:(UIViewController *)sendVC;

@end

@protocol FJBaiduToolDelegate <NSObject>

-(void)collectWithResult:(NSDictionary *)resultDict;

@end

NS_ASSUME_NONNULL_END
