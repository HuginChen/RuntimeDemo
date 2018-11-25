//
//  ViewController.m
//  RuntimeDemo
//
//  Created by Hugin on 2018/11/2.
//  Copyright © 2018 Hugin. All rights reserved.
//

#import "ViewController.h"

// 1.主要的有：
// 定义了runtime的类型各方法，类型有：类、对象、方法、实例变量、属性、分类、协议等等;
// 方法前缀有：class_、objc_、object_、method_、sel_、imp_、ivar_、property_、protocol_
#import <objc/runtime.h>
// 定义了oc消息机制的一些方法：最主要的是objc_msgSend()
#import <objc/message.h>

// 2.次要的有：
// 主要定义了类型SEL和IMP以及一些相关方法等
#import <objc/objc.h>
// 平时经常使用的类NSObject和协议NSObject
#import <objc/NSObject.h>
// 对NSInteger和NSUInteger进行了定义;
// 在64位操作系统上： typedef long NSInteger; typedef unsigned long NSUInteger;
// 在32位操作系统上： typedef int NSInteger; typedef unsigned int NSUInteger;
#import <objc/NSObjCRuntime.h>

// 3.其他的有
#import <objc/objc-auto.h>      ///< 该头文件方法都被废除了！！！！！
#import <objc/objc-api.h>       ///< 一大堆宏定义，好像都不使用了
#import <objc/objc-exception.h> ///< 未知
#import <objc/objc-sync.h>      ///< 未知





// 下面的文件在ios项目中不会出现，在macos项目会出现
// #import <objc/objc-load.h>    未知
// #import <objc/Protocol.h>     这个头文件中的方法在1.0版本的runtime可以使用，2.0版本的话用objc/runtime.h头文件中的方法
// #import <objc/Object.h>       运行时object的一些方法，如初始化，创建，比较，内存管理等
// #import <objc/List.h>         好像没用到
// #import <objc/hashtable2.h>   该是方法查找相关的
// #import <objc/hashtable.h>    这个头文件导入了头文件 #include <objc/hashtable2.h>
// #import <objc/objc-runtime.h> 这个头文件导入了其他两个头文件#include <objc/runtime.h> 和 #include<objc/message.h>
// #import <objc/objc-class.h>   这个头文件导入了其他两个头文件#include <objc/runtime.h> 和 #include<objc/message.h>


@interface MyObject : NSObject
@end

@implementation MyObject
@end

@interface Person : MyObject {
    NSString *_sex;
}
@property (nonatomic, copy) NSString *name1;
@property (nonatomic, assign, getter = GetAge, getter = SetAge) int age;
@property (nonatomic, assign) double height;
@property (nonatomic, assign) double weight;
@property (nonatomic, strong) NSArray *sArray; // strong类型数组
@property (nonatomic, weak) NSArray *wArray;   // weak类型数组
@end

@interface Person (category)
@property (nonatomic, copy) NSString *name2;
@end

@implementation Person (category)
const void *name2_key;
- (void)setName2:(NSString *)name2 {
    objc_setAssociatedObject(self, name2_key, name2, OBJC_ASSOCIATION_COPY);
}
- (NSString *)name2 {
    return objc_getAssociatedObject(self, name2_key);
}
@end

@interface Person () {
    NSString *_name4;
}
@property (nonatomic, copy) NSString *name3;

@end

@implementation Person {
    NSString *_name5;
}
    
- (void)run {
    NSLog(@"Person run");
}
- (void)eat {
    NSLog(@"Person eat");
}
- (int)addCalculateWithNum1:(int)num1 num2:(int)num2 {
    NSLog(@"Person addCalculateWithNum1");
    return num1 + num2;
}
+ (void)swim {
    NSLog(@"Person swim");
}
    
