import { NumberObject } from '../utils/BaseObjects';
import { DesignSystem } from '../utils/DesignSystem';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { MissionArr, MissionInfo } from '../model/Mission';

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
  /*@Local schedules: ScheduleList = AppStorageV2.connect<ScheduleList>(ScheduleList, () => new ScheduleList())!;*/
  @Local showDialog: boolean = false;
  @Local MissionName: string = "";
  @Local MissionDetails: string = "";
  @Local MissionRequest: number = 0;

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

  /*  @Builder
    PageMap(name: string) {
      if (name === "first_page") {
        pageOneTmp()
      }
    }*/

  build() {
    /*Navigation(this.pathStack) {*/
    Column() {
      Text($r('app.string.Awards'))
        .fontSize(this.ds.getSize(1.5))
        .textAlign(TextAlign.Start)
        .lineHeight(this.ds.getSize(2))
        .fontWeight(FontWeight.Bolder)
        .width('100%')
      // Row() {
      //   Button("已完成", { type: ButtonType.Normal, stateEffect: false })
      //     .onClick(() => {
      //       this.completed = true;
      //     })
      //     .borderRadius(8)
      //     .fontSize(this.ds.getSize(0.75))
      //     .fontWeight(FontWeight.Bold)
      //     .width('50%')
      //     .backgroundColor(this.completed ? this.ds.getColor(this.ccm, 'surface', 600, 0.3) :
      //     this.ds.getColor(this.ccm, 'surface', 400, 0.2))
      //     .fontColor(this.ds.getColor(this.ccm, 'surface', 1000))
      //   Button("未完成", { type: ButtonType.Normal, stateEffect: false })
      //     .onClick(() => {
      //       this.completed = false;
      //     })
      //     .borderRadius(8)
      //     .fontSize(this.ds.getSize(0.75))
      //     .fontWeight(FontWeight.Bold)
      //     .width('50%')
      //     .backgroundColor(this.completed ? this.ds.getColor(this.ccm, 'surface', 400, 0.2) :
      //     this.ds.getColor(this.ccm, 'surface', 600, 0.3))
      //     .fontColor(this.ds.getColor(this.ccm, 'surface', 1000))
      // }
      // .width('100%')

      Stack() {
        List() {
          ForEach(this.MissionArr, (item: MissionInfo, index: number) => {
            if (item.MissionState === this.completed) {
              ListItem() {
                Row() {
                  Column() {
                    Text(item.MissionName)
                      .textAlign(TextAlign.Start)
                    Text(item.MissionDetails)
                      .textAlign(TextAlign.Start)
                  }
                  .width('55%')

                  Text('需要火种' + item.MissionRequest + '个')
                    .width('15%')
                  Button("delete")
                    .width('30%')
                    .onClick(() => {
                      this.MissionArr.splice(index, 1);
                    })
                    .backgroundColor(this.ds.getColor(this.ccm, 'surface', 0))
                    .fontColor(this.ds.getColor(this.ccm, 'surface', 1000))
                }
                .width('100%').height(100)
                .borderRadius(10).backgroundColor(this.ds.getColor(this.ccm, 'surface', 0, 1))
              }
            }
          }, (item: MissionInfo) => item.MissionName)
        }
        .width('100%')
        .height('88%')

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

    /*}
    .navDestination(this.PageMap)
    .mode(NavigationMode.Stack)*/
  }
}

/*
@ComponentV2
export struct pageOneTmp {
  @Local newMission: MissionInfo = new MissionInfo('','',0,false);
  @Local pathStack: NavPathStack = new NavPathStack();
  @Consumer('DesignSystem') ds: DesignSystem = new DesignSystem();
  @Local ccm: NumberObject =
    AppStorageV2.connect<NumberObject>(NumberObject, 'currentColorMode',
      () => new NumberObject(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT))!;

  build() {
    NavDestination() {
      Column() {
        Row()
        {
          Text("任务名")
          TextInput({text:this.newMission.MissionName!!})
        }
        Row()
        {
          Text("任务细节")
          TextInput({text:this.newMission.MissionDetails!!})
        }
        Row()
        {
          Text("火种需求")
          TextInput(*/
/*{text:this.newMission.MissionRequest}*/
/*
)
            .type(InputType.Number)
        }
        Button("确定", { type: ButtonType.Normal, stateEffect: false })
          .onClick(() => {

          })
          .borderRadius(8)
          .fontSize(this.ds.getSize(1.5))
          .fontWeight(FontWeight.Bolder)
          .width('50%')
          .backgroundColor(this.ds.getColor(this.ccm, 'primary', 500, 1))
        Text(this.newMission.MissionName)
      }.width('100%').height('100%')
    }.title("添加一个任务")
    .onBackPressed(() => {
      const popDestinationInfo = this.pathStack.pop(); // 弹出路由栈栈顶元素
      console.info('pop' + '返回值' + JSON.stringify(popDestinationInfo));
      return true
    })
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }
}*/
