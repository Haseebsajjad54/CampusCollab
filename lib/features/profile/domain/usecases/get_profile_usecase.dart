import 'package:campus_collab/core/errors/failures.dart';
import 'package:campus_collab/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

import '../entities/student_profile.dart';

class GetProfileUseCase{
  late final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<Either<Failure, Profile>>getCurrentProfile(){
    return repository.getCurrentProfile();
  }


  Future<Either<Failure, Profile>>getProfileById(String userId){
    return repository.getProfileById(userId );
  }
}