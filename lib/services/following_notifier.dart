class FollowingNotifier {
  static final FollowingNotifier _instance = FollowingNotifier._internal();
  factory FollowingNotifier() => _instance;
  FollowingNotifier._internal();

  Function()? _onFollowingChanged;

  void setCallback(Function() callback) {
    _onFollowingChanged = callback;
  }

  void notifyFollowingChanged() {
    _onFollowingChanged?.call();
  }
}