import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart' as dabase;
import 'package:flutter/foundation.dart';
import 'package:rebeal/helper/enum.dart';
import 'package:rebeal/helper/utility.dart';
import 'package:rebeal/model/user.module.dart';

class ProfileState extends ChangeNotifier {
  ProfileState(this.profileId) {
    databaseInit();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      _getloggedInUserProfile(userId);
      _getProfileUser(profileId);
    } else {
      print("Error: User is not authenticated.");
    }
  }

  String? userId;

  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  dabase.Query? _profileQuery;
  StreamSubscription<DatabaseEvent>? profileSubscription;

  final String profileId;

  UserModel? _profileUserModel;
  UserModel? get profileUserModel => _profileUserModel;

  bool _isBusy = true;
  bool get isbusy => _isBusy;
  set loading(bool value) {
    _isBusy = value;
    notifyListeners();
  }

  databaseInit() {
    try {
      if (_profileQuery == null) {
        _profileQuery = kDatabase.child("profile").child(profileId);
        if (_profileQuery != null) {
          profileSubscription = _profileQuery!.onValue.listen(_onProfileChanged);
        }
      }
    } catch (error) {
      print("Error in databaseInit: $error");
    }
  }

  bool get isMyProfile => profileId == userId;

  void _getloggedInUserProfile(String? userId) {
    if (userId == null) return;
    try {
      kDatabase.child("profile").child(userId).once().then((DatabaseEvent event) {
        final snapshot = event.snapshot;
        if (snapshot.value != null) {
          var map = snapshot.value as Map<dynamic, dynamic>?;
          if (map != null) {
            _userModel = UserModel.fromJson(map);
          }
        }
      });
    } catch (error) {
      print("Error in _getloggedInUserProfile: $error");
    }
  }

  void _getProfileUser(String? userProfileId) {
    if (userProfileId == null) return;
    try {
      loading = true;
      kDatabase.child("profile").child(userProfileId).once().then((DatabaseEvent event) {
        final snapshot = event.snapshot;
        if (snapshot.value != null) {
          var map = snapshot.value as Map;
          _profileUserModel = UserModel.fromJson(map);
        }
        loading = false;
      });
    } catch (error) {
      print("Error in _getProfileUser: $error");
      loading = false;
    }
  }

  followUser({bool removeFollower = false}) {
    try {
        if (userModel?.userId != null && profileUserModel?.userId != null) {
            List<String>? followers = profileUserModel?.followersList ?? [];
            List<String>? following = userModel?.followingList ?? [];

            if (removeFollower) {
                followers.remove(userModel!.userId);
                following.remove(profileUserModel!.userId);
            } else {
                followers.add(userModel!.userId!);
                following.add(profileUserModel!.userId!);
                addFollowNotification();
            }

            kDatabase.child('profile')
                .child(profileUserModel!.userId!)
                .child('followerList')
                .set({"key": following, "accept": false});

            kDatabase.child('profile')
                .child(userModel!.userId!)
                .child('followingList')
                .set({"key": following, "accept": false});

            notifyListeners();
        }
    } catch (error) {
        print("Error in followUser: $error");
    }
  }

  void addFollowNotification() {
    kDatabase.child('notification').child(profileId).child(userId!).set({
      'type': NotificationType.Follow.toString(),
      'createdAt': DateTime.now().toUtc().toString(),
      'data': UserModel(
              displayName: userModel!.displayName,
              profilePic: userModel!.profilePic,
              userId: userModel!.userId,
              bio: userModel!.bio == "Edit profile to update bio"
                  ? ""
                  : userModel!.bio,
              userName: userModel!.userName)
          .toJson()
    });
  }

  void _onProfileChanged(DatabaseEvent event) {
    final updatedUser = UserModel.fromJson(event.snapshot.value as Map);
    if (updatedUser.userId == profileId) {
      _profileUserModel = updatedUser;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _profileQuery?.onValue.drain();
    profileSubscription?.cancel();
    super.dispose();
  }
}

