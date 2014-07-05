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
  final List<ControlerButton> _pressedDirectionButtons;
  ControlerListener _controlerListener;
  
  bool get isDeactivated=>_controlerListener==null;
  
  set controlerListener(ControlerListener cl) {
    _controlerListener = cl;
    _pressedDirectionButtons.clear();
  }
  
  Controler.wasdSpace(Stream<KeyboardEvent> onKeyUp, Stream<KeyboardEvent> onKeyDown):
    this(87, 83, 65, 68, 32, onKeyUp, onKeyDown);
  
  Controler.arrowsEnter(Stream<KeyboardEvent> onKeyUp, Stream<KeyboardEvent> onKeyDown):
      this(38, 40, 37, 39, 13, onKeyUp, onKeyDown);
  
  Controler(int upKeyCode, int downKeyCode, int leftKeyCode, int rightKeyCode, int aKeyCode,
            Stream<KeyboardEvent> onKeyUp, Stream<KeyboardEvent> onKeyDown):
              _mapping = {
                upKeyCode    : ControlerButton.UP,
                downKeyCode  : ControlerButton.DOWN,
                leftKeyCode  : ControlerButton.LEFT,
                rightKeyCode : ControlerButton.RIGHT,
                aKeyCode     : ControlerButton.A
              },
              _pressedDirectionButtons = new List<ControlerButton>()
  {    
    onKeyDown.listen(
        (KeyboardEvent e) {
          if(isDeactivated) {
            return;
          }
          
          var button = _mapping[e.keyCode];
          if(button!=null) {
            if(button.isDirectionButton && !_pressedDirectionButtons.contains(button)) {
              switch(_pressedDirectionButtons.length) {
              case 0:
                //direction-button presses only get transmitted if only one direction is pressed
                onButtonDown(button);
                break;
              case 1:
                //deactivate the the former pressed button
                onButtonUp(_pressedDirectionButtons.first);
                break;
              }
              _pressedDirectionButtons.add(button);
            }else{
              //non-direction Button always get transmitted
              onButtonDown(button);
            }
          }
        }
    );
    
    onKeyUp.listen(
        (KeyboardEvent e) {
          if(isDeactivated) {
            return;
          }
          
          var button = _mapping[e.keyCode];
          if(button!=null) {
            if(button.isDirectionButton) {
              _pressedDirectionButtons.remove(button);
              switch(_pressedDirectionButtons.length) {
                case 0:
                  //deactivate this active direction button
                  onButtonUp(button);
                  break;
                case 1:
                  //activate the last pressed direction button
                  onButtonDown(_pressedDirectionButtons.first);
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