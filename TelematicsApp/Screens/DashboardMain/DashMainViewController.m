//
//  DashMainViewController.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 28.11.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "AFNetworking.h"
#import "DashMainViewController.h"
#import "DashboardResponse.h"
#import "EcoResponse.h"
#import "EcoIndividualResponse.h"
#import "LatestDayScoringResponse.h"
#import "LatestDayScoringResultResponse.h"
#import "DrivingDetailsResponse.h"
#import "TagResponse.h"
#import "TagResultResponse.h"
#import "CoinsResponse.h"
#import "CoinsResultResponse.h"
#import "StreaksResponse.h"
#import "AppDelegate.h"
#import "CoreTabBarController.h"
#import "ProfileViewController.h"
#import "ProgressBarView.h"
#import "LineChart.h"
#import "DashLiteCell.h"
#import "UICountingLabel.h"
#import "UserActivityCell.h"
#import "SettingsViewController.h"
#import "SystemServices.h"
#import "WiFiGPSChecker.h"
#import "UIViewController+Preloader.h"
#import "UIImageView+WebCache.h"
#import "GeneralPermissionsPopupDelegate.h"
#import "CongratulationsPopupDelegate.h"
#import "TelematicsAppPrivacyRequestManager.h"
#import "TelematicsAppLocationAccessor.h"
#import "HapticHelper.h"
#import "CMTabbarView.h"
#import "Helpers.h"
#import "Format.h"
#import "NSDate+UI.h"
#import "NSDate+ISO8601.h"
#import "TelematicsAppCollapsibleConstraints.h"
#import "UIImage+FixOrientation.h"
#import "JobsAcceptedCell.h"
#import "JobsCompletedCell.h"
#import <StoreKit/StoreKit.h>
#import <NMAKit/NMAKit.h>


@interface DashMainViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, GeneralPermissionsPopupProtocol, CongratulationsPopupProtocol, CMTabbarViewDelegate, CMTabbarViewDatasouce> {
    GeneralPermissionsPopupDelegate *permissionPopup;
    CongratulationsPopupDelegate *congratulationsPopup;
}

@property (strong, nonatomic) TelematicsAppModel                *appModel;
@property (strong, nonatomic) TelematicsLeaderboardModel        *leaderboardModel;

@property (strong, nonatomic) DashboardResultResponse           *dashboard;
@property (strong, nonatomic) LatestDayScoringResultResponse    *latestScoring;

@property (strong, nonatomic) DrivingDetailsResponse            *drivingDetails;

@property (strong, nonatomic) EcoResultResponse                 *eco;
@property (strong, nonatomic) EcoIndividualResultResponse       *ecoIndividual;

@property (strong, nonatomic) CoinsResultResponse               *coinsDetails;

@property (strong, nonatomic) StreaksResultResponse             *streaksDetails;

@property (strong, nonatomic) TagResultResponse                 *tagIndividual;

@property (nonatomic, weak) IBOutlet UIButton                   *showLeaderBtn;
@property (nonatomic, weak) IBOutlet UILabel                    *showLeaderLbl;
@property (nonatomic, weak) IBOutlet UILabel                    *latestScoredTripLbl;

@property (weak, nonatomic) IBOutlet UIScrollView               *mainScrollView;
@property (weak, nonatomic) IBOutlet UIView                     *mainSuperView;

@property (weak, nonatomic) IBOutlet UIView                     *mainDashboardView;
@property (weak, nonatomic) IBOutlet UIImageView                *mainBackgroundView;

@property (weak, nonatomic) IBOutlet UIView                     *trackingBtnView;
@property (weak, nonatomic) IBOutlet UILabel                    *trackingStartTxt;
@property (nonatomic, weak) IBOutlet UIButton                   *trackingStartBtn;
@property (nonatomic, weak) IBOutlet UILabel                    *trackingStartLbl;

@property (weak, nonatomic) IBOutlet UIView                     *demoDashboardView;
@property (weak, nonatomic) IBOutlet UIImageView                *needDistanceDemoImgView;
@property (weak, nonatomic) IBOutlet UIView                     *needDistanceAverageStatView;
@property (weak, nonatomic) IBOutlet UILabel                    *needDistanceLabel;
@property (nonatomic) IBOutlet ProgressBarView                  *progressBarDistance;

@property (weak, nonatomic) IBOutlet UICollectionView           *collectionViewCurve;
@property (weak, nonatomic) IBOutlet UIPageControl              *curvePageCtrl;

@property (weak, nonatomic) IBOutlet UICollectionView           *collectionViewDemoCurve;
@property (weak, nonatomic) IBOutlet UIPageControl              *demoCurvePageCtrl;
@property (weak, nonatomic) IBOutlet UIImageView                *demoGraphImg;
@property (weak, nonatomic) IBOutlet UIImageView                *demoEcoScoringImg;

@property (weak, nonatomic) IBOutlet UICollectionView           *collectionViewStartAdvice;
@property (weak, nonatomic) IBOutlet UIPageControl              *pageCtrlStartAdvice;
@property (weak, nonatomic) IBOutlet UIImageView                *backImageAdvice;
@property (strong, nonatomic) NSMutableArray                    *collectionAdviceTitleArr;

@property (nonatomic, strong) IBOutlet LineChart                *chartWithDates;
@property (nonatomic, weak) IBOutlet UIButton                   *arrowUpDownBtn;
@property (assign, nonatomic) BOOL                              expanding;

@property (weak, nonatomic) IBOutlet UITableView                *tableViewChallenges;
    
@property (weak, nonatomic) IBOutlet UILabel                    *userNameLbl;
@property (weak, nonatomic) IBOutlet UIImageView                *avatarImg;

@property (weak, nonatomic) IBOutlet UICountingLabel            *totalTripsLbl;
@property (weak, nonatomic) IBOutlet UICountingLabel            *totalMileageLbl;
@property (weak, nonatomic) IBOutlet UICountingLabel            *totalTimeLbl;
@property (weak, nonatomic) IBOutlet UICountingLabel            *totalTripsMainLbl;
@property (weak, nonatomic) IBOutlet UICountingLabel            *totalMileageMainLbl;
@property (weak, nonatomic) IBOutlet UICountingLabel            *totalTimeMainLbl;
@property (nonatomic, weak) IBOutlet UIButton                   *chatButton;
@property (assign, nonatomic) BOOL                              disableCounting;
@property (assign, nonatomic) BOOL                              disableRefreshGraph;
@property (assign, nonatomic) BOOL                              disableRefreshGraphAfterResign;
@property (assign, nonatomic) BOOL                              itsNotAppFirstRun;
@property (assign, nonatomic) BOOL                              needHideLinearGraph;

//LATEST TRIP
@property (nonatomic) RPTrackProcessed                          *track;
@property (nonatomic) NSArray<NMAGeoCoordinates *>              *speedPoints;
@property (weak, nonatomic) IBOutlet UIImageView                *mapSnapshot;
@property (weak, nonatomic) IBOutlet UIImageView                *mapSnapshotForDemo;
@property (weak, nonatomic) IBOutlet UILabel                    *pointsLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *kmLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *timeLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *startTimeLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *endTimeLbl;

@property (weak, nonatomic) IBOutlet UIImageView                *mapDemo_snapshot;
@property (weak, nonatomic) IBOutlet UILabel                    *mapDemo_pointsLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *mapDemo_kmLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *mapDemo_startTimeLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *mapDemo_endTimeLbl;
@property (weak, nonatomic) IBOutlet UIView                     *mapDemo_noTripsView;
@property (weak, nonatomic) IBOutlet UIButton                   *mapDemo_permissBtn;

//ADDONS
@property (nonatomic, strong) NSTimer                           *alertTimer;
@property (weak, nonatomic) IBOutlet UILabel                    *scoringAvailableIn;
@property (weak, nonatomic) IBOutlet UILabel                    *driveAsYouDo;

@property (weak, nonatomic) IBOutlet UILabel                    *welcomeLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *descNeedTotalTripsLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *descNeedMileageLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *descNeedTimeDrivenLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *descNeedQuantityLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *descNeedKmLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *descNeedHoursLbl;

@property (weak, nonatomic) IBOutlet UILabel                    *descTotalTripsLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *descMileageLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *descTimeDrivenLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *descQuantityLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *descKmLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *descHoursLbl;

@property (weak, nonatomic) IBOutlet UIButton                   *mainDashCoinsBtn;
@property (weak, nonatomic) IBOutlet UILabel                    *mainDashCoinsLbl;
@property (weak, nonatomic) IBOutlet UIImageView                *mainDashCoinsImg;
@property (weak, nonatomic) IBOutlet UIImageView                *mainDashTriangleIcon;
@property (weak, nonatomic) IBOutlet UIImageView                *demo_mainDashTriangleIcon;

//ECO SCORING
@property (weak, nonatomic) IBOutlet UILabel                    *demo_completeFirstTripLbl;
@property (weak, nonatomic) IBOutlet UICollectionView           *collectionViewActivity;
@property (nonatomic, assign) CGFloat                           lastContentOffset;
@property (weak, nonatomic) IBOutlet CMTabbarView               *activityTabBarView;
@property (strong, nonatomic) NSArray                           *activityDates;
@property (nonatomic) IBOutlet ProgressBarView                  *progressBarFuel;
@property (nonatomic) IBOutlet ProgressBarView                  *progressBarTires;
@property (nonatomic) IBOutlet ProgressBarView                  *progressBarBrakes;
@property (nonatomic) IBOutlet ProgressBarView                  *progressBarCost;
@property (nonatomic) NSTimer                                   *timerFuel;
@property (nonatomic) NSTimer                                   *timerTires;
@property (nonatomic) NSTimer                                   *timerBrakes;
@property (nonatomic) NSTimer                                   *timerTravelCost;
@property (weak, nonatomic) IBOutlet UILabel                    *percentLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *tipLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *tipAdviceLbl;
@property (weak, nonatomic) IBOutlet UIImageView                *roundPercentImg;
@property (weak, nonatomic) IBOutlet UIImageView                *arrowPercentImg;
@property (weak, nonatomic) IBOutlet UIImageView                *zigzagIndividualImg;
@property (weak, nonatomic) IBOutlet UILabel                    *factor_costOfOwnershipLbl;

//ECO SCORING DEMO BLOCK
@property (weak, nonatomic) IBOutlet UICollectionView           *demo_collectionViewActivity;
@property (weak, nonatomic) IBOutlet CMTabbarView               *demo_activityTabBarView;
@property (strong, nonatomic) NSArray                           *demo_activityDates2;
@property (nonatomic) IBOutlet ProgressBarView                  *demo_progressBarFuel;
@property (nonatomic) IBOutlet ProgressBarView                  *demo_progressBarTires;
@property (nonatomic) IBOutlet ProgressBarView                  *demo_progressBarBrakes;
@property (nonatomic) IBOutlet ProgressBarView                  *demo_progressBarCost;
@property (nonatomic) NSTimer                                   *demo_timerFuel;
@property (nonatomic) NSTimer                                   *demo_timerTires;
@property (nonatomic) NSTimer                                   *demo_timerBrakes;
@property (nonatomic) NSTimer                                   *demo_timerTravelCost;
@property (weak, nonatomic) IBOutlet UILabel                    *demo_percentLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *demo_tipLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *demo_tipAdviceLbl;
@property (weak, nonatomic) IBOutlet UIImageView                *demo_roundPercentImg;
@property (weak, nonatomic) IBOutlet UIImageView                *demo_arrowPercentImg;
@property (weak, nonatomic) IBOutlet UIImageView                *demo_zigzagIndividualImg;
@property (weak, nonatomic) IBOutlet UILabel                    *demo_factor_costOfOwnershipLbl;

//COMING SOON IN NEXT RELEASE
@property (weak, nonatomic) IBOutlet UILabel                    *streaks_speedingLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *streaks_speedingValueLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *streaks_phoneLbl;
@property (weak, nonatomic) IBOutlet UILabel                    *streaks_phoneValueLbl;

//DELIVERY ON-DUTY MODE
@property (weak, nonatomic) IBOutlet UIView                     *jobsMainView;
@property (weak, nonatomic) IBOutlet UIButton                   *jobsStatusBtn;
@property (weak, nonatomic) IBOutlet UIButton                   *jobsGoBtn;
@property (weak, nonatomic) IBOutlet UILabel                    *jobsCurrentLbl;
@property (weak, nonatomic) IBOutlet UIButton                   *jobsOkGreenBtn;
@property (weak, nonatomic) IBOutlet UIButton                   *jobsPauseBtn;

@property (weak, nonatomic) IBOutlet UITextField                *jobsOnDutyTimerTextField;
@property (nonatomic, strong) NSTimer                           *jobsOnDutyTimerImplementation;
@property (nonatomic, strong) NSMutableArray                    *jobsOnDutyAcceptedArray;
@property (nonatomic, strong) NSMutableArray                    *jobsOnDutyCompletedArray;

@property (weak, nonatomic) IBOutlet UIButton                   *jobsOnDutyCurrentAcceptBtn;
@property (weak, nonatomic) IBOutlet UIButton                   *jobsOnDutyCurrentStartBtn;
@property (weak, nonatomic) IBOutlet UITableView                *jobsOnDutyAcceptTableView;
@property (weak, nonatomic) IBOutlet UITableView                *jobsOnDutyCompletedTableView;
@property (weak, nonatomic) IBOutlet UIView                     *jobsOnDutyAcceptPlaceholder;
@property (weak, nonatomic) IBOutlet UIView                     *jobsOnDutyCompletedPlaceholder;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint       *mainDashboardViewTopPositionForJobsREALConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint       *mainDashboardViewTopPositionForJobsDEMOConstraint;
@property (weak, nonatomic) IBOutlet UIView                     *mainDashboardViewSpecialWhiteEndREALView;
@property (weak, nonatomic) IBOutlet UIView                     *mainDashboardViewSpecialWhiteEndDEMOView;
@property (weak, nonatomic) IBOutlet UIView                     *mainDashboardViewSpecialGreyEndView;
@property (weak, nonatomic) IBOutlet UILabel *DriveAsYoulbl;
@property (weak, nonatomic) IBOutlet UILabel *latestScoredTrip2Lbl;
@property (weak, nonatomic) IBOutlet UILabel *EcoScoringlbl;
@property (weak, nonatomic) IBOutlet UILabel *EcoScoring2lbl;
@property (weak, nonatomic) IBOutlet UILabel *FuelDashlbl;
@property (weak, nonatomic) IBOutlet UILabel *FuelDash2lbl;
@property (weak, nonatomic) IBOutlet UILabel *TireDashlbl;
@property (weak, nonatomic) IBOutlet UILabel *TireDash2lbl;
@property (weak, nonatomic) IBOutlet UILabel *BrakesDashlbl;
@property (weak, nonatomic) IBOutlet UILabel *BrakesDash2lbl;
@property (weak, nonatomic) IBOutlet UILabel *MyActivitylbl;
@property (weak, nonatomic) IBOutlet UILabel *MyActivity2lbl;
@property (weak, nonatomic) IBOutlet UILabel *AvgSpeedlbl;
@property (weak, nonatomic) IBOutlet UILabel *AvgSpeed2lbl;
@property (weak, nonatomic) IBOutlet UILabel *MaxSpeedlbl;
@property (weak, nonatomic) IBOutlet UILabel *MaxSpeed2lbl;
@property (weak, nonatomic) IBOutlet UILabel *AvgDistancelbl;
@property (weak, nonatomic) IBOutlet UILabel *AvgDistance2lbl;
@property (weak, nonatomic) IBOutlet UILabel *HaveYoulbl;
@property (weak, nonatomic) IBOutlet UILabel *ButIslbl;
@property (weak, nonatomic) IBOutlet UILabel *DrivingStreaklbl;
@property (weak, nonatomic) IBOutlet UIButton *LeanrMorelbl;

@end


@implementation DashMainViewController

@synthesize collectionViewCurve;
@synthesize collectionViewDemoCurve;
@synthesize curvePageCtrl;
@synthesize demoCurvePageCtrl;
@synthesize collectionViewStartAdvice;
@synthesize pageCtrlStartAdvice;
@synthesize progressBarDistance = _progressBarDistance;

- (ProgressBarView *)progressBarDistance {
    if (!_progressBarDistance) {
        _progressBarDistance = [[ProgressBarView alloc] initWithFrame:CGRectZero];
        _progressBarDistance.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _progressBarDistance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //INITIALIZE USER APP MODEL
    self.appModel = [TelematicsAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];
    self.leaderboardModel = [TelematicsLeaderboardModel MR_findFirstByAttribute:@"leaderboard_user" withValue:@1];
    
    [self setupRoundViews];
    [self setupAdditionalTranslation];
    [self setupTabBarTitles];
    [self setupEcoCollectionsForViews];
    
    if (!self.appModel.notFirstRunApp) {
        [self showPreloader];
        
        //CREATE USER COREDATA MODEL
        [TelematicsAppModel MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"current_user == 1"]];
        self.appModel = [TelematicsAppModel MR_createEntity];
        self.appModel.current_user = @1;
        self.appModel = [TelematicsAppModel MR_findFirstByAttribute:@"current_user" withValue:@1];
        
        [TelematicsLeaderboardModel MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"leaderboard_user == 1"]];
        self.leaderboardModel = [TelematicsLeaderboardModel MR_createEntity];
        self.leaderboardModel.leaderboard_user = @1;
        self.leaderboardModel = [TelematicsLeaderboardModel MR_findFirstByAttribute:@"leaderboard_user" withValue:@1];
        
        self.appModel.notFirstRunApp = YES;
        self.disableCounting = YES;
        [self startFetchStatisticData];
        
        //IF NEED REPEAT FOR NEW USERS
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IMMEDIATELY_5_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.disableCounting = YES;
            [self getDashboardIndicatorsStatisticsData];
            [self getDashboardEcoDataAllTime];
            [self getDashboardEcoDataWeek];
            [self getDashboardEcoDataMonth];
            [self getDashboardEcoDataYear];
            [self hidePreloader];
        });
    } else {
        self.disableCounting = NO;
        [self updateDataFromCacheForDashboard];
        [self startFetchStatisticData];
    }
    
    self.progressBarDistance.barFillColor = [Color officialMainAppColor];
    [self.progressBarDistance setBarBackgroundColor:[Color lightSeparatorColor]];
    
    [self loadUserViewsForMainDashboard];
    
    self.collectionViewCurve.delegate = self;
    self.collectionViewCurve.dataSource = self;
    [self.collectionViewCurve reloadData];
    
    self.collectionViewDemoCurve.delegate = self;
    self.collectionViewDemoCurve.dataSource = self;
    [self.collectionViewDemoCurve reloadData];
    
    self.collectionAdviceTitleArr = [NSMutableArray arrayWithObjects:@"1", @"2", nil];
    
    self.collectionViewStartAdvice.delegate = self;
    self.collectionViewStartAdvice.dataSource = self;
    self.pageCtrlStartAdvice.currentPageIndicatorTintColor = [Color officialMainAppColor];
    self.curvePageCtrl.currentPageIndicatorTintColor = [Color officialMainAppColor];
    self.demoCurvePageCtrl.currentPageIndicatorTintColor = [Color officialMainAppColor];
    [self.collectionViewStartAdvice reloadData];
    
    self.needDisplayAlert = YES;
    
    permissionPopup = [[GeneralPermissionsPopupDelegate alloc] initOnView:self.view];
    permissionPopup.delegate = self;
    permissionPopup.dismissOnBackgroundTap = NO;
    defaults_set_object(@"permissionPopupShowing", @(NO));
    
    congratulationsPopup = [[CongratulationsPopupDelegate alloc] initOnView:self.view];
    congratulationsPopup.delegate = self;
    congratulationsPopup.dismissOnBackgroundTap = YES;
    
    UITapGestureRecognizer *avaTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avaTapDetect:)];
    self.avatarImg.userInteractionEnabled = YES;
    [self.avatarImg addGestureRecognizer:avaTap];
    
    UITapGestureRecognizer *lastTripTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lastTripTapDetect:)];
    self.mapSnapshot.userInteractionEnabled = YES;
    [self.mapSnapshot addGestureRecognizer:lastTripTap];
    
    UITapGestureRecognizer *lastTripDemoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lastTripTapDetect:)];
    self.mapSnapshotForDemo.userInteractionEnabled = YES;
    [self.mapSnapshotForDemo addGestureRecognizer:lastTripDemoTap];
    
    UITapGestureRecognizer *lastDemoTripTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lastTripTapDetect:)];
    self.mapDemo_snapshot.userInteractionEnabled = YES;
    [self.mapDemo_snapshot addGestureRecognizer:lastDemoTripTap];
    
    self.mainScrollView.refreshControl = [[UIRefreshControl alloc] init];
    self.mainScrollView.refreshControl.tintColor = [Color whiteSpinnerColor];
    [self.mainScrollView.refreshControl addTarget:self action:@selector(refreshStatisticData:) forControlEvents:UIControlEventValueChanged];
    [self.mainScrollView.refreshControl setFrame:CGRectMake(5, 0, 20, 20)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo:) name:@"updateUserInfo" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo:) name:@"reloadDashboardPage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo:) name:@"reloadOnDemandDashboardSection" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo:) name:@"finishOnDemandDashboardSection" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IMMEDIATELY_06_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self mainCheckPermissions];
    });
    
    //ONDEMAND DEMOBLOCK START INNITIALIZATION
    [self setupOnDemandUIDemoBlock];
    
    if (IS_IPHONE_5 || IS_IPHONE_4) [self lowFontsForOldDevices];
    
    [curvePageCtrl setNumberOfPages:6];
    [demoCurvePageCtrl setNumberOfPages:6];
    
    [self setupEcoDemoBlock];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self displayUserNavigationBarInfo];
    
    if (self.appModel.detailsAllDrivingScores.count != 0) {
        if (!_itsNotAppFirstRun) {
            [self loadLinearChart:curvePageCtrl.currentPage];
            [self loadLinearChart:demoCurvePageCtrl.currentPage];
            _disableRefreshGraphAfterResign = YES;
        }
    }
    
    [self loadLastCachedEventForDashboardMap];
    [self loadOneEventForDashboardMap];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![defaults_object(@"userDoneWizard") boolValue]) {
        [self startTelematicsBtnClick:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    _itsNotAppFirstRun = YES;
}

- (void)appWillEnterForeground {
    NSLog(@"appResignEnterForeground");
    [self startFetchStatisticData];
    
    [self loadLastCachedEventForDashboardMap];
    [self loadOneEventForDashboardMap];
}

- (void)startFetchStatisticData {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IMMEDIATELY_1_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.disableCounting = YES;
        [self getDashboardIndicatorsStatisticsData];
        [self getDashboardEcoDataAllTime];
        [self getDashboardEcoDataWeek];
        [self getDashboardEcoDataMonth];
        [self getDashboardEcoDataYear];
    });
}


#pragma mark - UserInfo fetch

