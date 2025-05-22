// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pokemon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Pokemon _$PokemonFromJson(Map<String, dynamic> json) => Pokemon(
      pokemonID: json['pokemonID'] as String?,
      name: json['name'] as String?,
      type: json['type'] as String?,
      type2: json['type2'] as String?,
    );

Map<String, dynamic> _$PokemonToJson(Pokemon instance) => <String, dynamic>{
      if (instance.pokemonID case final value?) 'pokemonID': value,
      if (instance.name case final value?) 'name': value,
      if (instance.type case final value?) 'type': value,
      if (instance.type2 case final value?) 'type2': value,
    };
