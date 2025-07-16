import { AbilityStage, Configuration } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { DesignSystem } from '../utils/DesignSystem';
import { AppStorageV2, ThemeControl } from '@kit.ArkUI';
import { NumberObject } from '../utils/BaseObjects';

export default class MyAbilityStage extends AbilityStage {
  onConfigurationUpdate(config: Configuration) {
    const currentColorMode = AppStorageV2.connect<NumberObject>(NumberObject, 'currentColorMode',
      () => new NumberObject(config.colorMode!))!;
    currentColorMode.value = config.colorMode!;
    hilog.info(0x0000, 'testTag', 'the newConfig.colorMode is %{public}s',
      JSON.stringify(AppStorage.get('currentColorMode')) ?? '');

    const ds = new DesignSystem();
    ds.register(this.context)
    ThemeControl.setDefaultTheme({
      colors: {
        brand: ds.getColor(new NumberObject(0), 'primary'),
        fontPrimary: ds.getColor(new NumberObject(0), 'surface', 900),
        backgroundPrimary: ds.getColor(new NumberObject(0), 'surface', 25),
      }
    });
  }
}