- (void)displayUserNavigationBarInfo {
    self.userNameLbl.text = self.appModel.userFullName ? self.appModel.userFullName : @"";
    
    self.avatarImg.layer.cornerRadius = self.avatarImg.frame.size.width / 2.0;
    self.avatarImg.layer.masksToBounds = YES;
    self.avatarImg.contentMode = UIViewContentModeScaleAspectFill;
    if (self.appModel.userPhotoData != nil) {
        self.avatarImg.image = [UIImage imageWithData:self.appModel.userPhotoData];
    }
}

- (void)loadUserViewsForMainDashboard {
    if ([defaults_object(@"needTrackingOnRequired") boolValue]) {
        float requiredDistance = self.appModel.statDistanceForScoring.floatValue;
        float userRealDistance = self.appModel.statSummaryDistance.floatValue;
        if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
            userRealDistance = convertKmToMiles(userRealDistance);
        }
        if (userRealDistance < requiredDistance) {
            self.mainDashboardView.hidden = YES;
            self.demoDashboardView.hidden = NO;
        } else {
            self.mainDashboardView.hidden = NO;
            self.demoDashboardView.hidden = YES;
        }
    } else {
        if (![defaults_object(@"userLogOuted") boolValue]) {
            self.mainDashboardView.hidden = NO;
            self.demoDashboardView.hidden = YES;
        } else {
            BOOL isMotionEnabled = [[WiFiGPSChecker sharedChecker] motionAvailable];
            BOOL isGPSAuthorized = ([CLLocationManager locationServicesEnabled]
                                    && ([CLLocationManager authorizationStatus]
                                        == kCLAuthorizationStatusAuthorizedAlways));
            if (isGPSAuthorized || isMotionEnabled) {
                self.mainDashboardView.hidden = YES;
                self.demoDashboardView.hidden = NO;
            } else {
                self.mainDashboardView.hidden = NO;
                self.demoDashboardView.hidden = YES;
            }
        }
    }
}

- (void)updateUserInfo:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"updateUserInfo"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.userNameLbl.text = self.appModel.userFullName ? self.appModel.userFullName : @"";
            if (self.appModel.userPhotoData != nil) {
                self.avatarImg.image = [UIImage imageWithData:self.appModel.userPhotoData];
                self.avatarImg.layer.masksToBounds = YES;
                self.avatarImg.contentMode = UIViewContentModeScaleAspectFill;
            }
        });
    } else if ([[notification name] isEqualToString:@"reloadDashboardPage"]) {
        [self refreshStatisticData:nil];
    } else if ([[notification name] isEqualToString:@"reloadOnDemandDashboardSection"]) {
        [self setupOnDemandUIDemoBlock];
    } else if ([[notification name] isEqualToString:@"finishOnDemandDashboardSection"]) {
        [self stopGreenBtnClick:self];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IMMEDIATELY_1_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self stopAllJobs];
        });
    }
}


#pragma mark - Statistics

- (void)getDashboardIndicatorsStatisticsData {
    //GET LATEST DAY SCORING FOR USER
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        NSLog(@"%s %@ %@", __func__, response, error);
        if (!error && [response isSuccesful]) {
            self.latestScoring = ((LatestDayScoringResponse *)response).Result;
            
            NSString *latestDateOfScoringString = self.latestScoring.LatestScoringDate;
            NSDate *latestDateOfScoring = [NSDate dateWithISO8601String:latestDateOfScoringString];
            if (latestDateOfScoring == nil) {
                latestDateOfScoring = [NSDate date];
            }
            [self fetchUserScoringsAnyway];
        } else {
            [self fetchUserScoringsAnyway];
            [self hidePreloader];
        }
    }] getLatestDayStatisticsScoringForUser];
}

- (void)fetchUserScoringsAnyway {
    
    NSDate *currentDate = [NSDate date];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:-20];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *dateMinusNeedYearsAllTime = [calendar dateByAddingComponents:dateComponents toDate:currentDate options:0];
    
    NSDateComponents *dateComponentsOneDay = [[NSDateComponents alloc] init];
    [dateComponentsOneDay setDay:-1];
    NSDate *dateMinusNeedOneDays = [calendar dateByAddingComponents:dateComponentsOneDay toDate:currentDate options:0];
    NSLog(@"One day ago: %@", dateMinusNeedOneDays);
    
    NSDateComponents *dateComponentsThisMonth = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    dateComponentsThisMonth.day = 1;
    NSDate *firstDayOfCurrentMonthDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponentsThisMonth];
    NSLog(@"First day of current month: %@", [firstDayOfCurrentMonthDate descriptionWithLocale:[NSLocale currentLocale]]);
    
    NSDateComponents *dateComponentsLastMonth = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    dateComponentsLastMonth.day = 1;
    dateComponentsLastMonth.month = dateComponentsLastMonth.month - 1;
    NSDate *firstDayOfLastMonthDate = [[NSCalendar currentCalendar] dateFromComponents:dateComponentsLastMonth];
    NSLog(@"First day of last month: %@", [firstDayOfLastMonthDate descriptionWithLocale:[NSLocale currentLocale]]);
    
    NSDateComponents *dateComponents14Days = [[NSDateComponents alloc] init];
    [dateComponents14Days setDay:-13];
    NSDate *dateMinus14Days = [calendar dateByAddingComponents:dateComponents14Days toDate:currentDate options:0];
    NSLog(@"14 days ago: %@", dateMinus14Days);
    
    //FETCH INDIVIDUAL
    [self getDashboardIndicatorsStatisticsIndividualForPeriod:dateMinusNeedYearsAllTime endDate:currentDate];
    
    //COINS PRELOAD FOR MYREWARDS SCREEN
    [self getDashboardCoinsAllTime:dateMinusNeedYearsAllTime endDate:currentDate];
    [self getDashboardCoinsOneDayTime:dateMinusNeedOneDays endDate:currentDate];
    [self getDashboardCoinsThisMonthTime:firstDayOfCurrentMonthDate endDate:currentDate];
    [self getDashboardCoinsLastMonthTime:firstDayOfLastMonthDate endDate:firstDayOfCurrentMonthDate];
    [self getCoinsLimitAllTimeNow];
    
    //STREAKS
    [self startFetchStreaksForDashboard];
}

- (void)getDashboardIndicatorsStatisticsIndividualForPeriod:(NSDate *)startDate endDate:(NSDate *)endDate {
    
    NSString *sDate = [startDate dateTimeStringSpecial];
    NSString *eDate = [endDate dateTimeStringSpecial];
    
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        NSLog(@"%s %@ %@", __func__, response, error);
        if (!error && [response isSuccesful]) {
            self.dashboard = ((DashboardResponse *)response).Result;
            
            self.appModel.statDistanceForScoring = [Configurator sharedInstance].needUserDriveDistanceForScoringKm;
            
            if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                float miles = convertKmToMiles(self.appModel.statDistanceForScoring.floatValue);
                self.appModel.statDistanceForScoring = @(miles);
            }
            
            self.appModel.statTrackCount = self.dashboard.TripsCount;
            self.appModel.statSummaryDistance = self.dashboard.MileageKm;
            self.appModel.statSummaryDuration = self.dashboard.DrivingTime;
            
            NSDate *currentDate = [NSDate date];
            [self getDashboardScoringsIndividualOnCurrentDay:currentDate endDate:currentDate];
        } else {
            self.appModel.statDistanceForScoring = [Configurator sharedInstance].needUserDriveDistanceForScoringKm;
            
            if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                float miles = convertKmToMiles(self.appModel.statDistanceForScoring.floatValue);
                self.appModel.statDistanceForScoring = @(miles);
            }
            
            self.appModel.statSummaryDistance = 0;
            [self getDashboardScoringsIndividualOnCurrentDay:startDate endDate:endDate];
        }
    }] getStatisticsIndividualAllTime:sDate endDate:eDate];
}

- (void)getDashboardScoringsIndividualOnCurrentDay:(NSDate *)startDate endDate:(NSDate *)endDate {
    
    NSString *sDate = [startDate dateTimeStringSpecial];
    NSString *eDate = [endDate dateTimeStringSpecial];
    
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        NSLog(@"%s %@ %@", __func__, response, error);
        if (!error && [response isSuccesful]) {
            self.dashboard = ((DashboardResponse *)response).Result;
            
            self.appModel.detailsScoreOverall = self.dashboard.SafetyScore;
            self.appModel.detailsScoreAcceleration = self.dashboard.AccelerationScore;
            self.appModel.detailsScoreDeceleration = self.dashboard.BrakingScore;
            self.appModel.detailsScorePhoneUsage = self.dashboard.PhoneUsageScore;
            self.appModel.detailsScoreSpeeding = self.dashboard.SpeedingScore;
            self.appModel.detailsScoreTurn = self.dashboard.CorneringScore;
            
            NSString *latestDateOfScoringString = self.latestScoring.LatestScoringDate;
            NSDate *latestDateOfScoring = [NSDate dateWithISO8601String:latestDateOfScoringString];
            if (latestDateOfScoring == nil) {
                latestDateOfScoring = [NSDate date];
            }
            
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            [dateComponents setDay:-14];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDate *dateMinus14days = [calendar dateByAddingComponents:dateComponents toDate:latestDateOfScoring options:0];
            
            [self getDashboardScoringsIndividual14daysDaily:dateMinus14days endDate:latestDateOfScoring];
        } else {
            
            self.appModel.detailsScoreOverall = @0;
            self.appModel.detailsScoreAcceleration = @0;
            self.appModel.detailsScoreDeceleration = @0;
            self.appModel.detailsScorePhoneUsage = @0;
            self.appModel.detailsScoreSpeeding = @0;
            self.appModel.detailsScoreTurn = @0;
            
            NSString *latestDateOfScoringString = self.latestScoring.LatestScoringDate;
            NSDate *latestDateOfScoring = [NSDate dateWithISO8601String:latestDateOfScoringString];
            if (latestDateOfScoring == nil) {
                latestDateOfScoring = [NSDate date];
            }
            
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            [dateComponents setDay:-14];
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDate *dateMinus14days = [calendar dateByAddingComponents:dateComponents toDate:latestDateOfScoring options:0];
            
            [self getDashboardScoringsIndividual14daysDaily:dateMinus14days endDate:latestDateOfScoring];
        }
    }] getScoringsIndividualCurrentDay:sDate endDate:eDate];
}

- (void)getDashboardScoringsIndividual14daysDaily:(NSDate *)startDate14 endDate:(NSDate *)endDate14 {
    
    NSString *sDate14 = [startDate14 dateTimeStringSpecial];
    NSString *eDate14 = [endDate14 dateTimeStringSpecial];
    
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        NSLog(@"%s %@ %@", __func__, response, error);
        if (!error && [response isSuccesful]) {
            self.drivingDetails = ((DrivingDetailsResponse *)response);
            
            self.appModel.detailsAllDrivingScores = self.drivingDetails.Result;
            [CoreDataCoordinator saveCoreDataCoordinatorContext];
            
            [self updateDataFromCacheForDashboard];
            [self hidePreloader];
            
            [self.collectionViewCurve reloadData];
            self->_disableRefreshGraphAfterResign = NO;
            [self loadLinearChart:0];
            self->_disableRefreshGraphAfterResign = YES;
            
            [self setupEcoViews];
        } else {
            [self updateDataFromCacheForDashboard];
            [self hidePreloader];
            
            [self.collectionViewCurve reloadData];
            self->_disableRefreshGraphAfterResign = NO;
            [self loadLinearChart:0];
            self->_disableRefreshGraphAfterResign = YES;
            
            [self setupEcoViews];
        }
    }] getScoringsIndividual14daysDaily:sDate14 endDate:eDate14];
}


#pragma mark - Indicators Eco Statistics

- (void)getDashboardEcoDataAllTime {
    
    NSDate *nowDate = [NSDate date];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:-20];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *twentyYears = [calendar dateByAddingComponents:dateComponents toDate:nowDate options:0];
    
    NSString *nowDateString = [nowDate dateTimeStringSpecial];
    NSString *minus20years = [twentyYears dateTimeStringSpecial];
    
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        NSLog(@"%s %@ %@", __func__, response, error);
        if (!error && [response isSuccesful]) {
            self.ecoIndividual = ((EcoIndividualResponse *)response).Result;
            self.appModel.statEcoScoringFuel = self.ecoIndividual.EcoScoreFuel;
            self.appModel.statEcoScoringTyres = self.ecoIndividual.EcoScoreTyres;
            self.appModel.statEcoScoringBrakes = self.ecoIndividual.EcoScoreBrakes;
            self.appModel.statEcoScoringDepreciation = self.ecoIndividual.EcoScoreDepreciation;
            self.appModel.statEco = self.ecoIndividual.EcoScore;
            self.appModel.statPreviousEcoScoring = self.ecoIndividual.EcoScore;
        } else {
            self.appModel.statEcoScoringFuel = @90;
            self.appModel.statEcoScoringTyres = @90;
            self.appModel.statEcoScoringBrakes = @90;
            self.appModel.statEcoScoringDepreciation = @90;
            self.appModel.statEco = @90;
            self.appModel.statPreviousEcoScoring = @90;
        }
    }] getEcoScoresForTimePeriod:minus20years endDate:nowDateString];
}

- (void)getDashboardEcoDataWeek {
    NSDate *nowDate = [NSDate date];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:-7];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *dateMinus7days = [calendar dateByAddingComponents:dateComponents toDate:nowDate options:0];
    
    NSString *nowDateString = [nowDate dateTimeStringSpecial];
    NSString *minus7DateString = [dateMinus7days dateTimeStringSpecial];
    
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        NSLog(@"%s %@ %@", __func__, response, error);
        if (!error && [response isSuccesful]) {
            self.eco = ((EcoResponse *)response).Result;
            self.appModel.statWeeklyMaxSpeed = self.eco.MaxSpeedKmh;
            self.appModel.statWeeklyAverageSpeed = self.eco.AverageSpeedKmh;
            self.appModel.statWeeklyTotalKm = self.eco.MileageKm;
        }
    }] getCoinsStatisticsIndividualForPeriod:minus7DateString endDate:nowDateString];
}

- (void)getDashboardEcoDataMonth {
    NSDate *nowDate = [NSDate date];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:-30];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *dateMinus30days = [calendar dateByAddingComponents:dateComponents toDate:nowDate options:0];
    
    NSString *nowDateString = [nowDate dateTimeStringSpecial];
    NSString *minus30DateString = [dateMinus30days dateTimeStringSpecial];
    
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        NSLog(@"%s %@ %@", __func__, response, error);
        if (!error && [response isSuccesful]) {
            self.eco = ((EcoResponse *)response).Result;
            self.appModel.statMonthlyMaxSpeed = self.eco.MaxSpeedKmh;
            self.appModel.statMonthlyAverageSpeed = self.eco.AverageSpeedKmh;
            self.appModel.statMonthlyTotalKm = self.eco.MileageKm;
            
        }
    }] getCoinsStatisticsIndividualForPeriod:minus30DateString endDate:nowDateString];
}

- (void)getDashboardEcoDataYear {
    NSDate *nowDate = [NSDate date];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:-365];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *dateMinus365days = [calendar dateByAddingComponents:dateComponents toDate:nowDate options:0];
    
    NSString *nowDateString = [nowDate dateTimeStringSpecial];
    NSString *minus365DateString = [dateMinus365days dateTimeStringSpecial];
    
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        if (!error && [response isSuccesful]) {
            self.eco = ((EcoResponse *)response).Result;
            self.appModel.statYearlyMaxSpeed = self.eco.MaxSpeedKmh;
            self.appModel.statYearlyAverageSpeed = self.eco.AverageSpeedKmh;
            self.appModel.statYearlyTotalKm = self.eco.MileageKm;
            
        }
    }] getCoinsStatisticsIndividualForPeriod:minus365DateString endDate:nowDateString];
}


#pragma mark - Coins

- (void)getCoinsLimitAllTimeNow {
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        if (!error && [response isSuccesful]) {
            self.coinsDetails = ((CoinsResponse *)response).Result;
            defaults_set_object(@"userCoinsDailyLimit", self.coinsDetails.DailyLimit);
        } else {
            defaults_set_object(@"userCoinsDailyLimit", @20);
        }
    }] getCoinsDailyLimit];
}

- (void)getDashboardCoinsAllTime:(NSDate *)startDate endDate:(NSDate *)endDate {
    NSString *sCoinsDate = [startDate dateTimeStringSpecial];
    NSString *eCoinsDate = [endDate dateTimeStringSpecial];
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        if (!error && [response isSuccesful]) {
            self.coinsDetails = ((CoinsResponse *)response).Result;
            self.mainDashCoinsLbl.text = self.coinsDetails.AcquiredCoins;
            defaults_set_object(@"userCoinsCountAllTime", self.coinsDetails.TotalEarnedCoins);
            defaults_set_object(@"userCoinsCountAcquired", self.coinsDetails.AcquiredCoins);
        } else {
            self.mainDashCoinsLbl.text = @"0";
        }
    }] getCoinsTotal:sCoinsDate endDate:eCoinsDate];
}

- (void)getDashboardCoinsOneDayTime:(NSDate *)startDate endDate:(NSDate *)endDate {
    NSString *sCoinsDate = [startDate dateTimeStringSpecial];
    NSString *eCoinsDate = [endDate dateTimeStringSpecial];
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        if (!error && [response isSuccesful]) {
            self.coinsDetails = ((CoinsResponse *)response).Result;
            NSLog(@"userCoinsCountOneDay %@", self.coinsDetails.TotalEarnedCoins);
            defaults_set_object(@"userCoinsCountOneDay", self.coinsDetails.TotalEarnedCoins);
        } else {
            defaults_set_object(@"userCoinsCountOneDay", @0);
        }
    }] getCoinsTotal:sCoinsDate endDate:eCoinsDate];
}

- (void)getDashboardCoinsThisMonthTime:(NSDate *)startDate endDate:(NSDate *)endDate {
    NSString *sCoinsDate = [startDate dateTimeStringSpecial];
    NSString *eCoinsDate = [endDate dateTimeStringSpecial];
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        if (!error && [response isSuccesful]) {
            self.coinsDetails = ((CoinsResponse *)response).Result;
            NSLog(@"userCoinsCountThisMonth %@", self.coinsDetails.TotalEarnedCoins);
            defaults_set_object(@"userCoinsCountThisMonth", self.coinsDetails.TotalEarnedCoins);
        } else {
            defaults_set_object(@"userCoinsCountThisMonth", 0);
        }
    }] getCoinsTotal:sCoinsDate endDate:eCoinsDate];
}

- (void)getDashboardCoinsLastMonthTime:(NSDate *)startDate endDate:(NSDate *)endDate {
    NSString *sCoinsDate = [startDate dateTimeStringSpecial];
    NSString *eCoinsDate = [endDate dateTimeStringSpecial];
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        if (!error && [response isSuccesful]) {
            self.coinsDetails = ((CoinsResponse *)response).Result;
            defaults_set_object(@"userCoinsCountLastMonth", self.coinsDetails.TotalEarnedCoins);
        } else {
            defaults_set_object(@"userCoinsCountLastMonth", 0);
        }
    }] getCoinsTotal:sCoinsDate endDate:eCoinsDate];
}


#pragma mark - Streaks Backend Preload

- (void)startFetchStreaksForDashboard {
    [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
        NSLog(@"%s %@ %@", __func__, response, error);
        if (!error && [response isSuccesful]) {
            self.streaksDetails = ((StreaksResponse *)response).Result;
            self.streaks_speedingValueLbl.text = [NSString stringWithFormat:localizeString(@"%@ trips"), self.streaksDetails.StreakOverSpeedCurrentStreak.stringValue];
            self.streaks_phoneValueLbl.text = [NSString stringWithFormat:localizeString(@"%@ trips"), self.streaksDetails.StreakPhoneUsageCurrentStreak.stringValue];
            NSLog(@"Streaks Ok");
        } else {
            NSLog(@"%s %@ %@", __func__, response, error);
        }
    }] getIndicatorsStreaksSection];
}


#pragma mark - Dashboard CachedData For Next App Runnings

- (void)updateDataFromCacheForDashboard {
    
    if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
        float miles = convertKmToMiles(self.appModel.statSummaryDistance.floatValue);
        self.progressBarDistance.progress = miles/self.appModel.statDistanceForScoring.floatValue;
    } else {
        self.progressBarDistance.progress = self.appModel.statSummaryDistance.floatValue/self.appModel.statDistanceForScoring.floatValue;
    }
    
    NSString *rounded = [NSString stringWithFormat:@"%.0f", self.appModel.statSummaryDistance.floatValue];
    NSString *kmLocalize = localizeString(@"km");
    if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
        float miles = convertKmToMiles(self.appModel.statSummaryDistance.floatValue);
        rounded = [NSString stringWithFormat:@"%.1f", miles];
        kmLocalize = localizeString(@"mi");
    }
    
    self.needDistanceLabel.text = [NSString stringWithFormat:@"%@%@ / %@%@", rounded, kmLocalize, self.appModel.statDistanceForScoring, kmLocalize];
    
    float tripsCount = self.appModel.statTrackCount.floatValue;
    float mileageKm = self.appModel.statSummaryDistance.floatValue;
    if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
        float miles = convertKmToMiles(mileageKm);
        mileageKm = miles;
    }
    
    float timeDriven = self.appModel.statSummaryDuration.floatValue / 60;
    
    self.totalTripsLbl.format = @"%d";
    self.totalMileageLbl.format = @"%d";
    self.totalTimeLbl.format = @"%d";
    self.totalTripsMainLbl.format = @"%d";
    self.totalMileageMainLbl.format = @"%d";
    self.totalTimeMainLbl.format = @"%d";
    
    if (_disableCounting) {
        [self.totalTripsLbl countFrom:tripsCount to:tripsCount];
        [self.totalTripsMainLbl countFrom:tripsCount to:tripsCount];
        [self.totalMileageLbl countFrom:mileageKm to:mileageKm];
        [self.totalMileageMainLbl countFrom:mileageKm to:mileageKm];
        [self.totalTimeLbl countFrom:timeDriven to:timeDriven];
        [self.totalTimeMainLbl countFrom:timeDriven to:timeDriven];
        return;
    } else {
        self.totalTripsLbl.method = UILabelCountingMethodLinear;
        [self.totalTripsLbl countFrom:0 to:tripsCount];
        
        self.totalMileageLbl.method = UILabelCountingMethodLinear;
        [self.totalMileageLbl countFrom:0 to:mileageKm];
        
        self.totalTimeLbl.method = UILabelCountingMethodLinear;
        [self.totalTimeLbl countFrom:0 to:timeDriven];
        
        self.totalTripsMainLbl.method = UILabelCountingMethodLinear;
        [self.totalTripsMainLbl countFrom:0 to:tripsCount];
        
        self.totalMileageMainLbl.method = UILabelCountingMethodLinear;
        [self.totalMileageMainLbl countFrom:0 to:mileageKm];
        
        self.totalTimeMainLbl.method = UILabelCountingMethodLinear;
        [self.totalTimeMainLbl countFrom:0 to:timeDriven];
    }
    [self.collectionViewCurve reloadData];
    _disableRefreshGraph = YES;
}


