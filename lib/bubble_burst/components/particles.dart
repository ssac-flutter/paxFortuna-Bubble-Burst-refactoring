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
}
