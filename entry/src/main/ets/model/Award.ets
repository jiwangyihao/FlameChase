@ObservedV2
export class Award {
  @Trace title: string = '';
  @Trace description: string = '';
  @Trace cost: number = 0;

  constructor(
    title: string = '',
    description: string = '',
    cost: number = 0
  ) {
    this.title = title;
    this.description = description;
    this.cost = cost;
  }

  toESObject(): ESObject {
    return {
      title: this.title,
      description: this.description,
      cost: this.cost,
    };
  }
}

export class AwardList extends Array<Award> {
  constructor(...awards: Award[]) {
    super(
      ...awards.map(award => new Award(
        award.title,
        award.description,
        award.cost
      ))
    );
  }

  addAward(award: Award) {
    this.push(new Award(
      award.title,
      award.description,
      award.cost
    ));
  }

  toESObject(): ESObject[] {
    return this.map((award): ESObject => award.toESObject());
  }
}