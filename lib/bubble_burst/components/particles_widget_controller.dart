class ParticlesWidgetController {
  Function? callback;

  void startAnimation() {
    callback?.call();
  }
}
