part of dartingflame;

class Level
{
  final LevelModel _model;
  LevelUI _ui;
  UnitToPixelPosConverter _pixelConv;
  
  Level(
    int unitPixelSize, int unitWidth, int unitHeight, int border,
    GameCanvas gameCanvas
  ):
    _model = new LevelModel(unitPixelSize, unitWidth, unitHeight, border)
  {
    _ui    = new LevelUI(_model, gameCanvas);
    _pixelConv = (double unitV)=>(unitV*unitPixelSize).round()+border;
        
    init();
  }
    
  void init()
  {
    bool isAllowed(int x, int y) {
      return x.isEven||y.isEven;
    }
    //remove all present objects
    _model.clear();
    
    //and add new crates
    final int middleWidthIndex = _model._unitWidth~/2;
    for(int tileX=1;tileX<_model._unitWidth-1;tileX++) {
      for(int tileY=1;tileY<_model._unitHeight-1;tileY++) {
        if(tileX!=middleWidthIndex && isAllowed(tileX, tileY)) {
          createCrateAt(tileX, tileY);
        }
      }
    }
    for(int tileX=3;tileX<_model._unitWidth-3;tileX++) {
//      createCrateAt(tileX, 0);
      createCrateAt(tileX, _model._unitHeight-1);
    }
    for(int tileY=2;tileY<_model._unitHeight-2;tileY++) {
      createCrateAt(0, tileY);
      createCrateAt(_model._unitWidth-1, tileY);
    }
    
  }
  
  Robot createRobotAt(int tileX, int tileY)
  {
    Robot robot = new Robot(_pixelConv, this, tileX, tileY);
    _model.addRobot(robot);
    return robot;
  }
  
  Explosion createExplosionAt(int tileX, int tileY, int explosionRadius)
  {
    Explosion explosion = new Explosion(_pixelConv, this, tileX, tileY, explosionRadius);
    _model.addExplosion(explosion);
    return explosion;
  }
  
  Crate createCrateAt(int tileX, int tileY)
  {
    Crate crate = new Crate(_pixelConv, tileX, tileY);
    _model.addCrate(crate);
    return crate;
  }
  
  bool createBombIfPossible(int tileX, int tileY, Robot parent)
  {
    if(!_model.containsBomb(tileX, tileY)) {
      Bomb bomb = new Bomb(_pixelConv, this, tileX, tileY, parent);
      _model.addBomb(bomb);
      return true;
    }
    return false;
  }
  
  void remove(GameObject go)
  {
    if(go is Explosion) {
      _model.removeExplosion(go);
    }
    else if(go is Bomb) {
      _model.removeBomb(go);
    }
    else if(go is Crate) {
      _model.removeCrate(go);
    }
    else if(go is Robot) {
      _model.removeRobot(go);
    }
  }

  bool isFree(int tileX, int tileY)
  {
    //if the game is outside of the level return false
    if(_model.isIndestructable(tileX, tileY)) {
      return false;
    }
    
    //if there is any crate on that position return false
    if(_model.containsCreate(tileX, tileY)) {
       return false; 
    }
    
    //if there is any crate on that position return false
    if(_model.containsBomb(tileX, tileY)) {
       return false; 
    }
  
    //the tile is free
    return true;
  }
  
  BlastRange getBlastRange(int tileX, int tileY, Direction blastDirection, int maxBlastRange)
  {
    UnmovableObject getBombOrCrateOrNull(int tileX, int tileY) {
      Crate crate = _model.getCreate(tileX, tileY);
      //if crate is not null return it
      if(crate!=null) return crate;
      Bomb bomb = _model.getBomb(tileX, tileY);
      //return bomb or null
      return bomb;
    }
    
    int range = 0;
    UnmovableObject terminator = null;
    
    for(int i=0;i<maxBlastRange;i++) {
      if(blastDirection==Direction.UP) {
        tileY--;
      }else if(blastDirection==Direction.DOWN) {
        tileY++;
      }else if(blastDirection==Direction.LEFT){
        tileX--;
      }else if(blastDirection==Direction.RIGHT){
        tileX++;
      }
      if(_model.isIndestructable(tileX, tileY)) {
        break;
      }
      range++;
      terminator = getBombOrCrateOrNull(tileX, tileY);
      if(terminator!=null) {
        break;
      }
    }
    
    return new BlastRange(terminator, range);
  }
  
}

class LevelModel
{
  final List<Bomb>  _bombs;
  final List<Crate> _crates;
  final List<Robot> _robots;
  final List<Explosion> _explosions;
  final int _border;
  final int _unitPixelSize;
  final int _unitWidth;
  final int _unitHeight;
    
