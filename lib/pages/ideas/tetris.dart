import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spectrum_chase/pages/ideas/tetris_related/piece.dart';
import 'package:spectrum_chase/pages/ideas/tetris_related/pixel.dart';
import 'package:spectrum_chase/pages/ideas/tetris_related/values.dart';

// https://www.youtube.com/watch?v=4sCSJW3hamE&list=PLlvRDpXh1Se6kipeBLiF1xByAEmxYie6J&index=8

List<List<Tetromino?>> gameBoard =
    List.generate(columnLength, (i) => List.generate(rowLength, (j) => null));

class Tetris extends StatefulWidget {
  @override
  _TetrisState createState() => _TetrisState();
}

class _TetrisState extends State<Tetris> {
  int currentScore = 0;
  bool isGameOver = false;

  /// current tetris piece ///
  Piece currentPiece = Piece(type: Tetromino.T);

  void startGame() {
    currentPiece.initializePiece();
    Duration frameRate = Duration(milliseconds: gameSpeed);
    gameLoop(frameRate);
  }

  void gameLoop(Duration frameRate) {
    Timer.periodic(frameRate, (timer) {
      setState(() {
        /// clearing the lines ///
        clearLines();

        /// check for the landing ///
        checkLanding();

        if (isGameOver) {
          timer.cancel();
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text('game over'),
                    content: Text('lost: $currentScore'),
                    actions: [
                      GestureDetector(
                        onTap: () {
                          gameBoard = List.generate(columnLength,
                              (i) => List.generate(rowLength, (j) => null));
                          isGameOver = false;
                          currentScore = 0;
                          createNewPiece();
                          startGame();
                          Navigator.pop(context);
                        },
                        child: Text('ok'),
                      )
                    ],
                  ));
        }

        /// move current piece down ///
        currentPiece.movePiece(direction: Direction.down);
      });
    });
  }

  bool checkCollision(Direction direction) {
    // loop through all direction index
    for (int i = 0; i < currentPiece.positions.length; i++) {
      // calculate the index of the current piece
      int row = (currentPiece.positions[i] / rowLength).floor();
      int col = (currentPiece.positions[i] % rowLength);

      // directions
      if (direction == Direction.down) {
        row++;
      } else if (direction == Direction.right) {
        col++;
      } else if (direction == Direction.left) {
        col--;
      }

      // check for collisions with boundaries
      if (col < 0 || col >= rowLength || row >= columnLength) {
        return true;
      }

      // check for collisions with other landed pieces
      if (row >= 0 && gameBoard[row][col] != null) {
        return true;
      }
    }
    // if there is no collision return false
    return false;
  }

  checkLanding() {
    if (checkCollision(Direction.down)) {
      for (int i = 0; i < currentPiece.positions.length; i++) {
        int row = (currentPiece.positions[i] / rowLength).floor();
        int col = currentPiece.positions[i] % rowLength;
        if (row >= 0 && col >= 0) {
          gameBoard[row][col] = currentPiece.type;
        }
      }

      /// once landed fill out new piece ///
      createNewPiece();
    }
  }

  createNewPiece() {
    /// create random tetris piece each time ///
    Random random = Random();
    Tetromino randomType =
        Tetromino.values[random.nextInt(Tetromino.values.length)];
    currentPiece = Piece(type: randomType);
    currentPiece.initializePiece();

    if (gameOver()) {
      isGameOver = true;
    }
  }

  /// movements ///
  moveLeft() {
    if (!checkCollision(Direction.left)) {
      setState(() {
        currentPiece.movePiece(direction: Direction.left);
      });
    }
  }

  moveRight() {
    if (!checkCollision(Direction.right)) {
      setState(() {
        currentPiece.movePiece(direction: Direction.right);
      });
    }
  }

  rotatePiece() {
    setState(() {
      currentPiece.rotatePiece();
    });
  }

  /// to clear lines and increment score ///
  clearLines() {
    for (int row = columnLength - 1; row >= 0; row--) {
      bool rowIsFull = true;
      for (int col = 0; col < rowLength; col++) {
        if (gameBoard[row][col] == null) {
          rowIsFull = false;
          break;
        }
      }
      if (rowIsFull) {
        for (int r = row; r > 0; r--) {
          gameBoard[r] = List.from(gameBoard[r - 1]);
        }
        gameBoard[0] = List.generate(row, (index) => null);
        currentScore++;
      }
    }
  }

  bool gameOver() {
    for (int col = 0; col < rowLength; col++) {
      if (gameBoard[0][col] != null) {
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    startGame();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.transparent,
              child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: rowLength * columnLength,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: rowLength),
                  itemBuilder: (context, index) {
                    int row = (index / rowLength).floor();
                    int col = index % rowLength;

                    if (currentPiece.positions.contains(index)) {
                      return Pixel(
                        color: tetrominoColors[currentPiece.type]!,
                        child: Container(),
                      );
                    } else if (gameBoard[row][col] != null) {
                      final Tetromino? tetroType = gameBoard[row][col];
                      return Pixel(
                        color: tetrominoColors[tetroType]!,
                        child: Container(),
                      );
                    } else {
                      return Container(
                        margin: EdgeInsets.all(3),
                        decoration: BoxDecoration( 
                          borderRadius: BorderRadius.all(
                            Radius.circular(0)
                          ),
                          border: Border.all(color: Colors.blue.withOpacity(.9))
                        ),
                      );
                    }
                  }),
            ),
          ),
          Container(
            height: 100,
            color: Colors.red,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    moveLeft();
                  },
                  child: Container(
                    child: Icon(Icons.chevron_left),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    rotatePiece();
                  },
                  child: Container(
                    child: Icon(Icons.rotate_90_degrees_ccw),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    moveRight();
                  },
                  child: Container(
                    child: Icon(Icons.chevron_right),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
