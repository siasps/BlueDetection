//
//  FJBaiduTool.m
//  FJDrugDetection
//
//  Created by peng on 2019/4/28.
//  Copyright © 2019 peng. All rights reserved.
//

#import "FJBaiduTool.h"

@implementation FJBaiduTool{
    // 默认的识别成功的回调
    void (^_successHandler)(id);
    // 默认的识别失败的回调
    void (^_failHandler)(NSError *);
}

+(void)initBaiduSDK{
    
    //    #error 【必须！】请在 ai.baidu.com中新建App, 绑定BundleId后，在此填写授权信息
    //    #error 【必须！】上传至AppStore前，请使用lipo移除AipBase.framework、AipOcrSdk.framework的模拟器架构，参考FAQ：ai.baidu.com/docs#/OCR-iOS-SDK/top
    //     授权方法1：在此处填写App的Api Key/Secret Key
    [[AipOcrService shardService] authWithAK:@"" andSK:@""];
}

-(instancetype)initWith:(id)delegate{
    
    self = [super init];
    if (self) {
        
        self.delegate = delegate;
        [self configCallback];
    }
    return self;
}

- (void)configCallback {
    __weak typeof(self) weakSelf = self;
    
    // 这是默认的识别成功的回调
    _successHandler = ^(id result){
        NSLog(@"%@", result);
        weakSelf.resultDict = result;
        NSString *title = @"识别结果";
        NSMutableString *message = [NSMutableString string];
        
        if(result[@"words_result"]){
            if([result[@"words_result"] isKindOfClass:[NSDictionary class]]){
                [result[@"words_result"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if([obj isKindOfClass:[NSDictionary class]] && [obj objectForKey:@"words"]){
                        [message appendFormat:@"%@: %@\n", key, obj[@"words"]];
                    }else{
                        [message appendFormat:@"%@: %@\n", key, obj];
                    }
                    
                }];
                
            }else if([result[@"words_result"] isKindOfClass:[NSArray class]]){
                for(NSDictionary *obj in result[@"words_result"]){
                    if([obj isKindOfClass:[NSDictionary class]] && [obj objectForKey:@"words"]){
                        [message appendFormat:@"%@\n", obj[@"words"]];
                    }else{
                        [message appendFormat:@"%@\n", obj];
                    }
                    
                }
            }
            
        }else{
            [message appendFormat:@"%@", result];
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:weakSelf cancelButtonTitle:@"信息无误，去检测" otherButtonTitles:nil];
            [alertView show];
            
//            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认无误，去检测" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//                if (weakSelf) {
//                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(collectWithResult:)]) {
//                        [weakSelf.delegate collectWithResult:result];
//                    }
//                }
//
//            }];
//            [alertVC addAction:action];
//            [weakSelf.delegate presentViewController:alertVC animated:YES completion:nil];
        }];
        
       
        
    };
    
    _failHandler = ^(NSError *error){
        NSLog(@"%@", error);
        NSString *msg = [NSString stringWithFormat:@"%li:%@", (long)[error code], [error localizedDescription]];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[[UIAlertView alloc] initWithTitle:@"识别失败" message:msg delegate:weakSelf cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
        }];
    };
}

- (void)cardOCROnlineFront:(UIViewController *)sendVC {
    
    UIViewController * vc =
    [AipCaptureCardVC ViewControllerWithCardType:CardTypeIdCardFont
                                 andImageHandler:^(UIImage *image) {
                                     
                                     [[AipOcrService shardService] detectIdCardFrontFromImage:image
                                                                                  withOptions:nil
                                                                               successHandler:_successHandler
                                                                                  failHandler:_failHandler];
                                 }];
    
    [sendVC presentViewController:vc animated:YES completion:nil];
    
    self.tempVC = vc;
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0){
    if (self.delegate && [self.delegate respondsToSelector:@selector(collectWithResult:)]) {
        [self.delegate collectWithResult:self.resultDict];
    }
    
    [self.tempVC dismissViewControllerAnimated:NO completion:nil];
}

@end
