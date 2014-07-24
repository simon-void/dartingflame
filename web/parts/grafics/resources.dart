part of dartingflame;

class ResourceLoader
{
  final CanvasElement _robotBaseTemplateUp;
  final CanvasElement _deadRobotTemplate;
  final CanvasElement _bombTemplate;
  final CanvasElement _crateTemplate;
  final CanvasElement _bombUpgradeTemplate;
//  final CanvasElement _multibombUpgradeTemplate;
  final CanvasElement _rangeUpgradeTemplate;
  
  CanvasImageSource get deadRobotTemplate=>_deadRobotTemplate;
  CanvasImageSource get bombTemplate=>_bombTemplate;
  CanvasImageSource get crateTemplate=>_crateTemplate;
  CanvasImageSource get bombUpgradeTemplate=>_bombUpgradeTemplate;
//  CanvasImageSource get multibombUpgradeTemplate=>_multibombUpgradeTemplate;
  CanvasImageSource get rangeUpgradeTemplate=>_rangeUpgradeTemplate;
  
  Map<Direction, CanvasImageSource> robotTemplates(String playerColor)
  {
    CanvasElement copy(CanvasElement src) {
      CanvasElement canvas = new CanvasElement(width: src.width, height: src.height);
      canvas.context2D.drawImage(src, 0, 0);
      return canvas;
    }
    CanvasElement rotate90DegreesClockwise(CanvasElement src) {
      CanvasElement dst = copy(src);
      double pivot_x=src.width/2;
      double pivot_y=src.height/2;
      dst.context2D..save()
                   ..translate(pivot_x, pivot_y)
                   ..transform(0, 1, -1, 0, 0, 0)
                   ..drawImage(src, -pivot_x, -pivot_y)
                   ..restore();
      return dst;
    }
    
    CanvasElement robotTemplateUp = _individualizeRobotTemplateUp(copy(_robotBaseTemplateUp), playerColor);    
    
    Map<Direction, CanvasImageSource> robotImgByDirection = new Map<Direction, CanvasImageSource>();
    CanvasImageSource template = robotTemplateUp;
    for(Direction d in Direction.values()) {
      robotImgByDirection[d]=template;
      if(d!=Direction.LEFT) {  //LEFT should be the last Direction
        template = rotate90DegreesClockwise(template);
      }
    }
    
    return robotImgByDirection;
  }
  
  ResourceLoader(int tilePixelSize):
    _robotBaseTemplateUp      = new CanvasElement(width: tilePixelSize, height: tilePixelSize),
    _deadRobotTemplate        = new CanvasElement(width: tilePixelSize, height: tilePixelSize),
    _bombTemplate             = new CanvasElement(width: tilePixelSize, height: tilePixelSize),
    _crateTemplate            = new CanvasElement(width: tilePixelSize, height: tilePixelSize),
    _bombUpgradeTemplate      = new CanvasElement(width: tilePixelSize, height: tilePixelSize),
//    _multibombUpgradeTemplate = new CanvasElement(width: tilePixelSize, height: tilePixelSize),
    _rangeUpgradeTemplate     = new CanvasElement(width: tilePixelSize, height: tilePixelSize)
  {
    _initRobotTemplateUp(_robotBaseTemplateUp);
    _initDeadRobotTemplate(_deadRobotTemplate);
    _initBombTemplate(_bombTemplate);
    _initCrateTemplate(_crateTemplate);
    _initBombUpgradeTemplate(_bombUpgradeTemplate);
    _initRangeUpgradeTemplate(_rangeUpgradeTemplate);
  }
  
  void _initRobotTemplateUp(CanvasElement canvas)
  {
    const String color = "#000";
    final tilePixelSize = canvas.width;
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
  
  CanvasElement _individualizeRobotTemplateUp(CanvasElement canvas, String color)
  {
    double middle = canvas.width/2;
    double radius = canvas.width/6;
    //paint an direction identifier on top of it
    canvas.context2D..fillStyle = color
                        ..beginPath()
                        ..moveTo(middle-radius, middle)
                        ..lineTo(middle, middle-radius)
                        ..lineTo(middle+radius, middle)
                        ..closePath()
                        ..fill()
//    canvas.context2D//..fillStyle = "#000"
                        ..beginPath()
                        ..arc(middle, middle, radius*.5, 0, PI)
                        ..closePath()
                        ..fill();
    
    return canvas;
  }
  
  void _initDeadRobotTemplate(CanvasElement canvas)
  {
    final tilePixelSize = canvas.width;
    final double unitSizeHalf = tilePixelSize/2;
    canvas.context2D..fillStyle = Explosion.OUTER_BLAST_COLOR
                    ..beginPath()
                    ..moveTo(unitSizeHalf,  0)
                    ..lineTo(tilePixelSize, unitSizeHalf)
                    ..lineTo(unitSizeHalf,  tilePixelSize)
                    ..lineTo(0,             unitSizeHalf)
                    ..closePath()
                    ..fill();
  }
  
  void _initBombTemplate(CanvasElement canvas)
  {
    const String outerRingColor = "#000";
    const String outerColor     = "#a00";
    
    double borderRadius = canvas.width/2;
    double radius = borderRadius-1;
    
    double arcMiddleX = borderRadius;
    double arcMiddleY = borderRadius;
    
    canvas.context2D..fillStyle = outerRingColor
                    ..beginPath()
                    ..arc(arcMiddleX, arcMiddleY, borderRadius, 0, 6.2)
                    ..closePath()
                    ..fill()
                    ..fillStyle = outerColor
                    ..beginPath()
                    ..arc(arcMiddleX, arcMiddleY, radius, 0, 6.2)
                    ..closePath()
                    ..fill();
  }
  
  void _initCrateTemplate(CanvasElement canvas)
  {
    const String color = "#5d5d5d";
    final tilePixelSize = canvas.width;
    canvas.context2D..fillStyle = color
                    ..fillRect(0, 0, tilePixelSize, tilePixelSize);
  }
  
  void _initBombUpgradeTemplate(CanvasElement canvas)
  {
    const String outerRingColor = "#000";
    const String bombBlueColor = "#333396";
            
    double radius = canvas.width/2;
        
    double arcMiddleX = radius;
    double arcMiddleY = radius;
    
    canvas.context2D..fillStyle = outerRingColor
                    ..beginPath()
                    ..arc(arcMiddleX, arcMiddleY, radius, 0, 6.2)
                    ..closePath()
                    ..fill()
                    ..fillStyle = bombBlueColor
                    ..beginPath()
                    ..arc(arcMiddleX, arcMiddleY, radius-1, 0, 6.2)
                    ..closePath()
                    ..fill();
  }
  
  void _initRangeUpgradeTemplate(CanvasElement canvas)
  {
    const String outerRingColor = "#000";
        
    double radius = canvas.width/2;
    
    double arcMiddleX = radius;
    double arcMiddleY = radius;
    
    canvas.context2D..fillStyle = outerRingColor
                    ..beginPath()
                    ..arc(arcMiddleX, arcMiddleY, radius, 0, 6.2)
                    ..closePath()
                    ..fill()
                    ..fillStyle = Explosion.INNER_BLAST_COLOR
                    ..beginPath()
                    ..arc(arcMiddleX, arcMiddleY, radius-1, 0, 6.2)
                    ..closePath()
                    ..fill();
  }
}