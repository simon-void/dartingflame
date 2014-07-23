part of dartingflame;

class GameLoop
{
  final List<Controler> _controlers;
  final GameCanvas _gameCanvas;
  Level _level;
  Configuration _config;
  
  GameLoop(HtmlElement appDiv, BaseConfiguration baseConfig, ResourceLoader resourceLoader):
    _gameCanvas = new GameCanvas(appDiv),
    _controlers = new List<Controler>()
  {
    //guaranteing this helps in painting
    assert(baseConfig.tilePixelSize.isEven);
    
    _level = new Level(baseConfig, this, resourceLoader);    
    _controlers.add(new Controler.wasdSpace(window.onKeyUp, window.onKeyDown));
    _controlers.add(new Controler.arrowsEnter(window.onKeyUp, window.onKeyDown));
    _config = getTwoPlayerConfig();
    
    //start the game as soon as the player clicks on 'start'
    _level.initRound(_config);
    _gameCanvas.paint();
    _gameCanvas.showMessage("let's play!", "start", startRound);
  }
  
  void startRound()
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
    new Timer(
      new Duration(microseconds: 800),
      ()=>_gameCanvas.showMessage(roundResultMsg, "restart", initNewRound)
    );
  }
  
  void initNewRound()
  {
    _level.initRound(_config);
    startRound();
  }
  
  Configuration getTwoPlayerConfig()
  {    
    return new Configuration(
        playerConfigs:
          [new PlayerConfiguration("player1", Corner.UPPER_LEFT,  _controlers[0]),
           new PlayerConfiguration("player2", Corner.LOWER_RIGHT, _controlers[1])],
        levelConfig: new LevelModConfiguration(
          numberOfBombUpgrades:  4,
          numberOfRangeUpgrades: 6,
          numberOfMissingCrates: 2)
     );
  }
}