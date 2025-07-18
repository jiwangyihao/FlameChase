import { NumberObject, StringObject } from '../utils/BaseObjects';
import { DesignSystem } from '../utils/DesignSystem';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { MissionArr, MissionInfo } from '../model/Mission';
import { Header } from '../view/Header';
import { BreakpointType, BreakpointTypeEnum } from '../utils/BreakpointSystem';

@ComponentV2
export struct AwardsPage {
  @Local pathStack: NavPathStack = new NavPathStack();
  /*@Local  MissionArr: Array<MissionInfo> = [
    new MissionInfo('example1','an example',1,false),
    new MissionInfo('example2','an example',2,false),
  ]*/
  @Local MissionArr: MissionArr = AppStorageV2.connect<MissionArr>(MissionArr, () => new MissionArr())!;
  @Local completed: boolean = true;
  @Consumer('DesignSystem') ds: DesignSystem = new DesignSystem();
  @Local ccm: NumberObject =
    AppStorageV2.connect<NumberObject>(NumberObject, 'currentColorMode',
      () => new NumberObject(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT))!;
  @Local currentBreakpoint: StringObject =
    AppStorageV2.connect<StringObject>(StringObject, 'currentBreakpoint',
      () => new StringObject(BreakpointTypeEnum.MD))!;
  /*@Local schedules: ScheduleList = AppStorageV2.connect<ScheduleList>(ScheduleList, () => new ScheduleList())!;*/
  @Local showDialog: boolean = false;
  @Local MissionName: string = "";
  @Local MissionDetails: string = "";
  @Local MissionRequest: number = 0;
  @Event openSetting: () => void = () => {
  };

  @Builder
  dialogBuilder() {
    Column({ space: this.ds.getSize(0.25) }) {
      Text("任务奖励")
        .fontSize(this.ds.getSize(1))
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 8 })

      TextInput({
        text: this.MissionName!!,
        placeholder: "请输入任务奖励",
      })
        .type(InputType.Normal)
        .margin({
          bottom: this.ds.getSize(1),
        })
        .backgroundColor(this.ds.getColor(this.ccm, 'surface', 100, 0.2))
        .borderColor(this.ds.getColor(this.ccm, 'surface', 800, 0.3))
        .borderWidth(this.ds.getSize(0.1))
        .borderRadius(this.ds.getSize(0.5))
        .placeholderColor(this.ds.getColor(this.ccm, 'surface', 800, 0.5))

