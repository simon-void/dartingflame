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
  void updatePosition();    
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
  
  //nothing to update because object is unmovable
  @override
  void updatePosition(){}
  
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