//
//  NSNull+safe.m
//  进阶学习demo
//
//  Created by nyl on 2019/8/9.
//  Copyright © 2019 nieyinlong. All rights reserved.
//

#import "NSNull+safe.h"
#import <objc/message.h>
#define NSNullObjectsArr @[@"", @0, @{}, @[]]

@implementation NSNull (safe)

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        for (NSObject *obj in NSNullObjectsArr) {
            signature = [obj methodSignatureForSelector:aSelector];
            if (signature) {
                break;
            }
        }
    }
    return signature;
}
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    for (NSObject *objc in NSNullObjectsArr) {
        if ([objc respondsToSelector:anInvocation.selector]) {
            [anInvocation invokeWithTarget:objc];
            return;
        }
    }
}


@end
