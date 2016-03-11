//
//  FCXSafeCollection.m
//  Array
//
//  Created by 冯 传祥 on 15/10/16.
//  Copyright © 2015年 冯 传祥. All rights reserved.
//

#import "FCXSafeCollection.h"
#import <objc/runtime.h>
#import "NSObject+AOP.h"

/**
 使用了runtime技术解决项目中经常遇到的数组越界、字典键值对为空操作等闪退问题， 在Debug模式会在控制台输出相应的错误原因，并且不会导致程序闪退
*/

#if DEBUG
#define FCXSCLOG(...) fcxSafeCollectionLog(__VA_ARGS__)
#else
#define FCXSCLOG(...)
#endif


void fcxSafeCollectionLog(NSString *fmt, ...) NS_FORMAT_FUNCTION(1, 2);

void fcxSafeCollectionLog(NSString *fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    NSString *content = [[NSString alloc] initWithFormat:fmt arguments:ap];
    NSLog(@"***Terminating app due to uncaught exception\n");
    NSLog(@"***reason:-%@", content);
    va_end(ap);
    
    NSLog(@"*** First throw call stack:\n%@", [NSThread callStackSymbols]);
}



#pragma mark - NSArray

@interface NSArray (Safty)

@end

@implementation NSArray (Safty)

- (id)fcx_safeObjectAtIndex:(NSUInteger)index {
    
    if (self.count > index) {
        return [self fcx_safeObjectAtIndex:index];
    }else {
        
        FCXSCLOG(@"[%@ %@] index %lu beyond bounds [0 .. %lu]",
                 NSStringFromClass([self class]),
                 NSStringFromSelector(_cmd),
                 (unsigned long)index,
                 MAX((unsigned long)self.count - 1, 0));
        return nil;
    }
}

@end


//**************************************************************

#pragma mark - NSMutableArray

@interface NSMutableArray (Safty)

@end

@implementation NSMutableArray (Safty)

- (id)fcx_safeObjectAtIndex:(NSUInteger)index {
    if (self.count > index) {
        return [self fcx_safeObjectAtIndex:index];
    }else {
        
        FCXSCLOG(@"[%@ %@] index %lu beyond bounds [0 .. %lu]",
                 NSStringFromClass([self class]),
                 NSStringFromSelector(_cmd),
                 (unsigned long)index,
                 MAX((unsigned long)self.count - 1, 0));
        return nil;
    }
}

