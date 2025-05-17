class Player {
  final String name;
  int score = 0;
  bool canTap = false;

  Player(this.name);

  void addPoint() {
    score++;
  }
}
