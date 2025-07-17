import { DesignSystem } from '../utils/DesignSystem';
import { Header } from '../view/Header';

@ComponentV2
export struct ChroniclePage {
  @Consumer('DesignSystem') ds: DesignSystem = new DesignSystem();
  @Event openSetting: () => void = () => {
  };

  build() {
    Column() {
      Header({
        title: $r('app.string.Chronicle'),
        openSetting: () => {
          this.openSetting();
        }
      })
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