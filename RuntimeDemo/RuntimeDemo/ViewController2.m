//
//  ViewController2.m
//  RuntimeDemo
//
//  Created by Hugin on 2018/11/26.
//  Copyright © 2018 Hugin. All rights reserved.
//

#import "ViewController2.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <CoreFoundation/CoreFoundation.h>

@interface ViewController2 (Swizzling)

@end
@implementation ViewController2 (Swizzling) 
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method method1 = class_getInstanceMethod([self class], @selector(viewWillAppear:));
        Method method2 = class_getInstanceMethod([self class], @selector(swizzling_viewWillAppear:));
        
        BOOL didAddMethod = class_addMethod([self class],
                                            @selector(viewWillAppear:),
                                            method_getImplementation(method2),
                                            method_getTypeEncoding(method2));
        if (didAddMethod) {
            class_replaceMethod([self class],
                                @selector(swizzling_viewWillAppear:),
                                method_getImplementation(method1),
                                method_getTypeEncoding(method1));
        } else {
            method_exchangeImplementations(method1, method2);
        }
    });
}
- (void)swizzling_viewWillAppear:(BOOL)animated {
    NSLog(@"%@---", NSStringFromSelector(_cmd));
    [self swizzling_viewWillAppear:animated];
}
@end

@interface delegate : NSProxy
@end
@interface delegate ()
@end

@interface Diplomat : NSObject
@end
@implementation Diplomat
- (void)negotiate {
    NSLog(@"Diplomat negotiate -- self = %@ -- 地址 = %p", self, &self);
}
@end
@interface Warrior : NSObject
@property (nonatomic, strong) Diplomat *surrogate;
@end

@implementation Warrior {
    Diplomat *_surrogate;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _surrogate = [[Diplomat alloc] init];
    }
    return self;
}
- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return YES;
    } else {
        return [_surrogate respondsToSelector:aSelector];
    }
}
- (BOOL)isKindOfClass:(Class)aClass {
    if ([super isKindOfClass:aClass]) {
        return YES;
    } else {
        return [_surrogate isKindOfClass:aClass];
    }
}
- (id)forwardingTargetForSelector:(SEL)aSelector {
//    return nil;
    return _surrogate;
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
//    return [self methodSignatureForSelector:aSelector];
    return [_surrogate methodSignatureForSelector:aSelector];
}
- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([_surrogate respondsToSelector:[anInvocation selector]]) {
//        [anInvocation invokeWithTarget:_surrogate];
    }
}
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    return YES;
}
- (void)aaa {
    NSLog(@"aaa");
}
@end

@interface Student : NSObject
- (void)study:(NSString *)subject andRead:(NSString *)bookName;
- (void)study:(NSString *)subject :(NSString *)bookName;
@end
@implementation Student
    
- (void)study:(NSString *)subject :(NSString *)bookName
{
    NSLog(@"A--Invorking method on %@ object with selector %@",[self class],NSStringFromSelector(_cmd));
}

- (void)study:(NSString *)subject andRead:(NSString *)bookName
{
    NSLog(@"B--Invorking method on %@ object with selector %@",[self class],NSStringFromSelector(_cmd));
}
@end

@protocol Invoker <NSObject>
@required
// 在调用对象中的方法前执行对功能的横切
- (void)preInvoke:(NSInvocation *)inv withTarget:(id)target;
@optional
// 在调用对象中的方法后执行对功能的横切
- (void)postInvoke:(NSInvocation *)inv withTarget:(id)target;
@end

@interface AspectProxy : NSProxy
/** 通过NSProxy实例转发消息的真正对象 */
@property(strong) id proxyTarget;
/** 能够实现横切功能的类（遵守Invoker协议）的实例 */
@property(strong) id<Invoker> invoker;
/** 定义了哪些消息会调用横切功能 */
@property(readonly) NSMutableArray *selectors;
// AspectProxy类实例的初始化方法
- (id)initWithObject:(id)object andInvoker:(id<Invoker>)invoker;
- (id)initWithObject:(id)object selectors:(NSArray *)selectors andInvoker:(id<Invoker>)invoker;
// 向当前的选择器列表中添加选择器
- (void)registerSelector:(SEL)selector;
@end

@implementation AspectProxy
- (id)initWithObject:(id)object selectors:(NSArray *)selectors andInvoker:(id<Invoker>)invoker{
    _proxyTarget = object;
    _invoker = invoker;
    _selectors = [selectors mutableCopy];
    
    return self;
}
- (id)initWithObject:(id)object andInvoker:(id<Invoker>)invoker{
    return [self initWithObject:object selectors:nil andInvoker:invoker];
}
// 添加另外一个选择器
- (void)registerSelector:(SEL)selector{
    NSValue *selValue = [NSValue valueWithPointer:selector];
    [self.selectors addObject:selValue];
}
// 为目标对象中被调用的方法返回一个NSMethodSignature实例
// 运行时系统要求在执行标准转发时实现这个方法
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    NSMethodSignature *singatureM = [self.proxyTarget methodSignatureForSelector:sel];
    NSLog(@"selector:%@ - %@", NSStringFromSelector(sel), singatureM);
    if (singatureM) {
        return singatureM;
    }
    
    return nil;
}
/**
 *  当调用目标方法的选择器与在AspectProxy对象中注册的选择器匹配时，forwardInvocation:会
 *  调用目标对象中的方法，并根据条件语句的判断结果调用AOP（面向切面编程）功能
 */
