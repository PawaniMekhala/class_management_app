import '../../models/user_profile_model.dart';

class ProfileService {
  UserProfileModel _demoProfile = const UserProfileModel(
    id: 1,
    name: 'Kamala Jayasinghe',
    role: 'institute_admin',
    username: 'admin@sipsala.demo.ims.lk',
    email: 'admin@sipsala.demo.ims.lk',
    mobile: '0771000002',
    instituteName: 'Sipsala Institute - Gampaha (SIPGAM)',
    googleEmail: 'miraclesoft.lk@gmail.com',
    photoUrl: 'https://example.com/photo.jpg',
  );

  Future<UserProfileModel> getProfile() async {
    // TO DO: GET /api/me/profile
    // Use the authenticated user's token.
    return _demoProfile;
  }

  Future<UserProfileModel> updatePhoto(String filePath) async {
    // TO DO: Upload image using multipart/form-data.
    // Example: PUT /api/me/profile/photo
    //
    // The backend should return the updated profile
    // with the permanent image URL.

    _demoProfile = _demoProfile.copyWith(photoUrl: filePath);
    return _demoProfile;
  }

  Future<UserProfileModel> removePhoto() async {
    // TO DO: DELETE /api/me/profile/photo
    // The backend must reject removal for students.

    _demoProfile = _demoProfile.copyWith(photoUrl: '');
    return _demoProfile;
  }

  Future<void> requestStudentPhotoChange(String filePath) async {
    // TO DO: POST /api/me/profile/photo-requests
    //
    // Upload the proposed photo for admin approval.
    // Do NOT change the current profile photo here.
  }
}
