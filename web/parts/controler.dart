part of dartingflame;

class ControlerButton
{
  static final ControlerButton UP = new ControlerButton._(true);
  static final ControlerButton DOWN = new ControlerButton._(true);
  static final ControlerButton LEFT = new ControlerButton._(true);
  static final ControlerButton RIGHT = new ControlerButton._(true);
  static final ControlerButton A = new ControlerButton._(false);
  
  final bool isDirectionButton;
  
  ControlerButton._(this.isDirectionButton);
}

abstract class ControlerListener
{
  void onButtonUp(ControlerButton button);    
  void onButtonDown(ControlerButton button);
}

/**
 * The Controler defines a subset of the keyboard to listen too.
 * It is guaranteed that only one of the direction buttons (up, down, left, right),
 * will appear to be pressed (as seen by buttonDown/Up-events) at any time
 * (pressing a second direction key will chancel the first). 
 */
class Controler
{
  final Map<int, ControlerButton> _mapping;
  ControlerListener _controlerListener;
  
  set controlerListener(ControlerListener cl) => _controlerListener = cl;
  
  Controler.wasdSpace(Stream<KeyboardEvent> onKeyUp, Stream<KeyboardEvent> onKeyDown):
    this(87, 83, 65, 68, 32, onKeyUp, onKeyDown);
  
  Controler(int upKeyCode, int downKeyCode, int leftKeyCode, int rightKeyCode, int aKeyCode,
            Stream<KeyboardEvent> onKeyUp, Stream<KeyboardEvent> onKeyDown):
              _mapping = {
                upKeyCode : ControlerButton.UP,
                downKeyCode : ControlerButton.DOWN,
                leftKeyCode : ControlerButton.LEFT,
                rightKeyCode : ControlerButton.RIGHT,
                aKeyCode : ControlerButton.A
              }
  {
    var pressedDirectionButtons = new List<ControlerButton>();
    
    onKeyDown.listen(
        (KeyboardEvent e) {
          var button = _mapping[e.keyCode];
          if(button!=null) {
            if(button.isDirectionButton && !pressedDirectionButtons.contains(button)) {
              switch(pressedDirectionButtons.length) {
              case 0:
                //direction-button presses only get transmitted if only one direction is pressed
                onButtonDown(button);
                break;
              case 1:
                //deactivate the the former pressed button
                onButtonUp(pressedDirectionButtons.first);
                break;
              }
              pressedDirectionButtons.add(button);
            }else{
              //non-direction Button always get transmitted
              onButtonDown(button);
            }
          }
        }
    );
    
    onKeyUp.listen(
        (KeyboardEvent e) {
          var button = _mapping[e.keyCode];
          if(button!=null) {
            if(button.isDirectionButton) {
              pressedDirectionButtons.remove(button);
              switch(pressedDirectionButtons.length) {
                case 0:
                  //deactivate this active direction button
                  onButtonUp(button);
                  break;
                case 1:
                  //activate the last pressed direction button
                  onButtonDown(pressedDirectionButtons.first);
                  break;
              }
            }
          }
        }
    );
  }
  
  void onButtonUp(ControlerButton button)
  {
    if(_controlerListener!=null) {
      _controlerListener.onButtonUp(button);
    }
  }
  
  void onButtonDown(ControlerButton button)
  {
    if(_controlerListener!=null) {
      _controlerListener.onButtonDown(button);
    }  
  }
}

//class PlayerMovementStatus
//{
//  static const double _unitsPerSecond = 4.5;
//  double _lastTimeInMillies = nowInMillies();
//  Movement _lastDirection = Movement.NONE;
//  Point<double> _lastLoaction;
//  final Environment _environment;
//  final Robot _robot;
//  
//  PlayerMovementStatus(double initialX, double initialY, this._environment, this._robot):
//    _lastLoaction = new Point(initialX, initialY);  
//  
//  Point<double> get currentLocation
//  {
//    double deltaMillies = nowInMillies()-_lastTimeInMillies;
//    double deltaDistance = (_unitsPerSecond * deltaMillies) / 1000;
//    return _moveIfPossible(_lastLoaction, deltaDistance, _lastDirection);
//  }
//  
//  void updateDirection(Movement direction) {
//    _lastLoaction = currentLocation;
//    _lastTimeInMillies = nowInMillies();
//    _lastDirection = direction;
//  }
//  
//  Point<double> _moveIfPossible(Point<double> from, double distance, Movement direction)
//  {
//    /**
//     * returns true if there exist an integer between oldV and newV (and it's neither oldV nor newV)
//     */
//    bool crossesInteger(double oldV, double newV) {
//      return oldV.floor()!=newV.floor() && oldV.ceil()!=newV.ceil();
//    }
//    
//    if(direction==Movement.UP) {
//      double newY = from.y - distance;
//      if(crossesInteger(from.y, newY)) {
//        if(!_environment.enterTileIfPossible(from.x.round(), newY.floor(), _robot)) {
//          newY = from.y.floorToDouble();
//        }
//      }
//      return new Point<double>(from.x, newY);
//    }
//    if(direction==Movement.DOWN) {
//      double newY = from.y + distance;
//      if(crossesInteger(from.y, newY)) {
//        if(!_environment.enterTileIfPossible(from.x.round(), newY.ceil(), _robot)) {
//          newY = from.y.ceilToDouble();
//        }
//      }
//      return new Point<double>(from.x, newY);
//    }
//    if(direction==Movement.LEFT) {
//      double newX = from.x - distance;
//      if(crossesInteger(from.x, newX)) {
//        if(!_environment.enterTileIfPossible(newX.floor(), from.y.round(), _robot)) {
//          newX = from.x.floorToDouble();
//        }
//      }
//      return new Point<double>(newX, from.y);
//    }
//    if(direction==Movement.RIGHT) {
//      double newX = from.x + distance;
//      if(crossesInteger(from.x, newX)) {
//        if(!_environment.enterTileIfPossible(newX.ceil(), from.y.round(), _robot)) {
//          newX = from.x.ceilToDouble();
//        }
//      }
//      return new Point<double>(newX, from.y);
//    }
//    //no movement
//    return from;
//  }
//}