part of dartingflame;

class Robot extends GameObject implements ControlerListener {
    final PlayerConfiguration _config;
    final Level _level;
    RobotModel model;
    RobotUI _ui;

    Robot(UnitPosToPixelConverter pixelConv, this._config, this._level,
            int tileX, int tileY, ResourceLoader resourceLoader, Clock clock) {
        model = new RobotModel(
                _level,
                this,
                tileX.toDouble(),
                tileY.toDouble(),
                _config.initialBombs,
                _config.initialRange,
                clock);
        _ui =
                new RobotUI(pixelConv, model, resourceLoader, _config.playerColor);
    }

    void startRobot() {
        //connect to a controler
        _config.controler.controlerListener = this;
    }

    void explode() {
//    _ui.color="#a50";
        disconnect();
        _level.createDeadRobotAt(model._lastLoaction);
        _level.removeRobot(this);
    }
    
    void disconnect() {
      _config.controler.controlerListener = null;
    }

    Repaintable getUI() => _ui;

    int get explosionRadius => model._explosionRadius;

    void increaseExplosionRadius() {
        model._explosionRadius += 1;
    }

    void addAvailableBomb() {
        model._bombsAvailable++;
    }

    void activateMultibomb() {
        model._hasMultibomb = true;
    }

    void layBomb() {
        //create a bomb at closest position if one is available
        if (model._bombsAvailable > 0) {
            Point<double> pos = model.currentLocation;
            Point<int> tile = Tile.posToTile(pos);
            bool bombCreated =
                    _level.createBombIfPossible(tile.x, tile.y, this);
            if (bombCreated) {
                model._bombsAvailable--;
            } else {
                layMultiBomb(tile);
            }
        }
    }

    void layMultiBomb(Point<int> tile) {
        //check if robot does multibomb and is standing in the middle of a tile
        if (model._hasMultibomb && model._isNotMoving()) {
            int numberOfMultiBombs = _level.createMultiBombIfPossible(
                    tile,
                    model._bombsAvailable,
                    model.currentDirection,
                    this);
            model._bombsAvailable -= numberOfMultiBombs;
        }
    }

    @override
    void onButtonDown(ControlerButton b) {
        if (b == ControlerButton.UP) {
            model.updateDirection(Movement.UP);
        } else if (b == ControlerButton.DOWN) {
            model.updateDirection(Movement.DOWN);
        } else if (b == ControlerButton.LEFT) {
            model.updateDirection(Movement.LEFT);
        } else if (b == ControlerButton.RIGHT) {
            model.updateDirection(Movement.RIGHT);
        } else if (b == ControlerButton.A) {
            layBomb();
        }
    }

    @override
    void onButtonUp(ControlerButton b) {
        model.updateDirection(Movement.NONE);
    }

    /**
   * return a list of one or two tiles the robot current stands on.
   * It's one tile if the robot is resting at the center of one, 
   * two if it's in transit from one to the next.
   */
    List<Point<int>> getOccupiedTiles() {
        Point<double> pos = model.currentLocation;
        int tileX1 = pos.x.floor();
        int tileY1 = pos.y.floor();
        int tileX2 = pos.x.ceil();
        int tileY2 = pos.y.ceil();

        if (tileX1 == tileX2 && tileY1 == tileY2) {
            return [new Point<int>(tileX1, tileY1)];
        } else {
            return [
                    new Point<int>(tileX1, tileY1),
                    new Point<int>(tileX2, tileY2)];
        }
    }
}

class RobotModel {
    static const double _unitsPerSecond = 4.34;
    final Level _level;
    final Robot _robot;
    final Clock _clock;
    int _bombsAvailable;
    int _explosionRadius;
    bool _hasMultibomb;
    double _lastTimeInMillies;
    Direction latestDirection;
    Movement currentMovement;
    Movement _nextMovement;
    Point<double> _lastLoaction;

    RobotModel(this._level, this._robot, double initialX, double initialY,
            this._bombsAvailable, this._explosionRadius, this._clock)
            : _lastLoaction = new Point(initialX, initialY) {
        _lastTimeInMillies = _clock();
        _hasMultibomb = false;
        latestDirection = Direction.UP;
        currentMovement = Movement.NONE;
        _nextMovement = Movement.NONE;
    }
    