- (void)forwardInvocation:(NSInvocation *)invocation {
    // 在调用目标方法前执行横切功能
    if ([self.invoker respondsToSelector:@selector(preInvoke:withTarget:)]) {
        if (self.selectors != nil) {
            SEL methodSel = [invocation selector];
            for (NSValue *selValue in self.selectors) {
                if (methodSel == [selValue pointerValue]) {
                    [[self invoker] preInvoke:invocation withTarget:self.proxyTarget];
                    break;
                }
            }
        }else{
            [[self invoker] preInvoke:invocation withTarget:self.proxyTarget];
        }
    }
    
    // 调用目标方法
    [invocation invokeWithTarget:self.proxyTarget];
    
    // 在调用目标方法后执行横切功能
    if ([self.invoker respondsToSelector:@selector(postInvoke:withTarget:)]) {
        if (self.selectors != nil) {
            SEL methodSel = [invocation selector];
            for (NSValue *selValue in self.selectors) {
                if (methodSel == [selValue pointerValue]) {
                    [[self invoker] postInvoke:invocation withTarget:self.proxyTarget];
                    break;
                }
            }
        }else{
            [[self invoker] postInvoke:invocation withTarget:self.proxyTarget];
        }
    }
}
@end

@interface AuditingInvoker : NSObject<Invoker>//遵守Invoker协议
@end
@implementation AuditingInvoker
- (void)preInvoke:(NSInvocation *)inv withTarget:(id)target{
    NSLog(@"before sending message with selector %@ to %s object", NSStringFromSelector([inv selector]),object_getClassName(target));
}
- (void)postInvoke:(NSInvocation *)inv withTarget:(id)target{
    NSLog(@"after sending message with selector %@ to %s object", NSStringFromSelector([inv selector]),object_getClassName(target));
    
}
@end

@interface ViewController2 ()
@property (nonatomic, copy) NSString *str;
@end

@implementation ViewController2 {
    Warrior *_warrior;
}
@synthesize str = _str;
//@dynamic str;
- (void)setStr:(NSString *)str {
    _str = str;
}
- (NSString *)str {
    return _str;
}
- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"-----");
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableString *a = [NSMutableString stringWithString:@"Tom"];
    NSString *b = @"aaa";
    int c = 1;
    NSLog(@"block以前：a指向的堆中地址：%p；a在栈中的指针地址：%p", a, &a);               //a在栈区
    NSLog(@"block以前：b指向的堆中地址：%p；b在栈中的指针地址：%p", b, &b);               //a在栈区
    NSLog(@"block以前：c指向的堆中地址：%d；c在栈中的指针地址：%p", c, &c);               //a在栈区
 
    void (^foo)(void) = ^{
        NSLog(@"block内部：a指向的堆中地址：%p；a在栈中的指针地址：%p", a, &a);
        NSLog(@"block内部：b指向的堆中地址：%p；b在栈中的指针地址：%p", b, &b);
        NSLog(@"block内部：c指向的堆中地址：%d；c在栈中的指针地址：%p", c, &c);
        // a = [NSMutableString stringWithString:@"William"];
    };
    foo();
    NSLog(@"block以后：a指向的堆中地址：%p；a在栈中的指针地址：%p", a, &a);               //a在栈区
    NSLog(@"block以后：b指向的堆中地址：%p；b在栈中的指针地址：%p", b, &b);               //a在栈区
    NSLog(@"block以后：c指向的堆中地址：%d；c在栈中的指针地址：%p", c, &c);               //a在栈区
    NSLog(@"");
    
    id student = [[Student alloc] init];

    // 设置代理中注册的选择器数组
    NSValue *selValue1 = [NSValue valueWithPointer:@selector(study:andRead:)];
    NSArray *selValues = @[selValue1];
    // 创建AuditingInvoker
    AuditingInvoker *invoker = [[AuditingInvoker alloc] init];
    // 创建Student对象的代理studentProxy
    id studentProxy = [[AspectProxy alloc] initWithObject:student selectors:selValues andInvoker:invoker];

    // 使用指定的选择器向该代理发送消息---例子1
    [studentProxy study:@"Computer" andRead:@"Algorithm"];

    // 使用还未注册到代理中的其他选择器，向这个代理发送消息！---例子2
    [studentProxy study:@"mathematics" :@"higher mathematics"];

    // 为这个代理注册一个选择器并再次向其发送消息---例子3
    [studentProxy registerSelector:@selector(study::)];
    [studentProxy study:@"mathematics" :@"higher mathematics"];

    
    Warrior *warrior = [[Warrior alloc] init];
    _warrior = warrior;
    BOOL res1 = [warrior isKindOfClass:[Diplomat class]];
    BOOL res2 = [warrior respondsToSelector:@selector(negotiate)];
    NSLog(@"%d - %d", res1, res2);
    [(id)_warrior negotiate];
    [(id)_warrior aaa];
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view snapshotViewAfterScreenUpdates:YES];
    [[UIApplication sharedApplication].keyWindow.screen snapshotViewAfterScreenUpdates:YES];
}
@end
