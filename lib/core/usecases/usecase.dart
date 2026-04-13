import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// Базовый интерфейс для Use Case
/// [Type] - тип возвращаемого значения
/// [Params] - тип параметров
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Класс для Use Case без параметров
class NoParams {
  const NoParams();
}
