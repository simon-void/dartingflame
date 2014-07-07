part of dartingflame;

class Level
{
  final GameLoop _gameLoop;
  final LevelModel _model;
  LevelUI _ui;
  UnitToPixelPosConverter _pixelConv;
  
  Level(int unitPixelSize, int unitWidth, int unitHeight, int border, this._gameLoop):
    _model = new LevelModel(unitPixelSize, unitWidth, unitHeight, border)
  {
    _ui    = new LevelUI(_model, _gameLoop._gameCanvas);
    _pixelConv = (double unitV)=>(unitV*unitPixelSize).round()+border;
  }
    
  void init(Configuration config,{bool connectRobotsWithControler:true})
  {
    bool isCrateAllowed(int x, int y) {
      return x.isEven||y.isEven;
    }
    //remove all present objects
    _model.clear();
    
    List<Crate> cratesCreated = new List<Crate>();
    
    //and add new crates
    final int middleWidthIndex = _model._unitWidth~/2;
    for(int tileX=1;tileX<_model._unitWidth-1;tileX++) {
      for(int tileY=1;tileY<_model._unitHeight-1;tileY++) {
        if(tileX!=middleWidthIndex && isCrateAllowed(tileX, tileY)) {
          cratesCreated.add(createCrateAt(tileX, tileY));
        }
      }
    }
    for(int tileX=3;tileX<_model._unitWidth-3;tileX++) {
      cratesCreated.add(createCrateAt(tileX, 0));
      cratesCreated.add(createCrateAt(tileX, _model._unitHeight-1));
    }
    for(int tileY=2;tileY<_model._unitHeight-2;tileY++) {
      cratesCreated.add(createCrateAt(0, tileY));
      cratesCreated.add(createCrateAt(_model._unitWidth-1, tileY));
    }
    
    //add powerUps to crates add random points
    Random random = new Random();
    //first bombUpgrades
    for(int i=0;i<config.numberOfBombUpgrades;i++) {
      if(cratesCreated.isEmpty) {
        break;
      }
      Crate crate = cratesCreated.removeAt(random.nextInt(cratesCreated.length));
      crate._powerUp = new BombUpgrade(_pixelConv, this, crate._tileX, crate._tileY);
    }
    //then rangeUpgrades
    for(int i=0;i<config.numberOfBombUpgrades;i++) {
      if(cratesCreated.isEmpty) {
        break;
      }
      Crate crate = cratesCreated.removeAt(random.nextInt(cratesCreated.length));
      crate._powerUp = new RangeUpgrade(_pixelConv, this, crate._tileX, crate._tileY);
    }
    
    // add robots/players
    for(var playerConfig in config.playerConfigs) {
      createRobotAt(playerConfig, connectRobotsWithControler);
    }
  }
  
  void createRobotAt(PlayerConfiguration config, bool connectRobotWithControler)
  {
    Point<int> tile = config.startCorner.getTile(_model._unitWidth, _model._unitHeight);
    Robot robot = new Robot(_pixelConv, config, this, tile.x, tile.y, connectRobotWithControler);
    _model.addRobot(robot);
  }
  
  Explosion createExplosionAt(int tileX, int tileY, int explosionRadius, List<Blast> trigger)
  {
    Explosion explosion = new Explosion(_pixelConv, this, tileX, tileY, explosionRadius, trigger);
    _model.addExplosion(explosion);
    return explosion;
  }
  
