//
//  GalleryResultResponse.h
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ResponseObject.h"
#import "GalleryObject.h"

@interface GalleryResultResponse: ResponseObject

@property (nonatomic, strong) NSMutableArray<GalleryObject, Optional> *images;

@end
