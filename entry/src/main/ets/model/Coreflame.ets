import { bufferToString } from '../utils/BufferUtil';

@ObservedV2
export class Coreflame {
  name: string;
  type: string;
  description: string;
  @Trace recycledTime: number = -1;

  constructor(name: string, type: string, description: string) {
    this.name = name;
    this.type = type;
    this.description = description;
  }
}

export class CoreflameGroup {
  type: string;
  coreflames: Coreflame[];

  constructor(type: string, coreflames: Coreflame[]) {
    this.type = type;
    this.coreflames = coreflames;
  }

  get unrecycledCoreflames(): Coreflame[] {
    return this.coreflames.filter(coreflame => coreflame.recycledTime < 0);
  }
}

export class CoreflameGroupList extends Array<CoreflameGroup> {
  constructor(...coreflameGroups: CoreflameGroup[]) {
    super(...coreflameGroups);
  }

  get unrecycledCoreflames(): Coreflame[] {
    return this.flatMap(group => group.unrecycledCoreflames);
  }
}

export function getCoreflamesFromJSON(context: Context) {
  return (JSON.parse(
    bufferToString(context.resourceManager.getRawFileContentSync('coreflame.json'))
  ) as Coreflame[])
    .map(coreflame => new Coreflame(
      coreflame.name,
      coreflame.type,
      coreflame.description
    ));
}