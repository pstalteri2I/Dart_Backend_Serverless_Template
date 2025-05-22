// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pokemon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pokemon _$PokemonFromJson(Map<String, dynamic> json) => Pokemon(
      pokemonID: json['pokemonID'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      type2: json['type2'] as String?,
    );

Map<String, dynamic> _$PokemonToJson(Pokemon instance) => <String, dynamic>{
      'pokemonID': instance.pokemonID,
      'name': instance.name,
      'type': instance.type,
      if (instance.type2 case final value?) 'type2': value,
    };