#pragma mark - Linear Chart for Dashboard - Green Graph 2 weeks

- (void)loadLinearChart:(NSInteger)type {
    
    if (_disableRefreshGraphAfterResign) {
        _disableRefreshGraphAfterResign = NO;
        return;
    }
    [_chartWithDates clearChartData];
    
    NSMutableArray* chartData = [NSMutableArray arrayWithCapacity:self.appModel.detailsAllDrivingScores.count];
    if (self.appModel.detailsAllDrivingScores.count == 0) {
        chartData = [NSMutableArray arrayWithCapacity:7];
        for (int i=0; i < 7; i++) {
            chartData[i] = [NSNumber numberWithFloat: (float)i / 55.0f + (float)(rand() % 100) / 500.0f];
        }
    } else {
        for (int i=0; i < self.appModel.detailsAllDrivingScores.count; i++) {
            
            DrivingDetailsObject *ddObj = self.appModel.detailsAllDrivingScores[i];
            NSNumber *value;
            int count = +1;
            if (type == 0 && count == 1) {
                value = ddObj[@"SafetyScore"];
            } else if (type == 1) {
                value = ddObj[@"AccelerationScore"];
            } else if (type == 2) {
                value = ddObj[@"BrakingScore"];
            } else if (type == 3) {
                value = ddObj[@"PhoneUsageScore"];
            } else if (type == 4) {
                value = ddObj[@"SpeedingScore"];
            } else if (type == 5) {
                value = ddObj[@"CorneringScore"];
            } else {
                value = ddObj[@"SafetyScore"];
            }
            chartData[i] = [NSNumber numberWithFloat:value.floatValue];
            if (self.appModel.detailsAllDrivingScores.count == 1) {
                chartData[i+1] = [NSNumber numberWithFloat:value.floatValue];
            }
        }
    }
    
    NSMutableArray* daysWeek = [NSMutableArray arrayWithObjects:
                                localizeString(@"Monday"),
                                localizeString(@"Tuesday"),
                                localizeString(@"Wednesday"),
                                localizeString(@"Thursday"),
                                localizeString(@"Friday"),
                                localizeString(@"Saturday"),
                                @"", nil];
    if (self.appModel.detailsAllDrivingScores.count == 0) {
        daysWeek = [NSMutableArray arrayWithObjects:localizeString(@"Monday"), localizeString(@"Tuesday"), localizeString(@"Wednesday"), localizeString(@"Thursday"), localizeString(@"Friday"), localizeString(@"Saturday"), @"", nil];
    } else {
        daysWeek = [NSMutableArray arrayWithCapacity:self.appModel.detailsAllDrivingScores.count];
        for (int i=0; i < self.appModel.detailsAllDrivingScores.count; i++) {
            
            DrivingDetailsObject *individualObj = self.appModel.detailsAllDrivingScores[i];
            NSString *currentDateValue = individualObj[@"CalcDate"];
            
            if (currentDateValue == nil)
                return;
            NSDate *dateStart = [NSDate dateWithISO8601String:currentDateValue];
            NSString *dateStartFormat = [dateStart dayDateShort];
            
            if (i == self.appModel.detailsAllDrivingScores.count - 1) {
                if (self.appModel.detailsAllDrivingScores.count == 1) {
                    daysWeek[i] = dateStartFormat;
                    daysWeek[i+1] = @"";
                } else {
                    daysWeek[i] = dateStartFormat; //daysWeek[i] = @"";
                }
            } else {
                daysWeek[i] = dateStartFormat;
            }
        }
    }
    
    _chartWithDates.verticalGridStep = 4;
    if (self.appModel.detailsAllDrivingScores.count <=4 && self.appModel.detailsAllDrivingScores != nil) {
        _chartWithDates.horizontalGridStep = (int)self.appModel.detailsAllDrivingScores.count;
    } else if (self.appModel.detailsAllDrivingScores != nil) {
        _chartWithDates.horizontalGridStep = (int)self.appModel.detailsAllDrivingScores.count;
    } else {
        _chartWithDates.horizontalGridStep = 5;
    }
    
    _chartWithDates.fillColor = [[Color OfficialDELBlueColor] colorWithAlphaComponent:0.1];
    _chartWithDates.displayDataPoint = YES;
    _chartWithDates.lineWidth = 3;
    _chartWithDates.dataPointColor = [Color OfficialDELBlueColor];
    _chartWithDates.dataPointBackgroundColor = [Color OfficialDELBlueColor];
    _chartWithDates.dataPointRadius = 0;
    _chartWithDates.color = [_chartWithDates.dataPointColor colorWithAlphaComponent:1.0];
    _chartWithDates.valueLabelPosition = ValueLabelLeftMirrored;
    
    _chartWithDates.fd_collapsed = NO;
    _chartWithDates.hidden = NO;
    [self.arrowUpDownBtn setImage:[UIImage imageNamed:@"curve_circle_down"] forState:UIControlStateNormal];
    
    if (self.needHideLinearGraph) {
        _chartWithDates.fd_collapsed = NO;
        _chartWithDates.hidden = NO;
        [self.arrowUpDownBtn setImage:[UIImage imageNamed:@"curve_circle_up"] forState:UIControlStateNormal];
    }
    
    _chartWithDates.labelForValue = ^(CGFloat value) {
        return [NSString stringWithFormat:@"%.f", value];
    };
    
    _chartWithDates.labelForIndex = ^(NSUInteger item) {
        return daysWeek[item];
    };
    
    [_chartWithDates setChartData:chartData];
}


#pragma mark - Graph Dashboard CollectionView Main Graph with Smiles

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.collectionViewCurve) {
        
        DashLiteCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DashLiteCell class]) forIndexPath:indexPath];
        cell.tag = indexPath.section;
        
        NSInteger numSection = indexPath.section;
        if (numSection == 0) {
            [cell loadGauge:self.appModel.detailsScoreOverall curveName:localizeString(@"dash_overall")];
        } else if (numSection == 1) {
            [cell loadGauge:self.appModel.detailsScoreAcceleration curveName:localizeString(@"dash_acceleration")];
        } else if (numSection == 2) {
            [cell loadGauge:self.appModel.detailsScoreDeceleration curveName:localizeString(@"dash_braking")];
        } else if (numSection == 3) {
            [cell loadGauge:self.appModel.detailsScorePhoneUsage curveName:localizeString(@"dash_phone")];
        } else if (numSection == 4) {
            [cell loadGauge:self.appModel.detailsScoreSpeeding curveName:localizeString(@"dash_speeding")];
        } else {
            [cell loadGauge:self.appModel.detailsScoreTurn curveName:localizeString(@"dash_cornering")];
        }
        return cell;
        
    } else if (collectionView == self.collectionViewDemoCurve) {
        
        DashLiteCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DashLiteCell class]) forIndexPath:indexPath];
        cell.tag = indexPath.section;
        
        NSInteger numSection = indexPath.section;
        if (numSection == 0) {
            [cell loadDemoGauge:@97 curveName:localizeString(@"dash_overall")];
        } else if (numSection == 1) {
            [cell loadDemoGauge:@85 curveName:localizeString(@"dash_acceleration")];
        } else if (numSection == 2) {
            [cell loadDemoGauge:@76 curveName:localizeString(@"dash_braking")];
        } else if (numSection == 3) {
            [cell loadDemoGauge:@65 curveName:localizeString(@"dash_phone")];
        } else if (numSection == 4) {
            [cell loadDemoGauge:@71 curveName:localizeString(@"dash_speeding")];
        } else {
            [cell loadDemoGauge:@90 curveName:localizeString(@"dash_cornering")];
        }
        return cell;
        
    } else if (collectionView == self.collectionViewActivity) {
        
        UserActivityCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UserActivityCell class]) forIndexPath:indexPath];
        if (indexPath.row == 0) {
            if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                float mi1 = convertKmToMiles(self.appModel.statWeeklyAverageSpeed.floatValue);
                float mi2 = convertKmToMiles(self.appModel.statWeeklyMaxSpeed.floatValue);
                float mi3 = convertKmToMiles(self.appModel.statWeeklyTotalKm.floatValue);
                cell.averageSpeed.text = [NSString stringWithFormat:@"%.0f mi/h", mi1];
                cell.maxSpeed.text = [NSString stringWithFormat:@"%.0f mi/h", mi2];
                cell.averageTrip.text = [NSString stringWithFormat:@"%.0f mi", mi3];
            } else {
                cell.averageSpeed.text = [NSString stringWithFormat:@"%@ km/h", self.appModel.statWeeklyAverageSpeed];
                cell.maxSpeed.text = [NSString stringWithFormat:@"%@ km/h", self.appModel.statWeeklyMaxSpeed];
                cell.averageTrip.text = [NSString stringWithFormat:@"%@ km", self.appModel.statWeeklyTotalKm];
            }
        } else if (indexPath.row == 1) {
            if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                float mi1 = convertKmToMiles(self.appModel.statMonthlyAverageSpeed.floatValue);
                float mi2 = convertKmToMiles(self.appModel.statMonthlyMaxSpeed.floatValue);
                float mi3 = convertKmToMiles(self.appModel.statMonthlyTotalKm.floatValue);
                cell.averageSpeed.text = [NSString stringWithFormat:@"%.0f mi/h", mi1];
                cell.maxSpeed.text = [NSString stringWithFormat:@"%.0f mi/h", mi2];
                cell.averageTrip.text = [NSString stringWithFormat:@"%.0f mi", mi3];
            } else {
                cell.averageSpeed.text = [NSString stringWithFormat:@"%@ km/h", self.appModel.statMonthlyAverageSpeed];
                cell.maxSpeed.text = [NSString stringWithFormat:@"%@ km/h", self.appModel.statMonthlyMaxSpeed];
                cell.averageTrip.text = [NSString stringWithFormat:@"%@ km", self.appModel.statMonthlyTotalKm];
            }
        } else if (indexPath.row == 2) {
            if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                float mi1 = convertKmToMiles(self.appModel.statYearlyAverageSpeed.floatValue);
                float mi2 = convertKmToMiles(self.appModel.statYearlyMaxSpeed.floatValue);
                float mi3 = convertKmToMiles(self.appModel.statYearlyTotalKm.floatValue);
                cell.averageSpeed.text = [NSString stringWithFormat:@"%.0f mi/h", mi1];
                cell.maxSpeed.text = [NSString stringWithFormat:@"%.0f mi/h", mi2];
                cell.averageTrip.text = [NSString stringWithFormat:@"%.0f mi", mi3];
            } else {
                cell.averageSpeed.text = [NSString stringWithFormat:@"%@ km/h", self.appModel.statYearlyAverageSpeed];
                cell.maxSpeed.text = [NSString stringWithFormat:@"%@ km/h", self.appModel.statYearlyMaxSpeed];
                cell.averageTrip.text = [NSString stringWithFormat:@"%@ km", self.appModel.statYearlyTotalKm];
            }
        }
        return cell;
        
    } else if (collectionView == self.demo_collectionViewActivity) {
        UserActivityCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UserActivityCell class]) forIndexPath:indexPath];
        cell.averageSpeed.text = @"?";
        cell.maxSpeed.text = @"?";
        cell.averageTrip.text = @"?";
        return cell;
    } else {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
        UILabel *lbl = [cell viewWithTag:10];
        
        NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
        imageAttachment.image = [UIImage imageNamed:@"info"];
        CGFloat imageOffsetY = -2.0;
        imageAttachment.bounds = CGRectMake(-4.0, imageOffsetY, imageAttachment.image.size.width/2, imageAttachment.image.size.height/2);
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
        NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:@""];
        [completeText appendAttributedString:attachmentString];
        
        NSNumber *numSection = [self.collectionAdviceTitleArr objectAtIndex:indexPath.section];
        NSString *totalLbl1 = localizeString(@"Users drive ");
        NSString *totalLbl2 = localizeString(@"60% safer");
        NSString *totalLbl3 = localizeString(@" with our awesome app!");
        NSString *totalMainLbl = [NSString stringWithFormat:@"%@%@%@", totalLbl1, totalLbl2, totalLbl3];
        NSString *additionalLbl = localizeString(@"Save time & money when searching for the best auto, life, home, or health insurance policy online");
        
        if (numSection.intValue == 2) {
            totalLbl1 = localizeString(@"Always listen ");
            totalLbl2 = localizeString(@"carefully");
            totalLbl3 = localizeString(@" to our advices!");
            totalMainLbl = [NSString stringWithFormat:@"%@%@%@", totalLbl1, totalLbl2, totalLbl3];
            additionalLbl = localizeString(@"Inappropriate braking behaviour has a cumulative effect on a vehicle safety systems. This leads to increased risk!");
        }
        
        NSMutableAttributedString *textAfterIcon = [[NSMutableAttributedString alloc] initWithString:totalMainLbl];
        
        NSRange mainRange = [totalMainLbl rangeOfString:totalMainLbl];
        UIFont *mainFont = [Font medium14];
        if (IS_IPHONE_5 || IS_IPHONE_4)
            mainFont = [Font medium10];
        
        [textAfterIcon addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:mainRange];
        [textAfterIcon addAttribute:NSFontAttributeName value:mainFont range:mainRange];
        
        NSRange range = [totalMainLbl rangeOfString:totalLbl2];
        [textAfterIcon addAttribute:NSForegroundColorAttributeName value:[Color officialMainAppColor] range:range];
        [textAfterIcon addAttribute:NSFontAttributeName value:[Font bold14] range:range];
        
        [completeText appendAttributedString:textAfterIcon];
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.attributedText = completeText;
        
        UILabel *lbl2 = [cell viewWithTag:11];
        [lbl2 setText:additionalLbl];
        lbl2.numberOfLines = 2;
        lbl2.lineBreakMode = NSLineBreakByWordWrapping;
        [lbl2 setFont:[Font regular11]];
        
        return cell;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (collectionView == self.collectionViewCurve || collectionView == self.collectionViewDemoCurve) {
        return 6;
    } else if (collectionView == self.collectionViewActivity || collectionView == self.demo_collectionViewActivity) {
        return 1;
    } else {
        return 2;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.collectionViewCurve || collectionView == self.collectionViewDemoCurve) {
        return 1;
    } else if (collectionView == self.collectionViewActivity || collectionView == self.demo_collectionViewActivity) {
        return self.activityDates.count;
    } else {
        return 1;
    }
}


#pragma mark - Graph Dashboard Scroll Delegate & All Scrolls

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.collectionViewCurve) {
        [self.collectionViewCurve layoutIfNeeded];
        for (DashLiteCell *cell in [self.collectionViewCurve visibleCells]) {
            NSIndexPath *indexPath = [self.collectionViewCurve indexPathForCell:cell];
            [self loadLinearChart:(long)indexPath.section];
        }
    } else if (scrollView == self.collectionViewDemoCurve) {
        [self.collectionViewDemoCurve layoutIfNeeded];
        for (DashLiteCell *cell in [self.collectionViewDemoCurve visibleCells]) {
            NSIndexPath *indexPath = [self.collectionViewDemoCurve indexPathForCell:cell];
            [self loadLinearChart:(long)indexPath.section];
        }
    }
}

- (IBAction)scrollCurveCollectionBackToPage:(id)sender {
    NSInteger firstSectionIndex = MAX(0, 1);
    NSInteger firstRowIndex = MAX(0, 1);
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:firstRowIndex inSection:firstSectionIndex - 1];
    
    NSArray *visibleItems = [self.collectionViewCurve indexPathsForVisibleItems];
    NSIndexPath *currentItem = [visibleItems objectAtIndex:0];
    if (currentItem.section == 0) {
        NSIndexPath *backtItem = [NSIndexPath indexPathForItem:0 inSection:5];
        [self.collectionViewCurve scrollToItemAtIndexPath:backtItem atScrollPosition:UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        [self loadLinearChart:backtItem.section];
        return;
    }
    
    NSIndexPath *backtItem = [NSIndexPath indexPathForItem:0 inSection:currentItem.section - 1];
    if (backtItem == firstIndexPath)
        return;
    
    [self.collectionViewCurve scrollToItemAtIndexPath:backtItem atScrollPosition:UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self loadLinearChart:backtItem.section];
}

- (IBAction)scrollCurveCollectionNextToPage:(id)sender {
    NSInteger lastSectionIndex = MAX(0, [self.collectionViewCurve numberOfSections] - 1);
    NSInteger lastRowIndex = MAX(0, [self.collectionViewCurve numberOfItemsInSection:lastSectionIndex] - 1);
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex + 1];
    
    NSArray *visibleItems = [self.collectionViewCurve indexPathsForVisibleItems];
    if (visibleItems.count == 0) {
        return;
    }
    NSIndexPath *currentItem = [visibleItems objectAtIndex:0];
    NSIndexPath *nextItem = [NSIndexPath indexPathForItem:0 inSection:currentItem.section + 1];
    if (nextItem == lastIndexPath) {
        nextItem = [NSIndexPath indexPathForItem:0 inSection:0];
        [self.collectionViewCurve scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        [self loadLinearChart:nextItem.section];
        return;
    }
    
    [self.collectionViewCurve scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self loadLinearChart:nextItem.section];
}

- (IBAction)scrollDemoCurveCollectionBackToPage:(id)sender {
    NSInteger firstSectionIndex = MAX(0, 1);
    NSInteger firstRowIndex = MAX(0, 1);
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:firstRowIndex inSection:firstSectionIndex - 1];
    
    NSArray *visibleItems = [self.collectionViewDemoCurve indexPathsForVisibleItems];
    NSIndexPath *currentItem = [visibleItems objectAtIndex:0];
    if (currentItem.section == 0) {
        NSIndexPath *backtItem = [NSIndexPath indexPathForItem:0 inSection:5];
        
        [self.collectionViewDemoCurve scrollToItemAtIndexPath:backtItem atScrollPosition:UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        [self loadLinearChart:backtItem.section];
        return;
    }
    
    NSIndexPath *backtItem = [NSIndexPath indexPathForItem:0 inSection:currentItem.section - 1];
    if (backtItem == firstIndexPath)
        return;
    
    [self.collectionViewDemoCurve scrollToItemAtIndexPath:backtItem atScrollPosition:UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self loadLinearChart:backtItem.section];
}

