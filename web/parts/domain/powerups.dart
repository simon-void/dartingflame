part of dartingflame;

abstract class PowerUp
extends RepaintableTileBasedGameObject
{
  static const String OUTER_RING_COLOR = "#000";
  static const String BOMB_COLOR = "#333396";
  static const String MULTIBOMB_COLOR = "#339633";
  final Level _level;
  
  PowerUp(UnitPosToPixelConverter pixelConv, this._level, int tileX, int tileY, CanvasImageSource template)
  :super(pixelConv, tileX, tileY, template);
  
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
  RangeUpgrade(UnitPosToPixelConverter pixelConv, Level level, int tileX, int tileY, ResourceLoader resourceLoader)
    :super(pixelConv, level, tileX, tileY, resourceLoader.rangeUpgradeTemplate);
  
  @override
  void upgradeRobot(Robot robot)
  {
    robot.increaseExplosionRadius();
  }
}

class BombUpgrade
extends PowerUp
{
  BombUpgrade(UnitPosToPixelConverter pixelConv, Level level, int tileX, int tileY, ResourceLoader resourceLoader)
  :super(pixelConv, level, tileX, tileY, resourceLoader.bombUpgradeTemplate);
  
  @override
  void upgradeRobot(Robot robot)
  {
    robot.addAvailableBomb();
  }
}

class MultibombUpgrade
extends PowerUp
{  
  MultibombUpgrade(UnitPosToPixelConverter pixelConv, Level level, int tileX, int tileY, ResourceLoader resourceLoader)
  :super(pixelConv, level, tileX, tileY, resourceLoader.multibombUpgradeTemplate);
  
  @override
  void upgradeRobot(Robot robot)
  {
    robot.activateMultibomb();
  }
}