import 'package:flutter/material.dart';

// int rowLength = 10;
// int columnLength = 15;

int rowLength = 10;
int columnLength = 18;

int gameSpeed = 400;

Map<Tetromino, Color> tetrominoColors = {
  Tetromino.L: Colors.red,
  Tetromino.J: Colors.green,
  Tetromino.I: Colors.amber,
  Tetromino.O: Colors.blueGrey,
  Tetromino.S: Colors.blue,
  Tetromino.Z: Colors.deepPurpleAccent,
  Tetromino.T: Colors.orange,
};

enum Tetromino { L, J, I, O, S, Z, T }

enum Direction { left, right, down }