- (IBAction)scrollDemoCurveCollectionNextToPage:(id)sender {
    NSInteger lastSectionIndex = MAX(0, [self.collectionViewCurve numberOfSections] - 1);
    NSInteger lastRowIndex = MAX(0, [self.collectionViewCurve numberOfItemsInSection:lastSectionIndex] - 1);
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex + 1];
    
    NSArray *visibleItems = [self.collectionViewDemoCurve indexPathsForVisibleItems];
    if (visibleItems.count == 0) {
        return;
    }
    NSIndexPath *currentItem = [visibleItems objectAtIndex:0];
    NSIndexPath *nextItem = [NSIndexPath indexPathForItem:0 inSection:currentItem.section + 1];
    if (nextItem == lastIndexPath) {
        nextItem = [NSIndexPath indexPathForItem:0 inSection:0];
        [self.collectionViewDemoCurve scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        [self loadLinearChart:nextItem.section];
        return;
    }
    
    [self.collectionViewDemoCurve scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionCenteredVertically | UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self loadLinearChart:nextItem.section];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.mainScrollView) {
        CGFloat y =  - scrollView.contentOffset.y - scrollView.contentInset.top;
        self.mainScrollView.layer.cornerRadius = 16;
        
        if (scrollView.contentOffset.y < 0) {
            self.mainBackgroundView.frame = CGRectMake(self.mainBackgroundView.frame.origin.x, self.mainBackgroundView.frame.origin.y, self.mainBackgroundView.frame.size.width, y + 156);
        }
    } else if (scrollView == self.collectionViewStartAdvice) {
            int index = scrollView.contentOffset.x / scrollView.frame.size.width;
            pageCtrlStartAdvice.currentPage = index;
    } else if (scrollView == self.collectionViewActivity) {
        if (self.lastContentOffset > scrollView.contentOffset.x || self.lastContentOffset < scrollView.contentOffset.x) {
            [_activityTabBarView setTabbarOffsetX:(scrollView.contentOffset.x)/self.collectionViewActivity.bounds.size.width];
        }
    } else if (scrollView == self.demo_collectionViewActivity) {
        if (self.lastContentOffset > scrollView.contentOffset.x || self.lastContentOffset < scrollView.contentOffset.x) {
            [_demo_activityTabBarView setTabbarOffsetX:(scrollView.contentOffset.x)/self.demo_collectionViewActivity.bounds.size.width];
        }
    } else if (scrollView == self.collectionViewDemoCurve) {
        float contentOffsetWhenFullyScrolledRight = self.collectionViewDemoCurve.frame.size.width * 5;
            
        if (scrollView.contentOffset.x >= (contentOffsetWhenFullyScrolledRight + 50.0f)) {
            NSIndexPath *firstIndex = [NSIndexPath indexPathForItem:0 inSection:0];
            [self.collectionViewDemoCurve scrollToItemAtIndexPath:firstIndex atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
            [self loadLinearChart:firstIndex.section];
        } else if (scrollView.contentOffset.x <= -50.0f)  {
            NSIndexPath *lastIndex = [NSIndexPath indexPathForItem:0 inSection:5];
            [self.collectionViewDemoCurve scrollToItemAtIndexPath:lastIndex atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
            [self loadLinearChart:lastIndex.section];
        }
        
        int index = scrollView.contentOffset.x / scrollView.frame.size.width;
        demoCurvePageCtrl.currentPage = index;
    } else {
        float contentOffsetWhenFullyScrolledRight = self.collectionViewCurve.frame.size.width * 5;
            
        if (scrollView.contentOffset.x >= (contentOffsetWhenFullyScrolledRight + 50.0f)) {
            NSIndexPath *firstIndex = [NSIndexPath indexPathForItem:0 inSection:0];
            [self.collectionViewCurve scrollToItemAtIndexPath:firstIndex atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
            [self loadLinearChart:firstIndex.section];
        } else if (scrollView.contentOffset.x <= -50.0f)  {
            NSIndexPath *lastIndex = [NSIndexPath indexPathForItem:0 inSection:5];
            [self.collectionViewCurve scrollToItemAtIndexPath:lastIndex atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
            [self loadLinearChart:lastIndex.section];
        }
        
        int index = scrollView.contentOffset.x / scrollView.frame.size.width;
        curvePageCtrl.currentPage = index;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.frame.size.width/1.0f, ceilf(collectionView.frame.size.height/1.0f));
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Check Permissions Timer We Need LOCATION ALWAYS!!!

- (void)mainCheckPermissions {
    
    BOOL isMotionEnabled = [[WiFiGPSChecker sharedChecker] motionAvailable];
    BOOL isGPSAuthorized = ([CLLocationManager locationServicesEnabled]
                            && ([CLLocationManager authorizationStatus]
                                == kCLAuthorizationStatusAuthorizedAlways));
    
#if TARGET_IPHONE_SIMULATOR
    isMotionEnabled = YES;
#endif
    
    if (!isGPSAuthorized) {
        permissionPopup.disabledGPS = YES;
    }
    if (!isMotionEnabled) {
        permissionPopup.disabledMotion = YES;
    }
    
    //always NO if needed
    permissionPopup.disabledPush = NO;
        
    if ([defaults_object(@"needTrackingOnRequired") boolValue]) {
        
        if (permissionPopup.disabledGPS || permissionPopup.disabledMotion || permissionPopup.disabledPush) {
            self.mainDashboardView.hidden = NO;
            self.demoDashboardView.hidden = YES;
            
            if ([defaults_object(@"userDoneWizard") boolValue]) {
                float requiredDistance = self.appModel.statDistanceForScoring.floatValue;
                float userRealDistance = self.appModel.statSummaryDistance.floatValue;
                if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                    userRealDistance = convertKmToMiles(userRealDistance);
                }
                
                if (userRealDistance < requiredDistance) {
                    self.mainDashboardView.hidden = YES;
                    self.demoDashboardView.hidden = NO;
                    [self updateMainConstraints];
                } else {
                    self.mainDashboardView.hidden = NO;
                    self.demoDashboardView.hidden = YES;
                    [self updateMainConstraints];
                }
                
                //SHOW PERMISSION POPUP ONLY ONCE
                [permissionPopup showPopup];
                defaults_set_object(@"permissionPopupShowing", @(YES));
            } else {
                if (!isGPSAuthorized || !isMotionEnabled) {
                    if (![defaults_object(@"permissionPopupShowing") boolValue]) {
                        if (isGPSAuthorized) {
                            self->permissionPopup.disabledGPS = NO;
                        } else {
                            self->permissionPopup.disabledGPS = YES;
                        }
                            
                        if (isMotionEnabled) {
                            self->permissionPopup.disabledMotion = NO;
                        } else {
                            self->permissionPopup.disabledMotion = YES;
                        }
                        
                        //SHOW PERMISSION POPUP ONLY ONCE
                        [permissionPopup showPopup];
                        defaults_set_object(@"permissionPopupShowing", @(YES));
                    }
                }
            }
            
        } else {
            
            float requiredDistance = self.appModel.statDistanceForScoring.floatValue;
            float userRealDistance = self.appModel.statSummaryDistance.floatValue;
            if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                userRealDistance = convertKmToMiles(userRealDistance);
            }
            
            if (userRealDistance < requiredDistance) {
                self.mainDashboardView.hidden = YES;
                self.demoDashboardView.hidden = NO;
            } else {
                self.mainDashboardView.hidden = NO;
                self.demoDashboardView.hidden = YES;
                [self updateMainConstraints];
            }
        }
    } else {
        if ([defaults_object(@"userDidNotNeedTrackingOnRequired") boolValue]) {
            if (permissionPopup.disabledGPS || permissionPopup.disabledMotion || permissionPopup.disabledPush) {
                self.mainDashboardView.hidden = NO;
                self.demoDashboardView.hidden = YES;
                
                //SHOW PERMISSION POPUP ONLY ONCE
                [permissionPopup showPopup];
                defaults_set_object(@"permissionPopupShowing", @(YES));
            }
        } else {
            if ([defaults_object(@"needTrackingOnRequired") boolValue]) {
                defaults_set_object(@"userDidNotNeedTrackingOnRequired", @(YES));
                
                self.mainDashboardView.hidden = NO;
                self.demoDashboardView.hidden = YES;
            }
        }
    }
}

- (void)setNeedDisplayAlert:(BOOL)needDisplayAlert {
    _needDisplayAlert = needDisplayAlert;
    
    if (self.needDisplayAlert) {
        if ([defaults_object(@"onDemandTracking") boolValue]) {
            if (!self.jobsOnDutyTimerImplementation.isValid) {
                self.jobsOnDutyTimerImplementation = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateOnDutyStartTextFieldDate) userInfo:nil repeats:YES];
            }
        } else {
            if (!self.jobsOnDutyTimerImplementation.isValid) {
                self.jobsOnDutyTimerImplementation = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateOnDutyStartTextFieldDate) userInfo:nil repeats:YES]; //TEST?
            }
        }
        
        if (!self.alertTimer.isValid) {
            self.alertTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(checkAlertRunTimer) userInfo:nil repeats:YES];
        }
        
    } else {
        [self.alertTimer invalidate];
        self.alertTimer = nil;
        [self.jobsOnDutyTimerImplementation invalidate];
        self.jobsOnDutyTimerImplementation = nil;
    }
}

- (void)checkAlertRunTimer {
    [self timerCheckPermissions];
}

- (void)updateOnDutyStartTextFieldDate {
    NSDate *currentDate = [NSDate date];
    if ([Configurator sharedInstance].needAmPmTime || [defaults_object(@"needDateSpecialFormat") boolValue] || [defaults_object(@"needAmPmFormat") boolValue]) {
        if ([defaults_object(@"needDateSpecialFormat") boolValue] && ![defaults_object(@"needAmPmFormat") boolValue]) {
            self.jobsOnDutyTimerTextField.text = [currentDate dateTimeStringShortMmDd24_OnDemand];
        } else if (![defaults_object(@"needDateSpecialFormat") boolValue] && [defaults_object(@"needAmPmFormat") boolValue]) {
            self.jobsOnDutyTimerTextField.text = [currentDate dateTimeStringShortDdMmAmPm_OnDemand];
        } else if (![defaults_object(@"needDateSpecialFormat") boolValue] && ![defaults_object(@"needAmPmFormat") boolValue]) {
            self.jobsOnDutyTimerTextField.text = [currentDate dateTimeStringShort_OnDemand];
        } else {
            self.jobsOnDutyTimerTextField.text = [currentDate dateTimeStringShortMmDdAmPm_OnDemand];
        }
    } else {
        self.jobsOnDutyTimerTextField.text = [currentDate dateTimeStringShort_OnDemand];
    }
}

- (void)timerCheckPermissions {
    
    BOOL isMotionEnabled = [[WiFiGPSChecker sharedChecker] motionAvailable];
    BOOL isGPSAuthorized = ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways));
    
#if TARGET_IPHONE_SIMULATOR
    isMotionEnabled = YES;
#endif
    
    if (!isGPSAuthorized || !isMotionEnabled) {
        
        self.mainDashboardView.hidden = NO;
        self.demoDashboardView.hidden = YES;
        
        if ([defaults_object(@"userDoneWizard") boolValue]) {
            float requiredDistance = self.appModel.statDistanceForScoring.floatValue;
            float userRealDistance = self.appModel.statSummaryDistance.floatValue;
            if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                userRealDistance = convertKmToMiles(userRealDistance);
            }
            
            if (userRealDistance < requiredDistance) {
                self.mainDashboardView.hidden = YES;
                self.demoDashboardView.hidden = NO;
                [self updateMainConstraints];
            } else {
                self.mainDashboardView.hidden = NO;
                self.demoDashboardView.hidden = YES;
                [self updateMainConstraints];
            }
            
            if (isGPSAuthorized) {
                self->permissionPopup.disabledGPS = NO;
            } else if (isMotionEnabled) {
                self->permissionPopup.disabledMotion = NO;
            }
            
            if (!isGPSAuthorized || !isMotionEnabled) {
                if (![defaults_object(@"permissionPopupShowing") boolValue]) {
                    if (isGPSAuthorized) {
                        self->permissionPopup.disabledGPS = NO;
                    } else {
                        self->permissionPopup.disabledGPS = YES;
                    }
                        
                    if (isMotionEnabled) {
                        self->permissionPopup.disabledMotion = NO;
                    } else {
                        self->permissionPopup.disabledMotion = YES;
                    }
                    
                    //SHOW PERMISSION POPUP ONLY ONCE
                    [permissionPopup showPopup];
                    defaults_set_object(@"permissionPopupShowing", @(YES));
                }
            }
        } else {
            if (!isGPSAuthorized || !isMotionEnabled) {
                if (![defaults_object(@"permissionPopupShowing") boolValue]) {
                    if (isGPSAuthorized) {
                        self->permissionPopup.disabledGPS = NO;
                    } else {
                        self->permissionPopup.disabledGPS = YES;
                    }
                        
                    if (isMotionEnabled) {
                        self->permissionPopup.disabledMotion = NO;
                    } else {
                        self->permissionPopup.disabledMotion = YES;
                    }
                    
                    //SHOW PERMISSION POPUP ONLY ONCE
                    [permissionPopup showPopup];
                    defaults_set_object(@"permissionPopupShowing", @(YES));
                }
            }
            
            float requiredDistance = self.appModel.statDistanceForScoring.floatValue;
            float userRealDistance = self.appModel.statSummaryDistance.floatValue;
            if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                userRealDistance = convertKmToMiles(userRealDistance);
            }
                
            if (userRealDistance < requiredDistance) {
                self.mainDashboardView.hidden = YES;
                self.demoDashboardView.hidden = NO;
            } else {
                self.mainDashboardView.hidden = NO;
                self.demoDashboardView.hidden = YES;
            }
            [self updateMainConstraints];
        }
        
    } else {
        
        float requiredDistance = self.appModel.statDistanceForScoring.floatValue;
        float userRealDistance = self.appModel.statSummaryDistance.floatValue;
        if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
            userRealDistance = convertKmToMiles(userRealDistance);
        }
        if (userRealDistance < requiredDistance) {
            self.mainDashboardView.hidden = YES;
            self.demoDashboardView.hidden = NO;
            self->permissionPopup.disabledGPS = NO;
            self->permissionPopup.disabledMotion = NO;
            [self updateMainConstraints];
            
            if ([defaults_object(@"permissionPopupShowing") boolValue]) {
                //HIDE PERMISSION POPUP ONLY ONCE
                [permissionPopup hidePopup];
                defaults_set_object(@"permissionPopupShowing", @(NO));
            }
        } else {
            self.mainDashboardView.hidden = NO;
            self.demoDashboardView.hidden = YES;
            [self updateMainConstraints];
            
            if ([defaults_object(@"permissionPopupShowing") boolValue]) {
                //HIDE PERMISSION POPUP ONLY ONCE
                [permissionPopup hidePopup];
                defaults_set_object(@"permissionPopupShowing", @(NO));
            }
            
            if (!_disableRefreshGraph) {
                [self.collectionViewCurve reloadData];
                _disableRefreshGraph = YES;
            }
            
            defaults_set_object(@"needTrackingOnRequired", @(YES));
            self->permissionPopup.disabledGPS = NO;
            
            if ([defaults_object(@"userDoneWizard") boolValue]) {
                if ([defaults_object(@"userWorkingWithPermissionsWizardNow") boolValue]) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IMMEDIATELY_5_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        defaults_set_object(@"userWorkingWithPermissionsWizardNow", @(NO));
                    });
                }
            }
        }
    }
    [self->permissionPopup setupButtonGPS];
    
    if (![defaults_object(@"needShowCongratulations") boolValue]) {
        if (!permissionPopup.disabledGPS && !permissionPopup.disabledMotion && !permissionPopup.disabledPush) {
            [self->permissionPopup hidePopup];
            //HIDE PERMISSION POPUP ONLY ONCE
            defaults_set_object(@"permissionPopupShowing", @(NO));
            [self->congratulationsPopup showCongratulationsPopup];
            defaults_set_object(@"needShowCongratulations", @(YES));
        }
    }
}


#pragma mark - Telematics SDK initialization on DASHBOARD AFTER WIZARD!!!

- (void)initPermissionsLocation {
    [TelematicsAppPrivacyRequestManager requestAuthorization:TelematicsAppPrivacyTypeLocationAlways handler:^(TelematicsAppAuthorizationStatus status) {
        if (status == TelematicsAppAuthorizationStatusAuthorizedAlways) {
            self->permissionPopup.disabledGPS = NO;
            [self->permissionPopup setupButtonGPS];
            
            [RPEntry initializeWithRequestingPermissions:NO];
            [RPEntry instance].virtualDeviceToken = [GeneralService sharedService].device_token_number;
            
            if ([Configurator sharedInstance].sdkEnableHighFrequency) {
                [RPEntry enableHF:YES];
            } else {
                [RPEntry enableHF:NO];
            }
            
            if ([Configurator sharedInstance].sdkEnableELM) {
                [RPEntry enableELM:YES];
            }
        }
        defaults_set_object(@"needTrackingOnRequired", @(YES));
    }];
}

- (void)initPermissionsMotion {
    [TelematicsAppPrivacyRequestManager requestAuthorization:TelematicsAppPrivacyTypeMotion handler:^(TelematicsAppAuthorizationStatus status) {
        if (status == TelematicsAppAuthorizationStatusAuthorized) {
            self->permissionPopup.disabledMotion = NO;
            [self->permissionPopup setupButtonMotion];
        }
        defaults_set_object(@"needMotionOn", @(YES));
    }];
}

- (void)initPushNotifications {
    //TODO PUSH-NOTIFICATIONS
}


#pragma mark - GeneralPermissionsPopup Permission Warning Actions

- (IBAction)startTelematicsBtnClick:(id)sender {
    if ([defaults_object(@"userDoneWizard") boolValue]) {
        //SHOW PERMISSION POPUP ONLY ONCE
        [permissionPopup showPopup];
        defaults_set_object(@"permissionPopupShowing", @(YES));
        defaults_set_object(@"userWorkingWithPermissionsWizardNow", @(NO));
    } else {
        if (@available(iOS 13.0, *)) {
            
            defaults_set_object(@"userWorkingWithPermissionsWizardNow", @(YES));
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                defaults_set_object(@"userWorkingWithPermissionsWizardNow", @(NO));
            });
            
            [[RPCSettings returnInstance] setWizardNextButtonBgColor:[Color officialMainAppColor]];
            [[RPCSettings returnInstance] setAppName:localizeString(@"TelematicsApp")];
            
            if ([Configurator sharedInstance].sdkEnableELM) {
                [[RPCPermissionsWizard returnInstance] setupBluetoothEnabled]; //IF YOU USE ELM BLUETOOTH CONNECTION ENABLE THIS LINE FOR TELEMATICS SDK
            }
            
            [[RPCPermissionsWizard returnInstance] launchWithFinish:^(BOOL showWizzard) {
                [RPEntry initializeWithRequestingPermissions:YES];
                [RPEntry instance].disableTracking = NO;
                [RPEntry instance].virtualDeviceToken = [GeneralService sharedService].device_token_number;
                
                if ([Configurator sharedInstance].sdkEnableHighFrequency) {
                    [RPEntry enableHF:YES];
                } else {
                    [RPEntry enableHF:NO];
                }
                
                if ([Configurator sharedInstance].sdkEnableELM) {
                    [RPEntry enableELM:YES];
                }
                
                defaults_set_object(@"userDoneWizard", @(YES));
                defaults_set_object(@"needTrackingOnRequired", @(YES));
            }];
            
            [[RPCPermissionsWizard returnInstance] setupHandlersWithUserNotificationResponce:^(BOOL granted, NSError * _Nullable error) {
                NSLog(@"PUSH_NOTIFICATIONS INIT SUCCESS");
                [self initPushNotifications];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    defaults_set_object(@"userWorkingWithPermissionsWizardNow", @(NO));
                });
            } motionManagerResponce:^(BOOL granted, NSError * _Nullable error) {
                NSLog(@"MOTION INIT SUCCESS");
                self->permissionPopup.disabledMotion = NO;
                defaults_set_object(@"needMotionOn", @(YES));
            } locationManagerResponce:^(CLAuthorizationStatus status) {
                NSLog(@"LOCATION INIT SUCCESS");
            }];
            
        } else {
            //IOS 12 AND LOWER
            if (![defaults_object(@"permissionPopupShowing") boolValue]) {
                //SHOW PERMISSION POPUP ONLY ONCE
                [permissionPopup showPopup];
                defaults_set_object(@"permissionPopupShowing", @(YES));
                defaults_set_object(@"userDoneWizard", @(YES)); //?
                defaults_set_object(@"userWorkingWithPermissionsWizardNow", @(NO));
            }
        }
    }
}

- (void)gpsButtonAction:(GeneralPermissionsPopup *)popupView button:(UIButton *)button {
    if ([defaults_object(@"needTrackingOnRequired") boolValue]) {
        [TelematicsAppPrivacyRequestManager gotoApplicationSystemSettings];
    } else {
        if ([CLLocationManager locationServicesEnabled]) {
            if (![defaults_object(@"userDoneWizard") boolValue]) {
                [self startTelematicsBtnClick:button];
            } else {
                [self initPermissionsLocation];
            }
        } else {
            [TelematicsAppPrivacyRequestManager gotoApplicationSystemSettings];
        }
    }
}

- (void)motionButtonAction:(GeneralPermissionsPopup *)popupView button:(UIButton *)button {
    switch ([CMMotionActivityManager authorizationStatus]) {
        case CMAuthorizationStatusNotDetermined:
        {
            [TelematicsAppPrivacyRequestManager requestAuthorizationMotionImmediately];
            defaults_set_object(@"needMotionOn", @(NO));
        }
            break;
        case CMAuthorizationStatusRestricted:
        {
            [TelematicsAppPrivacyRequestManager requestAuthorizationMotionImmediately];
            defaults_set_object(@"needMotionOn", @(NO));
        }
            break;
        case CMAuthorizationStatusDenied:
        {
            [TelematicsAppPrivacyRequestManager gotoApplicationSystemSettings];
            defaults_set_object(@"needMotionOn", @(NO));
        }
            break;
        case CMAuthorizationStatusAuthorized:
        {
            defaults_set_object(@"needMotionOn", @(YES));
        }
        default:
            break;
    }
}

- (void)pushButtonAction:(GeneralPermissionsPopup *)popupView button:(UIButton *)button {
    //HIDE PERMISSION POPUP ONLY ONCE
    [permissionPopup hidePopup];
    defaults_set_object(@"permissionPopupShowing", @(NO));
    [TelematicsAppPrivacyRequestManager gotoApplicationSystemSettings];
}


#pragma mark - Dashboard refresh spinner

- (void)refreshStatisticData:(id)sender {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IMMEDIATELY_3_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [sender endRefreshing];
    });
    [self getDashboardIndicatorsStatisticsData];
    [self getDashboardEcoDataAllTime];
    [self getDashboardEcoDataWeek];
    [self getDashboardEcoDataMonth];
    [self getDashboardEcoDataYear];
    
    [self setupAdditionalTranslation];
    defaults_set_object(@"LatestTripTokenInMemory", @"");
    [sender endRefreshing];
}


#pragma mark - CongratulationsPopup Actions

- (IBAction)showCongratulationsPopup:(id)sender {
    [congratulationsPopup showCongratulationsPopup];
}

- (void)okButtonAction:(CongratulationsPopup *)popupView button:(UIButton *)button {
    [congratulationsPopup hideCongratulationsPopup];
}


#pragma mark - EcoScoring

- (void)setupEcoViews {
    self.progressBarFuel.progress = 0.0f;
    self.progressBarTires.progress = 0.0f;
    self.progressBarBrakes.progress = 0.0f;
    self.progressBarCost.progress = 0.0f;
    
    self.timerFuel = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(incrementProgressFuel:) userInfo:nil repeats:YES];
    self.timerTires = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(incrementProgressTires:) userInfo:nil repeats:YES];
    self.timerBrakes = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(incrementProgressBrakes:) userInfo:nil repeats:YES];
    self.timerTravelCost = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(incrementProgressTravelCost:) userInfo:nil repeats:YES];
    
    _activityTabBarView.indicatorAttributes = @{CMTabIndicatorColor:[UIColor blackColor], CMTabIndicatorViewHeight:@(2.5f), CMTabBoxBackgroundColor:[UIColor blackColor]};
    _activityTabBarView.normalAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:10.0f]};
    _activityTabBarView.selectedAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:10.0f]};
    [_activityTabBarView setTabIndex:0 animated:NO];
    [_activityTabBarView reloadData];
    
    if (self.appModel.statEcoScoringFuel.intValue > 80) {
        self.progressBarFuel.barFillColor = [Color officialGreenColor];
    } else if (self.appModel.statEcoScoringFuel.intValue > 60) {
        self.progressBarFuel.barFillColor = [Color officialYellowColor];
    } else if (self.appModel.statEcoScoringFuel.intValue > 40) {
        self.progressBarFuel.barFillColor = [Color officialOrangeColor];
    } else {
        self.progressBarFuel.barFillColor = [Color officialRedColor];
    }
    
    if (self.appModel.statEcoScoringTyres.intValue > 80) {
        self.progressBarTires.barFillColor = [Color officialGreenColor];
    } else if (self.appModel.statEcoScoringTyres.intValue > 60) {
        self.progressBarTires.barFillColor = [Color officialYellowColor];
    } else if (self.appModel.statEcoScoringTyres.intValue > 40) {
        self.progressBarTires.barFillColor = [Color officialOrangeColor];
    } else {
        self.progressBarTires.barFillColor = [Color officialRedColor];
    }
    
    if (self.appModel.statEcoScoringBrakes.intValue > 80) {
        self.progressBarBrakes.barFillColor = [Color officialGreenColor];
    } else if (self.appModel.statEcoScoringBrakes.intValue > 60) {
        self.progressBarBrakes.barFillColor = [Color officialYellowColor];
    } else if (self.appModel.statEcoScoringBrakes.intValue > 40) {
        self.progressBarBrakes.barFillColor = [Color officialOrangeColor];
    } else {
        self.progressBarBrakes.barFillColor = [Color officialRedColor];
    }
    
    if (self.appModel.statEcoScoringDepreciation.intValue > 80) {
        self.progressBarCost.barFillColor = [Color officialGreenColor];
    } else if (self.appModel.statEcoScoringDepreciation.intValue > 60) {
        self.progressBarCost.barFillColor = [Color officialYellowColor];
    } else if (self.appModel.statEcoScoringDepreciation.intValue > 40) {
        self.progressBarCost.barFillColor = [Color officialOrangeColor];
    } else {
        self.progressBarCost.barFillColor = [Color officialRedColor];
    }
    
    [self.progressBarFuel setBarBackgroundColor:[Color lightSeparatorColor]];
    [self.progressBarTires setBarBackgroundColor:[Color lightSeparatorColor]];
    [self.progressBarBrakes setBarBackgroundColor:[Color lightSeparatorColor]];
    [self.progressBarCost setBarBackgroundColor:[Color lightSeparatorColor]];
    
    if (self.appModel.statRating >= self.appModel.statPreviousRating)
        self.arrowPercentImg.image = [UIImage imageNamed:@"arrow_up_green"];
    else
        self.arrowPercentImg.image = [UIImage imageNamed:@"arrow_down_red"];
    self.percentLbl.text = [NSString stringWithFormat:@"%.0f", self.appModel.statEco.floatValue];
    
    if (self.appModel.statEco.floatValue > 80) {
        self.roundPercentImg.image = [UIImage imageNamed:@"round_green"];
    } else if (self.appModel.statEco.floatValue > 60) {
        self.roundPercentImg.image = [UIImage imageNamed:@"round_yellow"];
    } else if (self.appModel.statEco.floatValue > 40) {
        self.roundPercentImg.image = [UIImage imageNamed:@"round_orange"];
    } else {
        self.roundPercentImg.image = [UIImage imageNamed:@"round_red"];
    }
    
    [self setAccident];
}

