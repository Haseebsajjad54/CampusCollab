import 'dart:io';

import 'package:campus_collab/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';

class UploadProfilePictureUseCase{
  late final ProfileRepository repository;
  UploadProfilePictureUseCase(this.repository);

  Future<Either<Failure, String>> call(File image ){
    return repository.uploadProfilePicture(image);
  }
}