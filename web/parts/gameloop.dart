part of dartingflame;

class GameLoop
{
  final GameCanvas _gameCanvas;
  Level _level;
  Configuration _config;
  
  GameLoop(HtmlElement appDiv, BaseConfiguration baseConfig, ResourceLoader resourceLoader):
    _gameCanvas = new GameCanvas(appDiv)
  {
    //guaranteing this helps in painting
    assert(baseConfig.tilePixelSize.isEven);
    
    _level = new Level(baseConfig, this, resourceLoader);
    _config = _getTwoPlayerConfig();
    
    //start the game as soon as the player clicks on 'start'
    _level.initRound(_config);
    _gameCanvas.paint();
    _gameCanvas.showMessage("let's play!", "start", _startRound);
  }
  
  void _startRound()
  {
    _gameCanvas.animate = true;
    _level.startRound();
  }
  
  /**
   * winningPlayerName can be null if nobody won -> draw
   */
  void endRound(String winningPlayerName)
  {
    _gameCanvas.animate = false;
    
    //start a new round after a short while
    String roundResultMsg = winningPlayerName!=null ? "$winningPlayerName wins" : "draw";
    _gameCanvas.showMessage(roundResultMsg, "restart", _initNewRound);
  }
  
  void _initNewRound()
  {
    _level.initRound(_config);
    _startRound();
  }
  
  Configuration _getTwoPlayerConfig()
  {
    var playerColors = PlayerConfiguration.defaultPlayerColors;

    var controlers = [new Controler.wasdSpace(window.onKeyUp, window.onKeyDown),
                      new Controler.arrowsEnter(window.onKeyUp, window.onKeyDown)];
    
    return new Configuration(
        playerConfigs:
          [new PlayerConfiguration("player1", playerColors[0], Corner.UPPER_LEFT,  controlers[0]),
           new PlayerConfiguration("player2", playerColors[1], Corner.LOWER_RIGHT, controlers[1])],
        levelConfig: new LevelModConfiguration(
          numberOfBombUpgrades:      6,
          numberOfMultiBombUpgrades: 2,
          numberOfRangeUpgrades:     4,
          numberOfMissingCrates:     2)
     );
  }
}