    Direction get currentDirection {
      if(currentMovement==null || currentMovement==Movement.NONE) {
        return latestDirection;
      }
      return Direction.fromMovement(currentMovement);
    }

    Point<double> get currentLocation {
        assert(_lastTimeInMillies != null);
        assert(currentMovement != null);
        assert(_lastLoaction != null);

        //compute the difference to last location computation, update the last time we checked to now
        double nowMillies = _clock();
        double deltaMillies = nowMillies - _lastTimeInMillies;
        _lastTimeInMillies = nowMillies;

        if (currentMovement != Movement.NONE) {
            //and compute how far you came
            double deltaDistance = (_unitsPerSecond * deltaMillies) / 1000;
            _lastLoaction =
                    _moveIfPossible(_lastLoaction, deltaDistance, currentMovement);
        }

        return _lastLoaction;
    }

    void updateDirection(Movement newMovement) {
        assert(newMovement != null);
        assert(currentMovement != null);
        assert(_nextMovement != null);

        //update direction implicitly in call to currentLocation
        Point<double> currentPos = currentLocation;

        if (_inTransit(currentPos)) {
            //if the robot is between tiles he can only reverse his direction
            if (newMovement.hasSameAxis(currentMovement)) {
                currentMovement = newMovement;
                _nextMovement = newMovement;
                //else use that direction after you hit a tile
            } else {
                _nextMovement = newMovement;
            }
            //else you can go in any direction
        } else {
          currentMovement = newMovement;
            _nextMovement = newMovement;
        }
        if(newMovement!=Movement.NONE) {
          latestDirection = Direction.fromMovement(newMovement);
        }
    }

    Point<double> _moveIfPossible(Point<double> from, double distance,
            Movement direction) {
        //assert the robot didn't move more than MAX_DISTANCE units because
        //that would mess with the logic. should only be neccessary to


                //reset the distance value if the repaint-Loop calls currentLocatin way to rarely
        //or in debug mode!
        const double MAX_DISTANCE =
                .99; //must be smaller than 1 else i could jump over tiles
        if (distance >= MAX_DISTANCE) distance = MAX_DISTANCE;

        assert(from != null);
        assert(direction != null);

        Point<double> getEndPoint(Point<double> from, double distance,
                Movement direction) {
            double newY = from.y;
            double newX = from.x;

            if (direction == Movement.UP) {
                newY = from.y - distance;
            }
            if (direction == Movement.DOWN) {
                newY = from.y + distance;
            }
            if (direction == Movement.LEFT) {
                newX = from.x - distance;
            }
            if (direction == Movement.RIGHT) {
                newX = from.x + distance;
            }
            return new Point<double>(newX, newY);
        }

        Point<double> getEndTilePos(Point<double> fromPos,
                double distanceToTile, Movement direction) {
            Point<double> toPos =
                    getEndPoint(fromPos, distanceToTile, direction);


                    //toPos.x/y should be perfect int values but numerics could fail so round manually
            return new Point<double>(
                    toPos.x.roundToDouble(),
                    toPos.y.roundToDouble());
        }

        Point<double> moveIfPossibleFromTile(Point<double> fromTile,
                double distance, Movement direction) {
            Point<int> getEndTile(Point<double> fromTile, Movement direction) {
                Point<double> toTilePos =
                        getEndTilePos(fromTile, 1.0, direction);
                //x and y can perfectly be converted to ints
                return Tile.posToTile(toTilePos);
            }

            //improbable but not impossible
            if (distance == .0) {
                return fromTile;
            }

            Point<int> toTile = getEndTile(fromTile, direction);
            if (_level.isFree(toTile.x, toTile.y)) {
                //inform the level that the robot is entering a tile
                _level.robotEntersTile(_robot, toTile.x, toTile.y);
                return getEndPoint(fromTile, distance, direction);
            } else {
                currentMovement = Movement.NONE;
                _nextMovement = Movement.NONE;
                return fromTile;
            }
        }

        Point<double> moveFromTransientPosition(Point<double> transientPoint,
                double distance, Movement direction) {
            double distanceToNewTilePos(Point<double> fromPos,
                    Movement direction) {
                if (direction == Movement.UP) {
                    return fromPos.y - fromPos.y.floorToDouble();
                }
                if (direction == Movement.DOWN) {
                    return fromPos.y.ceilToDouble() - fromPos.y;
                }
                if (direction == Movement.LEFT) {
                    return fromPos.x - fromPos.x.floorToDouble();
                }
                if (direction == Movement.RIGHT) {
                    return fromPos.x.ceilToDouble() - fromPos.x;
                }
                throw new StateError(
                        "no valid direction:${direction==null?'null':direction.name}");
            }

            final distanceToNewTile =
                    distanceToNewTilePos(transientPoint, direction);
            if (distance < distanceToNewTile) {
                return getEndPoint(transientPoint, distance, direction);
            } else {


                        //go to tile than give over to moveIfPossibleFromTile(..) with restDistance
                Point<double> toTile =
                        getEndTilePos(transientPoint, distanceToNewTile, direction);
                //walk in new Direction the remaining distance
                currentMovement = _nextMovement;
                double newDistance = distance - distanceToNewTile;
                return moveIfPossibleFromTile(
                        toTile,
                        newDistance,
                        _nextMovement);
            }
        }


        if (_inTransit(from)) {
            return moveFromTransientPosition(from, distance, direction);
        } else {
            return moveIfPossibleFromTile(from, distance, direction);
        }
    }

