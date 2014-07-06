part of dartingflame;

abstract class PowerUp
extends UnmovableObject
{
  final Level _level;
  
  PowerUp(UnitToPixelPosConverter pixelConv, this._level, int tileX, int tileY)
  :super(pixelConv, tileX, tileY);
  
  void getCollectedByRobot(Robot robot)
  {
    upgradeRobot(robot);
    _level.remove(this);
  }
  
  void upgradeRobot(Robot robot);
}

class RangeUpgrade
extends PowerUp
{
  RangeUpgrade(UnitToPixelPosConverter pixelConv, Level level, int tileX, int tileY)
    :super(pixelConv, level, tileX, tileY);
  
  @override
  void upgradeRobot(Robot robot)
  {
    robot.increaseExplosionRadius();
  }
  
  @override
  void repaint(CanvasRenderingContext2D context2D, int unitPixelSize)
  {
    const String color = "#d3862b";
    const String outerRingColor = "#000";
    
    int radius = unitPixelSize~/2;
    
    int arcMiddleX = _offsetX+radius;
    int arcMiddleY = _offsetY+radius;
    
    context2D..fillStyle = color
             ..beginPath()
             ..arc(arcMiddleX, arcMiddleY, radius, 0, 6.2)
             ..fill();
    context2D..strokeStyle = outerRingColor
             ..beginPath()
             ..arc(arcMiddleX, arcMiddleY, radius, 0, 6.2)
             ..stroke();
  }
}

class BombUpgrade
extends PowerUp
{
  BombUpgrade(UnitToPixelPosConverter pixelConv, Level level, int tileX, int tileY)
    :super(pixelConv, level, tileX, tileY);
  
  @override
  void upgradeRobot(Robot robot)
  {
    robot.addAvalableBomb();
  }
  
  @override
  void repaint(CanvasRenderingContext2D context2D, int unitPixelSize)
  {
    const String color = "#333396";
    const String outerRingColor = "#000";
    
    int radius = unitPixelSize~/2;
    
    int arcMiddleX = _offsetX+radius;
    int arcMiddleY = _offsetY+radius;
    
    context2D..fillStyle = color
             ..beginPath()
             ..arc(arcMiddleX, arcMiddleY, radius, 0, 6.2)
             ..fill();
    context2D..strokeStyle = outerRingColor
             ..beginPath()
             ..arc(arcMiddleX, arcMiddleY, radius, 0, 6.2)
             ..stroke();
  }
}