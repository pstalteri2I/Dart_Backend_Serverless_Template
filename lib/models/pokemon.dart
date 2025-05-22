import 'package:json_annotation/json_annotation.dart';

part 'pokemon.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class Pokemon {
  String? pokemonID;
  String? name;
  String? type;
  String? type2;

  Pokemon({
    this.pokemonID,
    this.name,
    this.type,
    this.type2,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) =>
      _$PokemonFromJson(json);

  Map<String, dynamic> toJson() => _$PokemonToJson(this);
}
