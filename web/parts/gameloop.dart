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
    //guaranteing this helps in painting
    assert(unitPixelSize.isEven);
    
    _level = new Level(unitPixelSize, unitWidth, unitHeight, border, this);    
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
        numberOfBombUpgrades:  4,
        numberOfRangeUpgrades: 6,
        numberOfMissingCrates: 2
     );
  }
}

class Configuration
{
  final int numberOfMissingCrates;
  final int numberOfRangeUpgrades;
  final int numberOfBombUpgrades;
  final UnmodifiableListView<PlayerConfiguration> playerConfigs;
  
  Configuration(
      {List<PlayerConfiguration> playerConfigs,
      this.numberOfBombUpgrades, this.numberOfRangeUpgrades, this.numberOfMissingCrates}
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