@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    // TODO: 1.基本介绍
    {
        /*
         实例                                类                    元类
         instance of root class             root class(class)       root class(meta)
         instance of root SuperClass        Superclass(class)       Superclass(meta)
         instance of root Subclass          Subclass(class)         Subclass(meta)
         
         instance(实例)的isa指针指向这实例所属的class(class)(类)
         class(class)(类)的isa指针指向这个类所属的class(meta)(元类)
         
         class(meta)(元类)的isa指针指向root class(meta)(根元类)，即NSObject(metaclass)
         root class(meta)(根元类)的isa指针指向自己，即NSObject(metaclass)
         
         类的superclass指向这个类的父类，最终指向根类为NSObject(class)
         根类NSObject(class)的superclass为null
         
         元类的父类指向这个元类的父元类，最终指向根元类为NSObject(metaclass)
         根元类NSObject(metaclass)的父类为NSObject(class)
         
         null的isa和superclass可以理解为指向本身，即null
         */
        
        // 类的继承关系为：Person --- MyObject --- NSObject
        
        Class PersonClass = objc_getClass(class_getName([Person class]));
        Class PersonMetaClass = objc_getMetaClass(class_getName([Person class]));
        Class PersonSuperclass = class_getSuperclass(PersonClass);
        Class PersonMetaSuperclass = class_getSuperclass(PersonMetaClass);
        
        Class MyObjectClass = objc_getClass(class_getName([MyObject class]));
        Class MyObjectMetaClass = objc_getMetaClass(class_getName([MyObject class]));
        Class MyObjectSuperclass = class_getSuperclass(MyObjectClass);
        Class MyObjectMetaSuperclass = class_getSuperclass(MyObjectMetaClass);
        
        Class NSObjectClass = objc_getClass(class_getName([NSObject class]));
        Class NSObjectMetaClass = objc_getMetaClass(class_getName([NSObject class]));
        Class NSObjectSuperclass = class_getSuperclass(NSObjectClass);
        Class NSObjectMetaSuperclass = class_getSuperclass(NSObjectMetaClass);
        
        Class nullClass = objc_getClass(class_getName(NULL));
        Class nullMetaClass = objc_getMetaClass(class_getName(NULL));
        Class nullSuperclass = class_getSuperclass(nullClass);
        Class nullMetaSuperclass = class_getSuperclass(nullMetaClass);
        // null的父类和isa都是null，可以理解为指向本身，这样就形成了一个闭环
        NSLog(@"\n%@--%@--%@--%@\n%@--%@--%@--%@\n%@--%@--%@--%@\n%@--%@--%@--%@",
              PersonClass,   PersonMetaClass,   PersonSuperclass,   PersonMetaSuperclass,
              MyObjectClass, MyObjectMetaClass, MyObjectSuperclass, MyObjectMetaSuperclass,
              NSObjectClass, NSObjectMetaClass, NSObjectSuperclass, NSObjectMetaSuperclass,
              nullClass,     nullMetaClass,     nullSuperclass,     nullMetaSuperclass);
    }
    
    NSLog(@"---------------- 分隔线 ----------------\n\n");
    
    // TODO: 2.类相关
    {
        // 1.类的定义
        
        {
            /*
             每一个对象本质上都是一个类的实例，其中类定义了成员变量和成员方法的列表，对象通过对象的isa指针指向类。
             每一个类本质上都是一个对象，类其实是元类（meteClass）的实例，元类定义了类方法的列表，类通过类的isa指针指向元类。
             所有的元类最终继承一个根元类，根元类isa指针指向本身，形成一个封闭的内循环。
             */
            
            struct objc_object {
                Class isa;          ///< isa 对象的isa指针指向类，再通过类模板能够创建出实例变量、实例方法。
            };
            struct objc_class {
                /*
                 struct objc_classs结构体里存放的数据称为元数据(metadata)。
                 该结构体的第一个成员变量也是isa指针，这就说明了Class本身其实也是一个类对象，类对象在编译期产生用于创建实例对象。
                 类对象的isa指针指向元类(metaclass)，元类中保存了创建类对象以及类方法所需的所有信息。
                 */
                Class isa;          ///< isa Class的isa的指针, 指向meteClass(元类), 元类保存了类方法的列表
                Class super_class;  ///< 父类 如果该类已经是最顶层的根类, 那么它为NULL
                const char *name;   ///< 类的名称
                long version;       ///< 类的版本信息, 默认为0
                long info;          ///< 类的信息, 提供运行期使用的一些位标识
                long instance_size; ///< 类的实例大小
                struct objc_ivar_list *ivars;           ///< 实例变量列表
                struct objc_method_list **methodLists;  ///< 方法列表
                struct objc_cache *cache;               ///< 缓存
                struct objc_protocol_list *protocols;   ///< 协议列表
            };
            
            /// 指向类的指针.
            typedef struct objc_class *Class;
            /// 指向类实例的指针.
            typedef struct objc_object *id;
        }
        
        // 2.类相关的方法
        {
            // 2.1、获取父类 (2个方法)
            Class class_getSuperclass(Class cls);
            // NSObject + (Class)superclass;
            
            // 2.2、获取类的名称 (3个方法)
            const char * class_getName(Class cls);
            const char * object_getClassName(Class cls);
            NSString *NSStringFromClass(Class cls);
            
            // 2.3、类的版本(设置方法2个，获取方法2个)
            void class_setVersion(Class cls, int version);
            int class_getVersion(Class cls);
            
            // NSObject + (void)setVersion:(NSInteger)aVersion;
            // NSObject + (NSInteger)version;
            
            // 2.4、类的信息 暂无
            
            // 2.5、类的实例大小，单位为 bytes
            size_t class_getInstanceSize(Class cls);
            
            // 2.6、类的创建
            // 分配类或元类 啊了k
            Class objc_allocateClassPair(Class superclass, const char * name, size_t extraBytes);
            // 注册使用objc_allocateClassPair分配的类 屈叼si
            void objc_registerClassPair(Class cls);
            
            // 2.7、给类添加实例变量
            // 此函数只能在objc_allocateClassPair之后和objc_registerClassPair之前调用。不支持将实例变量添加到现有类。
            BOOL class_addIvar(Class cls, const char * name, size_t size, uint8_t alignment, const char * types);
            
            // 2.8、给类添加属性
            BOOL class_addProperty(Class cls, const char * name, const objc_property_attribute_t * attributes, unsigned int attributeCount);
            
            // 2.9、给类添加方法会覆盖超类的实现的，但不会替换此类中的现有实现，要更改现有实现要使用 method_setImplementation()
            BOOL class_addMethod(Class cls, SEL name, IMP imp, const char * types);
            
            // 2.9、给类添加协议
            BOOL class_addProtocol(Class cls, Protocol * protocol);
            
            // 2.10 获取指定类的元类的Class对象，如果该类未在Objective-C运行时注册，则为nil。
            id objc_getMetaClass(const char * name);
        }
 
    }
    
    // TODO: 3.实例变量
    {
        // 1.变量定义
        {
            struct objc_ivar {
                char * ivar_name; ///< 变量名
                char * ivar_type; ///< 变量编码类型
                int ivar_offset;  ///< 偏移量
                int space;        ///< 变量大小
            };
        }
        
        // 2.变量相关方法
        {
            // 2.1、获取实例变量名称
            const char * ivar_getName(Ivar v);
            
            // 2.2、获取实例变量的编码类型
            /*
             编码类型官方文档: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100
             一般可以通过@encode()获取编码类型
             */
            const char * ivar_getTypeEncoding(Ivar v);
            
            // 2.3、获取实例变量的偏移量，可以理解为对象的实例变量的索引，index * 8 (index > 0)
            ptrdiff_t ivar_getOffset(Ivar v);
            
            // 2.4、添加实例变量，只能在objc_allocateClassPair之后和objc_registerClassPair之前调用。不支持将实例变量添加到现有类。
            BOOL class_addIvar(Class cls, const char * name, size_t size, uint8_t alignment, const char * types);
            
            // 2.5、获取实例变量
            Ivar class_getInstanceVariable(Class cls, const char * name);
            
            // 2.6、获取实例变量列表
            Ivar * class_copyIvarList(Class cls, unsigned int * outCount);
            
            // 2.7、设置实例变量的值
            // 两者区别在于如果实例变量不是arc管理，那么前者是 __unsafe_unretainedr，后者是__strong
            void object_setIvar(id obj, Ivar ivar, id value);
            void object_setIvarWithStrongDefault(id obj, Ivar ivar, id value);
            
            // 2.8、获取实例变量的值
            id object_getIvar(id obj, Ivar ivar);
        }
        
        // 3.简单使用
        {
            unsigned int outCount;
            Ivar *ivars = class_copyIvarList([Person class], &outCount);
            for (int i = 0; i < outCount; i++) {
                Ivar ivar = ivars[i];
                const char * name = ivar_getName(ivar);
                const char * typeEncoding = ivar_getTypeEncoding(ivar);
                ptrdiff_t offset =ivar_getOffset(ivar);
                NSLog(@"变量名称：%s -- 编码类型：%s -- 偏移量：%td", name, typeEncoding, offset);
            }
        }
        NSLog(@"---------------- 分隔线 ----------------\n\n");
        // 4.使用演示
        {
            Person *person = [[Person alloc] init];
            
            // 获取实例变量
            Ivar sexIvar = class_getInstanceVariable([person class], "_sex");
            Ivar ageIvar = class_getInstanceVariable([person class], "_age");
            Ivar name1Ivar = class_getInstanceVariable([person class], "_name1");
            // _name2这个是通过分类添加关联属性的，所以为nil
            Ivar name2Ivar = class_getInstanceVariable([person class], "_name2");
            Ivar name3Ivar = class_getInstanceVariable([person class], "_name3");
            Ivar name4Ivar = class_getInstanceVariable([person class], "_name4");
            Ivar name5Ivar = class_getInstanceVariable([person class], "_name5");
            Ivar weightIvar = class_getInstanceVariable([person class], "_weight");
            Ivar heightIvar = class_getInstanceVariable([person class], "_height");
            
            // 设置实例变量的值
            object_setIvar(person, sexIvar, @"男");
            object_setIvar(person, ageIvar, @25);
            object_setIvar(person, name1Ivar, @"Jack1");
            object_setIvar(person, name2Ivar, @"Jack2");
            object_setIvar(person, name3Ivar, @"Jack3");
            object_setIvar(person, name4Ivar, @"Jack4");
            object_setIvar(person, name5Ivar, @"Jack5");
            object_setIvar(person, weightIvar, @170.0);
            object_setIvar(person, heightIvar, @177);
            
            
            unsigned int count = 0;
            Ivar * ivars = class_copyIvarList([Person class], &count);
            for (int i = 0; i < count; i++) {
                Ivar ivar = ivars[i];
                const char *name = ivar_getName(ivar);
                const char *encodingType = ivar_getTypeEncoding(ivar);
                ptrdiff_t offset = ivar_getOffset(ivar);
                id value = object_getIvar(person, ivar);
                NSLog(@"变量名称：%s -- 编码类型：%s -- 偏移量：%td -- 值为：%@", name, encodingType, offset, value);
            }
        }
    }
    
    NSLog(@"---------------- 分隔线 ----------------\n\n");
    
    // TODO: 4.属性相关
    {
        // 1.属性相关定义
        {
            // 属性定义
            typedef struct objc_property *objc_property_t;
            // 属性特性定义
            typedef struct {
                const char * _Nonnull name;  ///< 属性特性名称
                const char * _Nonnull value; ///< 属性特性的值（默认为空）
            } objc_property_attribute_t;
            /*
             官方文档: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH10
             属性的特性就是对属性的相关描述：
             1、属性的数据类型(T)，和Type Encodings相同;
             2、属性的原子性(N)，原子性(atomic)不显示，非原子性(nonatomic)显示N;
             3、属性的对应的实例变量名称(V)，_var;
             4、属性的内存管理(C,&,W)， copy策略显示C，retain策略显示&，weak策略显示W;
             5、属性的读写性(R)，读写(readwrite)不显示，只读(readonly)显示R;
             6、属性的setter(S)和getter(G)名称， 未设置不显示，设置的话显示设置的名称;
             7、属性的自动生成setter和getter方法(D), 未设置不显示，设置@dynamic显示D;
             8、属性的回收(P);
             9、属性的旧风格编码(t<encoding>);
             */
        }
        // 2.相关方法
        {
            // 2.1、获取属性名称
            const char * property_getName(objc_property_t property);
            
            // 2.2、获取属性特性1
            const char * property_getAttributes(objc_property_t property);
       
            // 2.3、获取属性特性值
            char * property_copyAttributeValue(objc_property_t property, const char * attributeName);
            
            // 2.4、获取属性特性列表
            objc_property_attribute_t * property_copyAttributeList(objc_property_t property, unsigned int * outCount);
            
            // 2.5、获取属性
            objc_property_t class_getProperty(Class cls, const char * name);
            
            // 2.6、获取属性列表
            objc_property_t * class_copyPropertyList(Class cls, unsigned int * outCount);
            
            // 2.7、设置属性的值和获取属性的值，通过关联属性的方式，属性可以理解为 setter getter 方法
            void objc_setAssociatedObject(id object, const void * key, id value, objc_AssociationPolicy policy);
            id objc_getAssociatedObject(id object, const void * key);
            
            // 2.8、创建属性 == 添加属性
            BOOL class_addProperty(Class cls, const char * name, const objc_property_attribute_t * attributes, unsigned int attributeCount);
            
            // 2.9、替换属性
            void class_replaceProperty(Class cls, const char * name, const objc_property_attribute_t * _Nullable attributes, unsigned int attributeCount);
        }
        // 3.相关代码
        {
            Person *person = [[Person alloc] init];
            person.name1 = @"Jack";
            person.name2 = @"Jack2";
            person.name3 = @"Jack3";
            person.age = 25;
            person.weight = 170.0;
            person.height = 177.0;
            
            unsigned int outCount = 0;
            objc_property_t *propertys = class_copyPropertyList([Person class], &outCount);
            for (int i = 0; i < outCount; i++) {
                objc_property_t property = propertys[i];
                const char * name = property_getName(property);
                const char * att = property_getAttributes(property);
                NSLog(@"属性名称：%s -- 属性特性：%s", name, att);
                unsigned int count = 0;
                objc_property_attribute_t *atts = property_copyAttributeList(property, &count);
                for (int i = 0; i < count; i++) {
                    objc_property_attribute_t att = atts[i];
                    char * value = property_copyAttributeValue(property, att.name);
                    // att.value == value
                    NSLog(@"属性特性 -- 名称:%s - 值:%s", att.name, value);
                }
                NSLog(@"\n");
            }
        }
    }
    NSLog(@"---------------- 分隔线 ----------------\n\n");
    
    // TODO: 5.方法相关
    {
        // 1.方法相关定义
        {
            typedef struct objc_method *Method;
            // 方法定义
            struct objc_method {
                SEL method_name;    ///< 方法名 SEL
                char * method_types; ///< 方法类型
                IMP method_imp;     ///< 方法实现 IMP
            };
            // 方法描述定义
            struct objc_method_description {
                SEL _Nullable name;     ///< 方法的名称
                char * _Nullable types; ///< 方法参数的类型
            };
        }
        
        // 2.相关方法
        {
            // 2.1、获取SEL
            SEL method_getName(Method m);
            
            // 2.2、获取IMP
            IMP method_getImplementation(Method m);
            
            // 2.3、设置方法的实现 返回之前的方法实现
            IMP method_setImplementation(Method m, IMP imp);
            
            // 2.4、获取类型编码
            const char * method_getTypeEncoding(Method m);
            
            // 2.5、获取参数数量
            unsigned int method_getNumberOfArguments(Method m);
            
            // 2.6、获取参数描述 一般使用前者，后者获取不了
            char * method_copyArgumentType(Method m, unsigned int index);
            void method_getArgumentType(Method m, unsigned int index, char * dst, size_t dst_len);
            
            // 2.7、获取返回值描述 一般使用前者，后者获取不了
            char * method_copyReturnType(Method m);
            void method_getReturnType(Method m, char * dst, size_t dst_len);
            
            // 2.8、获取方法的描述
            struct objc_method_description * method_getDescription(Method m);
            
            // 2.9、交换方法的实现
            void method_exchangeImplementations(Method m1, Method m2);
            
            // 2.10、调用指定方法的实现 这个方法比调用method_getImplementation和method_getName效率高
            id   method_invoke(id receiver, Method m, ...);
            void method_invoke_stret(id receiver, Method m, ...);
            
            // 2.11、创建SEL 4种
            SEL sel_getUid(const char * str);
            SEL sel_registerName(const char * str);
            SEL NSSelectorFromString(NSString * aSelectorName);
            // @selector();
            
            // 2.11、获取名称 2种
            const char * sel_getName(SEL sel);
            NSString * NSStringFromSelector(SEL aSelector);
            
            // 2.12、判断SEL是否相同
            BOOL sel_isEqual(SEL lhs, SEL rhs);
            
            // 2.13、判断SEL是否有效且具有函数实现
            BOOL sel_isMapped(SEL sel);
            
            // 2.14、返回与使用imp_implementationWithBlock创建的IMP关联的block
            id imp_getBlock(IMP anImp);
            
            // 2.15、通过block创建IMP
            IMP imp_implementationWithBlock(id block);
            
            // 2.16、将block与使用imp_implementationWithBlock创建的IMP解除关联，并释放已创建的block
            BOOL imp_removeBlock(IMP  anImp);
            
            // 2.17 获取类对应的IMP 这个方法效率高过 method_getImplementation
            IMP class_getMethodImplementation(Class cls, SEL name);
            IMP class_getMethodImplementation_stret(Class cls, SEL name);
            IMP class_lookupMethod(Class cls, SEL sel); // 方法作废使用前者
            
            // 2.18 获取方法列表 这个方法根据传入的类不同从而获取不同的方法列表
            // 类获取是实例方法列表; 元类获取到的是类方法列表;
            Method * class_copyMethodList(Class cls, unsigned int * outCount);
 
            // 2.19 获取实例方法
            Method class_getInstanceMethod(Class cls, SEL name);
            
            // 2.20 获取类方法
            Method class_getClassMethod(Class cls, SEL name);
            
            // 2.21 添加方法
            BOOL class_addMethod(Class cls, SEL name, IMP imp, const char * types);
            
            // 2.22 替换类的方法的实现，返回之前实现。
            // 如果方法存在相当于 method_setImplementation
            // 如果方法不存在，则添加它，相当于 class_addMethod
            IMP class_replaceMethod(Class cls, SEL name, IMP imp, const char * types);
            
            // 2.23 类是否实现特定方法
            BOOL class_respondsToSelector(Class cls, SEL sel);
            BOOL class_respondsToMethod(Class cls, SEL sel);   // 方法作废使用前者
        }
        
        // 3.简单使用
        {
            // 1.交换方法
            {
                // 方法1: 获取相应的方法Method，直接交换两个方法的实现
                {
                    Person *person = [[Person alloc] init];
                    [person run];
                    [person eat];
                    
                    Method runM = class_getInstanceMethod([person class], @selector(run));
                    Method eatM = class_getInstanceMethod([person class], @selector(eat));
                    method_exchangeImplementations(runM, eatM); //交换方法的实现
                    
                    [person run];
                    [person eat];
                }
                
                // 方法2: 获取相应的方法Method和实现IMP，设置方法的实现IMP
                {
                    Person *person = [[Person alloc] init];
                    [person run];
                    [person eat];
                    
                    Method runM = class_getInstanceMethod([person class], @selector(run));
                    Method eatM = class_getInstanceMethod([person class], @selector(eat));
                    
                    IMP rumIMP = method_getImplementation(runM);
                    IMP eatIMP = method_getImplementation(eatM);
    
                    method_setImplementation(runM, eatIMP);
                    method_setImplementation(eatM, rumIMP);
                    
                    [person run];
                    [person eat];
                }
            }
            
            // 2.获取方法列表
            {
                // 对比可以看到，class_copyMethodList方法根据传入的类不同从而获取不同的方法列表
                // 如果传入的是"类"，获取到的是"实例方法列表"
                // 如果传入的是"元类"，获取到的是"类方法列表"
                // 补充：方法列表指的是所有的方法，包含本类和分类的方法
                
                Person *person = [[Person alloc] init];
                person.name1 = @"Jack";
                person.age = 25;
                person.weight = 170.0;
                person.height = 177.0;
                
                // 1.获取实例方法列表
                {
                    unsigned int count = 0;
                    // 如果传入的是"类"，获取的是"实例方法列表"; 如果传入的是"元类"，获取的是"类方法列表";
                    Method *methods = class_copyMethodList([person class], &count);  // 获取所有的方法列表
                    for (int i = 0; i < count; i++) {
                        Method method = methods[i];
                        
                        SEL nameSel = method_getName(method);               // 方法名 SEL
                        const char *name = sel_getName(nameSel);            // 方法名 const char *
                        NSLog(@"方法名称：%s", name);
                        
                        IMP implement = method_getImplementation(method);   // 方法实现 IMP
                        NSLog(@"方法实现：%p", implement);
                        
                        const char *typeEncoding = method_getTypeEncoding(method);  // 方法参数和返回值
                        NSLog(@"方法的参数和返回值：%s", typeEncoding);
                        
                        unsigned int numberOfArguments = method_getNumberOfArguments(method); // 方法参数数量
                        NSLog(@"方法的参数数量：%d", numberOfArguments);
                        for (int j = 0; j < numberOfArguments; j++) {
                            char *describingTheTypeOfTheParameter = method_copyArgumentType(method, j); // 方法参数描述
                            NSLog(@"方法的参数描述：%s", describingTheTypeOfTheParameter);
                        }
                        
                        char *returnType = method_copyReturnType(method); // 方法返回值描述
                        NSLog(@"方法的返回值描述：%s", returnType);
                        
                        struct objc_method_description *methodDescription = method_getDescription(method);  //描述描述
                        SEL methodDescriptionName = methodDescription->name;
                        char *methodDescriptionTypes = methodDescription->types;
                        
                        NSLog(@"方法描述：-- 名称：%s -- 类型： %s", sel_getName(methodDescriptionName), methodDescriptionTypes);
                        
                        NSLog(@"\n");
                    }
                }
                NSLog(@"---------------- 分隔线 ----------------\n\n");
                // 2.获取类方法列表
                {
                    unsigned int count = 0;
                    // 如果传入的是"类"，获取的是"实例方法列表"; 如果传入的是"元类"，获取的是"类方法列表";
                    Method *methods = class_copyMethodList(objc_getMetaClass("Person"), &count);  // 获取所有的方法列表
                    for (int i = 0; i < count; i++) {
                        Method method = methods[i];
                        
                        SEL nameSel = method_getName(method);               // 方法名 SEL
                        const char *name = sel_getName(nameSel);            // 方法名 const char *
                        NSLog(@"方法名称：%s", name);
                        
                        IMP implement = method_getImplementation(method);   // 方法实现 IMP
                        NSLog(@"方法实现：%p", implement);
                        
                        const char *typeEncoding = method_getTypeEncoding(method);  // 方法参数和返回值
                        NSLog(@"方法的参数和返回值：%s", typeEncoding);
                        
                        unsigned int numberOfArguments = method_getNumberOfArguments(method); // 方法参数数量
                        NSLog(@"方法的参数数量：%d", numberOfArguments);
                        for (int j = 0; j < numberOfArguments; j++) {
                            char *describingTheTypeOfTheParameter = method_copyArgumentType(method, j); // 方法参数描述
                            NSLog(@"方法的参数描述：%s", describingTheTypeOfTheParameter);
                        }
                        
                        char *returnType = method_copyReturnType(method); // 方法返回值描述
                        NSLog(@"方法的返回值描述：%s", returnType);
                        
                        struct objc_method_description *methodDescription = method_getDescription(method);  //描述描述
                        SEL methodDescriptionName = methodDescription->name;
                        char *methodDescriptionTypes = methodDescription->types;
                        
                        NSLog(@"方法描述：-- 名称：%s -- 类型： %s", sel_getName(methodDescriptionName), methodDescriptionTypes);
                        
                        NSLog(@"\n");
                    }
                }
                NSLog(@"---------------- 分隔线 ----------------\n\n");
            }
            
           
        }
        
    }
    
    // TODO: 6.类的创建、给类添加实例变量、属性、方法
    {
        // 1 使用步骤
        // 1.1 objc_allocateClassPair
        // 1.2 class_addIvar class_addProperty class_addMethod class_addProtocol
        // 1.3 objc_registerClassPair
        
        // 2.代码
        {
            // 1.创建类 如果类的名称已经存在，会创建失败
            // 参数1 传需要继承的父类; 参数2 传类的名称; 参数3 默认传0;
            Class newClass = objc_allocateClassPair([NSObject class], "MyNewClass", 0);
            
            
            // 2.添加实例变量
            /*
             方法描述：
             1、类名称，不是元类！
             2、实例变量名称，添加下划线的，_ivar
             3、实例变量的大小，使用 sizeof(NSString *)   ---  sizeof(OC数据类型)
             4、alignment动态配置，传 log2(sizeof(pointer_type))  --- log2(sizeof(OC数据类型))
             5、实例变量的编码类型，使用 @encode(NSString *) 来获取  ---  @encode(OC数据类型)
             
             注意：
             1、这个方法在objc_allocateClassPair方法之后，objc_registerClassPair方法之前调用；添加一个实例变量到已经存在的类是不支持的；
             2、类不能是metaclass，把实例变量添加大metaclass是不支持的，实例变量只能添加到class中；
             3、alignment传递参数为：log2(sizeof(pointer_type))，代表是可以动态变化支持的
             */
            // 2.1、添加字符串
            if (class_addIvar(newClass, "_ivar1", sizeof(NSString *), log2(sizeof(NSString *)), @encode(NSString *))) {
                NSLog(@"添加实例变量成功!!!");
            } else {
                NSLog(@"添加实例变量失败!!!");
            }
            // 2.2、添加int
            if (class_addIvar(newClass, "_ivar2", sizeof(int), log2(sizeof(int)), @encode(int))) {
                NSLog(@"添加实例变量成功!!!");
            } else {
                NSLog(@"添加实例变量失败!!!");
            }
            
            unsigned int ivarCount = 0;
            Ivar *newIvars = class_copyIvarList(newClass, &ivarCount);
            for (int i = 0; i < ivarCount; i++) {
                Ivar ivar = newIvars[i];
                const char *name = ivar_getName(ivar);
                const char *typeEncoding = ivar_getTypeEncoding(ivar);
                NSLog(@"实例变量名称：%s - 实例变量编码类型：%s", name, typeEncoding);
                NSLog(@"-------- 分割线 --------");
            }
            
            // 3.添加属性
            objc_property_attribute_t typeAtt = {"T", @encode(NSString *)};
            objc_property_attribute_t atomicAtt = {"N", ""};
            objc_property_attribute_t varAtt = {"V", "_newPro"};
            objc_property_attribute_t memoryAtt = {"C", ""};
            objc_property_attribute_t readAtt = {"R", ""};
            objc_property_attribute_t setterAtt = {"S", "cusSetNewPro"};
            objc_property_attribute_t getterAtt = {"G", "cusGetNewPro"};
            objc_property_attribute_t atts[] = {typeAtt, atomicAtt, varAtt, memoryAtt, readAtt, setterAtt, getterAtt};
            
            if (class_addProperty(newClass, "newPro", atts, 7)) {
                NSLog(@"添加属性成功!!!");
            } else {
                NSLog(@"添加属性失败!!!");
            }
            
            unsigned int proCount = 0;
            objc_property_t *properties = class_copyPropertyList(newClass, &proCount); // 获取属性列表
            for (int i = 0; i < proCount; i++) {
                objc_property_t property = properties[i];
                const char *name = property_getName(property);      // 获取属性名称
                const char *att = property_getAttributes(property); // 获取属性对应的特性
                
                NSLog(@"属性名称：%s - 属性特性：%s", name, att);
                
                unsigned int count = 0;
                objc_property_attribute_t *atts = property_copyAttributeList(property, &count); // 获取属性特性列表
                
                for (int i = 0; i < count; i++) {
                    objc_property_attribute_t att = atts[i];
                    
                    char *value = property_copyAttributeValue(property, att.name); // 等价于att.value
                    
                    NSLog(@"属性特性 - 名称为：%s - 值为：%s -", att.name, value);
                    
                }
                NSLog(@"-------- 分割线 --------");
            }
            
            // 4.添加实例方法 添加到类的就是实例方法
            SEL methodSEL1 = sel_registerName("method1");
            IMP methodIMP1 = imp_implementationWithBlock(^(id obj, NSString *string){
                NSLog(@"%@", string);
            });
            if (class_addMethod(newClass, methodSEL1, methodIMP1, "@:@")) {
                NSLog(@"添加实例方法成功!!!");
            } else {
                NSLog(@"添加实例方法失败!!!");
            }
            
            unsigned int methodCount = 0;
            Method *methods = class_copyMethodList(newClass, &methodCount);
            for (int i = 0; i < methodCount; i++) {
                Method method = methods[i];
                SEL selName = method_getName(method);
                const char *name = sel_getName(selName);
                IMP imp = method_getImplementation(method);
                const char *typeEncoding = method_getTypeEncoding(method);
                
                NSLog(@"实例方法 - 名称：%s - 实现：%p - 类型编码：%s", name, imp, typeEncoding);
                NSLog(@"-------- 分割线 --------");
            }
            NSLog(@"\n");
        
            // 5.注册类
            objc_registerClassPair(newClass);
       
            // 6.添加类方法 添加到元类的就是类方法
            /*
             因为这里演示的代码是通过objc_allocateClassPair方法分配的Class，所以在调用objc_registerClassPair方法之前无法添加类方法。
             因为此时 Class还没有注册，所以在调用objc_getMetaClass获取时返回nil。
             */
            const char * newClassName = class_getName(newClass);
            id newMetaClass = objc_getMetaClass(newClassName);
            
            SEL methodSEL2 = sel_registerName("method2");
            IMP methodIMP2 = imp_implementationWithBlock(^(id obj, NSString *string){
                NSLog(@"%@", string);
            });
            if (class_addMethod(newMetaClass, methodSEL2, methodIMP2, "@:@")) {
                NSLog(@"添加类方法成功!!!");
            } else {
                NSLog(@"添加类方法失败!!!");
            }
            
            methodCount = 0;
            methods = class_copyMethodList(newMetaClass, &methodCount);
            for (int i = 0; i < methodCount; i++) {
                Method method = methods[i];
                SEL selName = method_getName(method);
                const char *name = sel_getName(selName);
                IMP imp = method_getImplementation(method);
                const char *typeEncoding = method_getTypeEncoding(method);
                
                NSLog(@"类方法 - 名称：%s - 实现：%p - 类型编码：%s", name, imp, typeEncoding);
                NSLog(@"-------- 分割线 --------");
            }
            
        }
    }
    
    [super viewDidLoad];
}

@end
