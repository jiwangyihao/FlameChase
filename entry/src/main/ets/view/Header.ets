import { NumberObject } from '../utils/BaseObjects';
import { DesignSystem } from '../utils/DesignSystem';
import { AppStorageV2 } from '@kit.ArkUI';
import { ConfigurationConstant } from '@kit.AbilityKit';

@ComponentV2
export struct Header {
  @Consumer('DesignSystem') ds: DesignSystem = new DesignSystem();
  @Local ccm: NumberObject =
    AppStorageV2.connect<NumberObject>(NumberObject, 'currentColorMode',
      () => new NumberObject(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT))!;
  @Param @Require title: ResourceStr;
  @Event openSetting: () => void = () => {
  };

  build() {
    Row() {
      Text(this.title)
        .fontSize(this.ds.getSize(1.5))
        .textAlign(TextAlign.Start)
        .lineHeight(this.ds.getSize(2))
        .fontWeight(FontWeight.Bolder)

      Button({ type: ButtonType.Circle }) {
        Image($r('app.media.mdi__settings'))
          .width(this.ds.getSize(1.5))
          .height(this.ds.getSize(1.5))
          .onClick(() => {
            this.openSetting();
          })
      }
      .backgroundColor(this.ds.getColor(this.ccm, 'surface', 900, 0.1))
      .width(this.ds.getSize(2.5))
      .height(this.ds.getSize(2.5))
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .height(this.ds.getSize(3))
    .width('100%')
  }
}
