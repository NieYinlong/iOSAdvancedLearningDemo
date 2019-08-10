//
//  MultithreadingVC.m
//  进阶学习demo
//
//  Created by nyl on 2019/8/9.
//  Copyright © 2019 nieyinlong. All rights reserved.
//

#import "MultithreadingVC.h"

@interface MultithreadingVC ()

@end

@implementation MultithreadingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
//    [self asyncAndConcurrent]; // 异步 + 并发
//    [self testDeadlock]; // 经典死锁
//    [self dispatchGroupNotify]; // 线程组
//    [self dispatchGroupWait];
//    [self groupEnterAndLeave];
    [self semaphoreSync];
}

#pragma mark - 异步 + 并发
- (void)asyncAndConcurrent {
    dispatch_queue_t queue = dispatch_queue_create("com.nyl", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 线程睡眠2秒, 模拟耗时操作
            NSLog(@"1 -- %@", [NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 线程睡眠2秒, 模拟耗时操作
            NSLog(@"2 -- %@", [NSThread currentThread]);
        }
    });
    /*
     2019-08-10 21:36:03.838942+0800 iOSAdvancedLearningDemo[2901:423038] 1 -- <NSThread: 0x600000590500>{number = 4, name = (null)}
     2019-08-10 21:36:03.838955+0800 iOSAdvancedLearningDemo[2901:423041] 2 -- <NSThread: 0x600000549680>{number = 3, name = (null)}
     2019-08-10 21:36:05.843703+0800 iOSAdvancedLearningDemo[2901:423041] 2 -- <NSThread: 0x600000549680>{number = 3, name = (null)}
     2019-08-10 21:36:05.843703+0800 iOSAdvancedLearningDemo[2901:423038] 1 -- <NSThread: 0x600000590500>{number = 4, name = (null)}
     */
    
    // 开启了两个子线程
}

#pragma mark - 经典死锁
- (void)testDeadlock {
    NSLog(@"test1");
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"test2");
    });
    NSLog(@"test3");
    
    /*
     以上代码只能打印test1, 发生了死锁;
     原因: testDeadlock是在同步操作队列里面的, 其内部也有dispatch_sync操作, 两个操作相互等待, 发生死锁
     */
}

#pragma mark - 线程组
- (void)dispatchGroupNotify {
    dispatch_group_t dispatchGroup = dispatch_group_create();
    
    dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:4]; // 线程睡眠
        
        NSLog(@"1. 第1个网络请求成功");
    });
    
    dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:1]; // 线程睡眠
        NSLog(@"2. 第2个网络请求成功");
    });
    
    dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:6]; // 线程睡眠
        NSLog(@"3. 第3个网络请求成功");
    });

    
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^{
        NSLog(@"3个网络请求全部完成");
    });
    
    // 依次打印
    /*
     2019-08-10 22:19:17.740184+0800 iOSAdvancedLearningDemo[3348:462543] 2. 第2个网络请求成功
     2019-08-10 22:19:20.738979+0800 iOSAdvancedLearningDemo[3348:462546] 1. 第1个网络请求成功
     2019-08-10 22:19:22.740009+0800 iOSAdvancedLearningDemo[3348:462544] 3. 第3个网络请求成功
     2019-08-10 22:19:22.740248+0800 iOSAdvancedLearningDemo[3348:462497] 3个网络请求全部完成

     */
}


- (void)dispatchGroupWait {
    dispatch_group_t dispatchGroup = dispatch_group_create();
    
    dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:4]; // 线程睡眠
        
        NSLog(@"1. 第1个网络请求成功");
    });
    
    dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:1]; // 线程睡眠
        NSLog(@"2. 第2个网络请求成功");
    });
    
    dispatch_group_async(dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:6]; // 线程睡眠
        NSLog(@"3. 第3个网络请求成功");
    });
    
    // dispatch_group_wait 等待上面的任务全部执行完毕, 会继续向下执行(线程阻塞)
    dispatch_group_wait(dispatchGroup, DISPATCH_TIME_FOREVER);/** 第1个参数线程组, 第2个参数超时时间(DISPATCH_TIME_FOREVER永不超时) */
    
    NSLog(@"全部执行成功");
    /*
     2019-08-10 22:34:15.997349+0800 iOSAdvancedLearningDemo[3472:474544] 2. 第2个网络请求成功
     2019-08-10 22:34:18.995982+0800 iOSAdvancedLearningDemo[3472:474410] 1. 第1个网络请求成功
     2019-08-10 22:34:20.997071+0800 iOSAdvancedLearningDemo[3472:474545] 3. 第3个网络请求成功
     2019-08-10 22:34:20.997333+0800 iOSAdvancedLearningDemo[3472:474275] 全部执行成功
     */
}

- (void)groupEnterAndLeave {
   
    dispatch_group_t dispatchGroup = dispatch_group_create();
    
    dispatch_group_enter(dispatchGroup);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:4]; // 线程睡眠
        NSLog(@"1. 第1个网络请求成功");
        dispatch_group_leave(dispatchGroup);
    });
    
    dispatch_group_enter(dispatchGroup);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:1]; // 线程睡眠
        NSLog(@"2. 第2个网络请求成功");
        dispatch_group_leave(dispatchGroup);
    });
    
    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^{
        NSLog(@"完成上面所有网络请求, 回到了主线程");
    });
    
    /*
     2019-08-10 23:17:45.698751+0800 iOSAdvancedLearningDemo[3847:507453] 2. 第2个网络请求成功
     2019-08-10 23:17:48.698024+0800 iOSAdvancedLearningDemo[3847:507452] 1. 第1个网络请求成功
     2019-08-10 23:17:50.698975+0800 iOSAdvancedLearningDemo[3847:507457] 3. 第3个网络请求成功
     2019-08-10 23:17:50.699212+0800 iOSAdvancedLearningDemo[3847:507329] 完成上面所有网络请求, 回到了主线程
     */
    
    /*
     总结:
        从dispatch_group_enter, dispatch_group_leave运行结果看出, 当所有任务完成之后, 才执行dispatch_group_notify中的任务. 这一点等同于dispatch_group_async
     调用了dispatch_group_enter, 必须有与之对应的dispatch_group_leave才行(跟引用计数类似), 如果缺少不是成对出现, 有可能造成内存泄露或者无法进入到dispatch_group_notify函数.
     
     例如:
        如果注释了其中的dispatch_group_enter(dispatchGroup), 会造成内存泄露, 如果注释了其中的一个dispatch_group_leave(dispatchGroup)则永远无法进入dispatch_group_notify函数
     */
    
}

#pragma mark - GCD信号量: dispatch_semaphore



/**
 * semaphore 线程同步
 */
- (void)semaphoreSync{
    NSLog(@"semaphore---begin");
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block int num = 0;
    dispatch_async(queue, ^{
        // 追加任务1
        [NSThread sleepForTimeInterval:2];
        NSLog(@"1---%@",[NSThread currentThread]);
        num = 200;
        dispatch_semaphore_signal(semaphore);
    });
    
    // 等待上面的异步操作执行完毕, 才会执行下面的NSLog代码
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"end,number = %d", num);
    
    /*
     2019-08-11 00:37:46.169351+0800 iOSAdvancedLearningDemo[4570:570595] semaphore---begin
     2019-08-11 00:37:48.173772+0800 iOSAdvancedLearningDemo[4570:570637] 1---<NSThread: 0x600003875a40>{number = 3, name = (null)}
     2019-08-11 00:37:48.174012+0800 iOSAdvancedLearningDemo[4570:570595] end,num = 200
     */
    
    /*
     总结:
     
     */
    
}

@end
