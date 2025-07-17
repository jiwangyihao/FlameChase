import { bufferToString } from '../utils/BufferUtil';
import { ScheduleCategory } from './Schedule';

@ObservedV2
export class Coreflame {
  name: string;
  type: string;
  description: string;
  bind: ScheduleCategory;
  @Trace recycledTime: number = -1;

  constructor(name: string, type: string, description: string, bind: ScheduleCategory = ScheduleCategory.CHAOS) {
    this.name = name;
    this.type = type;
    this.description = description;
    this.bind = bind;
  }
}

export class CoreflameGroup {
  type: string;
  bind: ScheduleCategory;
  coreflames: Coreflame[];

  constructor(coreflames: Coreflame[]) {
    this.type = coreflames[0].type;
    this.bind = coreflames[0].bind;
    this.coreflames = coreflames;
  }

  get unrecycledCoreflames(): Coreflame[] {
    return this.coreflames.filter(coreflame => coreflame.recycledTime < 0);
  }

  set unrecycledCoreflames(_: object) {
    //
  }

  get recycledCoreflames(): Coreflame[] {
    return this.coreflames.filter(coreflame => !(coreflame.recycledTime < 0));
  }

  set recycledCoreflames(_: object) {
    //
  }
}

export class CoreflameGroupList extends Array<CoreflameGroup> {
  constructor(...coreflameGroups: CoreflameGroup[]) {
    super(...coreflameGroups);
  }

  get unrecycledCoreflames(): Coreflame[] {
    return this.flatMap(group => group.unrecycledCoreflames);
  }

  set unrecycledCoreflames(_: object) {
    //
  }

  get recycledCoreflames(): Coreflame[] {
    return this.flatMap(group => group.recycledCoreflames);
  }

  set recycledCoreflames(_: object) {
    //
  }

  getRandomCoreflameByCategory(category: ScheduleCategory): Coreflame | null {
    for (const group of this) {
      if (group.bind === category) {
        const unrecycledCoreflames = group.unrecycledCoreflames;
        if (unrecycledCoreflames.length > 0) {
          return unrecycledCoreflames[Math.floor(Math.random() * unrecycledCoreflames.length)];
        }
      }
    }
    return null;
  }

  getRandomCoreflame(): Coreflame | null {
    const allUnrecycledCoreflames = this.unrecycledCoreflames;
    if (allUnrecycledCoreflames.length > 0) {
      return allUnrecycledCoreflames[Math.floor(Math.random() * allUnrecycledCoreflames.length)];
    }
    return null;
  }

  findByName(bindCoreflameName: string): Coreflame | undefined {
    for (const group of this) {
      const coreflame = group.coreflames.find(cf => cf.name === bindCoreflameName);
      if (coreflame) {
        return coreflame;
      }
    }
    return undefined;
  }
}

export function getCoreflamesFromJSON(context: Context) {
  return (JSON.parse(
    bufferToString(context.resourceManager.getRawFileContentSync('coreflame.json'))
  ) as Coreflame[])
    .map(coreflame => new Coreflame(
      coreflame.name,
      coreflame.type,
      coreflame.description,
      coreflame.bind as ScheduleCategory
    ));


}