// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameState _$GameStateFromJson(Map<String, dynamic> json) {
  return GameState(
    Board.fromJson(json['board'] as Map<String, dynamic>),
  )..wordsInOrderFound = (json['wordsInOrderFound'] as List<dynamic>)
      .map((e) => e as String)
      .toList();
}

Map<String, dynamic> _$GameStateToJson(GameState instance) => <String, dynamic>{
      'board': instance.board,
      'wordsInOrderFound': instance.wordsInOrderFound,
    };
