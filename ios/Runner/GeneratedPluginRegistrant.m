//
//  Generated file. Do not edit.
//

#import "GeneratedPluginRegistrant.h"
#import <flutter_barcode_scanner/FlutterBarcodeScannerPlugin.h>
#import <flutter_webview_plugin/FlutterWebviewPlugin.h>
#import <image_crop/ImageCropPlugin.h>
#import <image_cropper/ImageCropperPlugin.h>
#import <image_picker/ImagePickerPlugin.h>

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FlutterBarcodeScannerPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterBarcodeScannerPlugin"]];
  [FlutterWebviewPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterWebviewPlugin"]];
  [ImageCropPlugin registerWithRegistrar:[registry registrarForPlugin:@"ImageCropPlugin"]];
  [FLTImageCropperPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTImageCropperPlugin"]];
  [FLTImagePickerPlugin registerWithRegistrar:[registry registrarForPlugin:@"FLTImagePickerPlugin"]];
}

@end
