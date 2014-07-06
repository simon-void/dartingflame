part of dartingflame;

class GameLoop
{
  final List<Controler> _controlers;
  final GameCanvas _gameCanvas;
  Level _level;
  Configuration _config;
  
  GameLoop(HtmlElement appDiv, int unitWidth, int unitHeight, int unitPixelSize, int border):
    _gameCanvas = new GameCanvas(appDiv),
    _controlers = new List<Controler>()
  {
    _level = new Level(unitPixelSize, unitWidth, unitHeight, border, this);    
    _controlers.add(new Controler.wasdSpace(window.onKeyUp, window.onKeyDown));
    _controlers.add(new Controler.arrowsEnter(window.onKeyUp, window.onKeyDown));
    _config = getTwoPlayerConfig();
    
    startRound();
  }
  
  void startRound()
  {
    _level.init(_config);
    
    _gameCanvas.animate = true;
  }
  
  /**
   * winningPlayerName can be null if nobody won -> draw
   */
  void endRound(String winningPlayerName)
  {
    _gameCanvas.animate = false;
    
    //start a new round after a short while
    new Timer(
      new Duration(seconds: 3),
      ()=>startRound()
    );
  }
  
  Configuration getTwoPlayerConfig()
  {
    Configuration config = new Configuration();
    config.playerConfigs.add(new PlayerConfiguration("player1", Corner.UPPER_LEFT,  _controlers[0]));
    config.playerConfigs.add(new PlayerConfiguration("player2", Corner.LOWER_RIGHT, _controlers[1]));
    config.numberOfBombUpgrades = 6;
    config.numberOfBombUpgrades = 4;
    
    return config;
  }
}

class Configuration
{
  int numberOfRangeUpgrades = 0;
  int numberOfBombUpgrades  = 0;
  List<PlayerConfiguration> playerConfigs = new List<PlayerConfiguration>();
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