      Text("奖励描述")
        .fontSize(this.ds.getSize(1))
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 8 })

      TextArea({
        text: this.MissionDetails!!,
        placeholder: "请输入奖励描述\n\n",
      })
        .margin({
          bottom: this.ds.getSize(1),
        })
        .backgroundColor(this.ds.getColor(this.ccm, 'surface', 100, 0.2))
        .borderColor(this.ds.getColor(this.ccm, 'surface', 800, 0.3))
        .borderWidth(this.ds.getSize(0.1))
        .borderRadius(this.ds.getSize(0.5))
        .placeholderColor(this.ds.getColor(this.ccm, 'surface', 800, 0.5))

      Row() {
        Text("火种个数")
          .fontSize(this.ds.getSize(1))
          .fontWeight(FontWeight.Bold)
        Text(this.MissionRequest.toFixed(0) + " 个")
          .fontSize(this.ds.getSize(1))
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Slider({
        value: this.MissionRequest,
        step: 1,
        style: SliderStyle.InSet,
        max: 12,
      })
        .trackColor(this.ds.getColor(this.ccm, 'surface', 100, 0.2))
        .blockColor(this.ds.getColor(this.ccm, 'surface', 800, 0.3))
        .selectedColor(this.ds.getColor(this.ccm, 'primary', 500, 0.8))
        .showSteps(true)
        .onChange((value: number, mode: SliderChangeMode) => {
          this.MissionRequest = value;
          console.info('value:' + value + 'mode:' + mode.toString());
        })
        .margin({
          bottom: this.ds.getSize(1),
        })

      Button(
        '提交',
        { type: ButtonType.Normal, stateEffect: true }
      )
        .linearGradient({
          angle: 150,
          colors: [
            [
              this.ds.getColor(this.ccm, 'primary', 500),
              0
            ],
            [
              this.ds.getColor(this.ccm, 'primary', 600),
              0.5
            ],
          ]
        })
        .opacity(this.MissionRequest && this.MissionName && this.MissionDetails ? 1 : 0.5)
        .borderRadius(8)
        .width(this.ds.getSize(6))
        .height(this.ds.getSize(2.5))
        .alignSelf(ItemAlign.End)
        .onClick(() => {
          if (this.MissionRequest && this.MissionName && this.MissionDetails) {
            this.MissionArr.push(new MissionInfo(
              this.MissionName,
              this.MissionDetails,
              this.MissionRequest,
              false
            ));
            this.showDialog = false;
            this.MissionName = "";
            this.MissionDetails = "";
            this.MissionRequest = 0;
          } else {
            console.warn("请填写完整的计划信息");
          }
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
    Column() {
      Header({
        title: $r('app.string.Awards'),
        openSetting: () => {
          this.openSetting();
        }
      })

      Stack() {
        Column() {
          Text("上架中")
            .fontSize(this.ds.getSize(1))
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: this.ds.getSize(0.5) })

          if (
            this.MissionArr.length > 0
          ) {
            List() {
              ForEach(this.MissionArr, (item: MissionInfo, index: number) => {
                ListItem() {
                  Row() {
                    Image($r('app.media.material_symbols__star_shine_rounded'))
                      .width(this.ds.getSize(1.5))
                      .height(this.ds.getSize(1.5))
                      .fillColor(
                        this.ds.getColor(this.ccm, 'surface', 900)
                      )
                    Column({ space: this.ds.getSize(0.25) }) {
                      Row() {
                        Text(item.MissionName)
                          .fontSize(this.ds.getSize(1))
                          .fontWeight(FontWeight.Bold)

                        Text(`售价：${item.MissionRequest} 火种`)
                          .fontSize(this.ds.getSize(0.8))
                          .fontWeight(FontWeight.Medium)
                      }
                      .justifyContent(FlexAlign.SpaceBetween)
                      .width('100%')

                      Text(item.MissionDetails)
                        .fontSize(this.ds.getSize(0.8))
                        .fontWeight(FontWeight.Medium)
                    }
                    .alignItems(HorizontalAlign.Start)
                    .margin({ left: this.ds.getSize(1), right: this.ds.getSize(1.5) })
                    .flexGrow(1)
                  }
                  .width('100%')
                  .height(this.ds.getSize(5))
                  .alignItems(VerticalAlign.Center)

                  // Row() {
                  //   Column() {
                  //     Text(item.MissionName)
                  //       .textAlign(TextAlign.Start)
                  //     Text(item.MissionDetails)
                  //       .textAlign(TextAlign.Start)
                  //   }
                  //   .width('55%')
                  //
                  //   Text('需要火种' + item.MissionRequest + '个')
                  //     .width('15%')
                  //   Button("delete")
                  //     .width('30%')
                  //     .onClick(() => {
                  //       this.MissionArr.splice(index, 1);
                  //     })
                  //     .backgroundColor(this.ds.getColor(this.ccm, 'surface', 0))
                  //     .fontColor(this.ds.getColor(this.ccm, 'surface', 1000))
                  // }
                  // .width('100%').height(100)
                  // .borderRadius(10).backgroundColor(this.ds.getColor(this.ccm, 'surface', 0, 1))
                }
              }, (item: MissionInfo) => item.MissionName)
            }
            .padding({ left: this.ds.getSize(1), right: this.ds.getSize(1) })
            .divider({
              strokeWidth: this.ds.getSize(0.1),
              color: this.ds.getColor(this.ccm, 'surface', 800, 0.25)
            })
            .backgroundColor(this.ds.getColor(this.ccm, 'surface', 100, 0.5))
            .borderColor(
              this.ds.getColor(this.ccm, 'surface', 800, 0.3)
            )
            .borderWidth(this.ds.getSize(0.15))
            .borderRadius(this.ds.getSize(1))
            .lanes(new BreakpointType<number>({
              sm: 1,
              md: 1,
              lg: 2,
              xl: 2
            }).getValue(this.currentBreakpoint.value))
          } else {

            Row() {
              Text("暂无上架中的奖励，新建一个吧！")
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
            .width('100%')
            .height(this.ds.getSize(5))
            .borderRadius(this.ds.getSize(1))
            .justifyContent(FlexAlign.Center)
            .margin({
              bottom: this.ds.getSize(1),
            })
          }
        }
        .width('100%')
        .margin({ top: 28 })
        .alignItems(HorizontalAlign.Start)

        Button() {
          Image($r('app.media.material_symbols__add_rounded'))
            .width(this.ds.getSize(3))
            .height(this.ds.getSize(3))
            .fillColor(this.ds.getColor(this.ccm, 'primary', 0))
        }
        .linearGradient({
          angle: 150,
          colors: [
            [
              this.ds.getColor(this.ccm, 'primary', 500),
              0
            ],
            [
              this.ds.getColor(this.ccm, 'primary', 600),
              0.5
            ],
          ]
        })
        .width(this.ds.getSize(4))
        .height(this.ds.getSize(4))
        .position({
          right: this.ds.getSize(1),
          bottom: this.ds.getSize(0)
        })
        .onClick(() => {
          this.showDialog = true;
        })
        .bindSheet($$this.showDialog, this.dialogBuilder(), {
          backgroundColor: this.ds.getColor(this.ccm, 'surface', 50, 0.2),
          detents: [this.ds.getSize(20), SheetSize.MEDIUM, SheetSize.LARGE],
          blurStyle: BlurStyle.Thick,
          maskColor: this.ds.getColor(this.ccm, 'surface', 950, 0.2),
          showClose: true,
          title: { title: "新建奖励任务" },
          width: '95%',
          borderWidth: this.ds.getSize(0.15),
          borderColor: this.ds.getColor(this.ccm, 'surface', 950, 0.25)
        })
      }
      .width('100%')
      .height('100%')
      .align(Alignment.TopStart)
    }
    .height('100%')
    .width('100%')
    .padding({
      left: this.ds.getSize(1),
      right: this.ds.getSize(1),
      bottom: this.ds.getSize(5.5),
      top: this.ds.getSize(2)
    })
    .alignItems(HorizontalAlign.Start)
  }
}
