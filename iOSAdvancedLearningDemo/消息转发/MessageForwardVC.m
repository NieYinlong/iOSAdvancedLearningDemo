//
//  MessageForwardVC.m
//  进阶学习demo
//
//  Created by nyl on 2019/8/6.
//  Copyright © 2019 nieyinlong. All rights reserved.
//

#import "MessageForwardVC.h"
#import <objc/message.h>

#import "MessageForwardPerson.h"
#import "MessageForwardAnimal.h"

@interface MessageForwardVC ()

@end

@implementation MessageForwardVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    MessageForwardPerson *person = [MessageForwardPerson new];
    [self performSelector:@selector(testMethod)];
}


+ (BOOL)resolveInstanceMethod:(SEL)sel {
    NSLog(@"%s", __FUNCTION__);
    if (sel == @selector(testMethod)) {
        // 动态添加方法(dynamicMethod), 拯救了崩溃
        // (第1次拯救)
//          class_addMethod([self class], sel, (IMP)dynamicMethod, "v@:@");  // 打印  拯救了崩溃 dynamicMethod
    }
    return [super resolveInstanceMethod:sel];
}

- (id)forwardingTargetForSelector:(SEL)aSelector { // 快速消息转发, 指定备用接收者
    NSLog(@"%s", __FUNCTION__);
    if (aSelector == @selector(testMethod)) {
        // (第2次拯救)
//         return [MessageForwardAnimal new]; // MessageForwardAnimal.h 中没有声明testMethod方法, 但是.m中有testMethod方法即可
        // 打印  😁（MessageForwardAnimal） 我来实现, -[MessageForwardAnimal testMethod]
    }
    return [super forwardingTargetForSelector:aSelector];
}

//- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
//    NSLog(@"%s", __FUNCTION__);
//    if (aSelector == @selector(testMethod)) {
//        NSMethodSignature *methodSignature = [super methodSignatureForSelector:aSelector];
//        if (!methodSignature) {
//            if ([MessageForwardPerson instancesRespondToSelector:aSelector]) {
//                // (第3次拯救), 3次拯救失败就调用 doesNotRecognizeSelector:
//                methodSignature = [MessageForwardPerson instanceMethodSignatureForSelector:aSelector];
//            }
//            return methodSignature;
//        }
//    }
//    return [super methodSignatureForSelector:aSelector];
//}


// 同上
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSLog(@"%s", __FUNCTION__);
    if (aSelector == @selector(testMethod)) {
        // 手动生成签名
        return [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    return [super methodSignatureForSelector:aSelector];
}


// 拿到消息转发签名
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    NSLog(@"%s", __FUNCTION__);
    if (anInvocation.selector == @selector(testMethod)) {
        // 正常转发, MessageForwardAnimal来实现
//        MessageForwardPerson *object = [MessageForwardPerson new];
        MessageForwardAnimal *object = [MessageForwardAnimal new];
        if ([object respondsToSelector:anInvocation.selector]) {
            [anInvocation invokeWithTarget:object]; //  😁（MessageForwardAnimal） 我来实现, -[MessageForwardAnimal testMethod]
        }
    }
}

- (void)doesNotRecognizeSelector:(SEL)aSelector{
    NSString *selStr = NSStringFromSelector(aSelector);
    NSLog(@"%@不存在",selStr);
}



#pragma mark -

void dynamicMethod(id self, SEL _cmd) {
    NSLog(@"拯救了崩溃 %s", __FUNCTION__);
}


@end


