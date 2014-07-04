library dartingflame;

import 'dart:async';
//import 'dart:collection';
import 'dart:html';
import 'dart:math';

part 'parts/animation.dart';
part 'parts/controler.dart';
part 'parts/domain/basics.dart';
part 'parts/domain/bomb.dart';
part 'parts/domain/level.dart';
part 'parts/domain/robot.dart';


void main()
{
  const unitPixelSize    = 20;
  const unitWidth        = 9;
  const unitHeight       = 7;
  const border           = 9;          
  final HtmlElement appDiv = querySelector("#appId");
    
  GameCanvas gameCanvas = new GameCanvas(appDiv);
  Level level           = new Level(unitPixelSize, unitWidth, unitHeight, border, gameCanvas);
  Robot robot1          = level.createRobotAt(0, 0);
  Controler controler   = new Controler.wasdSpace(window.onKeyUp, window.onKeyDown);
  controler.controlerListener = robot1;
  
  gameCanvas.animate = true;
}

