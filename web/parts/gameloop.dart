part of dartingflame;

class GameLoop
{
  final GameCanvas _gameCanvas;
  Level _level;
  
  GameLoop(HtmlElement appDiv, int unitWidth, int unitHeight, int unitPixelSize, int border):
    _gameCanvas = new GameCanvas(appDiv) 
  {
    _level = new Level(unitPixelSize, unitWidth, unitHeight, border, _gameCanvas);
    
    startGame();
  }
  
  void startGame()
  {
    _level.init();
    Robot robot1          = _level.createRobotAt(Corner.UPPER_LEFT);
    Robot robot2          = _level.createRobotAt(Corner.LOWER_RIGHT);
    
    Controler controler1   = new Controler.wasdSpace(window.onKeyUp, window.onKeyDown);
    controler1.controlerListener = robot1;
    Controler controler2   = new Controler.arrowsEnter(window.onKeyUp, window.onKeyDown);
    controler2.controlerListener = robot2;
    
    _gameCanvas.animate = true;
  }
}