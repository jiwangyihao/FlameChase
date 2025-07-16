import { BreakpointSystem, BreakpointTypeEnum } from '../utils/BreakpointSystem';
import { DesignSystem } from '../utils/DesignSystem';
import { AwardsPage } from './AwardsPage';
import { ChroniclePage } from './ChroniclePage';
import { CoreflamesPage } from './CoreflamesPage';
import { SchedulePage } from './SchedulePage';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { NumberObject, StringObject } from '../utils/BaseObjects';

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
  @Local currentIndex: number = 0;
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

  build() {
    Tabs({
      barPosition: this.currentBreakpoint.value === BreakpointTypeEnum.LG ? BarPosition.Start : BarPosition.End,
      controller: this.tabsController
    }) {
      TabContent() {
        CoreflamesPage()
      }
      .padding({
        left: this.ds.getSize(1),
        right: this.ds.getSize(1)
      })
      .tabBar(this.tabBarBuilder($r('app.string.Coreflames'), 0, $r("app.media.mdi__flame")))

      TabContent() {
        SchedulePage()
      }
      .padding({
        left: this.ds.getSize(1),
        right: this.ds.getSize(1)
      })
      .tabBar(this.tabBarBuilder($r('app.string.Schedule'), 1, $r("app.media.mdi__invoice_text_scheduled")))

      TabContent() {
        AwardsPage()
      }
      .padding({
        left: this.ds.getSize(1),
        right: this.ds.getSize(1)
      })
      .tabBar(this.tabBarBuilder($r('app.string.Awards'), 2, $r("app.media.streamline_block__other_ui_award")))

      TabContent() {
        ChroniclePage()
      }
      .padding({
        left: this.ds.getSize(1),
        right: this.ds.getSize(1)
      })
      .tabBar(this.tabBarBuilder($r('app.string.Chronicle'), 3, $r("app.media.mdi__scroll_text")))
    }
    .scrollable(false)
    .vertical(this.currentBreakpoint.value === BreakpointTypeEnum.LG ? true : false)
    .divider({
      strokeWidth: 0.5,
      color: this.ds.getColor(this.ccm, 'surface', 900, 0.2)
    })
    .padding({
      top: this.ds.getSize(2),
      bottom: this.ds.getSize(1.5)
    })
    .backgroundColor(this.ds.getColor(this.ccm, 'surface', 20))
    .barHeight(this.ds.getSize(4))
  }
}
