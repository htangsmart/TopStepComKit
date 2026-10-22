#import <Foundation/Foundation.h>
#import <TopStepInterfaceKit/TSECGMeasurementEvent.h>
#import <FitCloudKit/FitCloudECGMeasurementV2EventObject.h>

NS_ASSUME_NONNULL_BEGIN
@interface TSFitECGMeasurementConverter : NSObject
+ (nullable TSECGMeasurementEvent *)eventFromFitEvent:(FitCloudECGMeasurementV2EventObject *)event;
@end
NS_ASSUME_NONNULL_END
