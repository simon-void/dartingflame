part of dartingflame;

/**
 * @return true if animation should continue, false otherwise
 */
typedef bool Animatable();

class AnimationTimer
{
  Animatable _anim;
  
  void start(Animatable anim)
  {
    _anim = anim;
    
    _scheduleAnimation();
  }
  
  void _scheduleAnimation()
  {
    window.animationFrame.then(_animate);
  }
  
  void _animate(num sincePageLoadMillies)
  {    
    bool continueAnimation = _anim();
    if(continueAnimation) {
      _scheduleAnimation();
    }
  }
}

///returns the time in millies
typedef double Clock();

double nowInMillies() => window.performance.now();

/**
 * a paint-function that draws on a 2D-context
 */
typedef void Paint(CanvasRenderingContext2D context2D);

class GameCanvas
{
  final HtmlElement _parent;
  final CanvasElement _canvas;
  final AnimationTimer _animationTimer;
  Paint _proxyPaint;
  bool _animate;
  int _width;
  int _height;
  
  set animate(bool doRepaint) {
    //if we should animate and were not animating before
    if(doRepaint && !_animate) {
      //start the animation
      _animate = true;
      _animationTimer.start(this.paint);
    //if we shouldn't repaint (anymore)
    }else if(!doRepaint) {
      //stop repainting
      _animate = false;
    }
  }
  
  void setProxyPaint(Paint proxyPaint, int width, int height)
  {
    //set the new size on everything
    _width = width;
    _height = height;
    _canvas..width  = width
           ..height = height;
    _parent.style..width="${width}px"
                 ..height="${height}px";    

    //and the paint-function
    _proxyPaint = proxyPaint;
    //if we're now animating, call the new paint-function at least once
    if(!_animate) {
      proxyPaint(_canvas.context2D);
    }
  }
    
  GameCanvas(this._parent):
    _canvas = new CanvasElement(width: 1, height: 1),
    _animationTimer = new AnimationTimer(),
    _animate = false
  {
    _parent.children.add(_canvas);
  }
  
  void showMessage(String msg, String buttonTxt, VoidCallback callback)
  {

    DivElement dialogDiv = new DivElement()
          ..id = "startPopup"
          ..style.visibility = "hidden"; //hide first so perfect centered positioning can be computed
    
    DivElement textDiv = new DivElement()
          ..id = "popupText"
          ..text = msg;
    
    ButtonElement button = new ButtonElement()
          ..id = "popupButton"
          ..text = buttonTxt
          ..onClick.first.then(
               (MouseEvent e){
                 _parent.children.remove(dialogDiv);
                 callback();
               }
    );
    
    dialogDiv.children.add(textDiv);
    dialogDiv.children.add(button);
    
    
    _parent.children.add(dialogDiv);
    
    //after the dialogDiv was added to the DOM i can get it's dimensions
    CssRect dialogDimension = dialogDiv.borderEdge;
    Point<int> leftUpperCorner = new Point<int>((_width-dialogDimension.width)~/2,(_height-dialogDimension.height)~/2);
    dialogDiv.style..left = "${leftUpperCorner.x}px"
                   ..top  = "${leftUpperCorner.y}px"
                   ..visibility = "visible";
    
    button.focus();
  }
  
  bool paint()
  {
    if(_proxyPaint!=null) {
      _proxyPaint(_canvas.context2D);
    }
    
    return _animate;
  }
}