- (void)setAccident {
    self.tipAdviceLbl.text = localizeString(@"tip 2");
}


//DEMO DASHBOARD FOR NEW USERS LOWER 10km

- (void)setupEcoDemoBlock {

    self.mapDemo_noTripsView.hidden = NO;
    self.mapDemo_snapshot.hidden = NO;
    self.mapDemo_pointsLbl.hidden = YES;
    self.mapDemo_kmLbl.hidden = YES;
    self.mapDemo_startTimeLbl.hidden = YES;
    self.mapDemo_endTimeLbl.hidden = YES;
    [self.mapDemo_permissBtn setAttributedTitle:[self createOpenAppSettingsLblImgBefore:localizeString(@"Check App Permissions")] forState:UIControlStateNormal];
    
    _demo_activityTabBarView.indicatorAttributes = @{CMTabIndicatorColor:[UIColor blackColor], CMTabIndicatorViewHeight:@(2.5f), CMTabBoxBackgroundColor:[UIColor blackColor]};
    _demo_activityTabBarView.normalAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:10.0f]};
    _demo_activityTabBarView.selectedAttributes = @{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont boldSystemFontOfSize:10.0f]};
    [_demo_activityTabBarView setTabIndex:0 animated:NO];
    [_demo_activityTabBarView reloadData];

    self.demo_progressBarFuel.progress = 0.90f;
    self.demo_progressBarTires.progress = 0.80f;
    self.demo_progressBarBrakes.progress = 0.70f;
    self.demo_progressBarCost.progress = 0.60f;

    self.demo_progressBarFuel.barFillColor = [Color officialGreenColor];
    self.demo_progressBarTires.barFillColor = [Color officialYellowColor];
    self.demo_progressBarBrakes.barFillColor = [Color officialOrangeColor];
    self.demo_progressBarCost.barFillColor = [Color officialRedColor];

    [self.demo_progressBarFuel setBarBackgroundColor:[Color lightSeparatorColor]];
    [self.demo_progressBarTires setBarBackgroundColor:[Color lightSeparatorColor]];
    [self.demo_progressBarBrakes setBarBackgroundColor:[Color lightSeparatorColor]];
    [self.demo_progressBarCost setBarBackgroundColor:[Color lightSeparatorColor]];

    self.demo_progressBarFuel.alpha = 0.55;
    self.demo_progressBarTires.alpha = 0.55;
    self.demo_progressBarBrakes.alpha = 0.55;
    self.demo_progressBarCost.alpha = 0.55;

    self.demo_arrowPercentImg.image = [UIImage imageNamed:@"arrow_up_green"];
    self.demo_roundPercentImg.image = [UIImage imageNamed:@"round_lightgrey"];
    self.demo_percentLbl.text = @"?";
    self.demo_percentLbl.font = [Font heavy44];

    self.demo_tipAdviceLbl.text = localizeString(@"tip 2");
}

- (void)incrementProgressFuel:(NSTimer *)timer {
    int rate = [self.appModel.statEcoScoringFuel intValue];
    int rateProg = [@(self.progressBarFuel.progress*100) intValue];
    
    if (rateProg <= rate) {
        self.progressBarFuel.progress = self.progressBarFuel.progress + 0.01f;
    }
    if (rate == rateProg || rateProg > rate) {
        [_timerFuel invalidate];
    }
}

- (void)incrementProgressTires:(NSTimer *)timer {
    int rate = [self.appModel.statEcoScoringTyres intValue];
    int rateProg = [@(self.progressBarTires.progress*100) intValue];
    
    if (rateProg <= rate) {
        self.progressBarTires.progress = self.progressBarTires.progress + 0.01f;
    }
    if (rate == rateProg || rateProg > rate) {
        [_timerTires invalidate];
    }
}

- (void)incrementProgressBrakes:(NSTimer *)timer {
    int rate = [self.appModel.statEcoScoringBrakes intValue];
    int rateProg = [@(self.progressBarBrakes.progress*100) intValue];
    
    if (rateProg <= rate) {
        self.progressBarBrakes.progress = self.progressBarBrakes.progress + 0.01f;
    }
    if (rate == rateProg || rateProg > rate) {
        [_timerBrakes invalidate];
    }
}

- (void)incrementProgressTravelCost:(NSTimer *)timer {
    int rate = [self.appModel.statEcoScoringDepreciation intValue];
    int rateProg = [@(self.progressBarCost.progress*100) intValue];
    
    if (rateProg <= rate) {
        self.progressBarCost.progress = self.progressBarCost.progress + 0.01f;
    }
    if (rate == rateProg || rateProg > rate) {
        [_timerTravelCost invalidate];
    }
}


#pragma mark - ActivityTabBarView DataSource

- (NSArray<NSString *> *)tabbarTitlesForTabbarView:(CMTabbarView *)activityTabBarView {
    return self.activityDates;
}

- (void)tabbarView:(CMTabbarView *)activityTabBarView didSelectedAtIndex:(NSInteger)index {
    [self.collectionViewActivity scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:false];
    [self.demo_collectionViewActivity scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:false];
}


#pragma mark - Visual for Activity Eco Collection

- (void)setupEcoCollectionsForViews {
    self.activityDates = @[localizeString(@"WEEK"), localizeString(@"MONTH"), localizeString(@"YEAR")];
    
    [self.collectionViewActivity setContentOffset:CGPointMake(self.collectionViewActivity.bounds.size.width * 0, 0)];
    [self.collectionViewActivity registerNib:[UINib nibWithNibName:NSStringFromClass([UserActivityCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([UserActivityCell class])];
    [self.collectionViewActivity reloadData];
    
    [self.demo_collectionViewActivity setContentOffset:CGPointMake(self.demo_collectionViewActivity.bounds.size.width * 0, 0)];
    [self.demo_collectionViewActivity registerNib:[UINib nibWithNibName:NSStringFromClass([UserActivityCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([UserActivityCell class])];
    [self.demo_collectionViewActivity reloadData];
}


#pragma mark - Last Trip for Dashboard by HERE Maps http://developer.here.com

- (void)loadOneEventForDashboardMap {
    [[RPEntry instance].api getTracksWithOffset:0 limit:1 startDate:nil endDate:nil completion:^(id response, NSError *error) {
        RPFeed* feed = (RPFeed*)response;
        if (feed.tracks.count) {
            NSString *ttk = feed.tracks.firstObject.trackToken;
            NSString *latestTt = defaults_object(@"LatestTripTokenInMemory");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.mapDemo_noTripsView.hidden = YES;
                self.mapDemo_snapshot.hidden = NO;
                self.mapDemo_pointsLbl.hidden = NO;
                self.mapDemo_kmLbl.hidden = NO;
                self.mapDemo_startTimeLbl.hidden = NO;
                self.mapDemo_endTimeLbl.hidden = NO;
            });
            
            if (![ttk isEqualToString:latestTt])
                [self loadLastTrackData:ttk];
        } else {
            NSLog(@"NO LAST TRIP REQUEST ERROR");
        }
    }];
}

- (void)loadLastTrackData:(NSString*)ttk {
    [[RPEntry instance].api getTrackWithTrackToken:ttk completion:^(id response, NSError *error) {
        self.track = response;
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL loadMainData = NO;
            if (!self.track) {
                loadMainData = YES;
            }
            
            float rating = self.track.rating100;
            if (rating == 0)
                rating = self.track.rating*20;
            
            [self sheetUpdatePointsLabel:[NSString stringWithFormat:@"%.0f", rating]];
            
            if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                float miles = convertKmToMiles(self.track.distance);
                [self sheetUpdateKmLabel:[NSString stringWithFormat:@"%.1f", miles]];
            } else {
                [self sheetUpdateKmLabel:[NSString stringWithFormat:@"%.0f", self.track.distance]];
            }
            
            [self sheetUpdateStartEndTimeLabel:self.track.startDate timeEnd:self.track.endDate];
            
            [self loadMainMapPointsToSnapshot];
            
            if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                float miles = convertKmToMiles(self.track.distance);
                defaults_set_object(@"LatestTripDistance", [NSString stringWithFormat:@"%.1f", miles]);
            } else {
                defaults_set_object(@"LatestTripDistance", [NSString stringWithFormat:@"%.0f", self.track.distance]);
            }
            defaults_set_object(@"LatestTripTokenInMemory", ttk);
            defaults_set_object(@"LatestTripRating", [NSString stringWithFormat:@"%.0f", rating]);
            defaults_set_object(@"LatestTripTimeStart", self.track.startDate);
            defaults_set_object(@"LatestTripTimeEnd", self.track.endDate);
        });
    }];
}

- (void)sheetUpdatePointsLabel:(NSString*)points {
    if ([points containsString:@"."]) {
        NSRange rangeSearch = [points rangeOfString:@"." options:NSBackwardsSearch];
        points = [points substringToIndex:rangeSearch.location];
    }
    
    float p = [points floatValue];
    
    NSString *pointsLbl1 = points;
    NSString *pointsLbl2 = localizeString(@"dash_points");
    
    if (points.length > 0) {
        //
    } else {
        pointsLbl1 = @"";
        pointsLbl2 = @"";
    }
    
    NSString *totalPointsLbl = [NSString stringWithFormat:@"%@ %@", pointsLbl1, pointsLbl2];
    NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:totalPointsLbl];
    
    NSRange mainRangeTotalPoints = [totalPointsLbl rangeOfString:pointsLbl1];
    UIFont *mainFontTotalPoints = [Font heavy24];
    if (IS_IPHONE_5 || IS_IPHONE_4)
        mainFontTotalPoints = [Font heavy18];
    
    if (p > 80) {
        [completeText addAttribute:NSForegroundColorAttributeName value:[Color officialGreenColor] range:mainRangeTotalPoints];
    } else if (p > 60) {
        [completeText addAttribute:NSForegroundColorAttributeName value:[Color officialYellowColor] range:mainRangeTotalPoints];
    } else if (p > 40) {
        [completeText addAttribute:NSForegroundColorAttributeName value:[Color officialOrangeColor] range:mainRangeTotalPoints];
    } else {
        [completeText addAttribute:NSForegroundColorAttributeName value:[Color officialDarkRedColor] range:mainRangeTotalPoints];
    }
    
    [completeText addAttribute:NSFontAttributeName value:mainFontTotalPoints range:mainRangeTotalPoints];
    
    NSRange mainRangePointsLbl = [totalPointsLbl rangeOfString:pointsLbl2];
    UIFont *mainFontPointsLbl = [Font semibold13];
    if (IS_IPHONE_5 || IS_IPHONE_4)
        mainFontPointsLbl = [Font semibold11];
    
    [completeText addAttribute:NSForegroundColorAttributeName value:[Color lightGrayColor] range:mainRangePointsLbl];
    [completeText addAttribute:NSFontAttributeName value:mainFontPointsLbl range:mainRangePointsLbl];
    
    self.pointsLbl.attributedText = completeText;
    self.mapDemo_pointsLbl.attributedText = completeText;
}

- (void)sheetUpdateKmLabel:(NSString*)km {
    NSString *kmLbl1 = km;
    NSString *kmLbl2 = localizeString(@"dash_km");
    if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
        kmLbl2 = localizeString(@"dash_miles");
    }
    
    if (km.length > 0) {
        //
    } else {
        kmLbl1 = @"";
        kmLbl2 = @"";
    }
    
    NSString *totalKmLbl = [NSString stringWithFormat:@"%@ %@", kmLbl1, kmLbl2];
    NSMutableAttributedString *completeTextKm = [[NSMutableAttributedString alloc] initWithString:totalKmLbl];
    
    NSRange mainRange1 = [totalKmLbl rangeOfString:kmLbl1];
    UIFont *mainFont1 = [Font heavy24];
    if (IS_IPHONE_5 || IS_IPHONE_4)
        mainFont1 = [Font heavy18];
    
    [completeTextKm addAttribute:NSForegroundColorAttributeName value:[Color darkGrayColor] range:mainRange1];
    [completeTextKm addAttribute:NSFontAttributeName value:mainFont1 range:mainRange1];
    
    NSRange mainRange2 = [totalKmLbl rangeOfString:kmLbl2];
    UIFont *mainFont2 = [Font semibold13];
    if (IS_IPHONE_5 || IS_IPHONE_4)
        mainFont2 = [Font semibold11];
    
    [completeTextKm addAttribute:NSForegroundColorAttributeName value:[Color lightGrayColor] range:mainRange2];
    [completeTextKm addAttribute:NSFontAttributeName value:mainFont2 range:mainRange2];
    
    self.kmLbl.attributedText = completeTextKm;
    self.mapDemo_kmLbl.attributedText = completeTextKm;
}

- (void)sheetUpdateStartEndTimeLabel:(NSDate*)timeStart timeEnd:(NSDate*)timeEnd {
    NSString *stDate = [timeStart dateTimeStringShort];
    NSString *endDate = [timeEnd dateTimeStringShort];
    
    if ([Configurator sharedInstance].needAmPmTime || [defaults_object(@"needDateSpecialFormat") boolValue] || [defaults_object(@"needAmPmFormat") boolValue]) {
        if ([defaults_object(@"needDateSpecialFormat") boolValue] && ![defaults_object(@"needAmPmFormat") boolValue]) {
            stDate = [timeStart dateTimeStringShortMmDd24];
            endDate = [timeEnd dateTimeStringShortMmDd24];
        } else if (![defaults_object(@"needDateSpecialFormat") boolValue] && [defaults_object(@"needAmPmFormat") boolValue]) {
            stDate = [timeStart dateTimeStringShortDdMmAmPm];
            endDate = [timeEnd dateTimeStringShortDdMmAmPm];
        } else if (![defaults_object(@"needDateSpecialFormat") boolValue] && ![defaults_object(@"needAmPmFormat") boolValue]) {
            stDate = [timeStart dateTimeStringShortDdMm24];
            endDate = [timeEnd dateTimeStringShortDdMm24];
        } else {
            stDate = [timeStart dateTimeStringShortMmDdAmPm];
            endDate = [timeEnd dateTimeStringShortMmDdAmPm];
        }
    }
    
    self.startTimeLbl.attributedText = [self createStartDateLabelImgBefore:stDate];
    self.endTimeLbl.attributedText = [self createEndDateLabelImgBefore:endDate];
    self.mapDemo_startTimeLbl.attributedText = [self createStartDateLabelImgBefore:stDate];
    self.mapDemo_endTimeLbl.attributedText = [self createEndDateLabelImgBefore:endDate];
    if (IS_IPHONE_5 || IS_IPHONE_4) {
        self.startTimeLbl.font = [Font semibold11];
        self.endTimeLbl.font = [Font semibold11];
    }
}

- (void)loadMainMapPointsToSnapshot {
    NSMutableArray *allPointsArr = [[NSMutableArray alloc] init];
    NSMutableArray *markerPointsArr = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.track.points.count; i++) {
        RPTrackPointProcessed *point = self.track.points[i];
        
        NSString *la = [[NSNumber numberWithDouble:point.latitude] stringValue];
        NSString *lo = [[NSNumber numberWithDouble:point.longitude] stringValue];
        [allPointsArr addObject:la];
        [allPointsArr addObject:lo];
        
        if (i == 0 || i == self.track.points.count-1) {
            [markerPointsArr addObject:la];
            [markerPointsArr addObject:lo];
        }
    }
    
    NSString *specialAllPointsArrForHERE = [allPointsArr componentsJoinedByString:@","];
    NSString *specialMarkersPointsArrForHERE = [markerPointsArr componentsJoinedByString:@","];
    NSString *imgW = @"900";
    if (IS_IPHONE_5 || IS_IPHONE_4)
        imgW = @"700";
    
    //USE YOUR HEREMAPS KEYS FOR REST API REQUEST TO GENERATE JPG PICTURE WITH USER TRIP FOR DASHBOARD
    //YOU NEED GENERATE REST API KEY AT HTTP://DEVELOPER.HERE.COM AND PASTE IT IN CONFIGURATION.PLIST PLEASE! <mapsRestApiKey>
    NSString *resParams = [NSString stringWithFormat:@"?apiKey=%@&w=%@&h=%@&nocp=%@&ml=%@&mtxc=%@&lc=%@&mthm=%@&t=%@&ppi=%@&lw=%@&f=%@&mfc=%@&m=%@", [Configurator sharedInstance].mapsRestApiKey, imgW, @"360", @"1", @"eng", @"20", @"54C751", @"1", @"7", @"100", @"7", @"0", @"000000", specialMarkersPointsArrForHERE];
    NSString *finalURL = [NSString stringWithFormat:@"https://image.maps.ls.hereapi.com/mia/1.6/route%@", resParams];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:finalURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    NSDictionary *headers = @{@"Content-Type":@"application/x-www-form-urlencoded"};
    [request setAllHTTPHeaderFields:headers];
    
    NSString *rPoints = [NSString stringWithFormat:@"r=%@", specialAllPointsArrForHERE];
    NSData *postData = [[NSData alloc] initWithData:[rPoints dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
          UIImage *image = [UIImage imageWithData:data];
          dispatch_async(dispatch_get_main_queue(), ^{
              if (image != nil) {
                  self.mapSnapshot.layer.cornerRadius = 16;
                  self.mapSnapshot.contentMode = UIViewContentModeScaleAspectFill;
                  self.mapSnapshot.image = image;
                  
                  self.mapSnapshotForDemo.layer.cornerRadius = 16;
                  self.mapSnapshotForDemo.contentMode = UIViewContentModeScaleAspectFill;
                  self.mapSnapshotForDemo.image = image;
                  
                  self.mapDemo_snapshot.layer.cornerRadius = 16;
                  self.mapDemo_snapshot.contentMode = UIViewContentModeScaleAspectFill;
                  self.mapDemo_snapshot.image = image;

                  NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:data];
                  defaults_set_object(@"LatestTripPhotoTempory", encodedObject);
              }
          });
      }
    }];
    [dataTask resume];
}

- (void)loadLastCachedEventForDashboardMap {
    NSString *latestRating = defaults_object(@"LatestTripRating") ? defaults_object(@"LatestTripRating") : @"";
    NSString *latestDistance = defaults_object(@"LatestTripDistance") ? defaults_object(@"LatestTripDistance") : @"";
    NSDate *latestTimeStart = defaults_object(@"LatestTripTimeStart") ? defaults_object(@"LatestTripTimeStart") : nil;
    NSDate *latestTimeEnd = defaults_object(@"LatestTripTimeEnd") ? defaults_object(@"LatestTripTimeEnd") : nil;
    [self sheetUpdatePointsLabel:latestRating];
    [self sheetUpdateKmLabel:latestDistance];
    if (latestTimeStart != nil && latestTimeEnd != nil)
        [self sheetUpdateStartEndTimeLabel:latestTimeStart timeEnd:latestTimeEnd];
    
    NSData *encodedSavedObject = defaults_object(@"LatestTripPhotoTempory");
    UIImage *savedImg = [UIImage imageWithData:[NSKeyedUnarchiver unarchiveObjectWithData:encodedSavedObject]];
    if (savedImg != nil) {
        self.mapSnapshot.layer.cornerRadius = 16;
        self.mapSnapshot.contentMode = UIViewContentModeScaleAspectFill;
        self.mapSnapshot.image = savedImg;
        
        self.mapSnapshotForDemo.layer.cornerRadius = 16;
        self.mapSnapshotForDemo.contentMode = UIViewContentModeScaleAspectFill;
        self.mapSnapshotForDemo.image = savedImg;
    }
}


#pragma mark - UI Elements updates

- (void)setupRoundViews {
    self.mainBackgroundView.image = [UIImage imageNamed:[Configurator sharedInstance].additionalBackgroundImg];
    self.mainSuperView.layer.cornerRadius = 16;
    self.mainSuperView.layer.masksToBounds = NO;
    self.mainSuperView.layer.shadowOffset = CGSizeMake(0, 0);
    self.mainSuperView.layer.shadowRadius = 2;
    self.mainSuperView.layer.shadowOpacity = 0.1;
    
    self.demoDashboardView.layer.cornerRadius = 16;
    self.demoDashboardView.layer.masksToBounds = NO;
    self.demoDashboardView.layer.shadowOffset = CGSizeMake(0, 0);
    self.demoDashboardView.layer.shadowOpacity = 0.1;
    if ([defaults_object(@"onDemandTracking") boolValue]) {
        self.demoDashboardView.layer.shadowRadius = 0;
    } else {
        self.demoDashboardView.layer.shadowRadius = 2;
    }
    
    self.mainDashboardView.layer.cornerRadius = 16;
    self.mainDashboardView.layer.masksToBounds = NO;
    self.mainDashboardView.layer.shadowOffset = CGSizeMake(0, 0);
    self.mainDashboardView.layer.shadowOpacity = 0.1;
    if ([defaults_object(@"onDemandTracking") boolValue]) {
        self.mainDashboardView.layer.shadowRadius = 0;
    } else {
        self.mainDashboardView.layer.shadowRadius = 2;
    }
    
    self.jobsMainView.layer.cornerRadius = 16;
    self.jobsMainView.layer.masksToBounds = NO;
    self.jobsMainView.layer.shadowOffset = CGSizeMake(0, 0);
    self.jobsMainView.layer.shadowRadius = 2;
    self.jobsMainView.layer.shadowOpacity = 0.1;
    
    [self updateMainConstraints];
}

