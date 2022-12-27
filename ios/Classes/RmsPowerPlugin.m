#import "RmsPowerPlugin.h"
#if __has_include(<rms_power/rms_power-Swift.h>)
#import <rms_power/rms_power-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "rms_power-Swift.h"
#endif

@implementation RmsPowerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftRmsPowerPlugin registerWithRegistrar:registrar];
}
@end
