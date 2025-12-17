import 'package:flutter/material.dart';
import 'package:demo/models/game_models.dart';
import 'package:demo/services/game_service.dart';
class GameBoardScreen extends StatefulWidget {
  final Player player1;
  final Player player2;

  const GameBoardScreen({
    Key? key,
    required this.player1,
    required this.player2,
  }) : super(key: key);