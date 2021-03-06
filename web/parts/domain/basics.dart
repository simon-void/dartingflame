part of dartingflame;

class UnitPosToPixelConverter
{
  final int _border;
  final int _tilePixelSize;
  
  UnitPosToPixelConverter(this._border, this._tilePixelSize);
  
  int _posToPixel(double unitV)   =>(unitV*_tilePixelSize).round()+_border;
  
  int tileToPixelOffset(int tileIndex)=>(tileIndex*_tilePixelSize)+_border;

  Point<int> getPixelOffsetFromTile(int tileX, int tileY) 
    => new Point<int>(tileToPixelOffset(tileX), tileToPixelOffset(tileY));
    
  Point<int> getPixelOffsetFromPos(double posX, double posY) 
      => new Point<int>(_posToPixel(posX), _posToPixel(posY));
}

abstract class Repaintable
{
  void repaint(CanvasRenderingContext2D context2D, int unitPixelSize);
}

abstract class GameObject
{  
  Repaintable getUI();
}

abstract class UnmovableObject
{
  final int _offsetX;
  final int _offsetY;

  UnmovableObject(this._offsetX, this._offsetY);
}

abstract class TileBasedObject extends UnmovableObject
{
  final int _tileX;
  final int _tileY;

  TileBasedObject(UnitPosToPixelConverter pixelConv, int tileX, int tileY):
    super(pixelConv.tileToPixelOffset(tileX), pixelConv.tileToPixelOffset(tileY)),
    _tileX    = tileX,
    _tileY    = tileY;
  
  bool isOnTile(int tileX, int tileY)=>tileX==_tileX && tileY==_tileY;
}

abstract class RepaintableTileBasedGameObject
extends TileBasedObject
implements GameObject, Repaintable
{
  final CanvasImageSource _template;

  RepaintableTileBasedGameObject(UnitPosToPixelConverter pixelConv, int tileX, int tileY, this._template):
    super(pixelConv, tileX, tileY);
  
  @override
  void repaint(CanvasRenderingContext2D context2D, int unitPixelSize)
  {
    context2D.drawImage(_template, _offsetX, _offsetY);
  }
  
  @override
  Repaintable getUI()
  {
    return this;
  }
}

abstract class RepaintableUnmovableGameObject
extends UnmovableObject
implements GameObject, Repaintable
{
  final CanvasImageSource _template;

  RepaintableUnmovableGameObject(int offsetX, int offsetY, this._template):
    super(offsetX, offsetY);
  
  @override
  void repaint(CanvasRenderingContext2D context2D, int unitPixelSize)
  {
    context2D.drawImage(_template, _offsetX, _offsetY);
  }
  
  @override
  Repaintable getUI()
  {
    return this;
  }
}

class Crate
extends RepaintableTileBasedGameObject
{
  final Level _level;
  PowerUp _powerUp;
  int _blastCounter = 0;
  
  Crate(UnitPosToPixelConverter pixelConv, this._level, int tileX, int tileY, ResourceLoader resourceLoader):
    super(pixelConv, tileX, tileY, resourceLoader.crateTemplate);

  void hitByInitialBlast(Blast blast)
  {
    //if this crate is hit bei two bombs than delete its powerup
    if(_blastCounter++==2) {
      _powerUp=null;
    }
  }
  
  void explode()
  {
    _level.remove(this);
    if(_powerUp!=null) {
      _level.addPowerUp(_powerUp);
    }
  }
}

class Direction
{
  static final Direction UP = new Direction._();
  static final Direction DOWN = new Direction._();
  static final Direction LEFT = new Direction._();
  static final Direction RIGHT = new Direction._();
  
  static List<Direction> values()=>[UP, RIGHT, DOWN, LEFT];
  
  static Direction fromMovement(Movement movement)
  {
    assert(movement!=null);
    assert(movement!=Movement.NONE);
    
    if(movement==Movement.UP) {
      return Direction.UP;
    }
    else if(movement==Movement.RIGHT) {
      return Direction.RIGHT;
    }
    else if(movement==Movement.DOWN) {
      return Direction.DOWN;
    }
    else /*(movement==Movement.LEFT)*/ {
      return Direction.LEFT;
    }
  }
  
  Direction._();
  
  bool isOposite(Direction other)
  {
    if(this==Direction.UP)    return other==Direction.DOWN;
    if(this==Direction.DOWN)  return other==Direction.UP;
    if(this==Direction.LEFT)  return other==Direction.RIGHT;
    if(this==Direction.RIGHT) return other==Direction.LEFT;
    throw new StateError("unknown direction");
  }
}

class Tile
{
  static Point<int> posToTile(Point<double> pos)
  {
    return new Point<int>(pos.x.round(), pos.y.round());
  }
  
  static Point<int> nextTile(int tileX, int tileY, Direction direction)
  {
    if(direction==Direction.UP)    return new Point<int>(tileX,   tileY-1);
    if(direction==Direction.DOWN)  return new Point<int>(tileX,   tileY+1);
    if(direction==Direction.LEFT)  return new Point<int>(tileX-1, tileY);
    if(direction==Direction.RIGHT) return new Point<int>(tileX+1, tileY);
    throw new StateError("unknown direction");
  }
}

class Corner
{
  static final Corner UPPER_LEFT  = new Corner._();
  static final Corner UPPER_RIGHT = new Corner._();
  static final Corner LOWER_LEFT  = new Corner._();
  static final Corner LOWER_RIGHT = new Corner._();
  
  Corner._();
  
  Point<int> getTile(int boardWidth, int boardHeight)
  {
    if(this==Corner.UPPER_LEFT)  return new Point<int>(0, 0);
    if(this==Corner.UPPER_RIGHT) return new Point<int>(boardWidth-1, 0);
    if(this==Corner.LOWER_LEFT)  return new Point<int>(0, boardHeight-1);
    if(this==Corner.LOWER_RIGHT) return new Point<int>(boardWidth-1, boardHeight-1);
    throw new StateError("unknown corner");
  }
}