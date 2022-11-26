import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'components/particles.dart';

class BurstScreen extends StatefulWidget {
  const BurstScreen({Key? key}) : super(key: key);

  @override
  State<BurstScreen> createState() => _BurstScreenState();
}

class _BurstScreenState extends State<BurstScreen>
    with SingleTickerProviderStateMixin {
  final List<Color> colors = [
    const Color(0xffffc100),
    const Color(0xffff9a00),
    const Color(0xffff7400),
    const Color(0xffff4d00),
    const Color(0xffff0000),
  ];

  final GlobalKey _boxKey = GlobalKey();

  final Random random = Random();

  // 중력, 당기는 힘, 공기 저항, 초당 프레임 변수 설정
  final double gravity = 9.81;
  final dragCof = 0.47;
  final airDensity = 1.1644;
  final fps = 1 / 24;

  late Timer timer;

  // 전체 박스 사이즈
  Rect boxSize = Rect.zero;

  List<Particle> particles = [];

  // particle과 함께 burst되는 숫자와 색 초기값
  Map<String, dynamic> counterText = {
    "count": 1,
    "color": const Color(0xffffc100)
  };

  late AnimationController _animationController;
  late Animation _animation;

  // initState 내용
  // 1. AnimationController for initial Burst Animation of Text
  // 2. _boxKey로 boxSize 가져오기
  // 3. 24/fps로 리프레쉬 하기

  @override
  void initState() {
    // 텍스트의 이니셜 버스터 위한 에니메이션 콘트롤러
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _animation = Tween(begin: 1.0, end: 2.0).animate(
      _animationController,
    );

    // Getting the Initial size of Container as soon as the First Frame Renders
    // 프레임 렌더링시 timeStamp 파라미터로 콘테이너의 시작 boxSize 가져오는 메소드
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Size? size = _boxKey.currentContext!.size;
      boxSize = Rect.fromLTRB(
        0,
        0,
        size!.width,
        size.height,
      );
    });

    // Refreshing State at Rate of 24/Sec -> frameBuilder 실행 주기
    timer = Timer.periodic(
      Duration(milliseconds: (fps * 1000).floor()),
      frameBuilder,
    );

    super.initState();
  }

  _animationListener() {
    if (_animationController.isCompleted) {
      _animationController.reverse();
    }
  }

  // Partkcle 클래스 모델에서 기본 생성된 값 참조
  //class Particle {
  //   ParticleType type = ParticleType.CIRCLE;
  //   String text = "";
  //   PVector position = PVector(0.0, 0.0);
  //   PVector velocity = PVector(0.0, 0.0);
  //   double mass = 10.0; //Kg
  //   double radius = 10 / 100; // 1m = 100 pt or px
  //   double area = 0.0314; //PI x R x R;
  //   double jumpFactor = -0.6;
  //   Color color = Colors.green;
  // }

  // frameBuilder(dynamic timestamp) {}
  // 시간 변수에 따른 공기저항, 당기는 힘, 속도, 면적 적용하여 프레임 빌드 구성 메소드
  // 1. 새로운 위치 계산 위해 파티클을 forEach 구문으로 루핑 돌린다
  //   -당기는 힘 변수 계산 -> 가속도 변수 계산 ->가속도 증가 계산 -> 포지션 증감 계산
  //   -> 벽 충돌 이후 포지션과 가속도 변화 계산 메소드 적용

  frameBuilder(dynamic timestamp) {
    // 파티클의 새 포지션 계산하기 위한 파티클 루핑
    particles.forEach((pt) {
      // dragForce : 당기는 힘 계산, 네거티브 값이어야 함
      double dragForceX =
          -0.5 * airDensity * pow(pt.velocity.x, 2) * dragCof * pt.area;
      double dragForceY =
          -0.5 * airDensity * pow(pt.velocity.y, 2) * dragCof * pt.area;

      dragForceX = dragForceX.isInfinite ? 0.0 : dragForceX;
      dragForceY = dragForceY.isInfinite ? 0.0 : dragForceY;

      // 가속도 계산, 당기는 힘에 중량을 나눈 값 x와 중력을 합친 y값
      double accX = dragForceX / pt.mass;
      double accY = gravity + dragForceY / pt.mass;

      // 속력 변화 계산
      pt.velocity.x += accX * fps;
      pt.velocity.y += accY * fps;

      // 위치 변화 계산
      pt.position.x += pt.velocity.x * fps * 100;
      pt.position.y += pt.velocity.y * fps * 100;

      // 벽 충돌후 속도와 위치 변화 메서드
      boxCollision(pt);
    });

    // 메모리 누수 있다고 경고하지만, 없으면 작동 안함
    if (particles.isNotEmpty) {
      setState(() {});
    }
  }

  // 작동 버튼 클릭하면 이전 파티클 제거 후 파티클 폭발 메소드 순서
  // 1. 동작 버튼 클릭 시 오래된 파티클 제거하기
  // 2. _animationController 메소드
  // 3. circle 변수 color & text : random 값을 X,Y position 계산
  // 4. circle Particle() 객체 p 인스턴스에 전달 후 particles.add(p);
  // 5. text 리스트 numbers 계산 -> Particle() 인스턴스 p에 입력 -> particles.add(p);

  burstParticles() {
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
      double randomX = random.nextDouble() * 7.0;
      // X position: 짝수이면 줄여야는데, 사방 터지지 않는 이슈 있음
      if (x % 2 == 0) {
        randomX += randomX;
      }
      // Y position
      double randomY = random.nextDouble() * -7.0;
      // Particle 인스턴스 생성
      Particle p = Particle();
      // p.type = ParticleType.CIRCLE; // circle은 default 값임
      // 파티클 반지름은 최소 2, 최대 10 -> 크기 변경 할 수 있음
      p.radius = (random.nextDouble() * 10.0).clamp(2.0, 10.0);
      p.color = prevColor;
      p.position = PVector(boxSize.center.dx, boxSize.center.dy);
      p.velocity = PVector(randomX, randomY);
      particles.add(p);
    }

    // circle count : for looping endPoint
    // text 리스트 numbers를 Particle() 인스턴스 p에 전달 particles.add(p);
    // int count 대신 List<String> lottoBall = ['assets/b1', 'assets/b2'..] 가능함
    List<String> numbers = previousCount.split("");

    for (int x = 0; x < numbers.length; x++) {
      double randomX = random.nextDouble();
      // double randomX = random.nextDouble() * 7.0;
      if (x % 2 == 0) {
        randomX = -randomX;
      }
      double randomY = random.nextDouble() * -7.0;

      Particle p = Particle();
      // TEXT enum 값 생성, default -> CIRCLE
      p.type = ParticleType.TEXT;
      p.text = numbers[x];
      p.radius = 25;
      p.color = color;
      p.position = PVector(boxSize.center.dx, boxSize.center.dy);
      p.velocity = PVector(randomX * 4.0, randomY);
      // List<Particle> particles = [];
      particles.add(p);
    }
  }

  // 지뢰찾기 게임의 바운더리 제한 메소드와 유사함, 같음
  boxCollision(Particle pt) {
    // 박스의 오른쪽 벽 충돌후 반응
    if (pt.position.x > boxSize.width - pt.radius) {
      pt.velocity.x *= pt.jumpFactor;
      pt.position.x = boxSize.width - pt.radius;
    }
    // 박스의 바닥 벽 충돌후 반응
    if (pt.position.y > boxSize.height - pt.radius) {
      pt.velocity.y *= pt.jumpFactor;
      pt.position.y = boxSize.height - pt.radius;
    }
    // 박스의 왼쪽 벽 충돌후 반응
    if (pt.position.x < pt.radius) {
      pt.velocity.x *= pt.jumpFactor;
      pt.position.x = pt.radius;
    }
  }

  // rotateWheel 메서드
  // rotateWheel 메서드 속에 burstParticles 추가
  // getTarot, getLotto 등 메서드 추가 Future.delayed 사용

  @override
  void dispose() {
    timer.cancel();
    _animationController.removeListener(_animationListener);
    _animationController.dispose();
    // particles = [];
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bubble Burst"),
        backgroundColor: counterText['color'],
        centerTitle: true,
      ),
      body: Container(
        key: _boxKey,
        color: Colors.deepPurple,
        child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: Stack(
            children: [
              Center(
                // 맨 위 스텍에 텍스트와 컬러 값 에니메이션
                child: Text(
                  "${counterText['count']}",
                  textScaleFactor: _animation.value,
                  style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: counterText['color']),
                ),
              ),
              // 파티클 (구슬) 생성
              ...particles.map((pt) {
                if (pt.type == ParticleType.TEXT) {
                  return Positioned(
                      top: pt.position.y,
                      left: pt.position.x,
                      child: Text(
                        pt.text,
                        style: TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: pt.color),
                      ));
                } else {
                  return Positioned(
                      top: pt.position.y,
                      left: pt.position.x,
                      child: Container(
                        width: pt.radius * 2,
                        height: pt.radius * 2,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: pt.color),
                      ));
                }
              }).toList(),

              // 필요한 Positioned 위젯 추가
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
         for (int i = 0; i < 6; i++) {
            burstParticles();
          }
        },
        backgroundColor: counterText['color'],
        child: const Icon(Icons.add),
      ),
    );
  }
}
