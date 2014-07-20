part of dartingflame;

class Level
{
  final GameLoop _gameLoop;
  final LevelModel _model;
  LevelUI _ui;
  BaseConfiguration _baseConfig;
  
  Level(BaseConfiguration baseConfig, this._gameLoop):
    _model = new LevelModel(baseConfig),
    _baseConfig = baseConfig
  {
    _ui    = new LevelUI(_model, _gameLoop._gameCanvas, baseConfig);
  }
    
  void initRound(Configuration config)
  {
    bool isCrateAllowed(int x, int y) {
      return x.isEven||y.isEven;
    }
    
    //to increase readability let's make the variable names shorter
    final UnitToPixelPosConverter pixelConv = _baseConfig.pixelConv;
    final int widthTiles = _baseConfig.widthTiles;
    final int heightTiles = _baseConfig.heightTiles;
    final int numberOfBombUpgrades = config.levelConfig.numberOfBombUpgrades;
    final int numberOfRangeUpgrades = config.levelConfig.numberOfRangeUpgrades;
    final int numberOfMissingCrates = config.levelConfig.numberOfMissingCrates;
    
    //remove all present objects
    _model.clear();
    
    List<Crate> cratesCreated = new List<Crate>();
    
    //and add new crates
    final int middleWidthIndex = widthTiles~/2;
    for(int tileX=1;tileX<widthTiles-1;tileX++) {
      for(int tileY=1;tileY<heightTiles-1;tileY++) {
        if(tileX!=middleWidthIndex && isCrateAllowed(tileX, tileY)) {
          cratesCreated.add(createCrateAt(tileX, tileY));
        }
      }
    }
    for(int tileX=3;tileX<widthTiles-3;tileX++) {
      cratesCreated.add(createCrateAt(tileX, 0));
      cratesCreated.add(createCrateAt(tileX, heightTiles-1));
    }
    for(int tileY=2;tileY<heightTiles-2;tileY++) {
      cratesCreated.add(createCrateAt(0, tileY));
      cratesCreated.add(createCrateAt(_model._widthTiles-1, tileY));
    }
    
    assert(
        cratesCreated.length >=
        numberOfBombUpgrades+numberOfRangeUpgrades+numberOfMissingCrates
    );
    
    //remove some crates and add powerUps to other at random points
    Random random = new Random();
    //first remove some crates
    for(int i=0;i<numberOfMissingCrates;i++) {
      Crate crate = cratesCreated.removeAt(random.nextInt(cratesCreated.length));
      _model.removeCrate(crate);
    }
    //then add bombUpgrades
    for(int i=0;i<numberOfBombUpgrades;i++) {
      Crate crate = cratesCreated.removeAt(random.nextInt(cratesCreated.length));
      crate._powerUp = new BombUpgrade(_baseConfig.pixelConv, this, crate._tileX, crate._tileY);
    }
    //then rangeUpgrades to some
    for(int i=0;i<numberOfRangeUpgrades;i++) {
      Crate crate = cratesCreated.removeAt(random.nextInt(cratesCreated.length));
      crate._powerUp = new RangeUpgrade(_baseConfig.pixelConv, this, crate._tileX, crate._tileY);
    }
    
    // add robots/players
    for(var playerConfig in config.playerConfigs) {
      createRobotAt(playerConfig);
    }
  }
  
  void startRound()
  {
    //start all the robots
    _model.allRobots.forEach(
        (Robot robot)=>robot.startRobot()
    );
  }
  
  void createRobotAt(PlayerConfiguration config)
  {
    Point<int> tile = config.startCorner.getTile(_baseConfig.widthTiles, _baseConfig.heightTiles);
    Robot robot = new Robot(_baseConfig.pixelConv, config, this, tile.x, tile.y);
    _model.addRobot(robot);
  }
  
  Explosion createExplosionAt(int tileX, int tileY, int explosionRadius, List<Blast> trigger)
  {
    Explosion explosion = new Explosion(_baseConfig.pixelConv, this, tileX, tileY, explosionRadius, trigger);
    _model.addExplosion(explosion);
    return explosion;
  }
  
  Crate createCrateAt(int tileX, int tileY)
  {
    Crate crate = new Crate(_baseConfig.pixelConv, this, tileX, tileY);
    _model.addCrate(crate);
    return crate;
  }
  
  bool createBombIfPossible(int tileX, int tileY, Robot parent)
  {
    if(!_model.containsBomb(tileX, tileY)) {
      Bomb bomb = new Bomb(_baseConfig.pixelConv, this, tileX, tileY, parent);
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
        Duration timeTillEndOfRound = new Duration(milliseconds: 500);
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
  final int _heightTiles;
  final int _widthTiles;
    
  LevelModel(BaseConfiguration baseConfig):
    _heightTiles   = baseConfig.heightTiles,
    _widthTiles    = baseConfig.widthTiles,
    _deadlyTiles   = new BucketMap<int>.filled(baseConfig.numberOfTiles, 0),
    _bombs         = new BucketMap<Bomb>(baseConfig.numberOfTiles),
    _crates        = new BucketMap<Crate>(baseConfig.numberOfTiles),
    _explosions    = new BucketMap<Explosion>(baseConfig.numberOfTiles),
    _powerUps      = new BucketMap<PowerUp>(baseConfig.numberOfTiles),
    _robots        = new List<Robot>();
  
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
  
  Iterable<Robot> get allRobots=>_robots;
  
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
    if(notInRange(tileX, _widthTiles) || notInRange(tileY, _heightTiles)) {
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
    assert( 0<=tileX && tileX<_widthTiles );
    assert( 0<=tileY && tileY<_heightTiles );
    
    return tileX*_heightTiles + tileY;
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
  final BaseConfiguration _baseConfig;
  
  LevelUI(this._model, GameCanvas gameCanvas, this._baseConfig)
  {
    gameCanvas.setProxyPaint(repaint, _baseConfig.totalPixelWidth, _baseConfig.totalPixelHeight);
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
             ..fillRect(0, 0, _baseConfig.totalPixelWidth, _baseConfig.totalPixelHeight);
  }
  
  void paintObjects(CanvasRenderingContext2D context2D)
  {
    UI getUI(GameObject go)=>go.getUI();
    
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
        foregroundObject.repaint(context2D, _baseConfig.tilePixelSize);
      }
    );
  }
  
  void paintIndestructable(CanvasRenderingContext2D context2D)
  {
    //to increase readability let's make the variable names shorter
    final int border = _baseConfig.border;
    final int totalWidth = _baseConfig.totalPixelWidth;
    final int totalHeigth = _baseConfig.totalPixelHeight;
    final int tileSize = _baseConfig.tilePixelSize;
    final int widthTiles = _baseConfig.widthTiles;
    final int heightTiles = _baseConfig.heightTiles;
    
    //paint border
    context2D..fillStyle= blockColor
             ..fillRect(0, 0, border, totalHeigth)
             ..fillRect(0, 0, totalWidth, border)
             ..fillRect(totalWidth, totalHeigth, -border, -totalHeigth)
             ..fillRect(totalWidth, totalHeigth, -totalWidth, -border);
    
    
    //paint all the undestructable boxes
    for(int tileX=2;tileX<=widthTiles;tileX+=2) {
      for(int tileY=2;tileY<=heightTiles;tileY+=2) {
        int offsetX = _baseConfig.getPixelOffset(tileX);
        int offsetY = _baseConfig.getPixelOffset(tileY);
        
        context2D..fillStyle= blockColor
                 ..fillRect(offsetX, offsetY, tileSize, tileSize);
      }
    }
  }
}