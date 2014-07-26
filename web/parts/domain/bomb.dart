part of dartingflame;

class Bomb
extends RepaintableTileBasedGameObject
with Timed
{
  static const int MILLIES_TO_LIVE = 2000;
  static const int MILLIES_TO_LIVE_AFTER_TRIGGER = 100;
  final Level _level;
  final Robot _parent;
  final List<Blast> _trigger; 
  
  Bomb(UnitPosToPixelConverter pixelConv, this._level, int tileX, int tileY, this._parent, ResourceLoader resourceLoader):
    super(pixelConv, tileX, tileY, resourceLoader.bombTemplate),
    _trigger = new List<Blast>()
  {
    startTimer(MILLIES_TO_LIVE, _goBooom);
  }
  
  void triggerByBlast(Blast blast)
  {
    //only the first blast that hits this bomb can shorten its remaining time
    if(_trigger.isEmpty) {
      shortenRestOfLive(MILLIES_TO_LIVE_AFTER_TRIGGER);
    }
    _trigger.add(blast);
  }
  
  void _goBooom()
  {
    //boom
    _parent.addAvailableBomb();
    _level.createExplosionAt(_tileX, _tileY, _parent.explosionRadius, _trigger);
    _level.remove(this);
  }
    
  
  @override
  void repaint(CanvasRenderingContext2D context2D, int unitPixelSize)
  {
    //paint bomb template
    super.repaint(context2D, unitPixelSize);
    
    //paint explosion timer
    const String innerColor      = "#d3862b";

    double radiusPercentage = _tickTock();
    
    int borderRadius = unitPixelSize~/2;
    int radius = borderRadius-1;
    int innerRadius = max(0,radius-(radius*radiusPercentage).ceil());
    
    int arcMiddleX = _offsetX+borderRadius;
    int arcMiddleY = _offsetY+borderRadius;
    
    context2D..fillStyle = innerColor
             ..beginPath()
             ..arc(arcMiddleX, arcMiddleY, innerRadius, 0, 6.2)
             ..fill();
  }
}

class Timed
{
  int _initialMilliesToLive;
  int _realMilliesToLive;
  double _creationTimeMillies;
  bool _isAlive = true;
  VoidCallback _onTimeout;
  
  void startTimer(int milliesToLive, VoidCallback onTimeout)
  {
    this._creationTimeMillies   = nowInMillies();
    this._initialMilliesToLive  = milliesToLive;
    this._realMilliesToLive     = milliesToLive;
    this._onTimeout             = onTimeout;
  }
  
  void shortenRestOfLive(int newMilliesToLive)
  {
    int milliesLived = (nowInMillies()-_creationTimeMillies).ceil();  
    _realMilliesToLive = min(milliesLived+newMilliesToLive, _realMilliesToLive);
  }
  
  /**
   * 1) returns a value [0-1] which represents the percentage of livetime that this timer
   * currently has spend.
   * 2) Sets isAlive to false, if the the number of milliseconds since startTimer was
   *    called is bigger than _milliesToLive millisenconds 
   * 3) calls onTimeout the moment isAlive is set to false
   */
  double _tickTock()
  {
    double milliesLived = nowInMillies()-_creationTimeMillies;    
    if(_isAlive && milliesLived>_realMilliesToLive) {
      _isAlive = false;
      _onTimeout();
    }

    double livePercentage = min(1.0, milliesLived/_initialMilliesToLive);
    return livePercentage;
  }
}