    bool _inTransit(Point<double> pos) {
        bool isNaturalNum(double d) => d.roundToDouble() == d;
        return !(isNaturalNum(pos.x) && isNaturalNum(pos.y));
    }

    bool _isNotMoving() => currentMovement == Movement.NONE;
}

class RobotUI extends Repaintable {
    final RobotModel _model;
    final Map<Direction, CanvasImageSource> _robotTemplateByDirection;
    final UnitPosToPixelConverter _pixelConv;

    RobotUI(this._pixelConv, this._model, ResourceLoader resourceLoader,
            String playerColor)
            : this._robotTemplateByDirection = resourceLoader.robotTemplates(
                    playerColor);

    @override
    void repaint(CanvasRenderingContext2D context2D, int unitPixelSize) {
        final Point<double> robotPos = _model.currentLocation;
        final Point<int> offset =
                _pixelConv.getPixelOffsetFromPos(robotPos.x, robotPos.y);
        final CanvasImageSource robotTemplate =
                _robotTemplateByDirection[_model.currentDirection];

        context2D.drawImage(robotTemplate, offset.x, offset.y);
    }
}

class DeadRobot extends RepaintableUnmovableGameObject with Timed {
    static const int MILLIES_TO_LIVE = 200;
    final Level _level;

    DeadRobot(this._level, int offsetX, int offsetY,
            ResourceLoader resourceLoader)
            : super(offsetX, offsetY, resourceLoader.deadRobotTemplate) {
        startTimer(MILLIES_TO_LIVE, _fadeOut);
    }

    void _fadeOut() {
        _level.remove(this);
    }

    @override
    void repaint(CanvasRenderingContext2D context2D, int unitPixelSize) {
        //tick tock
        _tickTock();

        super.repaint(context2D, unitPixelSize);
    }
}

class Movement {
    final int _orientationIndex;
    final String _name;

    static final UP = new Movement._("UP", 1);
    static final DOWN = new Movement._("DOWN", 1);
    static final LEFT = new Movement._("LEFT", 2);
    static final RIGHT = new Movement._("RIGHT", 2);
    static final NONE = new Movement._("NONE", 0);

    Movement._(this._name, this._orientationIndex);



            /**@returns true if this and other are either the same or working in opposite directions*/
    bool hasSameAxis(Movement other) {
        return this._orientationIndex == other._orientationIndex;
    }

    @override
    String toString() => "Movement.$_name";

    String get name => _name;
}