- (void)updateMainConstraints {
    float requiredDistance = self.appModel.statDistanceForScoring.floatValue;
    float userRealDistance = self.appModel.statSummaryDistance.floatValue;
    if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
        userRealDistance = convertKmToMiles(userRealDistance);
    }
    
    //Real-time update
    if ([defaults_object(@"onDemandTracking") boolValue]) {
        
        self.mainDashboardViewTopPositionForJobsREALConstraint.constant = 700;
        self.mainDashboardViewTopPositionForJobsDEMOConstraint.constant = 700;
        self.mainDashboardViewSpecialWhiteEndREALView.hidden = NO;
        self.mainDashboardViewSpecialWhiteEndDEMOView.hidden = NO;
        self.mainDashboardViewSpecialGreyEndView.hidden = NO;
        
        NSLayoutConstraint *heightConstraint;
        for (NSLayoutConstraint *constraint in self.mainScrollView.constraints) {
            if (constraint.firstAttribute == NSLayoutAttributeHeight) {
                heightConstraint = constraint;
                break;
            }
        }
        if (userRealDistance >= requiredDistance) {
            if (IS_IPHONE_5 || IS_IPHONE_4) {
                heightConstraint.constant = 1700;
            } else if (IS_IPHONE_8) {
                heightConstraint.constant = 1600;
            } else if (IS_IPHONE_8P) {
                heightConstraint.constant = 1620;
            } else if (IS_IPHONE_11 || IS_IPHONE_13_PRO) {
                heightConstraint.constant = 1550;
            } else if (IS_IPHONE_11_PROMAX || IS_IPHONE_13_PROMAX) {
                heightConstraint.constant = 1430;
            }
        } else if (userRealDistance < requiredDistance) {
            if (IS_IPHONE_5 || IS_IPHONE_4) {
                heightConstraint.constant = 1640;
            } else if (IS_IPHONE_8 || IS_IPHONE_8P) {
                heightConstraint.constant = 1560;
            } else if (IS_IPHONE_11 || IS_IPHONE_13_PRO) {
                heightConstraint.constant = 1470;
            } else if (IS_IPHONE_11_PROMAX || IS_IPHONE_13_PROMAX) {
                heightConstraint.constant = 1400;
            }
        }
        
    } else {
        
        self.mainDashboardViewTopPositionForJobsREALConstraint.constant = 0;
        self.mainDashboardViewTopPositionForJobsDEMOConstraint.constant = 0;
        self.mainDashboardViewSpecialWhiteEndREALView.hidden = YES;
        self.mainDashboardViewSpecialWhiteEndDEMOView.hidden = YES;
        self.mainDashboardViewSpecialGreyEndView.hidden = YES;
        
        NSLayoutConstraint *heightConstraint;
        for (NSLayoutConstraint *constraint in self.mainScrollView.constraints) {
            if (constraint.firstAttribute == NSLayoutAttributeHeight) {
                heightConstraint = constraint;
                break;
            }
        }
        if (userRealDistance >= requiredDistance) {
            if (IS_IPHONE_5 || IS_IPHONE_4) {
                heightConstraint.constant = 1000;
            } else if (IS_IPHONE_8) {
                heightConstraint.constant = 890;
            } else if (IS_IPHONE_8P) {
                heightConstraint.constant = 850;
            } else if (IS_IPHONE_11 || IS_IPHONE_13_PRO) {
                heightConstraint.constant = 830;
            } else if (IS_IPHONE_11_PROMAX || IS_IPHONE_13_PROMAX) {
                heightConstraint.constant = 730;
            }
        } else if (userRealDistance < requiredDistance) {
            if (IS_IPHONE_5 || IS_IPHONE_4) {
                heightConstraint.constant = 940;
            } else if (IS_IPHONE_8 || IS_IPHONE_8P) {
                heightConstraint.constant = 860;
            } else if (IS_IPHONE_11 || IS_IPHONE_13_PRO) {
                heightConstraint.constant = 770;
            } else if (IS_IPHONE_11_PROMAX || IS_IPHONE_13_PROMAX) {
                heightConstraint.constant = 700;
            }
        }
    }
}


#pragma mark - ONDEMAND TRACKING SAMPLE IMPLEMENTATION NOVEMBER 2021 - ON/OFF IN APP SETTINGS
#pragma mark - ONDEMAND Duty Job Main buttons

- (void)setupOnDemandUIDemoBlock {
    
    [[RPEntry instance].api getFutureTrackTag:0 completion:^(RPTagStatus status, NSArray<RPTag *> *tags, NSInteger timestamp) {
        for (RPTag *item in tags) {
            NSLog(@"%@", item.tag);
            NSLog(@"%@", item.source);
            NSLog(@"TAGS OK WORKING");
        }
    }];
    
    [self.mainScrollView setContentOffset:CGPointZero animated:NO];
    [self setupRoundViews];
    self.jobsOnDutyAcceptTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.jobsOnDutyCompletedTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if ([RPEntry instance].disableTracking) {
        [self.jobsStatusBtn setAttributedTitle:[self createJobOfflineBtnImgBefore:@"Offline"] forState:UIControlStateNormal];
        
        NSMutableAttributedString *goOnDuty = [[NSMutableAttributedString alloc] initWithString:localizeString(@"Go Online")];
        [goOnDuty addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [goOnDuty length])];
        [goOnDuty addAttribute:NSForegroundColorAttributeName value:[Color officialMainAppColor] range:NSMakeRange(0, [goOnDuty length])];
        [self.jobsGoBtn setAttributedTitle:goOnDuty forState:UIControlStateNormal];
    } else {
        [self.jobsStatusBtn setAttributedTitle:[self createJobOnlineBtnImgBefore:@"Online"] forState:UIControlStateNormal];
        
        NSMutableAttributedString *goOnDuty = [[NSMutableAttributedString alloc] initWithString:localizeString(@"Go Offline")];
        [goOnDuty addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [goOnDuty length])];
        [goOnDuty addAttribute:NSForegroundColorAttributeName value:[Color softGrayColor] range:NSMakeRange(0, [goOnDuty length])];
        [self.jobsGoBtn setAttributedTitle:goOnDuty forState:UIControlStateNormal];
    }
    
    NSString *jname = defaults_object(@"currentJobNameTitle");
    if (![jname isEqualToString:@""] && jname.length > 0) {
        
        [self.jobsStatusBtn setAttributedTitle:[self createJobOnlineBtnImgBefore:@"On Duty"] forState:UIControlStateNormal];
        
        NSMutableAttributedString *goOnDuty = [[NSMutableAttributedString alloc] initWithString:localizeString(@"Go Offline")];
        [goOnDuty addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [goOnDuty length])];
        [goOnDuty addAttribute:NSForegroundColorAttributeName value:[Color softGrayColor] range:NSMakeRange(0, [goOnDuty length])];
        [self.jobsGoBtn setAttributedTitle:goOnDuty forState:UIControlStateNormal];
        
        self.jobsCurrentLbl.text = defaults_object(@"currentJobNameTitle");
        self.jobsCurrentLbl.textColor = [Color darkGrayColor43];
        
        self.jobsOkGreenBtn.alpha = 1.0;
        self.jobsPauseBtn.alpha = 1.0;
        self.jobsOkGreenBtn.userInteractionEnabled = YES;
        self.jobsPauseBtn.userInteractionEnabled = YES;
    } else {
        self.jobsCurrentLbl.text = @"No current job";
        self.jobsCurrentLbl.textColor = [Color softGrayColor];
        
        self.jobsOkGreenBtn.alpha = 0.7;
        self.jobsPauseBtn.alpha = 0.7;
        self.jobsOkGreenBtn.userInteractionEnabled = NO;
        self.jobsPauseBtn.userInteractionEnabled = NO;
    }
    NSMutableArray *accJobs = defaults_object(@"acceptedJobs");
    NSMutableArray *compJobs = defaults_object(@"completedJobs");
    self.jobsOnDutyAcceptedArray = [[NSMutableArray alloc] initWithArray:accJobs];
    self.jobsOnDutyCompletedArray = [[NSMutableArray alloc] initWithArray:compJobs];
    
    NSDate *currentDate = [NSDate date];
    self.jobsOnDutyTimerTextField.delegate = self;
    [self.jobsOnDutyTimerTextField makeFormFieldShift10];
    self.jobsOnDutyTimerTextField.textColor = [UIColor blackColor];
    [self.jobsOnDutyTimerTextField setBackgroundColor:[Color officialWhiteColor]];
    [self.jobsOnDutyTimerTextField.layer setMasksToBounds:YES];
    [self.jobsOnDutyTimerTextField.layer setCornerRadius:15.0f];
    [self.jobsOnDutyTimerTextField.layer setBorderColor:[[Color officialMainAppColor] CGColor]];
    [self.jobsOnDutyTimerTextField.layer setBorderWidth:1.9];
    
    if ([Configurator sharedInstance].needAmPmTime || [defaults_object(@"needDateSpecialFormat") boolValue] || [defaults_object(@"needAmPmFormat") boolValue]) {
        if ([defaults_object(@"needDateSpecialFormat") boolValue] && ![defaults_object(@"needAmPmFormat") boolValue]) {
            self.jobsOnDutyTimerTextField.text = [currentDate dateTimeStringShortMmDd24_OnDemand];
        } else if (![defaults_object(@"needDateSpecialFormat") boolValue] && [defaults_object(@"needAmPmFormat") boolValue]) {
            self.jobsOnDutyTimerTextField.text = [currentDate dateTimeStringShortDdMmAmPm_OnDemand];
        } else if (![defaults_object(@"needDateSpecialFormat") boolValue] && ![defaults_object(@"needAmPmFormat") boolValue]) {
            self.jobsOnDutyTimerTextField.text = [currentDate dateTimeStringShort_OnDemand];
        } else {
            self.jobsOnDutyTimerTextField.text = [currentDate dateTimeStringShortMmDdAmPm_OnDemand];
        }
    } else {
        self.jobsOnDutyTimerTextField.text = [currentDate dateTimeStringShort_OnDemand];
    }
    
    [self.jobsOnDutyAcceptTableView reloadData];
    [self.jobsOnDutyCompletedTableView reloadData];
    [self checkJobsArraysNow];
    
    self.jobsOnDutyCurrentAcceptBtn.layer.borderWidth = 0.8;
    self.jobsOnDutyCurrentAcceptBtn.layer.borderColor = [Color officialMainAppColor].CGColor;
    self.jobsOnDutyCurrentAcceptBtn.backgroundColor = [Color officialWhiteColor];
    [self.jobsOnDutyCurrentAcceptBtn setTitleColor:[Color officialMainAppColor] forState:UIControlStateNormal];
    
    self.jobsOnDutyCurrentStartBtn.layer.borderWidth = 0.8;
    self.jobsOnDutyCurrentStartBtn.layer.borderColor = [Color officialMainAppColor].CGColor;
    self.jobsOnDutyCurrentStartBtn.backgroundColor = [Color officialMainAppColor];
    [self.jobsOnDutyCurrentStartBtn setTitleColor:[Color officialWhiteColor] forState:UIControlStateNormal];
    
    if (IS_IPHONE_5 || IS_IPHONE_4)
        [self lowFontsForOldDevices];
}

- (IBAction)goOnDutyBtnClick:(id)sender {
    self.jobsStatusBtn.hidden = NO;
    
    if ([RPEntry instance].disableTracking) {
        self.jobsStatusBtn.hidden = YES;
        [RPEntry instance].disableTracking = NO;
        [[RPEntry instance] setEnableSdk:YES];
        defaults_set_object(@"onDemandTracking", @(YES));
        
        [self.jobsStatusBtn setAttributedTitle:[self createJobOnlineBtnImgBefore:@"Online"] forState:UIControlStateNormal];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IMMEDIATELY_03_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.jobsStatusBtn.hidden = NO;
        });
        
        NSMutableAttributedString *goOnDuty = [[NSMutableAttributedString alloc] initWithString:localizeString(@"Go Offline")];
        [goOnDuty addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [goOnDuty length])];
        [goOnDuty addAttribute:NSForegroundColorAttributeName value:[Color softGrayColor] range:NSMakeRange(0, [goOnDuty length])];
        [self.jobsGoBtn setAttributedTitle:goOnDuty forState:UIControlStateNormal];
    } else {
        NSString *jname = defaults_object(@"currentJobNameTitle");
        if (![jname isEqualToString:@""] && jname.length > 0) {
            self.jobsStatusBtn.hidden = NO;
            [self showAlertStoppingAllUserJobs:sender];
            return;
        } else {
            NSMutableArray *accJobs = defaults_object(@"acceptedJobs");
            for (int i = 0; i < accJobs.count; i++) {
                NSString *jobStatus = [[accJobs objectAtIndex:i] valueForKey:@"currentJobStatus"];
                if ([jobStatus isEqualToString:@"Pause"]) {
                    self.jobsStatusBtn.hidden = NO;
                    [self showAlertStoppingAllUserJobs:sender];
                    return;
                }
            }
        }
        
        self.jobsStatusBtn.hidden = YES;
        [RPEntry instance].disableTracking = YES;
        [[RPEntry instance] setEnableSdk:NO];
        [self.jobsStatusBtn setAttributedTitle:[self createJobOfflineBtnImgBefore:@"Offline"] forState:UIControlStateNormal];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IMMEDIATELY_03_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.jobsStatusBtn.hidden = NO;
        });
        
        NSMutableAttributedString *goOnDuty = [[NSMutableAttributedString alloc] initWithString:localizeString(@"Go Online")];
        [goOnDuty addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [goOnDuty length])];
        [goOnDuty addAttribute:NSForegroundColorAttributeName value:[Color officialMainAppColor] range:NSMakeRange(0, [goOnDuty length])];
        [self.jobsGoBtn setAttributedTitle:goOnDuty forState:UIControlStateNormal];
    }
}

- (IBAction)showAlertStoppingAllUserJobs:(id)sender {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:localizeString(@"Job in progress")
                                message:localizeString(@"All current jobs will be paused. Are you sure?")
                                //message:localizeString(@"All current jobs will be completed. Are you sure?")
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesButton = [UIAlertAction
                                actionWithTitle:localizeString(@"Yes")
                                style:UIAlertActionStyleDestructive
                                handler:^(UIAlertAction *action) {
                                    [self pauseBtnClick:sender];
        
                                    [self.jobsStatusBtn setAttributedTitle:[self createJobOfflineBtnImgBefore:@"Offline"] forState:UIControlStateNormal];
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        self.jobsStatusBtn.hidden = NO;
                                    });
        
                                    [RPEntry instance].disableTracking = YES;
                                    [[RPEntry instance] setEnableSdk:NO];

                                    NSMutableAttributedString *goOnDuty = [[NSMutableAttributedString alloc] initWithString:localizeString(@"Go Online")];
                                    [goOnDuty addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [goOnDuty length])];
                                    [goOnDuty addAttribute:NSForegroundColorAttributeName value:[Color officialMainAppColor] range:NSMakeRange(0, [goOnDuty length])];
                                    [self.jobsGoBtn setAttributedTitle:goOnDuty forState:UIControlStateNormal];
                                }];
    UIAlertAction *noButton = [UIAlertAction
                               actionWithTitle:localizeString(@"No")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {}];
    [alert addAction:yesButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)stopAllJobs {
    NSMutableArray *accJobs = defaults_object(@"acceptedJobs");
    for (int i = 0; i < accJobs.count; i++) {
        NSString *jobStatus = [[accJobs objectAtIndex:i] valueForKey:@"currentJobStatus"];
        if ([jobStatus isEqualToString:@"Pause"]) {
            NSMutableDictionary *jobDict = [[NSMutableDictionary alloc] init];
            [jobDict setDictionary:@{@"currentJobName": [[accJobs objectAtIndex:i] valueForKey:@"currentJobName"],
                                     @"currentJobStatus": @"Finished",
                                     @"currentJobTimeStamp": [[accJobs objectAtIndex:i] valueForKey:@"currentJobTimeStamp"],
                                     @"currentJobDate": [[accJobs objectAtIndex:i] valueForKey:@"currentJobDate"]
            }];
            
            NSMutableArray *compJobs = defaults_object(@"completedJobs");
            NSString *jfs = [[accJobs objectAtIndex:i] valueForKey:@"currentJobName"];
            BOOL completedContainsJobAlready = [self checkArray:compJobs containsJob:jfs];
            
            if (completedContainsJobAlready) {
                [self.jobsOnDutyAcceptedArray removeObjectAtIndex:i];
            } else {
                [self.jobsOnDutyCompletedArray insertObject:jobDict atIndex:0];
                if (i >= self.jobsOnDutyAcceptedArray.count) {
                    [self.jobsOnDutyAcceptedArray removeObjectAtIndex:0];
                } else {
                    [self.jobsOnDutyAcceptedArray removeObjectAtIndex:i];
                }
            }
        }
    }
    
    [self.jobsOnDutyAcceptedArray removeAllObjects];
    
    defaults_set_object(@"acceptedJobs", self.jobsOnDutyAcceptedArray);
    defaults_set_object(@"completedJobs", self.jobsOnDutyCompletedArray);
    [self.jobsOnDutyAcceptTableView reloadData];
    [self.jobsOnDutyCompletedTableView reloadData];
    [self checkJobsArraysNow];
}

- (IBAction)stopGreenBtnClick:(id)sender {
    NSString *jobSavedTime = defaults_object(@"currentJobNameTimeStamp");
    NSMutableArray *accJobs = defaults_object(@"acceptedJobs");
    for (int i = 0; i < accJobs.count; i++) {
        NSString *jStatusTimeStamp = [[accJobs objectAtIndex:i] valueForKey:@"currentJobTimeStamp"];
        if ([jStatusTimeStamp isEqualToString:jobSavedTime]) {
            
            NSMutableDictionary *jobDict = [[NSMutableDictionary alloc] init];
            [jobDict setDictionary:@{@"currentJobName": [[accJobs objectAtIndex:i] valueForKey:@"currentJobName"],
                                     @"currentJobStatus": @"Finished",
                                     @"currentJobTimeStamp": [[accJobs objectAtIndex:i] valueForKey:@"currentJobTimeStamp"],
                                     @"currentJobDate": [[accJobs objectAtIndex:i] valueForKey:@"currentJobDate"]
            }];
            
            NSMutableArray *compJobs = defaults_object(@"completedJobs");
            NSString *jfc = [[accJobs objectAtIndex:i] valueForKey:@"currentJobName"];
            BOOL completedContainsJobAlready = [self checkArray:compJobs containsJob:jfc];
            
            if (completedContainsJobAlready) {
                [self.jobsOnDutyAcceptedArray removeObjectAtIndex:i];
            } else {
                [self.jobsOnDutyCompletedArray insertObject:jobDict atIndex:0];
                [self.jobsOnDutyAcceptedArray removeObjectAtIndex:i];
            }
            
            defaults_set_object(@"acceptedJobs", self.jobsOnDutyAcceptedArray);
            defaults_set_object(@"completedJobs", self.jobsOnDutyCompletedArray);
        }
    }
    
    [[RPEntry instance].api removeAllFutureTrackTagsWithСompletion:^(RPTagStatus status, NSInteger timestamp) {}];
    
    [self.jobsStatusBtn setAttributedTitle:[self createJobOnlineBtnImgBefore:@"Online"] forState:UIControlStateNormal];
    self.jobsOkGreenBtn.alpha = 0.7;
    self.jobsPauseBtn.alpha = 0.7;
    self.jobsOkGreenBtn.userInteractionEnabled = NO;
    self.jobsPauseBtn.userInteractionEnabled = NO;
    
    defaults_set_object(@"currentJobNameTitle", @"");
    defaults_set_object(@"currentJobNameTimeStamp", @"");
    self.jobsCurrentLbl.text = @"No current job";
    self.jobsCurrentLbl.textColor = [Color softGrayColor];
    [self checkJobsArraysNow];
    
    [self.jobsOnDutyAcceptTableView reloadData];
    [self.jobsOnDutyCompletedTableView reloadData];
}

- (IBAction)pauseBtnClick:(id)sender {
    NSString *jobTime = defaults_object(@"currentJobNameTimeStamp");
    NSMutableArray *accJobs = defaults_object(@"acceptedJobs");
    
    for (int i = 0; i < accJobs.count; i++) {
        NSString *jStatusName = [[accJobs objectAtIndex:i] valueForKey:@"currentJobTimeStamp"];
        if ([jStatusName isEqualToString:jobTime]) {
            
            NSMutableDictionary *jobDict = [[NSMutableDictionary alloc] init];
            [jobDict setDictionary:@{@"currentJobName": [[accJobs objectAtIndex:i] valueForKey:@"currentJobName"],
                                     @"currentJobStatus": @"Pause",
                                     @"currentJobTimeStamp": [[accJobs objectAtIndex:i] valueForKey:@"currentJobTimeStamp"],
                                     @"currentJobDate": [[accJobs objectAtIndex:i] valueForKey:@"currentJobDate"]
            }];
            [self.jobsOnDutyAcceptedArray replaceObjectAtIndex:i withObject:jobDict];
            defaults_set_object(@"acceptedJobs", self.jobsOnDutyAcceptedArray);
        }
    }
    
    [self.jobsOnDutyAcceptTableView reloadData];
    defaults_set_object(@"currentJobNameTitle", @"");
    defaults_set_object(@"currentJobNameTimeStamp", @"");
    self.jobsCurrentLbl.text = @"No current job";
    self.jobsCurrentLbl.textColor = [Color softGrayColor];
    
    [[RPEntry instance].api removeAllFutureTrackTagsWithСompletion:^(RPTagStatus status, NSInteger timestamp) {}];
    
    [self.jobsStatusBtn setAttributedTitle:[self createJobOnlineBtnImgBefore:@"Online"] forState:UIControlStateNormal];
    self.jobsOkGreenBtn.alpha = 0.7;
    self.jobsPauseBtn.alpha = 0.7;
    self.jobsOkGreenBtn.userInteractionEnabled = NO;
    self.jobsPauseBtn.userInteractionEnabled = NO;
    [self checkJobsArraysNow];
}

- (IBAction)acceptJobBtnClick:(id)sender {
    
    NSString *jobForAddToAccepted = self.jobsOnDutyTimerTextField.text;
    NSMutableArray *accJobs = defaults_object(@"acceptedJobs");
    
    for (int i = 0; i < accJobs.count; i++) {
        NSString *jNameForSearch = [[accJobs objectAtIndex:i] valueForKey:@"currentJobName"];
        if ([jNameForSearch isEqualToString:jobForAddToAccepted]) {
            
            [self becomeFirstResponder];
            [self.jobsOnDutyTimerTextField.layer setBorderColor:[[Color officialRedColor] CGColor]];
            
            UIAlertController *alert = [UIAlertController
                                        alertControllerWithTitle:localizeString(@"Choose a new name")
                                        message:localizeString(@"This job name is already taken")
                                        preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *yesButton = [UIAlertAction
                                        actionWithTitle:localizeString(@"Ok")
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action) {
                                            //
                                        }];
            [alert addAction:yesButton];
            [self presentViewController:alert animated:YES completion:nil];
            [self.view endEditing:YES];
            return;
        }
    }
    
    time_t result = time(NULL);
    NSString *timeStampString = [@(result) stringValue];
    
    NSDate *currentDate = [NSDate date];
    NSString *jDate = [currentDate dateTimeStringSpecial];
    
    NSMutableDictionary *jobDict = [[NSMutableDictionary alloc] init];
    [jobDict setDictionary:@{@"currentJobName": self.jobsOnDutyTimerTextField.text,
                             @"currentJobStatus": @"Pending",
                             @"currentJobTimeStamp": timeStampString,
                             @"currentJobDate": jDate
    }];
    
    [self.jobsOnDutyAcceptedArray insertObject:jobDict atIndex:0];
    defaults_set_object(@"acceptedJobs", self.jobsOnDutyAcceptedArray);
    [self.jobsOnDutyAcceptTableView reloadData];
    [self.jobsOnDutyCompletedTableView reloadData];
    
    NSString *jobName = defaults_object(@"currentJobNameTitle");
    if (![jobName isEqualToString:@""] && jobName.length > 0) {
        self.jobsOkGreenBtn.alpha = 1.0;
        self.jobsPauseBtn.alpha = 1.0;
        self.jobsOkGreenBtn.userInteractionEnabled = YES;
        self.jobsPauseBtn.userInteractionEnabled = YES;
    } else {
        self.jobsOkGreenBtn.alpha = 0.7;
        self.jobsPauseBtn.alpha = 0.7;
        self.jobsOkGreenBtn.userInteractionEnabled = NO;
        self.jobsPauseBtn.userInteractionEnabled = NO;
    }
    
    [self.jobsOnDutyTimerTextField.layer setBorderColor:[[Color officialMainAppColor] CGColor]];
    self.needDisplayAlert = YES;
    [self checkJobsArraysNow];
    [self.view endEditing:YES];
}

