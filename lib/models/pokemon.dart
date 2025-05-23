import 'package:json_annotation/json_annotation.dart';

part 'pokemon.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Pokemon {
  String pokemonID;
  String name;
  String type;
  String type2;
  String? imageUrl;

  Pokemon({
    required this.pokemonID,
    required this.name,
    required this.type,
    required this.type2,
    this.imageUrl,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) =>
      _$PokemonFromJson(json);

  Map<String, dynamic> toJson() => _$PokemonToJson(this);
}
