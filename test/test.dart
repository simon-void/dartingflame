library dartingflame_test;

import 'dart:math';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart';
import 'package:mockito/mockito.dart';
import '../web/dartingflame.dart';

void main() {
  useHtmlConfiguration();
  
  test("verify robot's location after move",  verifyRobotLocationAfterMove);
  test("verify robot's direction after move", verifyRobotDirectionAfterMove);
}

void verifyRobotLocationAfterMove() {
  var robot = createRobot(Corner.UPPER_LEFT, 5, 3);
  
  activateRobot(robot, [ControlerButton.RIGHT]);
  waitUntillRobotStops(robot);
  
  var occupiedTiles = robot.getOccupiedTiles();
  expect(robot.model.currentMovement, Movement.NONE, reason: "robot shouldn't move now");
  expect(new Point<double>(1.0,.0), robot.model.currentLocation,  reason: 'robot should be on this tile');
  expect(Direction.RIGHT, robot.model.currentDirection, reason: 'robot should be facing right');
}
      
void verifyRobotDirectionAfterMove() {
  var robot = createRobot(Corner.UPPER_LEFT, 5, 3);
  
  activateRobot(robot, [ControlerButton.RIGHT, ControlerButton.DOWN]);
  waitUntillRobotStops(robot);
  
  var occupiedTiles = robot.getOccupiedTiles();
  expect(robot.model.currentMovement, Movement.NONE, reason: "robot shouldn't move now");
  expect(new Point<double>(1.0,.0), robot.model.currentLocation,  reason: 'robot should be on this tile');
  expect(Direction.DOWN, robot.model.currentDirection, reason: 'robot should be facing down');
}

void activateRobot(Robot robot, List<ControlerButton> buttonsPressed) {
  buttonsPressed.forEach((button){
    robot.onButtonDown(button);
    robot.onButtonUp(button);
  });
}

void waitUntillRobotStops(Robot robot) {
  int iteractionCount = 0;
  final int maxIterationCount = 1000;
  
  while(robot.model.currentMovement!=Movement.NONE) {
    //this call also increments the location
    robot.model.currentLocation;
    
    assert( (++iteractionCount)<=maxIterationCount);
  }while(true);
}

Robot createRobot(Corner initialCorner, int levelWidth, int levelHeight) {
  var pixelConv = null;
  var config = createTestConfig(initialCorner);
  var level = createCratelessLevel(levelWidth,  levelHeight);
  var initialPos = initialCorner.getTile(levelWidth,  levelHeight);
  var resourceLoader = new MockResourceLoader();
  var clock = createFastClock();
    
  var robot = new Robot(
      pixelConv,
      config,
      level,
      initialPos.x, initialPos.y,
      resourceLoader,
      clock);
  
  return robot;
}

PlayerConfiguration createTestConfig(Corner initialCorner) {
  var controler = null;
  var config = new PlayerConfiguration(
      'testRobot',
      PlayerConfiguration.defaultPlayerColors[0],
      initialCorner,
      controler);
  
  return config;
}

Level createCratelessLevel(int levelWidth, int levelHeight) {
  
  var level = new MockLevel();
  //is free on any level with only undestructable block
  when(level.isFree(argThat(any), argThat(any))).thenAnswer(
      (Invocation invoc) {
        int tileX = invoc.positionalArguments[0];
        int tileY = invoc.positionalArguments[1];
        return tileX.isEven || tileY.isEven;
      }
  );
  
  return level;
}

Clock createFastClock() {
  double startMillies = .0;
  double getFakeTime() {
    return startMillies+=100.0;
  }
  
  return getFakeTime;
}

class MockLevel extends Mock implements Level{}
class MockResourceLoader extends Mock implements ResourceLoader{}