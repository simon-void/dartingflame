part of dartingflame;

class ResourceLoader
{
  final CanvasImageSource robotTemplate;
  final CanvasImageSource deadRobotTemplate;
  final CanvasImageSource bombTemplate;
  final CanvasImageSource crateTemplate;
  final CanvasImageSource bombUpgradeTemplate;
  final CanvasImageSource rangeUpgradeTemplate;
  
  ResourceLoader(int tilePixelSize):
    robotTemplate        = new CanvasElement(width: tilePixelSize, height: tilePixelSize),
    deadRobotTemplate    = new CanvasElement(width: tilePixelSize, height: tilePixelSize),
    bombTemplate         = new CanvasElement(width: tilePixelSize, height: tilePixelSize),
    crateTemplate        = new CanvasElement(width: tilePixelSize, height: tilePixelSize),
    bombUpgradeTemplate  = new CanvasElement(width: tilePixelSize, height: tilePixelSize),
    rangeUpgradeTemplate = new CanvasElement(width: tilePixelSize, height: tilePixelSize)    
  {
    _initRobotTemplate(tilePixelSize, robotTemplate);
    _initDeadRobotTemplate(tilePixelSize, deadRobotTemplate);
    _initBombTemplate(tilePixelSize, bombTemplate);
    _initCrateTemplate(tilePixelSize, crateTemplate);
    _initBombUpgradeTemplate(tilePixelSize, bombUpgradeTemplate);
    _initRangeUpgradeTemplate(tilePixelSize, rangeUpgradeTemplate);
  }
  
  void _initRobotTemplate(int tilePixelSize, CanvasElement canvas)
  {
    const String color = "#000";
    final int unitSizeHalf = tilePixelSize~/2;
    canvas.context2D..fillStyle = color
                    ..beginPath()
                    ..moveTo(unitSizeHalf,  0)
                    ..lineTo(tilePixelSize, unitSizeHalf)
                    ..lineTo(unitSizeHalf,  tilePixelSize)
                    ..lineTo(0,             unitSizeHalf)
                    ..closePath()
                    ..fill();
  }
  
  void _initDeadRobotTemplate(int tilePixelSize, CanvasElement canvas)
  {
    final int unitSizeHalf = tilePixelSize~/2;
    canvas.context2D..fillStyle = Explosion.OUTER_BLAST_COLOR
                    ..beginPath()
                    ..moveTo(unitSizeHalf,  0)
                    ..lineTo(tilePixelSize, unitSizeHalf)
                    ..lineTo(unitSizeHalf,  tilePixelSize)
                    ..lineTo(0,             unitSizeHalf)
                    ..closePath()
                    ..fill();
  }
  
  void _initBombTemplate(int tilePixelSize, CanvasElement canvas)
  {
    const String outerRingColor = "#000";
    const String outerColor     = "#a00";
    
    int borderRadius = tilePixelSize~/2;
    int radius = borderRadius-1;
    
    int arcMiddleX = borderRadius;
    int arcMiddleY = borderRadius;
    
    canvas.context2D..fillStyle = outerRingColor
                    ..beginPath()
                    ..arc(arcMiddleX, arcMiddleY, borderRadius, 0, 6.2)
                    ..fill()
                    ..fillStyle = outerColor
                    ..beginPath()
                    ..arc(arcMiddleX, arcMiddleY, radius, 0, 6.2)
                    ..fill();
  }
  
  void _initCrateTemplate(int tilePixelSize, CanvasElement canvas)
  {
    const String color = "#5d5d5d";
    canvas.context2D..fillStyle = color
                    ..fillRect(0, 0, tilePixelSize, tilePixelSize);
  }
  
  void _initBombUpgradeTemplate(int tilePixelSize, CanvasElement canvas)
  {
    const String outerRingColor = "#000";
    const String bombBlueColor = "#333396";
            
    int radius = tilePixelSize~/2;
    
    int arcMiddleX = radius;
    int arcMiddleY = radius;
    
    canvas.context2D..fillStyle = outerRingColor
                    ..beginPath()
                    ..arc(arcMiddleX, arcMiddleY, radius, 0, 6.2)
                    ..fill()
                    ..fillStyle = bombBlueColor
                    ..beginPath()
                    ..arc(arcMiddleX, arcMiddleY, radius-1, 0, 6.2)
                    ..fill();
  }
  
  void _initRangeUpgradeTemplate(int tilePixelSize, CanvasElement canvas)
  {
    const String outerRingColor = "#000";
        
    int radius = tilePixelSize~/2;
    
    int arcMiddleX = radius;
    int arcMiddleY = radius;
    
    canvas.context2D..fillStyle = outerRingColor
                    ..beginPath()
                    ..arc(arcMiddleX, arcMiddleY, radius, 0, 6.2)
                    ..fill()
                    ..fillStyle = Explosion.INNER_BLAST_COLOR
                    ..beginPath()
                    ..arc(arcMiddleX, arcMiddleY, radius-1, 0, 6.2)
                    ..fill();
  }
}