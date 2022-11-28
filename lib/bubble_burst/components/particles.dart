import 'dart:math';

import 'package:flutter/material.dart';

// Vector 값은 x,y 값 KEEP하기 위한 것일뿐, 정확한 값은 아님

class PVector {
  double x;
  double y;

  PVector(this.x, this.y);
}

enum ParticleType { TEXT, CIRCLE }

class Particle {
  // 디폴트 enum: 서클 타입
  ParticleType type = ParticleType.CIRCLE;
  String text = "";
  // 디폴트 위치
  PVector position = PVector(0.0, 0.0);
  // 디폴터 속도
  PVector velocity = PVector(0.0, 0.0);
  // mass -> Kg
  double mass = 10.0;
  // 1m = 100 pt or px
  double radius = 10 / 100;
  //PI x R x R;
  double area = 0.0314;
  // 반발계수
  double jumpFactor = -0.6;
  Color color = Colors.green;

  static const List<Color> colors = [
    Color(0xffffc100),
    Color(0xffff9a00),
    Color(0xffff7400),
    Color(0xffff4d00),
    Color(0xffff0000),
  ];

  Particle();

  factory Particle.text(Rect boxSize, String text) {
    final Random random = Random();

    double randomX = random.nextDouble() * 2.0 - 1;   // -1.0 ~ 1.0
    // double randomX = random.nextDouble() * 7.0;
    double randomY = random.nextDouble() * -7.0;

    Particle p = Particle();
    // TEXT enum 값 생성, default -> CIRCLE
    p.type = ParticleType.TEXT;
    p.text = text;
    p.radius = 25;

    double colorRandom = random.nextDouble();
    Color color = colors[(colorRandom * colors.length).floor()];

    p.color = color;
    p.position = PVector(boxSize.center.dx, boxSize.center.dy);
    p.velocity = PVector(randomX * 4.0, randomY);

    return p;
  }

  factory Particle.circle(Rect boxSize) {
    final Random random = Random();
    double randomX = random.nextDouble() * 7.0;
    // X position: 짝수이면 줄여야는데, 사방 터지지 않는 이슈 있음
    // Y position
    double randomY = random.nextDouble() * -7.0;
    // Particle 인스턴스 생성
    Particle p = Particle();
    // p.type = ParticleType.CIRCLE; // circle은 default 값임
    // 파티클 반지름은 최소 2, 최대 10 -> 크기 변경 할 수 있음
    p.radius = (random.nextDouble() * 10.0).clamp(2.0, 10.0);

    double colorRandom = random.nextDouble();
    Color color = colors[(colorRandom * colors.length).floor()];

    p.color = color;
    p.position = PVector(boxSize.center.dx, boxSize.center.dy);
    p.velocity = PVector(randomX, randomY);
    return p;
  }

  // 중력, 당기는 힘, 공기 저항, 초당 프레임 변수 설정
  final double gravity = 9.81;
  final dragCof = 0.47;
  final airDensity = 1.1644;
  final fps = 1 / 24;

  void animate(Rect boxSize) {
    // dragForce : 당기는 힘 계산, 네거티브 값이어야 함
    double dragForceX =
        -0.5 * airDensity * pow(velocity.x, 2) * dragCof * area;
    double dragForceY =
        -0.5 * airDensity * pow(velocity.y, 2) * dragCof * area;

    dragForceX = dragForceX.isInfinite ? 0.0 : dragForceX;
    dragForceY = dragForceY.isInfinite ? 0.0 : dragForceY;

    // 가속도 계산, 당기는 힘에 중량을 나눈 값 x와 중력을 합친 y값
    double accX = dragForceX / mass;
    double accY = gravity + dragForceY / mass;

    // 속력 변화 계산
    velocity.x += accX * fps;
    velocity.y += accY * fps;

    // 위치 변화 계산
    position.x += velocity.x * fps * 100;
    position.y += velocity.y * fps * 100;

    _boxCollision(this, boxSize);
  }

  // 지뢰찾기 게임의 바운더리 제한 메소드와 유사함, 같음
  void _boxCollision(Particle pt, Rect boxSize) {
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
}
