class Verdict {
  String index;
  String name;
  String verdict;
  int passedTestCount;
  int timeConsumedMillis;
  int memoryConsumedBytes;

  Verdict(
      {this.index,
      this.name,
      this.memoryConsumedBytes,
      this.passedTestCount,
      this.timeConsumedMillis,
      this.verdict});
}