  LevelModel(int unitPixelSize, int unitWidth, int unitHeight, int border):
    _bombs         = new List<Bomb>(),
    _crates        = new List<Crate>(),
    _robots        = new List<Robot>(),
    _explosions    = new List<Explosion>(),
    _border        = border,
    _unitPixelSize = unitPixelSize,
    _unitHeight    = unitHeight,
    _unitWidth     = unitWidth;
  
  void addBomb(Bomb bomb)
  {
    _bombs.add(bomb);
  }
  
  void addCrate(Crate crate)
  {
    _crates.add(crate);
  }
  
  void addExplosion(Explosion explosion)
  {
    _explosions.add(explosion);
  }
  
  void addRobot(Robot robot)
  {
    _robots.add(robot);
  }
  
  void removeBomb(Bomb bomb)
  {
    _bombs.remove(bomb);
  }
  
  void removeExplosion(Explosion explosion)
  {
    _explosions.remove(explosion);
  }
  
  void removeCrate(Crate crate)
  {
    _crates.remove(crate);
  }
  
  void removeRobot(Robot robot)
  {
    _robots.remove(robot);
  }
  
  void clear()
  {
    _bombs.clear();
    _crates.clear();
    _explosions.clear();
    _robots.clear();
  }

  bool isIndestructable(int tileX, int tileY)
  {   
    //if the game is outside of the level return false
    bool notInRange(int x, int maxX)=> 0>x || x>=maxX;
    if(notInRange(tileX, _unitWidth) || notInRange(tileY, _unitHeight)) {
      return true;
    }
    
    //if the tile denotes the position of an (indestructable) rock return false
    if(tileX.isOdd&&tileY.isOdd) {
      return true;
    }
    
    return false;
  }
  
  bool containsBomb(int tileX, int tileY)
  {
    return _bombs.any(
        (Bomb bomb) {return bomb.isOnTile(tileX, tileY);}
    );
  }
  
  bool containsCreate(int tileX, int tileY)
  {
    return  _crates.any(
        (Crate crate) {return crate.isOnTile(tileX, tileY);}
    );
  }
  
  Bomb getBomb(int tileX, int tileY)
  {
    return _bombs.firstWhere(
        (Bomb bomb) {return bomb.isOnTile(tileX, tileY);},
        orElse: ()=>null
    );
  }
    
  Crate getCreate(int tileX, int tileY)
  {
    return _crates.firstWhere(
        (Crate crate) {return crate.isOnTile(tileX, tileY);},
        orElse: ()=>null
    );
  }
}

class LevelUI
{
  final LevelModel _model;
  final int _totalWidth;
  final int _totalHeight;
  
  LevelUI(LevelModel model, GameCanvas gameCanvas):
    _model       = model,
    _totalWidth  = 2*model._border+model._unitWidth*model._unitPixelSize,
    _totalHeight = 2*model._border+model._unitHeight*model._unitPixelSize
  {
    gameCanvas.setProxyPaint(repaint, _totalWidth, _totalHeight);
  }
  
  void repaint(CanvasRenderingContext2D context2D)
  {
    paintBackground(context2D);
    paintObjects(context2D);
  }
  
  void paintBackground(CanvasRenderingContext2D context2D)
  {       
    const String black = "#000";
    const String white = "#fff";
    
    context2D..fillStyle= black
             ..fillRect(0, 0, _totalWidth, _totalHeight);
    
    final int borderTimesTwo = 2*_model._border;          
    context2D..fillStyle= white
             ..fillRect(_model._border, _model._border, _totalWidth-borderTimesTwo, _totalHeight-borderTimesTwo);
    
    //paint all the undestructable boxes
    int getOffset(int unitValue)=>_model._border + ((unitValue-1)*_model._unitPixelSize);
    for(int unitX=2;unitX<=_model._unitWidth;unitX+=2) {
      for(int unitY=2;unitY<=_model._unitHeight;unitY+=2) {
        int offsetX = getOffset(unitX);
        int offsetY = getOffset(unitY);
        
        context2D..fillStyle= black
                 ..fillRect(offsetX, offsetY, _model._unitPixelSize, _model._unitPixelSize);
      }
    }
  }
  
  void paintObjects(CanvasRenderingContext2D context2D)
  {
    int getOffset(double unitValue)=>_model._border + ((unitValue-1)*_model._unitPixelSize).round();
    //clear the old position
    paintBackground(context2D);
    //repaint the game Objects
    List<GameObject> allGameObjects = new List<GameObject>();
    allGameObjects.addAll(_model._crates);
    allGameObjects.addAll(_model._explosions);
    allGameObjects.addAll(_model._bombs);
    allGameObjects.addAll(_model._robots);
    allGameObjects.forEach(
      (GameObject foregroundObject) {
        foregroundObject.updatePosition();
        foregroundObject.getUI().repaint(context2D, _model._unitPixelSize);
      }
    );
  }
}