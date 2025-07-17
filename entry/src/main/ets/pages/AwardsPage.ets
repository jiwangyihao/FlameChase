import { NumberObject } from '../utils/BaseObjects';
import { DesignSystem } from '../utils/DesignSystem';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { AppStorageV2 } from '@kit.ArkUI';
import { MissionInfo } from '../model/Mission';

@ComponentV2
export struct AwardsPage {
  @Local pathStack: NavPathStack = new NavPathStack();
  @Local  MissionArr: Array<MissionInfo> = [
    new MissionInfo('example1','an example',1,false),
    new MissionInfo('example2','an example',2,false),
  ]
  @Local completed: boolean = true;
  @Consumer('DesignSystem') ds: DesignSystem = new DesignSystem();
  @Local ccm: NumberObject =
    AppStorageV2.connect<NumberObject>(NumberObject, 'currentColorMode',
      () => new NumberObject(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT))!;

  @Builder
  PageMap(name: string) {
    if (name === "first_page") {
      pageOneTmp()
    }
  }

  build() {
    Navigation(this.pathStack) {
      Column() {
        Text($r('app.string.Awards'))
          .fontSize(this.ds.getSize(1.5))
          .textAlign(TextAlign.Start)
          .lineHeight(this.ds.getSize(2))
          .fontWeight(FontWeight.Bolder)
          .width('100%')
        Row() {
          Button("已完成", { type: ButtonType.Normal, stateEffect: false })
            .onClick(() => {
              this.completed = true;
            })
            .borderRadius(8)
            .fontSize(this.ds.getSize(1.5))
            .fontWeight(FontWeight.Bolder)
            .width('50%')
            .backgroundColor(this.completed ? this.ds.getColor(this.ccm, 'primary', 500, 1) :
            this.ds.getColor(this.ccm, 'primary', 200, 1))
          Button("未完成", { type: ButtonType.Normal, stateEffect: false })
            .onClick(() => {
              this.completed = false;
            })
            .borderRadius(8)
            .fontSize(this.ds.getSize(1.5))
            .fontWeight(FontWeight.Bolder)
            .width('50%')
            .backgroundColor(this.completed ? this.ds.getColor(this.ccm, 'primary', 200, 1) :
            this.ds.getColor(this.ccm, 'primary', 500, 1))
        }
        .width('100%')

        List() {
          ForEach(this.MissionArr, (item: MissionInfo, index: number) => {
            ListItem() {
              Row() {
                Column() {
                  Text('' + index)
                  Text(item.MissionName)
                  Text(item.MissionDetails)
                }

                Text('' + item.MissionRequest)
                Button("delete")
                  .onClick(()=>{
                    this.MissionArr.splice(index,1);
                  })
              }
              .width('100%').height(200)
              .borderRadius(10).backgroundColor(this.ds.getColor(this.ccm, 'primary', 200, 1))
            }
          }, (item: MissionInfo) => item.MissionName)
        }
        .width('100%')
        .height('88%')

        Button({ type: ButtonType.Circle }) {
          Image($r('app.media.add'))
            .width(60)
            .height(60)
        }
        .width(60)
        .height(60)
        .position({ x: '80%', y: 550 })
        .shadow({ radius: 10 })
        .onClick(() => {
          this.pathStack.pushPath({ name: "first_page" });
        })
      }
      .height('100%')
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .navDestination(this.PageMap)
    .mode(NavigationMode.Stack)
  }
}

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
          TextInput(/*{text:this.newMission.MissionRequest}*/)
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
}