class Explosion
extends TileBasedObject
with Timed
{
  static const int MILLIES_TO_LIVE = 600;
  static const String OUTER_BLAST_COLOR = "#a00";
  static const String INNER_BLAST_COLOR = "#d3862b";
  final Level _level;
  final List<Blast> blasts;
  final Map<Blast, List<Point<int>>> blastedTiles;
  double liveSpanPercentage = .0;
  
  Explosion(UnitPosToPixelConverter pixelConv, this._level, int tileX, int tileY, int explosionRadius, List<Blast> trigger):
    super(pixelConv, tileX, tileY),
    blasts = new List<Blast>(),
    blastedTiles = new Map<Blast, List<Point<int>>>()
  {
    void collectBlastedTiles(Map<Blast, List<Point<int>>> blastsWithEffectedTiles, Blast blast)
    {
      List<Point<int>> blastedTiles = new List<Point<int>>();
      Point<int> blastTile = new Point<int>(tileX, tileY);
      //each blast collects the center-tile, so even with a blastRange of 0, 1 element will be collected!
      for(int i=0; i<=blast._blastRange.range; i++) {
        blastedTiles.add(blastTile);
        blastTile = Tile.nextTile(blastTile.x, blastTile.y, blast._direction);
      }
      blastsWithEffectedTiles[blast]=blastedTiles;
    }
    bool bombWasBlastedFrom(Direction direction)
    {
      return trigger.map((Blast blast)=>blast._direction).any(
          (Direction blastDirection)=>direction.isOposite(blastDirection)
      );
    }
    
    //add a blast for each direction the original bomb wasn't blasted from
    Direction.values().forEach(
      (Direction direction) {
        //we need zeroRange-Blast so we have blast responsible for the center explosion tile
        BlastRange blastRange = bombWasBlastedFrom(direction) ?
                                  new BlastRange.zeroRange() :
                                  _level.getBlastRange(tileX, tileY, direction, explosionRadius);
        Blast blast = new Blast(blastRange, direction, _level);
        blasts.add(blast);
        collectBlastedTiles(blastedTiles, blast);
      }
    );
    
    blastedTiles.forEach(
      (Blast blast, List<Point<int>> tiles)=>_level.addDeadlyTiles(tiles, blast)
    );
    
    startTimer(MILLIES_TO_LIVE, _fadeOut);
  }
  
  void _fadeOut()
  {
    blastedTiles.forEach(
      (Blast blast, List<Point<int>> tiles)=>_level.removeDeadlyTiles(tiles, blast)
    );
    _level.remove(this);
    
    blasts.forEach(
      (Blast blast) {
        blast.fadeOut();
      }
    );
  }
  
  void updateLivespanPercentage()
  {
    liveSpanPercentage = _tickTock();
  }
  
  void repaintOuterBlast(CanvasRenderingContext2D context2D, int unitPixelSize)
  {
    int radius = (unitPixelSize*sqrt(.5)).floor()+1;
    int unitPixelSizeHalf = unitPixelSize~/2;
    
    int arcMiddleX = _offsetX+unitPixelSizeHalf;
    int arcMiddleY = _offsetY+unitPixelSizeHalf;
        
    context2D..fillStyle = OUTER_BLAST_COLOR
             ..beginPath()
             ..arc(arcMiddleX, arcMiddleY, radius, 0, 6.2)
             ..fill();
        
    blasts.forEach(
      (Blast blast) {
        blast.repaintOuterBlast(context2D, unitPixelSize, _offsetX, _offsetY, liveSpanPercentage);
      }
    );
  }
  
  void repaintInnerBlast(CanvasRenderingContext2D context2D, int unitPixelSize)
  {
    int radius = (unitPixelSize*sqrt(.5)).floor()-1;
    int unitPixelSizeHalf = unitPixelSize~/2;
    
    int arcMiddleX = _offsetX+unitPixelSizeHalf;
    int arcMiddleY = _offsetY+unitPixelSizeHalf;
        
    context2D..fillStyle = INNER_BLAST_COLOR
             ..beginPath()
             ..arc(arcMiddleX, arcMiddleY, radius, 0, 6.2)
             ..fill();
    
    blasts.forEach(
      (Blast blast) {
        blast.repaintInnerBlast(context2D, unitPixelSize, _offsetX, _offsetY, liveSpanPercentage);
      }
    );
  }
}

class Blast
{
  final BlastRange _blastRange;
  final Direction _direction;
  final Level _level;
  
  Blast(this._blastRange, this._direction, this._level)
  {
    if(_blastRange.hasTerminator) {
      var terminator = _blastRange.terminator;
      if(terminator is Bomb) {
        terminator.triggerByBlast(this);
      }
    }
  }
  
  void fadeOut()
  {
    if(_blastRange.hasTerminator) {
      var terminator = _blastRange.terminator;
      if(terminator is Crate) {
        terminator.explode();
      }
    }
  }
  