- (IBAction)startJobBtnClick:(id)sender {
    [self.view endEditing:YES];
    
    NSString *jobToStartNow = self.jobsOnDutyTimerTextField.text;
    NSMutableArray *accJobs = defaults_object(@"acceptedJobs");
    
    for (int i = 0; i < accJobs.count; i++) {
        NSString *jNameForSearch = [[accJobs objectAtIndex:i] valueForKey:@"currentJobName"];
        if ([jNameForSearch isEqualToString:jobToStartNow]) {
            
            [self becomeFirstResponder];
            [self.jobsOnDutyTimerTextField.layer setBorderColor:[[Color officialRedColor] CGColor]];
            
            UIAlertController *alert = [UIAlertController
                                        alertControllerWithTitle:localizeString(@"Choose a new name")
                                        message:localizeString(@"This job name is already taken")
                                        preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *yesButton = [UIAlertAction
                                        actionWithTitle:localizeString(@"Ok")
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction *action) {
                                            //
                                        }];
            [alert addAction:yesButton];
            [self presentViewController:alert animated:YES completion:nil];
            [self.view endEditing:YES];
            return;
        }
    }
    
    NSString *jobName = defaults_object(@"currentJobNameTitle");
    if (![jobName isEqualToString:@""] && jobName.length > 0) {
        [self showJobCancelledErrorForMainJobView:sender];
        return;
    }
    
    if (self.jobsOnDutyTimerTextField.text.length == 0) {
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:nil
                                    message:localizeString(@"Job must have a name. Enter it in the field below")
                                    preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction
                                    actionWithTitle:localizeString(@"Ok")
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction *action) {
                                        //NOT NEEDED
                                    }];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [RPEntry instance].disableTracking = NO;
    [[RPEntry instance] setEnableSdk:YES];
    defaults_set_object(@"onDemandTracking", @(YES));
    
    [self.jobsStatusBtn setAttributedTitle:[self createJobOnlineBtnImgBefore:@"On Duty"] forState:UIControlStateNormal];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(DELAY_IMMEDIATELY_03_SEC * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.jobsStatusBtn.hidden = NO;
    });
    
    NSMutableAttributedString *goOnDuty = [[NSMutableAttributedString alloc] initWithString:localizeString(@"Go Offline")];
    [goOnDuty addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [goOnDuty length])];
    [goOnDuty addAttribute:NSForegroundColorAttributeName value:[Color softGrayColor] range:NSMakeRange(0, [goOnDuty length])];
    [self.jobsGoBtn setAttributedTitle:goOnDuty forState:UIControlStateNormal];
    
    time_t result = time(NULL);
    NSString *timeStampString = [@(result) stringValue];
    
    NSDate *currentDate = [NSDate date];
    NSString *jDate = [currentDate dateTimeStringSpecial];
    
    NSMutableDictionary *jobDict = [[NSMutableDictionary alloc] init];
    [jobDict setDictionary:@{@"currentJobName": self.jobsOnDutyTimerTextField.text,
                             @"currentJobStatus": @"Start",
                             @"currentJobTimeStamp": timeStampString,
                             @"currentJobDate": jDate
    }];
    [self.jobsOnDutyAcceptedArray insertObject:jobDict atIndex:0];
    defaults_set_object(@"acceptedJobs", self.jobsOnDutyAcceptedArray);
    
    [self.jobsOnDutyAcceptTableView reloadData];
    [self.jobsOnDutyCompletedTableView reloadData];
    
    self.jobsCurrentLbl.text = self.jobsOnDutyTimerTextField.text;
    self.jobsCurrentLbl.textColor = [Color darkGrayColor43];
    
    self.jobsOkGreenBtn.alpha = 1.0;
    self.jobsPauseBtn.alpha = 1.0;
    self.jobsOkGreenBtn.userInteractionEnabled = YES;
    self.jobsPauseBtn.userInteractionEnabled = YES;
    [self.jobsOnDutyTimerTextField.layer setBorderColor:[[Color officialMainAppColor] CGColor]];
    
    [[RPEntry instance].api removeAllFutureTrackTagsWithСompletion:^(RPTagStatus status, NSInteger timestamp) {}];
    RPTag *tag = [[RPTag alloc] init];
    tag.tag = self.jobsOnDutyTimerTextField.text;
    tag.source = @"TelematicsApp OnDemand";
    [[RPEntry instance].api addFutureTrackTag:tag completion:nil];
    
    defaults_set_object(@"currentJobNameTitle", self.jobsOnDutyTimerTextField.text);
    defaults_set_object(@"currentJobNameTimeStamp", timeStampString);
    self.needDisplayAlert = YES;
    [self checkJobsArraysNow];
    [self.view endEditing:YES];
}

- (void)checkJobsArraysNow {
    if (self.jobsOnDutyAcceptedArray.count == 0)
        self.jobsOnDutyAcceptPlaceholder.hidden = NO;
    else
        self.jobsOnDutyAcceptPlaceholder.hidden = YES;
    
    if (self.jobsOnDutyCompletedArray.count == 0)
        self.jobsOnDutyCompletedPlaceholder.hidden = NO;
    else
        self.jobsOnDutyCompletedPlaceholder.hidden = YES;
}


#pragma mark - ONDEMAND Duty Job Table buttons

- (void)declineCellBtnClicked:(UIButton*)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.jobsOnDutyAcceptTableView];
    NSIndexPath *indexPath = [self.jobsOnDutyAcceptTableView indexPathForRowAtPoint:buttonPosition];
    [self.jobsOnDutyAcceptedArray removeObjectAtIndex:indexPath.row];
    defaults_set_object(@"acceptedJobs", self.jobsOnDutyAcceptedArray);
    
    [self.jobsOnDutyAcceptTableView reloadData];
    [self.jobsOnDutyCompletedTableView reloadData];
    
    [self checkJobsArraysNow];
}

- (void)startJobCellBtnClicked:(UIButton*)sender {
    NSString *jname = defaults_object(@"currentJobNameTitle");
    if (![jname isEqualToString:@""] && jname.length > 0) {
        [self showJobCancelledErrorForCell:sender];
        return;
    }
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.jobsOnDutyAcceptTableView];
    NSIndexPath *indexPath = [self.jobsOnDutyAcceptTableView indexPathForRowAtPoint:buttonPosition];
    NSString *startjobCellSelectedTimeStamp = [[self.jobsOnDutyAcceptedArray objectAtIndex:indexPath.row] valueForKey:@"currentJobTimeStamp"];
    
    NSMutableArray *accJobs = defaults_object(@"acceptedJobs");
    
    NSMutableDictionary *jobDict = [[NSMutableDictionary alloc] init];
    [jobDict setDictionary:@{@"currentJobName": [[accJobs objectAtIndex:indexPath.row] valueForKey:@"currentJobName"],
                             @"currentJobStatus": @"Start",
                             @"currentJobTimeStamp": startjobCellSelectedTimeStamp,
                             @"currentJobDate": [[accJobs objectAtIndex:indexPath.row] valueForKey:@"currentJobDate"]
    }];
    
    [self.jobsOnDutyAcceptedArray replaceObjectAtIndex:indexPath.row withObject:jobDict];
    defaults_set_object(@"acceptedJobs", self.jobsOnDutyAcceptedArray);
    [self.jobsOnDutyAcceptTableView reloadData];
    
    [RPEntry instance].disableTracking = NO;
    [[RPEntry instance] setEnableSdk:YES];
    
    [[RPEntry instance].api removeAllFutureTrackTagsWithСompletion:^(RPTagStatus status, NSInteger timestamp) {}];
    RPTag *tag = [[RPTag alloc] init];
    tag.tag = [[accJobs objectAtIndex:indexPath.row] valueForKey:@"currentJobName"];
    tag.source = @"TelematicsApp OnDemand";
    [[RPEntry instance].api addFutureTrackTag:tag completion:nil];
    
    defaults_set_object(@"onDemandTracking", @(YES));
    
    [self.jobsStatusBtn setAttributedTitle:[self createJobOnlineBtnImgBefore:@"On Duty"] forState:UIControlStateNormal];
    NSMutableAttributedString *goOnDuty = [[NSMutableAttributedString alloc] initWithString:localizeString(@"Go Offline")];
    [goOnDuty addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [goOnDuty length])];
    [goOnDuty addAttribute:NSForegroundColorAttributeName value:[Color softGrayColor] range:NSMakeRange(0, [goOnDuty length])];
    [self.jobsGoBtn setAttributedTitle:goOnDuty forState:UIControlStateNormal];
    
    self.jobsOkGreenBtn.alpha = 1.0;
    self.jobsPauseBtn.alpha = 1.0;
    self.jobsOkGreenBtn.userInteractionEnabled = YES;
    self.jobsPauseBtn.userInteractionEnabled = YES;
    
    defaults_set_object(@"currentJobNameTitle", [[accJobs objectAtIndex:indexPath.row] valueForKey:@"currentJobName"]);
    defaults_set_object(@"currentJobNameTimeStamp", [[accJobs objectAtIndex:indexPath.row] valueForKey:@"currentJobTimeStamp"]);
    self.jobsCurrentLbl.text = [[accJobs objectAtIndex:indexPath.row] valueForKey:@"currentJobName"];
    self.jobsCurrentLbl.textColor = [Color darkGrayColor43];
    
    [self checkJobsArraysNow];
}

- (void)pauseJobCellBtnClicked:(UIButton*)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.jobsOnDutyAcceptTableView];
    NSIndexPath *indexPath = [self.jobsOnDutyAcceptTableView indexPathForRowAtPoint:buttonPosition];
    NSString *jobCellSelected = [[self.jobsOnDutyAcceptedArray objectAtIndex:indexPath.row] valueForKey:@"currentJobTimeStamp"];
    
    NSMutableArray *accJobs = defaults_object(@"acceptedJobs");
    for (int i = 0; i < accJobs.count; i++) {
        NSString *jStatusName = [[accJobs objectAtIndex:i] valueForKey:@"currentJobTimeStamp"];
        if ([jStatusName isEqualToString:jobCellSelected]) {
            
            NSMutableDictionary *jobDict = [[NSMutableDictionary alloc] init];
            [jobDict setDictionary:@{@"currentJobName": [[accJobs objectAtIndex:i] valueForKey:@"currentJobName"],
                                     @"currentJobStatus": @"Pause",
                                     @"currentJobTimeStamp": [[accJobs objectAtIndex:i] valueForKey:@"currentJobTimeStamp"],
                                     @"currentJobDate": [[accJobs objectAtIndex:i] valueForKey:@"currentJobDate"]
            }];
            [self.jobsOnDutyAcceptedArray replaceObjectAtIndex:i withObject:jobDict];
            defaults_set_object(@"acceptedJobs", self.jobsOnDutyAcceptedArray);
        }
    }
    
    [self.jobsOnDutyAcceptTableView reloadData];
    defaults_set_object(@"currentJobNameTitle", @"");
    defaults_set_object(@"currentJobNameTimeStamp", @"");
    self.jobsCurrentLbl.text = @"No current job";
    self.jobsCurrentLbl.textColor = [Color softGrayColor];
    
    [[RPEntry instance].api removeAllFutureTrackTagsWithСompletion:^(RPTagStatus status, NSInteger timestamp) {}];
    
    [self.jobsStatusBtn setAttributedTitle:[self createJobOnlineBtnImgBefore:@"Online"] forState:UIControlStateNormal];
    self.jobsOkGreenBtn.alpha = 0.7;
    self.jobsPauseBtn.alpha = 0.7;
    self.jobsOkGreenBtn.userInteractionEnabled = NO;
    self.jobsPauseBtn.userInteractionEnabled = NO;
    
    [self checkJobsArraysNow];
}

- (void)hideJobCellBtnClicked:(UIButton*)sender {
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.jobsOnDutyCompletedTableView];
    NSIndexPath *indexPath = [self.jobsOnDutyCompletedTableView indexPathForRowAtPoint:buttonPosition];
    
    [self.jobsOnDutyCompletedArray removeObjectAtIndex:indexPath.row];
    defaults_set_object(@"completedJobs", self.jobsOnDutyCompletedArray);
    [CoreDataCoordinator saveCoreDataCoordinatorContext];
    [self.jobsOnDutyAcceptTableView reloadData];
    [self.jobsOnDutyCompletedTableView reloadData];
    [self checkJobsArraysNow];
}


#pragma mark - ONDEMAND Duty Job Risk & Statistics Tags

- (void)getRiskScoreForEachTag {
    NSMutableArray *compJobs = defaults_object(@"completedJobs");
    NSMutableArray *tempForCompJobs = [compJobs mutableCopy];
    for (int i = 0; i < compJobs.count; i++) {
        NSDate *currentDate = [NSDate date];
        NSString *jStatusName = [[compJobs objectAtIndex:i] valueForKey:@"currentJobName"];
        //jStatusName = @"1614868760"; //TEST
        
        NSString *jStartDate = [[compJobs objectAtIndex:i] valueForKey:@"currentJobDate"];
        if (jStartDate == nil) {
            jStartDate = [currentDate dateTimeStringSpecial];
        }
        NSString *jCurrentDate = [currentDate dateTimeStringSpecial];
        
        [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
            NSLog(@"%s %@ %@", __func__, response, error);
            if (!error && [response isSuccesful]) {
                self.tagIndividual = ((TagResponse *)response).Result;
                
                float riskScoreFloat = [self.tagIndividual.OverallScore floatValue];
                NSString *jobStatRiskScore = [NSString stringWithFormat:@"%.1f", riskScoreFloat];
                
                NSMutableDictionary *jobDict = [[NSMutableDictionary alloc] init];
                [jobDict setDictionary:@{@"currentJobName": [[compJobs objectAtIndex:i] valueForKey:@"currentJobName"],
                                         @"currentJobStatus": [[compJobs objectAtIndex:i] valueForKey:@"currentJobStatus"],
                                         @"currentJobTimeStamp": [[compJobs objectAtIndex:i] valueForKey:@"currentJobTimeStamp"],
                                         @"currentJobDate": [[compJobs objectAtIndex:i] valueForKey:@"currentJobDate"],
                                         @"currentJobStatRiskScore": jobStatRiskScore,
                                         @"currentJobStatTripsCount": @"",
                                         @"currentJobStatMileage": @"",
                                         @"currentJobStatTime": @""
                }];
                [tempForCompJobs replaceObjectAtIndex:i withObject:jobDict];
                
                self.jobsOnDutyCompletedArray = [[NSMutableArray alloc] initWithArray:tempForCompJobs];
                defaults_set_object(@"completedJobs", self.jobsOnDutyCompletedArray);
                [self.jobsOnDutyCompletedTableView reloadData];
            }
        }] getTagRiskScore:jStatusName startDate:jStartDate endDate:jCurrentDate];
    }
}

- (void)getStatisticsDataForEachTag {
    NSMutableArray *compJobs = defaults_object(@"completedJobs");
    NSMutableArray *tempForCompJobs = [compJobs mutableCopy];
    for (int i = 0; i < compJobs.count; i++) {
        
        NSDate *currentDate = [NSDate date];
        NSString *jStatusName = [[compJobs objectAtIndex:i] valueForKey:@"currentJobName"];
        
        NSString *jStartDate = [[compJobs objectAtIndex:i] valueForKey:@"currentJobDate"];
        if (jStartDate == nil) {
            jStartDate = [currentDate dateTimeStringSpecial];
        }
        NSString *jCurrentDate = [currentDate dateTimeStringSpecial];
        
        [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
            NSLog(@"%s %@ %@", __func__, response, error);
            if (!error && [response isSuccesful]) {
                self.tagIndividual = ((TagResponse *)response).Result;
                
                float tripsCountFloat = [self.tagIndividual.TripsCount floatValue];
                float mileageCountFloat = [self.tagIndividual.MileageKm floatValue];
                float driveTimeCountFloat = [self.tagIndividual.DrivingTime floatValue] / 60;
                if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                    float milesStat = convertKmToMiles(mileageCountFloat);
                    mileageCountFloat = milesStat;
                }
                
                NSString *jobStatTripsCount = [NSString stringWithFormat:@"%.0f", tripsCountFloat];
                NSString *jobStatMileage = [NSString stringWithFormat:@"%.1f", mileageCountFloat];
                NSString *jobStatTime = [NSString stringWithFormat:@"%.1f", driveTimeCountFloat];
                
                NSString *checkRSvalue = [[compJobs objectAtIndex:i] valueForKey:@"currentJobStatRiskScore"];
                if (checkRSvalue == nil) {
                    // STOP
                } else {
                    NSMutableDictionary *jobDict = [[NSMutableDictionary alloc] init];
                    [jobDict setDictionary:@{@"currentJobName": [[compJobs objectAtIndex:i] valueForKey:@"currentJobName"],
                                             @"currentJobStatus": [[compJobs objectAtIndex:i] valueForKey:@"currentJobStatus"],
                                             @"currentJobTimeStamp": [[compJobs objectAtIndex:i] valueForKey:@"currentJobTimeStamp"],
                                             @"currentJobDate": [[compJobs objectAtIndex:i] valueForKey:@"currentJobDate"],
                                             @"currentJobStatRiskScore": [[compJobs objectAtIndex:i] valueForKey:@"currentJobStatRiskScore"],
                                             @"currentJobStatTripsCount": jobStatTripsCount,
                                             @"currentJobStatMileage": jobStatMileage,
                                             @"currentJobStatTime": jobStatTime
                    }];
                    [tempForCompJobs replaceObjectAtIndex:i withObject:jobDict];
                    
                    self.jobsOnDutyCompletedArray = [[NSMutableArray alloc] initWithArray:tempForCompJobs];
                    defaults_set_object(@"completedJobs", self.jobsOnDutyCompletedArray);
                    [self.jobsOnDutyCompletedTableView reloadData];
                }
            }
        }] getTagStatistic:jStatusName startDate:jStartDate endDate:jCurrentDate];
    }
}