  Crate createCrateAt(int tileX, int tileY)
  {
    Crate crate = new Crate(_pixelConv, this, tileX, tileY);
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
  
  void addPowerUp(PowerUp powerUp)
  {
    _model.addPowerUp(powerUp);
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
    else if(go is PowerUp) {
      _model.removePowerUp(go);
    }
    else if(go is Robot) {
      _model.removeRobot(go);
      if(_model.onlyOneRobotLeft) {
        Duration timeTillEndOfRound = new Duration(milliseconds: 300);
        new Timer(timeTillEndOfRound, endRound);
      }
    }
  }
  
  void endRound()
  {
    Robot survivor = _model.survivingPlayer;
    String nameOfSurvivingPlayer = null;
    if(survivor!=null) {
      nameOfSurvivingPlayer = survivor._config.playerName;
      //decomision the last Robot so that it removes itself from the controler
      //turns out we have to wait a little bit so that the survivor doesn't disappear
      //from the canvas (although that one is told to stop repainint immediatly)
      Duration timeTillSurvivorDisconnect = new Duration(milliseconds: 50);
      new Timer(timeTillSurvivorDisconnect, survivor.explode);
    }
    
    _gameLoop.endRound(nameOfSurvivingPlayer);
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
  
  void robotEntersTile(Robot robot, int tileX, int tileY)
  {
    //check if you walk into an explosion
    if(_model.isDeadlyTile(tileX, tileY)) {
      //run asynchronously so that this painting operation can finish fast
      Timer.run(robot.explode);
    }
    
    //check if you walked into a powerup
    if(_model.containsPowerUp(tileX, tileY)) {
      //run asynchronously so that this painting operation can finish fast
      PowerUp powerUp = _model.getPowerUp(tileX, tileY);
      powerUp.getCollectedByRobot(robot);
    }
  }
  
  void addDeadlyTiles(Iterable<Point<int>> deadlyTiles)
  {
    _model.addDeadlyTiles(deadlyTiles);
    
    //check if robots are caugth in the blast
    List<Robot> deadRobots = [];
    for(var robot in _model._robots) {
      for(Point<int> tile in robot.getOccupiedTiles()) {
        if(_model.isDeadlyTile(tile.x, tile.y)) {
          deadRobots.add(robot);
          break;
        }
      }
    }
    //check if powerups are caugth in the blast
    for(Point<int> tile in deadlyTiles) {
      _model.removePowerUpFromTile(tile.x, tile.y);
    }
    //do this extra loop so that robot.explode() doesn't lead to a ConcurrentModificationException
    //while iteration over _model._robots
    for(var robot in deadRobots) {
      robot.explode();
    }
  }
  
  void removeDeadlyTiles(Iterable<Point<int>> deadlyTiles)
  {
    _model.removeDeadlyTiles(deadlyTiles);
  }
  
}

class LevelModel
{
  final Map<int, int> _deadlyTiles;
  final Map<int, Bomb>  _bombs;
  final Map<int, Crate> _crates;
  final Map<int, Explosion> _explosions;
  final Map<int, PowerUp> _powerUps;
  final List<Robot> _robots;
  final int _border;
  final int _unitPixelSize;
  final int _unitWidth;
  final int _unitHeight;
    
  LevelModel(int unitPixelSize, int unitWidth, int unitHeight, int border):
    _deadlyTiles   = new BucketMap<int>.filled(unitWidth*unitHeight, 0),
    _bombs         = new BucketMap<Bomb>(unitWidth*unitHeight),
    _crates        = new BucketMap<Crate>(unitWidth*unitHeight),
    _explosions    = new BucketMap<Explosion>(unitWidth*unitHeight),
    _powerUps      = new BucketMap<PowerUp>(unitWidth*unitHeight),
    _robots        = new List<Robot>(),
    _border        = border,
    _unitPixelSize = unitPixelSize,
    _unitHeight    = unitHeight,
    _unitWidth     = unitWidth;
  
  void addBomb(Bomb bomb)
  {
    int tileIndex = _getTileIndex(bomb._tileX, bomb._tileY);
    _bombs[tileIndex]=bomb;
  }
  
  void addCrate(Crate crate)
  {
    int tileIndex = _getTileIndex(crate._tileX, crate._tileY);
    _crates[tileIndex]=crate;
  }
  
  void addExplosion(Explosion explosion)
  {
    int tileIndex = _getTileIndex(explosion._tileX, explosion._tileY);
    _explosions[tileIndex]=explosion;
  }
  
  void addPowerUp(PowerUp powerUp)
  {
    int tileIndex = _getTileIndex(powerUp._tileX, powerUp._tileY);
    _powerUps[tileIndex]=powerUp;
  }
  
  void addRobot(Robot robot)
  {
    _robots.add(robot);
  }
  
  void removeBomb(Bomb bomb)
  {
    int tileIndex = _getTileIndex(bomb._tileX, bomb._tileY);
    _bombs.remove(tileIndex);
  }
  
  bool get onlyOneRobotLeft => _robots.length==1;
  
  Robot get survivingPlayer {
    assert( _robots.length<2);
    //no survivor
    if(_robots.isEmpty) {
      return null;
    }else{
      return _robots[0];
    }
  }
  
  void removeExplosion(Explosion explosion)
  {
    int tileIndex = _getTileIndex(explosion._tileX, explosion._tileY);
    _explosions.remove(tileIndex);
  }
  
  void removeCrate(Crate crate)
  {
    int tileIndex = _getTileIndex(crate._tileX, crate._tileY);
    _crates.remove(tileIndex);
  }
  
  void removePowerUp(PowerUp powerUp)
  {
    int tileIndex = _getTileIndex(powerUp._tileX, powerUp._tileY);
    _powerUps.remove(tileIndex);
  }
  
  PowerUp removePowerUpFromTile(int tileX, int tileY)
  {
    int tileIndex = _getTileIndex(tileX, tileY);
    return _powerUps.remove(tileIndex);
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
    _powerUps.clear();
    _robots.clear();
    _deadlyTiles.clear();
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
    int tileIndex = _getTileIndex(tileX, tileY);
    return _bombs.containsKey(tileIndex);
  }
  
  bool containsCreate(int tileX, int tileY)
  {
    int tileIndex = _getTileIndex(tileX, tileY);
    return _crates.containsKey(tileIndex);
  }
  
  bool containsPowerUp(int tileX, int tileY)
  {
    int tileIndex = _getTileIndex(tileX, tileY);
    return _powerUps.containsKey(tileIndex);
  }
  
  Bomb getBomb(int tileX, int tileY)
  {
    int tileIndex = _getTileIndex(tileX, tileY);
    return _bombs[tileIndex];
  }
    
  Crate getCreate(int tileX, int tileY)
  {
    int tileIndex = _getTileIndex(tileX, tileY);
    return _crates[tileIndex];
  }
  
  PowerUp getPowerUp(int tileX, int tileY)
  {
    int tileIndex = _getTileIndex(tileX, tileY);
    return _powerUps[tileIndex];
  }
  
  int _getTileIndex(int tileX, int tileY)
  {
    assert( 0<=tileX && tileX<_unitWidth );
    assert( 0<=tileY && tileY<_unitHeight );
    
    return tileX*_unitHeight + tileY;
  }
  
  void addDeadlyTiles(Iterable<Point<int>> deadlyTiles)
  {
    for(var deadlyTile in deadlyTiles) {
      int tileIndex = _getTileIndex(deadlyTile.x, deadlyTile.y);
      _deadlyTiles[tileIndex] = _deadlyTiles[tileIndex]+1;
    }
  }
  
  void removeDeadlyTiles(Iterable<Point<int>> deadlyTiles)
  {
    for(var deadlyTile in deadlyTiles) {
      int tileIndex = _getTileIndex(deadlyTile.x, deadlyTile.y);
      _deadlyTiles[tileIndex] = _deadlyTiles[tileIndex]-1;
    }
  }
  
  bool isDeadlyTile(int tileX, int tileY)
  {
    int tileIndex = _getTileIndex(tileX, tileY);
    int explosionCounter = _deadlyTiles[tileIndex];
    return explosionCounter!=0;
  }
}

class LevelUI
{
  static const String blockColor = "#000";
  static const String floorColor = "#909c90";
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
    paintIndestructable(context2D);
  }
  
  void paintBackground(CanvasRenderingContext2D context2D)
  {
    context2D..fillStyle= floorColor
             ..fillRect(0, 0, _totalWidth, _totalHeight);
  }
  
  void paintObjects(CanvasRenderingContext2D context2D)
  {
    UI getUI(GameObject go)=>go.getUI();
    
    int getOffset(double unitValue)=>_model._border + ((unitValue-1)*_model._unitPixelSize).round();
    //clear the old position
    paintBackground(context2D);
    //repaint the game Objects
    List<Repaintable> allGameObjects = new List<Repaintable>();
    allGameObjects.addAll(_model._powerUps.values);
    allGameObjects.addAll(_model._crates.values);
    allGameObjects.add( new Firework(_model._explosions.values));
    allGameObjects.addAll(_model._bombs.values);
    allGameObjects.addAll(_model._robots.map(getUI));
    allGameObjects.forEach(
      (Repaintable foregroundObject) {
        //foregroundObject.updatePosition();
        foregroundObject.repaint(context2D, _model._unitPixelSize);
      }
    );
  }
  
  void paintIndestructable(CanvasRenderingContext2D context2D)
  {
    //paint border
    int border = _model._border;
    context2D..fillStyle= blockColor
             ..fillRect(0, 0, border, _totalHeight)
             ..fillRect(0, 0, _totalWidth, border)
             ..fillRect(_totalWidth, _totalHeight, -border, -_totalHeight)
             ..fillRect(_totalWidth, _totalHeight, -_totalWidth, -border);
    
    
    //paint all the undestructable boxes
    int getOffset(int unitValue)=>border + ((unitValue-1)*_model._unitPixelSize);
    for(int unitX=2;unitX<=_model._unitWidth;unitX+=2) {
      for(int unitY=2;unitY<=_model._unitHeight;unitY+=2) {
        int offsetX = getOffset(unitX);
        int offsetY = getOffset(unitY);
        
        context2D..fillStyle= blockColor
                 ..fillRect(offsetX, offsetY, _model._unitPixelSize, _model._unitPixelSize);
      }
    }
  }
}