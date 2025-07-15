import { BreakpointSystem, BreakpointTypeEnum } from '../utils/BreakpointSystem';
import { DesignSystem } from '../utils/DesignSystem';
import { AwardsPage } from './AwardsPage';
import { ChroniclePage } from './ChroniclePage';
import { CoreflamesPage } from './CoreflamesPage';
import { SchedulePage } from './SchedulePage';

@Entry
@Component
struct Index {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  @State currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();
  private breakpointSystem: BreakpointSystem = new BreakpointSystem();
  private ds: DesignSystem = new DesignSystem();

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
        .width(24)
        .height(24)
        .fillColor(
          this.currentIndex === targetIndex
            ? this.ds.getColor('primary')
            : this.ds.getColor('surface', 900, 0.6)
        )
      Text(title)
        .fontFamily('HarmonyHeiTi-Medium')
        .fontSize(10)
        .fontColor(
          this.currentIndex === targetIndex
            ? this.ds.getColor('primary')
            : this.ds.getColor('surface', 900, 0.6))
        .textAlign(TextAlign.Center)
        .lineHeight(14)
        .fontWeight(500)
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
      barPosition: this.currentBreakpoint === BreakpointTypeEnum.LG ? BarPosition.Start : BarPosition.End,
      controller: this.tabsController
    }) {
      TabContent() {
        CoreflamesPage()
      }
      .tabBar(this.tabBarBuilder($r('app.string.Coreflames'), 0, $r("app.media.mdi__flame")))

      TabContent() {
        SchedulePage()
      }
      .tabBar(this.tabBarBuilder($r('app.string.Schedule'), 1, $r("app.media.mdi__invoice_text_scheduled")))

      TabContent() {
        AwardsPage()
      }
      .tabBar(this.tabBarBuilder($r('app.string.Awards'), 2, $r("app.media.streamline_block__other_ui_award")))

      TabContent() {
        ChroniclePage()
      }
      .tabBar(this.tabBarBuilder($r('app.string.Chronicle'), 3, $r("app.media.mdi__scroll_text")))
    }
    .scrollable(false)
    .vertical(this.currentBreakpoint === BreakpointTypeEnum.LG ? true : false)
    .divider({
      strokeWidth: 0.5,
      color: this.ds.getColor('surface', 900, 0.2)
    })
    .padding({ top: this.ds.getSize(2), bottom: this.ds.getSize(1.5) })
    .backgroundColor(this.ds.getColor('surface', 20))
  }
}