  void repaintOuterBlast(CanvasRenderingContext2D context2D, int unitPixelSize, int offsetX, int offsetY, double liveSpanPercentage)
  { 
    //no need to paint anything if blastrange is zero
    if(_blastRange.hasZeroRange) return;
    
    context2D.fillStyle = Explosion.OUTER_BLAST_COLOR;
    
    int rangePixelSize = _blastRange.hasTerminator && _blastRange.terminator is Bomb ?
        (unitPixelSize*(_blastRange.range-.5)).floor() :
        (unitPixelSize*_blastRange.range);
    
    if(_direction==Direction.UP) {
      context2D.fillRect(offsetX, offsetY, unitPixelSize, -rangePixelSize);
    }else if(_direction==Direction.DOWN) {
      context2D.fillRect(offsetX, offsetY+unitPixelSize, unitPixelSize, rangePixelSize);
    }else if(_direction==Direction.LEFT){
      context2D.fillRect(offsetX, offsetY, -rangePixelSize, unitPixelSize);
    }else if(_direction==Direction.RIGHT){
      context2D.fillRect(offsetX+unitPixelSize, offsetY, rangePixelSize, unitPixelSize);
    }
  }
  
  void repaintInnerBlast(CanvasRenderingContext2D context2D, int unitPixelSize, int offsetX, int offsetY, double liveSpanPercentage)
  {
    //no need to paint anything if blastrange is zero
    if(_blastRange.hasZeroRange) return;
  
    int _evenInnerBlastDiameter(double liveSpanPercentage, int unitPixelSize) {
      //value in range [0,1] -> what is the maximum of the inner blast in relation to the outer blast
      const double MAX_DIAMETER_FACTOR = .8;
      //must be smaller than .5! (else the math breaks)
      const double MIN_DELIMITER = .15;
      double t = liveSpanPercentage-(2*liveSpanPercentage-1)*MIN_DELIMITER;
      //compute the correct diameter
      double diameter = sin(t*PI)*MAX_DIAMETER_FACTOR*unitPixelSize;
      //now get the closest even int to it (because that's easiest to draw)
      int evenDiameter = (diameter/2).round()*2;
      return evenDiameter;
    }
    
    int rangePixelSize = _blastRange.hasTerminator && _blastRange.terminator is Bomb ?
        (unitPixelSize*(_blastRange.range-.5)).floor() :
        (unitPixelSize*_blastRange.range);
    
    int evenInnerBlastDiameter = _evenInnerBlastDiameter(liveSpanPercentage, unitPixelSize);
    //if the inner blast diameter is 0 there is nothing else to do
    if(evenInnerBlastDiameter==0) {
      return;
    }
    //else paint the inner blast
    int borderOffset = (unitPixelSize-evenInnerBlastDiameter)~/2;
    context2D.fillStyle = Explosion.INNER_BLAST_COLOR;
    
    if(_direction==Direction.UP) {
      context2D.fillRect(offsetX+borderOffset, offsetY, evenInnerBlastDiameter, -rangePixelSize);
    }else if(_direction==Direction.DOWN) {
      context2D.fillRect(offsetX+borderOffset, offsetY+unitPixelSize, evenInnerBlastDiameter, rangePixelSize);
    }else if(_direction==Direction.LEFT){
      context2D.fillRect(offsetX, offsetY+borderOffset, -rangePixelSize, evenInnerBlastDiameter);
    }else if(_direction==Direction.RIGHT){
      context2D.fillRect(offsetX+unitPixelSize, offsetY+borderOffset, rangePixelSize, evenInnerBlastDiameter);
    }
  }
}

class BlastRange
{
  final RepaintableTileBasedGameObject terminator;
  final int range;
  
  bool get hasTerminator=>terminator!=null;
  bool get hasZeroRange=>range==0;
  
  BlastRange(this.terminator, this.range);
  
  BlastRange.zeroRange():
    this.terminator = null,
    this.range = 0;
}

class Firework
implements Repaintable
{
  static Firework _firework = new Firework._();
  Iterable<Explosion> _explosions;
  
  Firework._();
  
  factory Firework(Iterable<Explosion> explosions)
  {
    _firework._explosions = explosions;
    return _firework;
  }
  
  @override
  void repaint(CanvasRenderingContext2D context2D, int unitPixelSize)
  {
    _explosions.forEach(
      (Explosion e) {
        e.updateLivespanPercentage();
      }
    );
    //paint the outer blast of all explosions first
    //so that no outer blast of one explosion will overpaint the inner blast of another
    _explosions.forEach(
      (Explosion e) {
        e.repaintOuterBlast(context2D, unitPixelSize);
      }
    );
    _explosions.forEach(
      (Explosion e) {
        e.repaintInnerBlast(context2D, unitPixelSize);
      }
    );
  }
}