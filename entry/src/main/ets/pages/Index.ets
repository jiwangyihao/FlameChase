import { BreakpointSystem, BreakpointTypeEnum } from '../utils/BreakpointSystem';
import { DesignSystem } from '../utils/DesignSystem';
import { AwardsPage } from './AwardsPage';
import { ChroniclePage } from './ChroniclePage';
import { CoreflamesPage } from './CoreflamesPage';
import { SchedulePage } from './SchedulePage';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { NumberObject, StringObject } from '../utils/BaseObjects';
import { ScheduleCategory, scheduleCategoryIcons } from '../model/Schedule';

@Entry
@ComponentV2
struct Index {
  @Provider('DesignSystem') ds: DesignSystem = new DesignSystem();
  @Local currentBreakpoint: StringObject =
    AppStorageV2.connect<StringObject>(StringObject, 'currentBreakpoint',
      () => new StringObject(BreakpointTypeEnum.MD))!;
  @Local ccm: NumberObject =
    AppStorageV2.connect<NumberObject>(NumberObject, 'currentColorMode',
      () => new NumberObject(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT))!;
  @Local topRectHeight: NumberObject = AppStorageV2.connect<NumberObject>(NumberObject, 'topRectHeight',
    () => new NumberObject(0))!;
  @Local bottomRectHeight: NumberObject = AppStorageV2.connect<NumberObject>(NumberObject, 'bottomRectHeight',
    () => new NumberObject(0))!;
  @Local currentIndex: number = 0;
  @Local showSetting: boolean = false;
  private tabsController: TabsController = new TabsController();
  private breakpointSystem: BreakpointSystem = new BreakpointSystem();

  aboutToAppear() {
    this.breakpointSystem.register();
    this.ds.register(this.getUIContext().getHostContext())
  }

  aboutToDisappear() {
    this.breakpointSystem.unregister();
  }

  @Builder
  tabBarBuilder(title: Resource, targetIndex: number, icon: Resource) {
    Column() {
      Image(icon)
        .width(this.ds.getSize(2))
        .height(this.ds.getSize(2))
        .fillColor(
          this.currentIndex === targetIndex
            ? this.ds.getColor(this.ccm, 'primary')
            : this.ds.getColor(this.ccm, 'surface', 900, 0.6)
        )
      Text(title)
        .fontFamily('HarmonyHeiTi-Medium')
        .fontSize(this.ds.getSize(1))
        .fontColor(
          this.currentIndex === targetIndex
            ? this.ds.getColor(this.ccm, 'primary')
            : this.ds.getColor(this.ccm, 'surface', 900, 0.6))
        .textAlign(TextAlign.Center)
        .lineHeight(this.ds.getSize(1.2))
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.currentIndex = targetIndex;
      this.tabsController.changeIndex(targetIndex);
    })
  }

  @Builder
  startPanelBuilder() {
    Column({ space: this.ds.getSize(0.25) }) {
      Text("- 选择类别快速开始 - ")
        .fontSize(this.ds.getSize(1))
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Center)
        .fontColor(
          this.ds.getColor(this.ccm, 'surface', 900, 0.6)
        )
        .width('100%')
        .margin({
          bottom: this.ds.getSize(0.25),
        })
      Row() {
        ForEach([
          ScheduleCategory.CHAOS,
          ScheduleCategory.STUDY,
          ScheduleCategory.WORK,
          ScheduleCategory.EXERCISE,
          ScheduleCategory.PONDER
        ], (category: ScheduleCategory) => {
          Column({ space: this.ds.getSize(0.5) }) {
            Image(scheduleCategoryIcons.get(category))
              .width(this.ds.getSize(1.5))
              .height(this.ds.getSize(1.5))
              .fillColor(
                this.ds.getColor(this.ccm, 'surface', 800, 0.6)
              )
            Text($r(`app.string.${category}`))
              .fontSize(this.ds.getSize(1))
              .fontWeight(FontWeight.Bold)
              .fontColor(
                this.ds.getColor(this.ccm, 'surface', 800, 0.6)
              )
          }
          .backgroundColor(
            this.ds.getColor(this.ccm, 'surface', 100, 0.2)
          )
          .borderColor(
            this.ds.getColor(this.ccm, 'surface', 800, 0.3)
          )
          .borderWidth(this.ds.getSize(0.15))
          .width(this.ds.getSize(4))
          .height(this.ds.getSize(5))
          .borderRadius(this.ds.getSize(1))
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
          })
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({
        bottom: this.ds.getSize(1),
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({
      left: this.ds.getSize(1),
      right: this.ds.getSize(1),
    })
  }

  build() {
    Tabs({
      barPosition: this.currentBreakpoint.value === BreakpointTypeEnum.LG ? BarPosition.Start : BarPosition.End,
      controller: this.tabsController
    }) {
      TabContent() {
        CoreflamesPage({
          openSetting: () => {
            this.showSetting = true;
          }
        })
      }
      .tabBar(this.tabBarBuilder($r('app.string.Coreflames'), 0, $r("app.media.mdi__flame")))

      TabContent() {
        SchedulePage({
          openSetting: () => {
            this.showSetting = true;
          }
        })
      }
      .tabBar(this.tabBarBuilder($r('app.string.Schedule'), 1, $r("app.media.mdi__invoice_text_scheduled")))

      TabContent() {
        AwardsPage({
          openSetting: () => {
            this.showSetting = true;
          }
        })
      }
      .tabBar(this.tabBarBuilder($r('app.string.Awards'), 2, $r("app.media.streamline_block__other_ui_award")))

      TabContent() {
        ChroniclePage({
          openSetting: () => {
            this.showSetting = true;
          }
        })
      }
      .tabBar(this.tabBarBuilder($r('app.string.Chronicle'), 3, $r("app.media.mdi__scroll_text")))
    }
    .scrollable(false)
    .vertical(this.currentBreakpoint.value === BreakpointTypeEnum.LG ? true : false)
    .divider({
      strokeWidth: 0.5,
      color: this.ds.getColor(this.ccm, 'surface', 900, 0.2)
    })
    .padding({
      top: px2vp(this.topRectHeight.value),
      bottom: px2vp(this.bottomRectHeight.value),
    })
    .backgroundColor(this.ds.getColor(this.ccm, 'surface', 30))
    .barHeight(this.ds.getSize(4))
    .bindSheet($$this.showSetting, this.startPanelBuilder(), {
      backgroundColor: this.ds.getColor(this.ccm, 'surface', 50, 0.2),
      detents: [this.ds.getSize(20), SheetSize.MEDIUM, SheetSize.LARGE],
      blurStyle: BlurStyle.Thick,
      maskColor: this.ds.getColor(this.ccm, 'surface', 950, 0.2),
      showClose: true,
      title: { title: "设置" },
      width: '95%',
      borderWidth: this.ds.getSize(0.15),
      borderColor: this.ds.getColor(this.ccm, 'surface', 950, 0.25),
      preferType: SheetType.BOTTOM
    })
  }
}
