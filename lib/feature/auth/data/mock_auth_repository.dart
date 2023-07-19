 import 'package:injectable/injectable.dart';

import '../domain/auth_repository.dart';
import '../domain/entities/user_entity/user_entity.dart';

 @Injectable(as: AuthRepository)
 class MockAuthRepository implements AuthRepository {
   @override
   Future getProfile() {
     // TODO: implement getProfile
     throw UnimplementedError();
   }

   @override
   Future passwordUpdate(
       {required String oldPassword, required String newPassword}) {
     // TODO: implement passwordUpdate
     throw UnimplementedError();
   }

   @override
   Future refreshToken({String? refreshToken}) {
     // TODO: implement refreshToken
     throw UnimplementedError();
   }

   @override
   Future signIn({required String password, required String username}) {
     return Future.delayed(const Duration(seconds: 2), () {
       return UserEntity(
         email: "testEmail",
         username: username,
         id: "-1",
       );
     });
   }

   @override
   Future signUp({
     required String password,
     required String username,
     required String email,
   }) {
     return Future.delayed(const Duration(seconds: 2), () {
       return UserEntity(
         email: email,
         username: username,
         id: "-1",
       );
     });
   }

   @override
   Future userUpdate({String? username, String? email}) {
     // TODO: implement userUpdate
     throw UnimplementedError();
   }
 }
