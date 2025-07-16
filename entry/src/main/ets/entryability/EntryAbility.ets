import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AppStorageV2, ThemeControl, window } from '@kit.ArkUI';
import { DesignSystem } from '../utils/DesignSystem';
import { CoreflameGroup, CoreflameGroupList, getCoreflamesFromJSON } from '../model/Coreflame';
import { preferences } from '@kit.ArkData';
import { NumberObject } from '../utils/BaseObjects';

const DOMAIN = 0x0000;


export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    AppStorageV2.connect<NumberObject>(NumberObject, 'currentColorMode',
      () => new NumberObject(this.context.config.colorMode!));
    const coreflames = getCoreflamesFromJSON(this.context)
    const startOfToday = new Date();
    startOfToday.setHours(0, 0, 0, 0);
    const startOfTodayTimestamp = startOfToday.getTime();
    const coreflamesPreferences = preferences.getPreferencesSync(this.context, { name: 'Coreflames' });
    const coreflameGroups: CoreflameGroup[] = []
    for (const coreflame of coreflames) {
      if (coreflamesPreferences.hasSync(coreflame.name)) {
        coreflame.recycledTime = coreflamesPreferences.getSync(coreflame.name, 0) as number - startOfTodayTimestamp;
      }
      if (coreflameGroups.find(group => group.type === coreflame.type) === undefined) {
        coreflameGroups.push(new CoreflameGroup(coreflame.type, [coreflame]));
      } else {
        const group = coreflameGroups.find(group => group.type === coreflame.type);
        if (group) {
          group.coreflames.push(coreflame);
        }
      }
    }
    AppStorageV2.connect<CoreflameGroupList>(CoreflameGroupList, () => new CoreflameGroupList(...coreflameGroups));
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }

      const ds = new DesignSystem();
      ds.register(this.context)
      ThemeControl.setDefaultTheme({
        colors: {
          brand: ds.getColor(new NumberObject(0), 'primary'),
          fontPrimary: ds.getColor(new NumberObject(0), 'surface', 900),
          backgroundPrimary: ds.getColor(new NumberObject(0), 'surface', 25),
        }
      });
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');

    const coreflamesPreferences = preferences.getPreferencesSync(this.context, { name: 'Coreflames' });
    const coreflameGroupList =
      AppStorageV2.connect<CoreflameGroupList>(CoreflameGroupList, () => new CoreflameGroupList())!;
    const startOfToday = new Date();
    startOfToday.setHours(0, 0, 0, 0);
    const startOfTodayTimestamp = startOfToday.getTime();
    for (const group of coreflameGroupList) {
      for (const coreflame of group.coreflames) {
        if (coreflame.recycledTime > startOfTodayTimestamp) {
          coreflamesPreferences.putSync(coreflame.name.toString(), coreflame.recycledTime);
        }
      }
    }
    coreflamesPreferences.flushSync();
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
