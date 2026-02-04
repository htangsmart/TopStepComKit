//
//  NSObject+TSObject.m
//  TSFoundation
//
//  Created by luigi on 2024/7/15.
//

#import "NSObject+TSObject.h"
#import "objc/runtime.h"

@implementation NSObject (TSObject)

+ (void)copyPropertyFrom:(id)object to:(id)newObject {

    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([newObject class], &count);
    for (int i = 0; i<count; i++) {
        objc_property_t property = properties[i];
        const char *name = property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:name];
        id value = [object valueForKey:propertyName];
        if (value) {
            [newObject setValue:[value isKindOfClass:[NSObject class]] ? [value copy] : value forKey:propertyName];
        }
    }
    free(properties);
}

@end
