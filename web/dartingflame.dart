library dartingflame;

import 'dart:async';
import 'dart:collection';
import 'dart:html';
import 'dart:math';

part 'parts/grafics/animation.dart';
part 'parts/grafics/resources.dart';
part 'parts/collection.dart';
part 'parts/configuration.dart';
part 'parts/controler.dart';
part 'parts/gameloop.dart';
part 'parts/domain/basics.dart';
part 'parts/domain/bomb.dart';
part 'parts/domain/level.dart';
part 'parts/domain/robot.dart';
part 'parts/domain/powerups.dart';


void main()
{
  BaseConfiguration baseConfig = new BaseConfiguration(
    tilePixelSize: 40,
    widthTiles: 9,
    heightTiles: 7,
    border: 9
  );          
  final HtmlElement appDiv = querySelector("#appId");
  final ResourceLoader resourceLoader = new ResourceLoader(baseConfig.tilePixelSize);
    
  GameLoop gameLoop = new GameLoop(appDiv, baseConfig, resourceLoader);
  
  //to figure out keyCodes by trying
//  window.onKeyUp.listen(
//    (KeyboardEvent event){
//      DivElement div = new DivElement();
//      div.text = "keyCode: ${event.keyCode}";
//      document.body.children.add(div);
//    }
//  );  
}

