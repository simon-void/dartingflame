part of dartingflame;

class Bomb
extends UnmovableObject
with Timer
{
  static const int MILLIES_TO_LIVE = 2000;
  static const int MILLIES_TO_LIVE_AFTER_TRIGGER = 100;
  final Level _level;
  final Robot _parent;
  
  Bomb(UnitToPixelPosConverter pixelConv, this._level, int tileX, int tileY, this._parent):
    super(pixelConv, tileX, tileY)
  {
    startTimer(MILLIES_TO_LIVE, _goBooom);
  }
  
  void triggeredByExplosion(Blast blast)
  {
    shortenRestOfLive(MILLIES_TO_LIVE_AFTER_TRIGGER);
  }
  
  void _goBooom()
  {
    //boom
    _parent.addAvalableBomb();
    _level.createExplosionAt(_tileX, _tileY, _parent.explosionRadius);
    _level.remove(this);
  }
    
  
  @override
  void repaint(CanvasRenderingContext2D context2D, int unitPixelSize)
  {
    const String outerRingColor = "#000";
    const String outerColor     = "#a00";
    const String innerColor      = "#fff";
    
    int radius = unitPixelSize~/2;
    double radiusPercentage = _liveSpanPercentage();
    int innerRadius = max(0,radius-(radius*radiusPercentage).ceil());
    
    int arcMiddleX = _offsetX+radius;
    int arcMiddleY = _offsetY+radius;
    
    context2D..fillStyle = outerColor
             ..beginPath()
             ..arc(arcMiddleX, arcMiddleY, radius, 0, 6.2)
             ..fill();
    context2D..fillStyle = innerColor
             ..beginPath()
             ..arc(arcMiddleX, arcMiddleY, innerRadius, 0, 6.2)
             ..fill();
    context2D..strokeStyle = outerRingColor
             ..beginPath()
             ..arc(arcMiddleX, arcMiddleY, radius, 0, 6.2)
             ..stroke();
  }
}

typedef void Callback();

class Timer
{
  int _initialMilliesToLive;
  int _realMilliesToLive;
  double _creationTimeMillies;
  bool _isAlive = true;
  Callback _onTimeout;
  
  void startTimer(int milliesToLive, Callback onTimeout)
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
  double _liveSpanPercentage()
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
extends UnmovableObject
with Timer
{
  static const int MILLIES_TO_LIVE = 500;
  final Level _level;
  final List<Blast> blasts;
  
  Explosion(UnitToPixelPosConverter pixelConv, this._level, int tileX, int tileY, int explosionRadius):
    super(pixelConv, tileX, tileY),
    blasts = new List<Blast>()
  {
    startTimer(MILLIES_TO_LIVE, _fadeOut);
    
    Direction.values().forEach(
      (Direction direction) {
        BlastRange blastRange = _level.getBlastRange(tileX, tileY, direction, explosionRadius);
        if(blastRange.isNotEmpty) {
          blasts.add(new Blast(blastRange, direction, _level));
        }
      }
    );
  }
  
  void _fadeOut()
  {
    _level.remove(this);
    
    blasts.forEach(
      (Blast blast) {
        blast.fadeOut();
      }
    );
  }
  
  @override
  void repaint(CanvasRenderingContext2D context2D, int unitPixelSize)
  {
    const String outerColor     = "#a00";
    
    double liveSpanPercentage = _liveSpanPercentage();
    
    context2D..fillStyle = outerColor
             ..fillRect(_offsetX, _offsetY, unitPixelSize, unitPixelSize);
    
    blasts.forEach(
      (Blast blast) {
        blast.repaint(context2D, unitPixelSize, _offsetX, _offsetY, outerColor);
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
        terminator.triggeredByExplosion(this);
      }
    }
  }
  
  void fadeOut()
  {
    if(_blastRange.hasTerminator) {
      var terminator = _blastRange.terminator;
      if(terminator is Crate) {
        _level.remove(terminator);
      }
    }
  }
  
  void repaint(CanvasRenderingContext2D context2D, int unitPixelSize, int offsetX, int offsetY, String blastColor)
  {
    context2D.fillStyle = blastColor;
    
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
}

class BlastRange
{
  final UnmovableObject terminator;
  final int range;
  
  bool get hasTerminator=>terminator!=null;
  bool get isNotEmpty=>range>0;
  
  BlastRange(this.terminator, this.range);
}

class Direction
{
  static final Direction UP = new Direction._();
  static final Direction DOWN = new Direction._();
  static final Direction LEFT = new Direction._();
  static final Direction RIGHT = new Direction._();
  
  static List<Direction> values()=>[UP, RIGHT, DOWN, LEFT];
  
  Direction._();
}