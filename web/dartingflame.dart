library dartingflame;

import 'dart:async';
import 'dart:collection';
import 'dart:html';
import 'dart:math';

part 'parts/animation.dart';
part 'parts/collection.dart';
part 'parts/controler.dart';
part 'parts/gameloop.dart';
part 'parts/domain/basics.dart';
part 'parts/domain/bomb.dart';
part 'parts/domain/level.dart';
part 'parts/domain/robot.dart';
part 'parts/domain/powerups.dart';


void main()
{
  const unitPixelSize    = 40;
  const unitWidth        = 9;
  const unitHeight       = 7;
  const border           = 9;          
  final HtmlElement appDiv = querySelector("#appId");
    
  GameLoop gameLoop = new GameLoop(appDiv, unitWidth, unitHeight, unitPixelSize, border);
  
  //to figure out keyCodes by trying
//  window.onKeyUp.listen(
//    (KeyboardEvent event){
//      DivElement div = new DivElement();
//      div.text = "keyCode: ${event.keyCode}";
//      document.body.children.add(div);
//    }
//  );  
}

