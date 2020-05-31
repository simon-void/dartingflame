library dartingflame;

import 'dart:async';
import 'dart:collection';
import 'dart:html';
import 'dart:math';

part 'parts/collection.dart';
part 'parts/configuration.dart';
part 'parts/controler.dart';
part 'parts/gameloop.dart';
part 'parts/glossary.dart';
part 'parts/domain/basics.dart';
part 'parts/domain/bomb.dart';
part 'parts/domain/level.dart';
part 'parts/domain/robot.dart';
part 'parts/domain/powerups.dart';
part 'parts/grafics/animation.dart';
part 'parts/grafics/resources.dart';


void main()
{
  BaseConfiguration baseConfig = new BaseConfiguration(
    tilePixelSize: 40,
    widthTiles: 9,
    heightTiles: 7,
    border: 9
  );
  
  final ResourceLoader resourceLoader = new ResourceLoader(baseConfig.tilePixelSize);
  var gameLoop = new GameLoop(querySelector("#appId"), baseConfig, resourceLoader);
  
  _showGlossary(querySelector("#glossaryId"), resourceLoader, baseConfig);
  
  //to figure out keyCodes by trying
//  window.onKeyUp.listen(
//    (KeyboardEvent event){
//      DivElement div = new DivElement();
//      div.text = "keyCode: ${event.keyCode}";
//      document.body.children.add(div);
//    }
//  );  
}