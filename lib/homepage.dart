import 'dart:async';

import 'package:bubbletrouble/ball.dart';
import 'package:bubbletrouble/button.dart';
import 'package:bubbletrouble/missile.dart';
import 'package:bubbletrouble/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

enum direction { LEFT, RIGHT }

class _HomePageState extends State<HomePage> {
  // player variables
  static double playerX = 0;

  //missile variables
  double missileX = playerX;
  double missileHeight = 10;
  bool midShot = false;

  //ball variables
  double ballX = 0.5;
  double ballY = 1;
  var ballDirection = direction.LEFT;

  void startGame() {

    double time = 0;
    double height = 0;
    double velocity = 50;

    Timer.periodic(Duration(milliseconds: 15), (timer) {
    //quadratic equetion that models a bounce(upside donw parabola)
    height = -5 * time * time + velocity * time;

    // if the ball hits the ground reset the jump
    if (height < 0) {
      time = 0;
    }

    setState(() {
      ballY = heightToPosition(height);
    });

  
    // move the ball right after hitting the left wall
      if (ballX - 0.005 < -1) {
        ballDirection = direction.RIGHT;
    // // move the ball right after hitting the left wall
      } else if (ballX + 0.005 > 1) {
        ballDirection = direction.LEFT;
      }
    //   // actually change direction
      if (ballDirection == direction.LEFT) {
        setState(() {
          ballX -= 0.005;
        });
      } else if (ballDirection == direction.RIGHT) {
        setState(() {
          ballX += 0.005;
        });
      }

      // check if ball hit player
      if (playerDies()) {
        timer.cancel();
        _showDialog();
      }

      // stop the timer
      time += 0.1;

    });
  }

  //show dialog
  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.grey[700],
        title: Center
        (child: Text("Y O U  D I E D", style: TextStyle(color: Colors.white),)),
      );
    });
  }

  void moveLeft() {
    setState(() {
      if (playerX - 0.1 < -1) {
        // do jack shit
      } else {
        playerX -= 0.1;
      }

      if (!midShot) {
        missileX = playerX;
      }
    });
  }

  void moveRight() {
    setState(() {
      if (playerX + 0.1 > 1) {
        // do jack shit
      } else {
        playerX += 0.1;
      }

      if (!midShot) {
        missileX = playerX;
      }
    });
  }

  void fireMissile() {
    if (midShot == false) {
      Timer.periodic(Duration(milliseconds: 20), (timer) {
        //shot fired
        midShot = true;

        // missile grows until it hits the top of the screen
        setState(() {
          missileHeight += 10;
        });

        // stops missile when at the top of the screen
        if (missileHeight > MediaQuery.of(context).size.height + 3 / 4) {
          resetMissile();
          timer.cancel();
          
        } 

        // check if missile hit the ball
        if (ballY > heightToPosition(missileHeight) && (ballX - missileX).abs() < 0.03) {
          resetMissile();
          ballX = 5;
          timer.cancel();
        }
      });
    }
  }

  // converts height to a position
  double heightToPosition(double height) {
    double totalHeight = MediaQuery.of(context).size.height * 3 / 4;
    double position = 1 - 2 * height / totalHeight;
    return position;
  }

  void resetMissile() {
    missileX = playerX;
    missileHeight = 10;
    midShot = false;
  }

  bool playerDies() {
    // if the ball position and the player position are the same the player dies
    if ((ballX - playerX).abs() < 0.12 && ballY > 0.85) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (event.isKeyPressed(LogicalKeyboardKey.arrowLeft)) {
          moveLeft();
        } else if (event.isKeyPressed(LogicalKeyboardKey.arrowRight)) {
          moveRight();
        }

        if (event.isKeyPressed(LogicalKeyboardKey.space)) {
          fireMissile();
        }
      },
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.pink[100],
              child: Container(
                child: Center(
                  child: Stack(
                    children: [
                      MyBall(
                        ballX: ballX, 
                        ballY: ballY),
                      MyMissile(
                        height: missileHeight,
                        missileX: missileX,
                      ),
                      MyPlayer(
                        playerX: playerX,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MyButton(
                    icon: Icons.play_arrow,
                    function: startGame,
                  ),
                  MyButton(
                    icon: Icons.arrow_back,
                    function: moveLeft,
                  ),
                  MyButton(
                    icon: Icons.arrow_upward,
                    function: fireMissile,
                  ),
                  MyButton(
                    icon: Icons.arrow_forward,
                    function: moveRight,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