#pragma mark - ONDEMAND Duty Job Table view datasource

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.jobsOnDutyAcceptTableView) {
        JobsAcceptedCell *jobsAcceptedCell = [tableView dequeueReusableCellWithIdentifier:@"JobsAcceptedCell"];
        jobsAcceptedCell.jobNameLbl.text = [[self.jobsOnDutyAcceptedArray objectAtIndex:indexPath.row] valueForKey:@"currentJobName"];
        [jobsAcceptedCell.jobDeclineBtn addTarget:self action:@selector(declineCellBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [jobsAcceptedCell.jobStartBtn addTarget:self action:@selector(startJobCellBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [jobsAcceptedCell.jobPauseBtn addTarget:self action:@selector(pauseJobCellBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        jobsAcceptedCell.jobDeclineBtn.hidden = NO;
        jobsAcceptedCell.jobStartBtn.hidden = NO;
        jobsAcceptedCell.jobPauseBtn.hidden = YES;
        
        if ([[[self.jobsOnDutyAcceptedArray objectAtIndex:indexPath.row] valueForKey:@"currentJobStatus"] isEqualToString:@"Pause"]) {
            jobsAcceptedCell.jobStartBtn.layer.borderWidth = 0.8;
            jobsAcceptedCell.jobStartBtn.layer.borderColor = [Color officialMainAppColor].CGColor;
            jobsAcceptedCell.jobStartBtn.backgroundColor = [Color officialWhiteColor];
            [jobsAcceptedCell.jobStartBtn setTitleColor:[Color officialMainAppColor] forState:UIControlStateNormal];
            [jobsAcceptedCell.jobStartBtn setTitle:@"RESUME" forState:UIControlStateNormal];
            
        } else if ([[[self.jobsOnDutyAcceptedArray objectAtIndex:indexPath.row] valueForKey:@"currentJobStatus"] isEqualToString:@"Start"]) {
            jobsAcceptedCell.jobDeclineBtn.hidden = YES;
            jobsAcceptedCell.jobStartBtn.hidden = YES;
            jobsAcceptedCell.jobPauseBtn.hidden = NO;
        } else {
            jobsAcceptedCell.jobStartBtn.layer.borderWidth = 0.8;
            jobsAcceptedCell.jobStartBtn.layer.borderColor = [Color officialMainAppColor].CGColor;
            jobsAcceptedCell.jobStartBtn.backgroundColor = [Color officialMainAppColor];
            [jobsAcceptedCell.jobStartBtn setTitleColor:[Color officialWhiteColor] forState:UIControlStateNormal];
            [jobsAcceptedCell.jobStartBtn setTitle:@"START" forState:UIControlStateNormal];
        }
        return jobsAcceptedCell;
    } else if (tableView == self.jobsOnDutyCompletedTableView) {
        
        JobsCompletedCell *jobsCompletedCell = [tableView dequeueReusableCellWithIdentifier:@"JobsCompletedCell"];
        jobsCompletedCell.jobCompletedNameLbl.text = [[self.jobsOnDutyCompletedArray objectAtIndex:indexPath.row] valueForKey:@"currentJobName"];
        [jobsCompletedCell.jobHideBtn addTarget:self action:@selector(hideJobCellBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        jobsCompletedCell.job_riskScoreImg.hidden = NO;
        jobsCompletedCell.job_tripsCountImg.hidden = NO;
        jobsCompletedCell.job_mileageImg.hidden = NO;
        jobsCompletedCell.job_timeImg.hidden = NO;
        
        NSString *checkRSvalue = [[self.jobsOnDutyCompletedArray objectAtIndex:indexPath.row] valueForKey:@"currentJobStatRiskScore"];
        if (checkRSvalue == nil) {
            jobsCompletedCell.job_riskScoreImg.hidden = NO;
            jobsCompletedCell.job_tripsCountImg.hidden = NO;
            jobsCompletedCell.job_mileageImg.hidden = NO;
            jobsCompletedCell.job_timeImg.hidden = NO;
            
        } else {
            
            //COMPLETED JOB RISK
            NSString *riskScoreLbl = @"Risk Score -";
            NSString *riskScoreTotalLbl = [NSString stringWithFormat:@"%@ %@", riskScoreLbl, checkRSvalue];
            NSMutableAttributedString *riskScoreCompletedLbl = [[NSMutableAttributedString alloc] initWithString:riskScoreTotalLbl];

            NSRange mainRangeTotalPoints = [riskScoreTotalLbl rangeOfString:checkRSvalue];
            UIFont *boldFontForPoints = [Font bold13];
            if (IS_IPHONE_5 || IS_IPHONE_4)
                boldFontForPoints = [Font bold12];

            if (checkRSvalue.floatValue > 80) {
                [riskScoreCompletedLbl addAttribute:NSForegroundColorAttributeName value:[Color officialGreenColor] range:mainRangeTotalPoints];
            } else if (checkRSvalue.floatValue > 60) {
                [riskScoreCompletedLbl addAttribute:NSForegroundColorAttributeName value:[Color officialYellowColor] range:mainRangeTotalPoints];
            } else if (checkRSvalue.floatValue > 40) {
                [riskScoreCompletedLbl addAttribute:NSForegroundColorAttributeName value:[Color officialOrangeColor] range:mainRangeTotalPoints];
            } else {
                [riskScoreCompletedLbl addAttribute:NSForegroundColorAttributeName value:[Color officialDarkRedColor] range:mainRangeTotalPoints];
            }
            [riskScoreCompletedLbl addAttribute:NSFontAttributeName value:boldFontForPoints range:mainRangeTotalPoints];
            jobsCompletedCell.job_riskScoreLbl.attributedText = riskScoreCompletedLbl;

            //COMPLETED JOB TRIPSCOUNT
            NSString *tripsCountValueLbl = [[self.jobsOnDutyCompletedArray objectAtIndex:indexPath.row] valueForKey:@"currentJobStatTripsCount"];
            NSString *tripsCountTotalLbl = [NSString stringWithFormat:@"%@ %@", @"Trips Count -", tripsCountValueLbl];
            NSMutableAttributedString *tripsCountCompletedLbl = [[NSMutableAttributedString alloc] initWithString:tripsCountTotalLbl];

            NSRange mainRangeTripsCount = [tripsCountTotalLbl rangeOfString:tripsCountValueLbl];
            [tripsCountCompletedLbl addAttribute:NSFontAttributeName value:boldFontForPoints range:mainRangeTripsCount];
            jobsCompletedCell.job_tripsCountLbl.attributedText = tripsCountCompletedLbl;
            
            //COMPLETED JOB MILEAGE
            NSString *mileageValueLbl = [[self.jobsOnDutyCompletedArray objectAtIndex:indexPath.row] valueForKey:@"currentJobStatMileage"];
            NSString *mileageTotalLbl = [NSString stringWithFormat:@"%@ %@ km", @"Mileage -", mileageValueLbl];
            if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
                float milesOnDemand = convertKmToMiles(mileageValueLbl.floatValue);
                mileageValueLbl = [NSString stringWithFormat:@"%.1f", milesOnDemand];
                mileageTotalLbl = [NSString stringWithFormat:@"%@ %@ mi", @"Mileage -", mileageValueLbl];
            }
            NSMutableAttributedString *mileageCompletedLbl = [[NSMutableAttributedString alloc] initWithString:mileageTotalLbl];

            NSRange mainRangeMileage = [mileageTotalLbl rangeOfString:mileageValueLbl];
            [mileageCompletedLbl addAttribute:NSFontAttributeName value:boldFontForPoints range:mainRangeMileage];
            jobsCompletedCell.job_mileageLbl.attributedText = mileageCompletedLbl;
            
            //COMPLETED JOB TIME
            NSString *timeValueLbl = [[self.jobsOnDutyCompletedArray objectAtIndex:indexPath.row] valueForKey:@"currentJobStatTime"];
            NSString *timeTotalLbl = [NSString stringWithFormat:@"%@ %@ h", @"Time -", timeValueLbl];
            NSMutableAttributedString *timeCompletedLbl = [[NSMutableAttributedString alloc] initWithString:timeTotalLbl];
            
            NSRange mainRangeTime = [timeTotalLbl rangeOfString:timeValueLbl];
            [timeCompletedLbl addAttribute:NSFontAttributeName value:boldFontForPoints range:mainRangeTime];
            jobsCompletedCell.job_timeLbl.attributedText = timeCompletedLbl;
            
            jobsCompletedCell.job_riskScoreImg.hidden = YES;
            if ([tripsCountValueLbl isEqual:@""]) {
                jobsCompletedCell.job_tripsCountImg.hidden = NO;
            } else {
                jobsCompletedCell.job_tripsCountImg.hidden = YES;
            }
            
            if ([mileageValueLbl isEqual:@""] || [mileageValueLbl isEqual:@"0.0"]) {
                jobsCompletedCell.job_mileageImg.hidden = NO;
            } else {
                jobsCompletedCell.job_mileageImg.hidden = YES;
            }
            
            if ([timeValueLbl isEqual:@""]) {
                jobsCompletedCell.job_timeImg.hidden = NO;
            } else {
                jobsCompletedCell.job_timeImg.hidden = YES;
            }
        }
        
        return jobsCompletedCell;
    } else {
        JobsCompletedCell *jobsCompletedCell = [tableView dequeueReusableCellWithIdentifier:@"JobsCompletedCell"];
        return jobsCompletedCell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.jobsOnDutyAcceptTableView) {
        return self.jobsOnDutyAcceptedArray.count;
    } else if (tableView == self.jobsOnDutyCompletedTableView) {
        return self.jobsOnDutyCompletedArray.count;
    } else {
        return 3;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.jobsOnDutyAcceptTableView) {
        return 40.0;
    } else if (tableView == self.jobsOnDutyCompletedTableView) {
        return 100.0;
    } else {
        return 68.0;
    }
}


#pragma mark - ONDEMAND Duty Job Pause & Errors

- (void)showJobCancelledErrorForMainJobView:(UIButton*)sender {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:localizeString(@"Job in progress")
                                message:localizeString(@"Do you want to Complete or Pause current job?")
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesButton = [UIAlertAction
                                actionWithTitle:localizeString(@"Complete")
                                style:UIAlertActionStyleDestructive
                                handler:^(UIAlertAction *action) {
                                    [self stopGreenBtnClick:sender];
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        [self startJobBtnClick:sender];
                                    });
                                }];
    UIAlertAction *pauseButton = [UIAlertAction
                                actionWithTitle:localizeString(@"Pause")
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action) {
                                    [self pauseBtnClick:sender];
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        [self startJobBtnClick:sender];
                                    });
                                }];
    UIAlertAction *noButton = [UIAlertAction
                               actionWithTitle:localizeString(@"Cancel")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {}];
    [alert addAction:yesButton];
    [alert addAction:pauseButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showJobCancelledErrorForCell:(UIButton*)sender {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:localizeString(@"Job in progress")
                                message:localizeString(@"Do you want to Complete or Pause current job?")
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesButton = [UIAlertAction
                                actionWithTitle:localizeString(@"Complete")
                                style:UIAlertActionStyleDestructive
                                handler:^(UIAlertAction *action) {
                                    [self stopGreenBtnClick:sender];
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        [self startJobCellBtnClicked:sender];
                                    });
                                }];
    UIAlertAction *pauseButton = [UIAlertAction
                                actionWithTitle:localizeString(@"Pause")
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction *action) {
                                    [self pauseBtnClick:sender];
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        [self startJobCellBtnClicked:sender];
                                    });
                                }];
    UIAlertAction *noButton = [UIAlertAction
                               actionWithTitle:localizeString(@"Cancel")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {}];
    [alert addAction:yesButton];
    [alert addAction:pauseButton];
    [alert addAction:noButton];
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - Main TabBar Titles Configuration for setting

- (void)setupTabBarTitles {
    
    UITabBarItem *tabBarItem0 = [self.tabBarController.tabBar.items objectAtIndex:[[Configurator sharedInstance].dashboardTabBarNumber intValue]];
    [tabBarItem0 setImage:[[UIImage imageNamed:@"dashboard_unselected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem0 setSelectedImage:[[UIImage imageNamed:@"dashboard_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem0 setTitle:localizeString(@"dashboard_title")];
    
    UITabBarItem *tabBarItem1 = [self.tabBarController.tabBar.items objectAtIndex:[[Configurator sharedInstance].feedTabBarNumber intValue]];
    [tabBarItem1 setImage:[[UIImage imageNamed:@"feed_unselected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem1 setSelectedImage:[[UIImage imageNamed:@"feed_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem1 setTitle:localizeString(@"feed_title")];
    
    UITabBarItem *tabBarItem2 = [self.tabBarController.tabBar.items objectAtIndex:[[Configurator sharedInstance].rewardsTabBarNumber intValue]];
    [tabBarItem2 setImage:[[UIImage imageNamed:@"rewards_unselected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem2 setSelectedImage:[[UIImage imageNamed:@"rewards_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem2 setTitle:localizeString(@"rewards_title")];
    
    UITabBarItem *tabBarItem3 = [self.tabBarController.tabBar.items objectAtIndex:[[Configurator sharedInstance].profileTabBarNumber intValue]];
    [tabBarItem3 setImage:[[UIImage imageNamed:@"profile_unselected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem3 setSelectedImage:[[UIImage imageNamed:@"profile_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [tabBarItem3 setTitle:localizeString(@"profile_title")];
}


#pragma mark - Translation sample Welcome to Localizable.strings file

- (void)setupAdditionalTranslation {
    
    self.welcomeLbl.text = localizeString(@"Welcome aboard!");
    self.demo_completeFirstTripLbl.text = localizeString(@"Complete your First Trip to Unlock Scoring");
    self.welcomeLbl.textColor = [Color officialMainAppColor];
    self.showLeaderLbl.text = localizeString(@"Rank");
    self.latestScoredTripLbl.text = localizeString(@"LATEST SCORED TRIP");
    self.latestScoredTrip2Lbl.text = localizeString(@"LATEST SCORED TRIP");
    self.EcoScoringlbl.text = localizeString(@"ECO SCORING");
    self.EcoScoring2lbl.text = localizeString(@"ECO SCORING");
    
    self.descNeedTotalTripsLbl.text = localizeString(@"Total Trips");
    self.descNeedMileageLbl.text = localizeString(@"Mileage");
    self.descNeedTimeDrivenLbl.text = localizeString(@"Time Driven");
    self.descNeedQuantityLbl.text = localizeString(@"quantity");
    self.descNeedKmLbl.text = localizeString(@"km");
    self.descNeedHoursLbl.text = localizeString(@"hours");
    
    self.HaveYoulbl.text = localizeString(@"Have you already made a trip");
    self.ButIslbl.text = localizeString(@"but it is not in the feed");
    
    self.descTotalTripsLbl.text = localizeString(@"Total Trips");
    self.descMileageLbl.text = localizeString(@"Mileage");
    self.descTimeDrivenLbl.text = localizeString(@"Time Driven");
    self.descQuantityLbl.text = localizeString(@"quantity");
    self.descKmLbl.text = localizeString(@"km");
    self.descHoursLbl.text = localizeString(@"hours");
    
    self.FuelDashlbl.text = localizeString(@"Fuel");
    self.FuelDash2lbl.text = localizeString(@"Fuel");
    self.TireDashlbl.text = localizeString(@"Tire");
    self.TireDash2lbl.text = localizeString(@"Tire");
    self.BrakesDashlbl.text = localizeString(@"Brakes");
    self.BrakesDash2lbl.text = localizeString(@"Brakes");
    self.factor_costOfOwnershipLbl.text = localizeString(@"Cost of Ownership");
    self.demo_factor_costOfOwnershipLbl.text = localizeString(@"Cost of Ownership");
    self.tipLbl.text = localizeString(@"tip 1");
    self.demo_tipLbl.text = localizeString(@"tip 1");
    
    self.MyActivitylbl.text = localizeString(@"My Activity");
    self.MyActivity2lbl.text = localizeString(@"My Activity");
    self.AvgSpeedlbl.text = localizeString(@"Average Speed");
    self.AvgSpeed2lbl.text = localizeString(@"Average Speed");
    self.MaxSpeedlbl.text = localizeString(@"Max Speed");
    self.MaxSpeed2lbl.text = localizeString(@"Max Speed");
    self.AvgDistancelbl.text = localizeString(@"Average Trip Distance");
    self.AvgDistance2lbl.text = localizeString(@"Average Trip Distance");
    self.DrivingStreaklbl.text = localizeString(@"DRIVING STREAKS");
    self.streaks_speedingLbl.text = localizeString(@"No Speeding");
    self.streaks_phoneLbl.text = localizeString(@"No Phone Usage");
    
    [_LeanrMorelbl setTitle:localizeString(@"Learn more>>") forState:UIControlStateNormal];
    
    if ([Configurator sharedInstance].needDistanceInMiles || [defaults_object(@"needDistanceInMiles") boolValue]) {
        self.descNeedKmLbl.text = localizeString(@"dash_miles");
        self.descKmLbl.text = localizeString(@"dash_miles");
    }
    
    self.scoringAvailableIn.text = localizeString(@"Scoring is available in:");
    //self.driveAsYouDo.text = localizeString(@"Drive as you do normally");
    self.DriveAsYoulbl.text = localizeString(@"Drive as you do normally");
}


#pragma mark - Helpers for labels with images left/right

- (IBAction)lastTripTapDetect:(id)sender {
    UITabBarController *tabBar = (UITabBarController *)[AppDelegate appDelegate].window.rootViewController;
    [tabBar setSelectedIndex:[[Configurator sharedInstance].feedTabBarNumber intValue]];
}

- (NSMutableAttributedString*)createStartDateLabelImgBefore:(NSString*)text {
    NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
    imageAttachment.image = [UIImage imageNamed:@"feed_round_grey"];
    imageAttachment.bounds = CGRectMake(0, 0, imageAttachment.image.size.width/1.5, imageAttachment.image.size.height/1.5);
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:@""];
    [completeText appendAttributedString:attachmentString];
    NSString *spaceText = [NSString stringWithFormat:@"  %@", text];
    NSMutableAttributedString *textAfterIcon = [[NSMutableAttributedString alloc] initWithString:spaceText];
    [completeText appendAttributedString:textAfterIcon];
    return completeText;
}

- (NSMutableAttributedString*)createEndDateLabelImgBefore:(NSString*)text {
    NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
    imageAttachment.image = [UIImage imageNamed:@"feed_round_green_mini"];
    imageAttachment.bounds = CGRectMake(0, 0, imageAttachment.image.size.width/1.5, imageAttachment.image.size.height/1.5);
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:@""];
    [completeText appendAttributedString:attachmentString];
    NSString *spaceText = [NSString stringWithFormat:@"  %@", text];
    NSMutableAttributedString *textAfterIcon = [[NSMutableAttributedString alloc] initWithString:spaceText];
    [completeText appendAttributedString:textAfterIcon];
    return completeText;
}

- (NSMutableAttributedString*)createOpenAppSettingsLblImgBefore:(NSString*)text {
    if IS_OS_12_OR_OLD
        text = @"Check App Permissions";
    NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
    imageAttachment.image = [UIImage imageNamed:@"demo_mapAlert"];
    imageAttachment.bounds = CGRectMake(0, -2, imageAttachment.image.size.width/2.8, imageAttachment.image.size.height/2.8);
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:@""];
    [completeText appendAttributedString:attachmentString];
    NSString *spaceText = [NSString stringWithFormat:@"  %@", text];
    NSMutableAttributedString *textAfterIcon = [[NSMutableAttributedString alloc] initWithString:spaceText];
    [textAfterIcon addAttribute:NSForegroundColorAttributeName value:[Color officialWhiteColor] range:(NSRange){0, [textAfterIcon length]}];
    [completeText appendAttributedString:textAfterIcon];
    return completeText;
}

- (NSMutableAttributedString*)createJobOfflineBtnImgBefore:(NSString*)text {
    NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
    imageAttachment.image = [UIImage imageNamed:@"delivery_ph"];
    imageAttachment.bounds = CGRectMake(0, -10, imageAttachment.image.size.width/5, imageAttachment.image.size.height/5);
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:@""];
    [completeText appendAttributedString:attachmentString];
    NSString *spaceText = [NSString stringWithFormat:@"  %@", text];
    NSMutableAttributedString *textAfterIcon = [[NSMutableAttributedString alloc] initWithString:spaceText];
    [textAfterIcon addAttribute:NSForegroundColorAttributeName value:[Color darkGrayColor43] range:NSMakeRange(0, [textAfterIcon length])];
    [completeText appendAttributedString:textAfterIcon];
    return completeText;
}

- (NSMutableAttributedString*)createJobOnlineBtnImgBefore:(NSString*)text {
    NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
    imageAttachment.image = [UIImage imageNamed:@"delivery_ph_g"];
    imageAttachment.bounds = CGRectMake(0, -10, imageAttachment.image.size.width/5, imageAttachment.image.size.height/5);
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
    NSMutableAttributedString *completeText = [[NSMutableAttributedString alloc] initWithString:@""];
    [completeText appendAttributedString:attachmentString];
    NSString *spaceText = [NSString stringWithFormat:@"  %@", text];
    NSMutableAttributedString *textAfterIcon = [[NSMutableAttributedString alloc] initWithString:spaceText];
    [textAfterIcon addAttribute:NSForegroundColorAttributeName value:[Color darkGrayColor43] range:NSMakeRange(0, [textAfterIcon length])];
    [completeText appendAttributedString:textAfterIcon];
    return completeText;
}

- (BOOL)checkArray:(NSArray *)array containsJob:(NSString *)jobName {
    BOOL jobFound = NO;
    for (id object in array) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSString *searchName = [object valueForKey:@"currentJobName"];
            NSRange range = [searchName rangeOfString:jobName];
            if (range.location != NSNotFound) {
                jobFound = YES;
                break;
            }
        }
    }
    return jobFound;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if (@available(iOS 13.0, *)) {
        CGFloat y =  - self.mainScrollView.contentOffset.y - self.mainScrollView.contentInset.top;
         if (self.mainScrollView.contentOffset.y < 0) {
            self.mainBackgroundView.frame = CGRectMake(self.mainBackgroundView.frame.origin.x, self.mainBackgroundView.frame.origin.y, self.mainBackgroundView.frame.size.width, y + 156);
        }
    }

    self.mapSnapshot.layer.borderWidth = 1.0;
    self.mapSnapshot.layer.borderColor = [UIColor clearColor].CGColor;
    self.mapSnapshot.layer.masksToBounds = true;
    self.mapSnapshot.clipsToBounds = true;
    
    self.mapSnapshotForDemo.layer.borderWidth = 1.0;
    self.mapSnapshotForDemo.layer.borderColor = [UIColor clearColor].CGColor;
    self.mapSnapshotForDemo.layer.masksToBounds = true;
    self.mapSnapshotForDemo.clipsToBounds = true;
    
    self.mapDemo_snapshot.layer.borderWidth = 1.0;
    self.mapDemo_snapshot.layer.borderColor = [UIColor clearColor].CGColor;
    self.mapDemo_snapshot.layer.masksToBounds = true;
    self.mapDemo_snapshot.clipsToBounds = true;
}


#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.jobsOnDutyTimerTextField) {
        [self.view endEditing:YES];
        return YES;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.jobsOnDutyTimerTextField.layer setBorderColor:[[Color officialMainAppColor] CGColor]];
    [self.jobsOnDutyTimerImplementation invalidate];
    self.jobsOnDutyTimerImplementation = nil;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    //self.needDisplayAlert = YES;
}


#pragma mark - Actions for avatar and Setting icon

- (IBAction)avaTapDetect:(id)sender {
    ProfileViewController *profileVC = [[UIStoryboard storyboardWithName:@"Profile" bundle:nil] instantiateInitialViewController];
    profileVC.hideBackButton = YES;
    CATransition *transition = [[CATransition alloc] init];
    transition.duration = 0.5;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [self.view.window.layer addAnimation:transition forKey:kCATransition];
    [self presentViewController:profileVC animated:NO completion:nil];
}

- (IBAction)settingsBtnAction:(id)sender {
    SettingsViewController *settingsVC = [[UIStoryboard storyboardWithName:@"Settings" bundle:nil] instantiateInitialViewController];
    [self presentViewController:settingsVC animated:YES completion:nil];
}

- (IBAction)openStreaksAction:(id)sender {
    defaults_set_object(@"userWantOpenStreaksNow", @(1));
    [HapticHelper generateFeedback:FeedbackTypeImpactMedium];
    [self.tabBarController setSelectedIndex:[[Configurator sharedInstance].rewardsTabBarNumber intValue]];
}

- (IBAction)chatOpenAction:(id)sender {
    //TODO IF NEEDED
}

- (IBAction)openAppSystemSettings:(id)sender {
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [Configurator sharedInstance].telematicsSettingsOS13]];
    if IS_OS_12_OR_OLD
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [Configurator sharedInstance].telematicsSettingsOS12]];
    SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:URL];
    svc.delegate = self;
    svc.preferredControlTintColor = [Color OfficialDELBlueColor];
    [self presentViewController:svc animated:YES completion:nil];
}


//iPHONE 5S DEPRECATED EXCUSE US, LOW FONTS IF YOU NEEDED HELPERS FOR SOME ELEMENTS
- (void)lowFontsForOldDevices {
    
    self.needDistanceLabel.font = [Font heavy21];
    
    self.descNeedTotalTripsLbl.font = [Font medium13];
    self.descNeedMileageLbl.font = [Font medium13];
    self.descNeedTimeDrivenLbl.font = [Font medium13];

    self.descTotalTripsLbl.font = [Font medium10];
    self.descMileageLbl.font = [Font medium10];
    self.descTimeDrivenLbl.font = [Font medium10];
    
    self.demo_completeFirstTripLbl.font = [Font bold14];
    
    self.trackingStartLbl.font = [Font bold12];
    
    self.tipLbl.font = [Font regular11];
    self.tipAdviceLbl.font = [Font regular11];
    
    self.demo_tipLbl.font = [Font regular11];
    self.demo_tipAdviceLbl.font = [Font regular11];
    
    self.jobsOnDutyTimerTextField.font = [Font regular9];
    [self.jobsOnDutyTimerTextField makeFormFieldShift5];
    
    self.factor_costOfOwnershipLbl.font = [Font light13];
    self.demo_factor_costOfOwnershipLbl.font = [Font light13];
    
    self.streaks_speedingLbl.font = [Font semibold11];
    self.streaks_phoneLbl.font = [Font semibold11];
    
    [self.arrowUpDownBtn addConstraint:[NSLayoutConstraint constraintWithItem:self.arrowUpDownBtn
                                                                      attribute:NSLayoutAttributeWidth
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1
                                                                       constant:35]];
    
    [self.arrowUpDownBtn addConstraint:[NSLayoutConstraint constraintWithItem:self.arrowUpDownBtn
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1
                                                                       constant:35]];
    
}


@end
