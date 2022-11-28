import 'dart:async';
import 'dart:math';

import 'package:bubble_burst_demo/bubble_burst/components/particles.dart';
import 'package:bubble_burst_demo/bubble_burst/components/particles_widget_controller.dart';
import 'package:flutter/material.dart';

class ParticlesWidget extends StatefulWidget {
  final Size size;
  final ParticlesWidgetController controller;

  const ParticlesWidget({
    Key? key,
    required this.size,
    required this.controller,
  }) : super(key: key);

  @override
  State<ParticlesWidget> createState() => _ParticlesWidgetState();
}

class _ParticlesWidgetState extends State<ParticlesWidget>
    with SingleTickerProviderStateMixin {

  List<Particle> particles = [];

  final List<Color> colors = [
    const Color(0xffffc100),
    const Color(0xffff9a00),
    const Color(0xffff7400),
    const Color(0xffff4d00),
    const Color(0xffff0000),
  ];

  late AnimationController _animationController;
  late Animation _animation;

  final fps = 1 / 24;

  late Timer timer;

  final Random random = Random();

  // particle과 함께 burst되는 숫자와 색 초기값
  Map<String, dynamic> counterText = {
    "count": 1,
    "color": const Color(0xffffc100)
  };

  @override
  void initState() {
    widget.controller.callback = _startAnimation;

    // 텍스트의 이니셜 버스터 위한 에니메이션 콘트롤러
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _animation = Tween(begin: 1.0, end: 2.0).animate(
      _animationController,
    );

    // Refreshing State at Rate of 24/Sec -> frameBuilder 실행 주기
    timer = Timer.periodic(
      Duration(milliseconds: (fps * 1000).floor()),
      _frameBuilder,
    );

    super.initState();
  }

  _animationListener() {
    if (_animationController.isCompleted) {
      _animationController.reverse();
    }
  }

  _frameBuilder(dynamic timestamp) {
    final boxSize = Rect.fromLTRB(
      0,
      0,
      widget.size.width,
      widget.size.height,
    );

    // 파티클의 새 포지션 계산하기 위한 파티클 루핑
    particles.forEach((Particle pt) {
      pt.animate(boxSize);
    });

    // 메모리 누수 있다고 경고하지만, 없으면 작동 안함
    if (particles.isNotEmpty) {
      setState(() {});
    }
  }

  void _startAnimation() {
    for (int i = 0; i < 6; i++) {
      _burstParticles();
    }
  }

  void _burstParticles() {
    final boxSize = Rect.fromLTRB(
      0,
      0,
      widget.size.width,
      widget.size.height,
    );

    // 올드 파티클 제거, FAB 버튼 클릭시
    if (particles.length > 200) {
      particles.removeRange(0, 75);
    }

    _animationController.forward();
    _animationController.addListener(_animationListener);

    // circle(particle)의 변수와 갯수 계산하여 Particle() 객체 p에 입력 후
    // List<Particle> particles = []; 에 저장 : particles.add(p);
    double colorRandom = random.nextDouble();

    // final List<Color> colors = [...] 랜덤 생성
    // particle color : 변경하려면 List color 수정하면 된다.
    Color color = colors[(colorRandom * colors.length).floor()];
    String previousCount = "${counterText['count']}";

    Color prevColor = counterText['color'];
    counterText['count'] = counterText['count'] + 1;
    counterText['color'] = color;

    // clamp(min, max) : 최소 5개, 최대 25개 파티클 랜덤 생성
    int count = random.nextInt(25).clamp(5, 25);
    for (int x = 0; x < count; x++) {
      particles.add(Particle.circle(boxSize));
    }

    // circle count : for looping endPoint
    // text 리스트 numbers를 Particle() 인스턴스 p에 전달 particles.add(p);
    // int count 대신 List<String> lottoBall = ['assets/b1', 'assets/b2'..] 가능함
    List<String> numbers = previousCount.split("");

    for (int x = 0; x < numbers.length; x++) {
      particles.add(Particle.text(boxSize, numbers[x]));
    }
  }

  @override
  void dispose() {
    timer.cancel();
    _animationController.removeListener(_animationListener);
    _animationController.dispose();

    widget.controller.callback = null;

    // particles = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: // 파티클 (구슬) 생성
          particles.map((pt) {
        if (pt.type == ParticleType.TEXT) {
          return Positioned(
              top: pt.position.y,
              left: pt.position.x,
              child: Text(
                pt.text,
                style: TextStyle(
                    fontSize: 50, fontWeight: FontWeight.bold, color: pt.color),
              ));
        } else {
          return Positioned(
              top: pt.position.y,
              left: pt.position.x,
              child: Container(
                width: pt.radius * 2,
                height: pt.radius * 2,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: pt.color),
              ));
        }
      }).toList(),
    );
  }
}


class ParticlesWidgetController {
  Function? callback;

  void startAnimation() {
    callback?.call();
  }
}
