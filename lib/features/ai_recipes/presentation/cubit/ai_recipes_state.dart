import 'package:equatable/equatable.dart';
import '../../domain/entities/generated_recipe_entity.dart';
import '../../../../core/error/failures.dart';

sealed class AiRecipesState extends Equatable {
  const AiRecipesState();

  @override
  List<Object?> get props => [];
}

class AiRecipesInitial extends AiRecipesState {}

class AiRecipesLoading extends AiRecipesState {}

class AiRecipesLoaded extends AiRecipesState {
  final GeneratedRecipeEntity recipe;
  final double remainingGenerations;

  const AiRecipesLoaded({
    required this.recipe,
    required this.remainingGenerations,
  });

  @override
  List<Object?> get props => [recipe, remainingGenerations];
}

class AiRecipesError extends AiRecipesState {
  final Failure failure;

  const AiRecipesError(this.failure);

  @override
  List<Object?> get props => [failure];
}

class ApiKeyStatus extends AiRecipesState {
  final bool isSet;

  const ApiKeyStatus(this.isSet);

  @override
  List<Object?> get props => [isSet];
}