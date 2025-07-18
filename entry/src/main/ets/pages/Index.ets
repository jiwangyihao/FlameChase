import { BreakpointSystem, BreakpointTypeEnum } from '../utils/BreakpointSystem';
import { DesignSystem } from '../utils/DesignSystem';
import { AwardsPage } from './AwardsPage';
import { ChroniclePage } from './ChroniclePage';
import { CoreflamesPage } from './CoreflamesPage';
import { SchedulePage } from './SchedulePage';
import { ConfigurationConstant } from '@kit.AbilityKit';
import {
  AppStorageV2,
  ColorMetrics,
  LengthMetrics,
  SegmentButtonV2Item,
  SegmentButtonV2Items,
  TabSegmentButtonV2
} from '@kit.ArkUI';
import { NumberObject, StringObject } from '../utils/BaseObjects';
import { deviceInfo } from '@kit.BasicServicesKit';

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
  @Local primaryHue: NumberObject = AppStorageV2.connect<NumberObject>(NumberObject, 'primaryHue',
    () => new NumberObject(-1))!;
  @Local primarySat: NumberObject = AppStorageV2.connect<NumberObject>(NumberObject, 'primarySat',
    () => new NumberObject(-1))!;
  @Local surfaceHue: NumberObject = AppStorageV2.connect<NumberObject>(NumberObject, 'surfaceHue',
    () => new NumberObject(-1))!;
  @Local surfaceSat: NumberObject = AppStorageV2.connect<NumberObject>(NumberObject, 'surfaceSat',
    () => new NumberObject(-1))!;
  @Local currentIndex: number = 0;
  @Local showSetting: boolean = false;
  @Local darkModeIndex: number = 0;
  @Local languageIndex: number = 0;
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
  settingsPanelBuilder() {
    Column({ space: this.ds.getSize(0.25) }) {
      Text("显示设置")
        .fontSize(this.ds.getSize(1))
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Start)
        .fontColor(
          this.ds.getColor(this.ccm, 'surface', 900, 0.6)
        )
        .width('100%')
        .margin({
          bottom: this.ds.getSize(0.25),
        })


      // Row() {
      //   Image($r('app.media.mdi__moon_and_stars'))
      //     .width(this.ds.getSize(1.5))
      //     .height(this.ds.getSize(1.5))
      //     .fillColor(
      //       this.ds.getColor(this.ccm, 'surface', 900)
      //     )
      //   Column({ space: this.ds.getSize(0.25) }) {
      //     Row() {
      //       Text("更改界面语言")
      //         .fontSize(this.ds.getSize(1))
      //         .fontWeight(FontWeight.Bold)
      //     }
      //     .justifyContent(FlexAlign.SpaceBetween)
      //
      //     Text("请选择偏好显示语言")
      //       .fontSize(this.ds.getSize(0.8))
      //       .fontWeight(FontWeight.Medium)
      //   }
      //   .alignItems(HorizontalAlign.Start)
      //   .margin({ left: this.ds.getSize(0.5) })
      //
      //   Blank()
      //
      //
      //   Select([
      //     { value: '跟随系统' },
      //     { value: '中文（简体）' },
      //     { value: 'English' }
      //   ])
      //     .selected(this.languageIndex)
      //     .onSelect((index: number) => {
      //       console.info('Select:' + index);
      //       this.languageIndex = index;
      //       try {
      //         switch (index) {
      //           case 0:
      //             i18n.System.setAppPreferredLanguage('default');
      //             break;
      //           case 1:
      //             i18n.System.setAppPreferredLanguage('zh-Hans'); // 设置应用偏好语言为中文（简体）
      //             break;
      //           case 2:
      //             i18n.System.setAppPreferredLanguage('en'); // 设置应用偏好语言为英文
      //             break;
      //           default:
      //             i18n.System.setAppPreferredLanguage('default');
      //         }
      //         i18n.System.setAppPreferredLanguage('zh-Hans'); // 设置应用偏好语言为zh-Hans
      //       } catch (error) {
      //         let err: BusinessError = error as BusinessError;
      //         console.error(`call System.setAppPreferredLanguage failed, error code: ${err.code}, message: ${err.message}.`);
      //       }
      //     })
      // }
      // .backgroundColor(
      //   this.ds.getColor(this.ccm, 'surface', 100, 0.2)
      // )
      // .borderColor(
      //   this.ds.getColor(this.ccm, 'surface', 800, 0.3)
      // )
      // .borderWidth(this.ds.getSize(0.15))
      // .width('100%')
      // .height(this.ds.getSize(4))
      // .borderRadius(this.ds.getSize(1))
      // .justifyContent(FlexAlign.Center)
      // .padding({
      //   left: this.ds.getSize(1),
      //   right: this.ds.getSize(0.5),
      // })
      // .margin({
      //   bottom: this.ds.getSize(0.5),
      // })


      Row() {
        Image($r('app.media.mdi__moon_and_stars'))
          .width(this.ds.getSize(1.5))
          .height(this.ds.getSize(1.5))
          .fillColor(
            this.ds.getColor(this.ccm, 'surface', 900)
          )
        Column({ space: this.ds.getSize(0.25) }) {
          Row() {
            Text("深色模式")
              .fontSize(this.ds.getSize(1))
              .fontWeight(FontWeight.Bold)
          }
          .justifyContent(FlexAlign.SpaceBetween)

          Text("深色模式")
            .fontSize(this.ds.getSize(0.8))
            .fontWeight(FontWeight.Medium)
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: this.ds.getSize(0.5) })

        Blank()

        if (deviceInfo.osFullName.startsWith('OpenHarmony')) {
          TabSegmentButtonV2({
            items: new SegmentButtonV2Items(
              [
                new SegmentButtonV2Item({ text: '跟随' }),
                new SegmentButtonV2Item({ text: '浅色' }),
                new SegmentButtonV2Item({ text: '深色' }),
              ]
            ),
            selectedIndex: this.darkModeIndex,
            buttonBackgroundColor: ColorMetrics.numeric(
              parseInt(
                (this.ds.getColor(this.ccm, 'surface', 100, 0.75) as string)
                  .replace('#', ''),
                16)
            ),
            itemSelectedBackgroundColor: ColorMetrics.numeric(
              parseInt(
                (this.ds.getColor(this.ccm, 'surface', 0, 0.5) as string)
                  .replace('#', ''),
                16)
            ),
            itemPadding: {
              start: LengthMetrics.vp(0),
              end: LengthMetrics.vp(0)
            },
            $selectedIndex: (index: number) => {
              this.darkModeIndex = index;
              this.getUIContext()
                .getHostContext()
              ?.getApplicationContext()
                .setColorMode(this.darkModeIndex === 0
                  ? ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET
                  : this.darkModeIndex === 1
                    ? ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT
                    : ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
            }
          })
            .width(this.ds.getSize(10))
        } else {
        }
      }
      .backgroundColor(
        this.ds.getColor(this.ccm, 'surface', 100, 0.2)
      )
      .borderColor(
        this.ds.getColor(this.ccm, 'surface', 800, 0.3)
      )
      .borderWidth(this.ds.getSize(0.15))
      .width('100%')
      .height(this.ds.getSize(4))
      .borderRadius(this.ds.getSize(1))
      .justifyContent(FlexAlign.Center)
      .padding({
        left: this.ds.getSize(1),
        right: this.ds.getSize(0.5),
      })
      .margin({
        bottom: this.ds.getSize(0.5),
      })

      Column() {
        Row() {
          Image($r('app.media.mdi__moon_and_stars'))
            .width(this.ds.getSize(1.5))
            .height(this.ds.getSize(1.5))
            .fillColor(
              this.ds.getColor(this.ccm, 'surface', 900)
            )
          Column({ space: this.ds.getSize(0.25) }) {
            Row() {
              Text("设置主题色")
                .fontSize(this.ds.getSize(1))
                .fontWeight(FontWeight.Bold)
            }
            .justifyContent(FlexAlign.SpaceBetween)

            Text("拖动下方滑块选择主题色")
              .fontSize(this.ds.getSize(0.8))
              .fontWeight(FontWeight.Medium)
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: this.ds.getSize(0.5) })
        }
        .justifyContent(FlexAlign.Start)
        .height(this.ds.getSize(4))
        .width('100%')

        Slider({
          value: this.primaryHue.value > 0 ? this.primaryHue.value * 1000 : 0,
          min: -1,
          max: 1000,
          style: SliderStyle.InSet
        })
          .blockColor(this.ds.getColor(this.ccm, 'primary', 100))
          .trackColor(new LinearGradient(Array.from<ESObject, ColorStop>({ length: 360 },
            (_: ESObject, i): ColorStop => {
              return {
                color: DesignSystem.rgbToHex(DesignSystem.hslToRgb({
                  h: i / 360,
                  s: 1,
                  l: 0.5,
                  a: 255
                })),
                offset: i / 360
              }
            })))
          .selectedColor(this.ds.getColor(this.ccm, 'primary', 100, 0.8))
          .showTips(true)
          .onChange((value: number, mode: SliderChangeMode) => {
            this.primaryHue.value = value / 1000;
            this.getUIContext()
              .getHostContext()
            ?.getApplicationContext()
              .setColorMode(this.ccm.value);
            console.info('value:' + value + 'mode:' + mode.toString());
          })

        Slider({
          value: this.primarySat.value > 0 ? this.primarySat.value * 1000 : 1000,
          min: -1,
          max: 1000,
          style: SliderStyle.InSet
        })
          .blockColor(this.ds.getColor(this.ccm, 'primary', 100))
          .trackColor(new LinearGradient(Array.from<ESObject, ColorStop>({ length: 360 },
            (_: ESObject, i): ColorStop => {
              return {
                color: DesignSystem.rgbToHex(DesignSystem.hslToRgb({
                  h: this.primaryHue.value,
                  s: i / 360,
                  l: 0.5,
                  a: 255
                })),
                offset: i / 360
              }
            })))
          .selectedColor(this.ds.getColor(this.ccm, 'primary', 100, 0.8))
          .showTips(true)
          .onChange((value: number, mode: SliderChangeMode) => {
            this.primarySat.value = value / 1000;
            this.getUIContext()
              .getHostContext()
            ?.getApplicationContext()
              .setColorMode(this.ccm.value);
            console.info('value:' + value + 'mode:' + mode.toString());
          })
      }
      .backgroundColor(
        this.ds.getColor(this.ccm, 'surface', 100, 0.2)
      )
      .borderColor(
        this.ds.getColor(this.ccm, 'surface', 800, 0.3)
      )
      .borderWidth(this.ds.getSize(0.15))
      .width('100%')
      .borderRadius(this.ds.getSize(1))
      .padding({
        left: this.ds.getSize(1),
        right: this.ds.getSize(0.5),
      })
      .margin({
        bottom: this.ds.getSize(0.5),
      })

      Column() {
        Row() {
          Image($r('app.media.mdi__moon_and_stars'))
            .width(this.ds.getSize(1.5))
            .height(this.ds.getSize(1.5))
            .fillColor(
              this.ds.getColor(this.ccm, 'surface', 900)
            )
          Column({ space: this.ds.getSize(0.25) }) {
            Row() {
              Text("设置背景色")
                .fontSize(this.ds.getSize(1))
                .fontWeight(FontWeight.Bold)
            }
            .justifyContent(FlexAlign.SpaceBetween)

            Text("拖动下方滑块选择背景色")
              .fontSize(this.ds.getSize(0.8))
              .fontWeight(FontWeight.Medium)
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: this.ds.getSize(0.5) })
        }
        .justifyContent(FlexAlign.Start)
        .height(this.ds.getSize(4))
        .width('100%')

        Slider({
          value: this.surfaceHue.value > 0 ? this.surfaceHue.value * 1000 : 0,
          min: -1,
          max: 1000,
          style: SliderStyle.InSet
        })
          .blockColor(this.ds.getColor(this.ccm, 'primary', 100))
          .trackColor(new LinearGradient(Array.from<ESObject, ColorStop>({ length: 360 },
            (_: ESObject, i): ColorStop => {
              return {
                color: DesignSystem.rgbToHex(DesignSystem.hslToRgb({
                  h: i / 360,
                  s: 1,
                  l: 0.5,
                  a: 255
                })),
                offset: i / 360
              }
            })))
          .selectedColor(this.ds.getColor(this.ccm, 'primary', 100, 0.8))
          .showTips(true)
          .onChange((value: number, mode: SliderChangeMode) => {
            this.surfaceHue.value = value / 1000;
            this.getUIContext()
              .getHostContext()
            ?.getApplicationContext()
              .setColorMode(this.ccm.value);
            console.info('value:' + value + 'mode:' + mode.toString());
          })

        Slider({
          value: this.surfaceSat.value > 0 ? this.surfaceSat.value * 1000 : 1000,
          min: -1,
          max: 1000,
          style: SliderStyle.InSet
        })
          .blockColor(this.ds.getColor(this.ccm, 'primary', 100))
          .trackColor(new LinearGradient(Array.from<ESObject, ColorStop>({ length: 360 },
            (_: ESObject, i): ColorStop => {
              return {
                color: DesignSystem.rgbToHex(DesignSystem.hslToRgb({
                  h: this.surfaceHue.value,
                  s: i / 360,
                  l: 0.5,
                  a: 255
                })),
                offset: i / 360
              }
            })))
          .selectedColor(this.ds.getColor(this.ccm, 'primary', 100, 0.8))
          .showTips(true)
          .onChange((value: number, mode: SliderChangeMode) => {
            this.surfaceSat.value = value / 1000;
            this.getUIContext()
              .getHostContext()
            ?.getApplicationContext()
              .setColorMode(this.ccm.value);
            console.info('value:' + value + 'mode:' + mode.toString());
          })
      }
      .backgroundColor(
        this.ds.getColor(this.ccm, 'surface', 100, 0.2)
      )
      .borderColor(
        this.ds.getColor(this.ccm, 'surface', 800, 0.3)
      )
      .borderWidth(this.ds.getSize(0.15))
      .width('100%')
      .borderRadius(this.ds.getSize(1))
      .padding({
        left: this.ds.getSize(1),
        right: this.ds.getSize(0.5),
      })
      .margin({
        bottom: this.ds.getSize(0.5),
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
    .bindSheet($$this.showSetting, this.settingsPanelBuilder(), {
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
