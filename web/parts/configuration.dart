part of dartingflame;

class BaseConfiguration
{
  final int tilePixelSize;
  final int widthTiles;
  final int heightTiles;
  final int border;
  //computed properties
  final int numberOfTiles;
  final int totalPixelWidth;
  final int totalPixelHeight;
  UnitToPixelPosConverter pixelConv;
  
  BaseConfiguration({int tilePixelSize, int widthTiles, int heightTiles, int border}):
    this.tilePixelSize = tilePixelSize,
    this.border = border,
    this.widthTiles = widthTiles,
    this.heightTiles = heightTiles,
    this.numberOfTiles = widthTiles*heightTiles,
    this.totalPixelWidth  = 2*border+widthTiles*tilePixelSize,
    this.totalPixelHeight = 2*border+heightTiles*tilePixelSize
  {
    pixelConv = (double unitV)=>(unitV*tilePixelSize).round()+border;
  }
  
  int getPixelOffset(int tileIndex)=>border + ((tileIndex-1)*tilePixelSize);
}

class Configuration
{
  final UnmodifiableListView<PlayerConfiguration> playerConfigs;
  final LevelModConfiguration levelConfig;
  
  Configuration(
      {List<PlayerConfiguration> playerConfigs,
      this.levelConfig}
  ):
    this.playerConfigs = new UnmodifiableListView(playerConfigs);
}

class PlayerConfiguration
{
  final String playerName;
  final Corner startCorner;
  final Controler controler;
  final int initialBombs;
  final int initialRange;
  
  PlayerConfiguration(
      this.playerName, this.startCorner, this.controler,
      {int initialBombs:2, int initialRange:2}
  ):
    this.initialBombs = initialBombs,
    this.initialRange = initialRange;
}

class LevelModConfiguration
{
  final int numberOfMissingCrates;
  final int numberOfRangeUpgrades;
  final int numberOfBombUpgrades;
  
  LevelModConfiguration(
      {this.numberOfBombUpgrades, this.numberOfRangeUpgrades, this.numberOfMissingCrates}
  );
}