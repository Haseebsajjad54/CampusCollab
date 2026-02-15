import 'package:campus_collab/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/student_profile.dart';

class UpdateProfileUseCase{
  late final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, Profile>> updateProfile(Profile profile){
    return repository.updateProfile(profile);
  }
}



