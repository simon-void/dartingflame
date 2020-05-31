part of dartingflame;

void _showGlossary(HtmlElement glossaryDiv, ResourceLoader resourceLoader, BaseConfiguration baseConfig)
{
  TableElement table = new TableElement();
  _getGlossary(resourceLoader, baseConfig.tilePixelSize).forEach(
    (GlossaryItem item)=>table.children.add(item.tableRow)
  );
  
  bool isGlossaryVisible = true;
  var buttonText = ["close glossary", "open glossary"];
  ButtonElement toggleVisibilityButton = new ButtonElement();
    toggleVisibilityButton.text = buttonText[0];
    toggleVisibilityButton.onClick.listen(
      (e) {
        if(isGlossaryVisible) {
          table.style.display         = "none";
          toggleVisibilityButton.text = buttonText[1];
          
        }else{
          table.style.display         = "inline";
          toggleVisibilityButton.text = buttonText[0];
        }
        isGlossaryVisible = !isGlossaryVisible;
      }
  );
  
  glossaryDiv..style.width="${baseConfig.totalPixelWidth}px"
             ..children.add(toggleVisibilityButton)
             ..children.add(table);
}

class GlossaryItem{
  final CanvasElement canvas;
  final String name;
  final String description;
  
  GlossaryItem(this.canvas, this.name, this.description);
  
  TableRowElement get tableRow {
    TableCellElement cellWithText(String text) {
      var cell = new TableCellElement();
      cell.text = text;
      return cell;
    }
    TableRowElement row = new TableRowElement();
    TableCellElement imgCell  = new TableCellElement();
    imgCell.children.add(canvas);
    
    row.children..add(imgCell)
                ..add(cellWithText(name))
                ..add(cellWithText(description));
    
    return row;
  }
}

Iterable<GlossaryItem> _getGlossary(ResourceLoader resourceLoader, int tilePixelSize)
{
  CanvasElement paintOnCanvas(CanvasImageSource img) {
    CanvasElement canvas = new CanvasElement(width: tilePixelSize, height: tilePixelSize);
    canvas.context2D.drawImage(img, 0, 0);
    return canvas;
  }
  CanvasElement getRobotCanvas(String playerColor) {
    CanvasImageSource robotImg = resourceLoader.robotTemplates(playerColor)[Direction.UP];
    return paintOnCanvas(robotImg);
  }
  
  var playerColors = PlayerConfiguration.defaultPlayerColors;
  return [
    new GlossaryItem(getRobotCanvas(playerColors[0]), "player1", "use wasd and space"),
    new GlossaryItem(getRobotCanvas(playerColors[1]), "player2", "use arrows and enter"),
    new GlossaryItem(paintOnCanvas(resourceLoader.rangeUpgradeTemplate), "range powerup", "the range of explosions is increased by one"),
    new GlossaryItem(paintOnCanvas(resourceLoader.bombUpgradeTemplate), "bomb powerup", "the player is able to lay one bomb more (initially you can lay two)"),
    new GlossaryItem(paintOnCanvas(resourceLoader.multibombUpgradeTemplate), "multibomb powerup", "doubleclick lays all the players bombs in a row")
          ];
}