- (void)fcx_safeAddObject:(id)anObject {
    
    if (anObject) {
        [self fcx_safeAddObject:anObject];
    }else {
        FCXSCLOG(@"[%@ %@], nil object. object cannot be nil", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    }
}

- (void)fcx_safeReplaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    
    if (index >= self.count) {
        FCXSCLOG(@"[%@ %@] index %lu beyond bounds [0 .. %lu].",
                 NSStringFromClass([self class]),
                 NSStringFromSelector(_cmd),
                 (unsigned long)index,
                 MAX((unsigned long)self.count - 1, 0));
        return;
    }else if (!anObject) {
        FCXSCLOG(@"[%@ %@] nil object. object cannot be nil", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;
        
    }
    [self fcx_safeReplaceObjectAtIndex:index withObject:anObject];
}

- (void)fcx_safeInsertObject:(id)anObject atIndex:(NSUInteger)index {
    
    if (index > self.count)
    {
        FCXSCLOG(@"[%@ %@] index %lu beyond bounds [0...%lu].",
                 NSStringFromClass([self class]),
                 NSStringFromSelector(_cmd),
                 (unsigned long)index,
                 MAX((unsigned long)self.count - 1, 0));
        return;
    }
    
    if (!anObject)
    {
        FCXSCLOG(@"[%@ %@] nil object. object cannot be nil", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;
    }
    
    [self fcx_safeInsertObject:anObject atIndex:index];
}

@end


//**************************************************************

#pragma mark - NSDictionary

@interface NSDictionary (Safty)

@end

@implementation NSDictionary (Safty)


+ (instancetype)fcx_safeDictionaryWithObjects:(const id  _Nonnull __unsafe_unretained *)objects forKeys:(const id<NSCopying>  _Nonnull __unsafe_unretained *)keys count:(NSUInteger)cnt {
    
    id validObjects[cnt];
    id<NSCopying> validKeys[cnt];
    NSUInteger count = 0;
    for (NSUInteger i = 0; i < cnt; i++)
    {
        if (objects[i] && keys[i])
        {
            validObjects[count] = objects[i];
            validKeys[count] = keys[i];
            count ++;
        }
        else
        {
            FCXSCLOG(@"[%@ %@] NIL object or key at index{%lu}.",
                     NSStringFromClass(self),
                     NSStringFromSelector(_cmd),
                     (unsigned long)i);
        }
    }
    
    return [self fcx_safeDictionaryWithObjects:validObjects forKeys:validKeys count:count];
}


@end


//**************************************************************

#pragma mark - NSMuatbleDictionary

@interface NSMutableDictionary (Safty)

@end

@implementation NSMutableDictionary (Safty)

- (void)fcx_safeSetObject:(id)anObject forKey:(id<NSCopying>)aKey {
    
    if (!aKey)
    {
        FCXSCLOG(@"[%@ %@] nil key. key cannot be nil", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;
    }
    if (!anObject)
    {
        FCXSCLOG(@"[%@ %@] nil object. object cannot be nil", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        return;
    }
    [self fcx_safeSetObject:anObject forKey:aKey];
}

@end

//**************************************************************

@implementation FCXSafeCollection

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        //NSArray
        [self aop_ExchangeInstanceSelector:@selector(objectAtIndex:)  swizzledSelector:@selector(fcx_safeObjectAtIndex:) class:NSClassFromString(@"__NSArrayI")];
        
        
        //NSMutableArray
        [self aop_ExchangeInstanceSelector:@selector(objectAtIndex:)  swizzledSelector:@selector(fcx_safeObjectAtIndex:) class:NSClassFromString(@"__NSArrayM")];
        [self aop_ExchangeInstanceSelector:@selector(replaceObjectAtIndex:withObject:) swizzledSelector:@selector(fcx_safeReplaceObjectAtIndex:withObject:) class:NSClassFromString(@"__NSArrayM")];
        [self aop_ExchangeInstanceSelector:@selector(insertObject:atIndex:) swizzledSelector:@selector(fcx_safeInsertObject:atIndex:) class:NSClassFromString(@"__NSArrayM")];
        
        
        //NSDictionary
        [self aop_ExchangeClassSelector:@selector(dictionaryWithObjects:forKeys:count:) swizzledSelector:@selector(fcx_safeDictionaryWithObjects:forKeys:count:) class:[NSDictionary class]];
        
        
        //NSMutableDictionary
        [self aop_ExchangeInstanceSelector:@selector(setObject:forKey:) swizzledSelector:@selector(fcx_safeSetObject:forKey:) class:NSClassFromString(@"__NSDictionaryM")];
    });
}


@end


#pragma mark - KeyValueSafeCollections

@interface NSObject (FCXKeyValueSafetyCollections)

@end

@implementation NSObject (FCXKeyValueSafetyCollections)

//当对一个非类对象属性设置nil时，就会执行setNilValueForKey:方法,setNilValueForKey:方法的默认实现,是产生一个NSInvalidArgumentException的异常,但是你可以重写这个方法.
- (void)setNilValueForKey:(NSString *)key {
    
    FCXSCLOG(@"[%@ %@]: could not set nil as the value for the key %@.", NSStringFromClass([self class]), NSStringFromSelector(_cmd), key);
}

//如果没有对应的访问器方法(setter方法),如果接受者的类的+accessInstanceVariablesDirectly方法返回YES,那么就查找这个接受者的与key相匹配的实例变量(匹配模式为_<key>,_is<Key>,<key>,is<Key>):比如:key为age,只要属性存在_age,_isAge,age,isAge中的其中一个就认为匹配上了,如果找到这样的一个实例变量,并且的类型是一个对象指针类型,首先released对象上的旧值,然后把传入的新值retain后的传入的值赋值该成员变量,如果方法的参数类型是NSNumber或NSValue的对应的基本类型,先把它转换为基本数据类,再执行方法,传入转换后的数据.
//+ (BOOL)accessInstanceVariablesDirectly {
//    return YES;
//}

//对于数据模型中缺少的、不能与任何键配对的属性的时候，系统会自动调用setValue:forUndefinedKey:这个方法，该方法默认的实现会引发一个NSUndefinedKeyExceptiony异常,但是我们可以重写setValue:forUndefinedKey:方法让程序在运行过程中不引发任何异常信息且正常工作
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    FCXSCLOG(@"[%@ %@]: this class is not key value coding-compliant for the key %@.", NSStringFromClass([self class]), NSStringFromSelector(_cmd), key);
}

//通过valueForKey获取对象属性值的方法时，如果代码中的key值不存在，系统会自动调用valueForUndefinedKey:这个方法，该方法默认的实现会引发一个NSUndefinedKeyExceptiony异常,但是我们可以重写valueForUndefinedKey:方法让程序在运行过程中不引发任何异常信息且正常工作
/**
 *  通过valueForKey获取对象属性值的方法时，如果代码中的key值不存在，系统会自动调用valueForUndefinedKey:这个方法，该方法默认的实现会引发一个NSUndefinedKeyExceptiony异常,但是我们可以重写valueForUndefinedKey:方法让程序在运行过程中不引发任何异常信息且正常工作
 *
 *  @return nil
 *
 *  @notice 虽然这步可以返回nil不闪退，但是后续操作依然可能有问题
 */
- (id)valueForUndefinedKey:(NSString *)key {
    
    FCXSCLOG(@"[%@ %@]: this class is not key value coding-compliant for the key %@.", NSStringFromClass([self class]), NSStringFromSelector(_cmd), key);
    return nil;
}

@end
