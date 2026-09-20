//
//  py_lpc.h
//  PyApp
//
//  Created by RT-Thread on 2021/10/21.
//  Copyright © 2021 Ventura. All rights reserved.
//


#import <stdbool.h>
#import <stdio.h>
#import "BridgeUtils.h"

#ifndef py_lpc_h
#define py_lpc_h



char* py_lpc_execNativePyJsonLpc(const char* service,const char* input);
void  py_lpc_nativeSetPyJsonLpcCallback(int (*callback)(const char *module,const char *event,const char *msg));

#endif /* py_lpc_h */
