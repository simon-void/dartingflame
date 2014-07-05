part of dartingflame;

typedef int UnitToPixelPosConverter(double widthOrHeight);

abstract class UI
{
  final UnitToPixelPosConverter _pixelConv;
  
  UI(this._pixelConv);
  
  void repaint(CanvasRenderingContext2D context2D, int unitPixelSize);
}

abstract class GameObject
{  
  UI getUI();
}

abstract class UnmovableObject extends UI implements GameObject
{
  final int _offsetX;
  final int _offsetY;
  final int _tileX;
  final int _tileY;

  UnmovableObject(UnitToPixelPosConverter pixelConv, int tileX, int tileY)
    :super(pixelConv),
    _offsetX = pixelConv(tileX.toDouble()),
    _offsetY = pixelConv(tileY.toDouble()),
    _tileX   = tileX,
    _tileY   = tileY;
  
  UI getUI() {
    return this;
  }
  
  bool isOnTile(int tileX, int tileY)=>tileX==_tileX && tileY==_tileY;
}

class Crate
extends UnmovableObject
{  
  Crate(UnitToPixelPosConverter pixelConv, int tileX, int tileY):
    super(pixelConv, tileX, tileY);
  
  @override
  void repaint(CanvasRenderingContext2D context2D, int unitPixelSize)
  {
    const String color = "#666";
    context2D..fillStyle = color
             ..fillRect(_offsetX, _offsetY, unitPixelSize, unitPixelSize);
  }
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

class Tile
{
  static Point<int> posToTile(Point<double> pos)
  {
    return new Point<int>(pos.x.toInt(), pos.y.toInt());
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