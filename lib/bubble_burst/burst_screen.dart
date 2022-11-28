import 'package:flutter/material.dart';

import 'components/particles_widget.dart';

class BurstScreen extends StatefulWidget {
  const BurstScreen({Key? key}) : super(key: key);

  @override
  State<BurstScreen> createState() => _BurstScreenState();
}

class _BurstScreenState extends State<BurstScreen> {
  final _particlesWidgetController = ParticlesWidgetController();

  final GlobalKey _boxKey = GlobalKey();

  // particle과 함께 burst되는 숫자와 색 초기값
  Map<String, dynamic> counterText = {
    "count": 1,
    "color": const Color(0xffffc100)
  };

  // initState 내용
  // 1. AnimationController for initial Burst Animation of Text
  // 2. _boxKey로 boxSize 가져오기
  // 3. 24/fps로 리프레쉬 하기

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

  // 작동 버튼 클릭하면 이전 파티클 제거 후 파티클 폭발 메소드 순서
  // 1. 동작 버튼 클릭 시 오래된 파티클 제거하기
  // 2. _animationController 메소드
  // 3. circle 변수 color & text : random 값을 X,Y position 계산
  // 4. circle Particle() 객체 p 인스턴스에 전달 후 particles.add(p);
  // 5. text 리스트 numbers 계산 -> Particle() 인스턴스 p에 입력 -> particles.add(p);

  // rotateWheel 메서드
  // rotateWheel 메서드 속에 burstParticles 추가
  // getTarot, getLotto 등 메서드 추가 Future.delayed 사용

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
                  textScaleFactor: 1.0,
                  style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: counterText['color']),
                ),
              ),

              ParticlesWidget(
                controller: _particlesWidgetController,
                size: size,
              ),
              // 필요한 Positioned 위젯 추가
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _particlesWidgetController.startAnimation();
        },
        backgroundColor: counterText['color'],
        child: const Icon(Icons.add),
      ),
    );
  }
}
