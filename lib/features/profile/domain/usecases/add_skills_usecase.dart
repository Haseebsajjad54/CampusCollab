import '../repositories/profile_repository.dart';

class AddSkillUseCase{
  late final ProfileRepository repository;

  AddSkillUseCase(this.repository);

  Future<void>addSkill(String skillName){
    return repository.addSkill(skillName);
    }
}