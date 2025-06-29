// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/user.dart';

// class SimpleStorageService {
//   // In-memory storage as fallback
//   static List<User> _users = [];
//   static User? _currentUser;
//   static bool _isLoggedIn = false;

//   // Keys for SharedPreferences
//   static const String _usersKey = 'registered_users';
//   static const String _currentUserKey = 'current_user';
//   static const String _isLoggedInKey = 'is_logged_in';

//   // Try to use SharedPreferences, fallback to memory
//   static Future<bool> _canUseStorage() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('test', 'test');
//       await prefs.remove('test');
//       return true;
//     } catch (e) {
//       print('SharedPreferences not available, using memory storage');
//       return false;
//     }
//   }

//   // Initialize storage - load existing data
//   static Future<void> initialize() async {
//     try {
//       if (await _canUseStorage()) {
//         final prefs = await SharedPreferences.getInstance();

//         // Load users
//         List<String> userStrings = prefs.getStringList(_usersKey) ?? [];
//         _users =
//             userStrings.map((str) => User.fromJson(jsonDecode(str))).toList();

//         // Load current user
//         String? currentUserString = prefs.getString(_currentUserKey);
//         if (currentUserString != null) {
//           _currentUser = User.fromJson(jsonDecode(currentUserString));
//         }

//         // Load login status
//         _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

//         print('Storage initialized: ${_users.length} users loaded');
//       }
//     } catch (e) {
//       print('Error initializing storage: $e');
//     }
//   }

//   // Register user
//   static Future<void> registerUser(User user) async {
//     try {
//       // Check if email already exists
//       bool emailExists = await _emailExists(user.email);
//       if (emailExists) {
//         throw Exception('ອີເມວນີ້ໄດ້ຖືກລົງທະບຽນແລ້ວ');
//       }

//       // Check if username already exists
//       bool usernameExists = await _usernameExists(user.username);
//       if (usernameExists) {
//         throw Exception('ຊື່ຜູ້ໃຊ້ນີ້ໄດ້ຖືກໃຊ້ແລ້ວ');
//       }

//       // Add to memory
//       _users.add(user);

//       // Save to SharedPreferences if available
//       if (await _canUseStorage()) {
//         final prefs = await SharedPreferences.getInstance();
//         List<String> userStrings =
//             _users.map((u) => jsonEncode(u.toJson())).toList();
//         await prefs.setStringList(_usersKey, userStrings);
//       }

//       print('User registered: ${user.email}');
//     } catch (e) {
//       print('Registration error: $e');
//       rethrow;
//     }
//   }

//   // Login user (supports email or username)
//   static Future<User?> login(String emailOrUsername, String password) async {
//     try {
//       // Ensure data is loaded
//       await initialize();

//       // Find user by email or username
//       for (User user in _users) {
//         bool isEmailMatch =
//             user.email.toLowerCase() == emailOrUsername.toLowerCase();
//         bool isUsernameMatch =
//             user.username.toLowerCase() == emailOrUsername.toLowerCase();

//         if ((isEmailMatch || isUsernameMatch) && user.password == password) {
//           await _saveCurrentUser(user);
//           return user;
//         }
//       }

//       throw Exception('ອີເມວ ຫຼື ລະຫັດຜ່ານບໍ່ຖືກຕ້ອງ');
//     } catch (e) {
//       print('Login error: $e');
//       rethrow;
//     }
//   }

//   // Reset password
//   static Future<void> resetPassword(String email, String newPassword) async {
//     try {
//       await initialize();

//       // Find user by email
//       User? targetUser;
//       int userIndex = -1;

//       for (int i = 0; i < _users.length; i++) {
//         if (_users[i].email.toLowerCase() == email.toLowerCase()) {
//           targetUser = _users[i];
//           userIndex = i;
//           break;
//         }
//       }

//       if (targetUser == null) {
//         throw Exception('ບໍ່ພົບອີເມວນີ້ໃນລະບົບ');
//       }

//       // Update password
//       User updatedUser = User(
//         username: targetUser.username,
//         email: targetUser.email,
//         password: newPassword,
//       );

//       _users[userIndex] = updatedUser;

//       // Update current user if it's the same user
//       if (_currentUser?.email.toLowerCase() == email.toLowerCase()) {
//         _currentUser = updatedUser;
//       }

//       // Save to SharedPreferences if available
//       if (await _canUseStorage()) {
//         final prefs = await SharedPreferences.getInstance();
//         List<String> userStrings =
//             _users.map((u) => jsonEncode(u.toJson())).toList();
//         await prefs.setStringList(_usersKey, userStrings);

//         // Update current user in storage if needed
//         if (_currentUser?.email.toLowerCase() == email.toLowerCase()) {
//           await prefs.setString(
//               _currentUserKey, jsonEncode(_currentUser!.toJson()));
//         }
//       }

//       print('Password reset for: $email');
//     } catch (e) {
//       print('Password reset error: $e');
//       rethrow;
//     }
//   }

//   // Find user by email (for forgot password)
//   static Future<User?> findUserByEmail(String email) async {
//     try {
//       await initialize();

//       for (User user in _users) {
//         if (user.email.toLowerCase() == email.toLowerCase()) {
//           return user;
//         }
//       }
//       return null;
//     } catch (e) {
//       print('Error finding user by email: $e');
//       return null;
//     }
//   }

//   // Save current user
//   static Future<void> _saveCurrentUser(User user) async {
//     try {
//       _currentUser = user;
//       _isLoggedIn = true;

//       if (await _canUseStorage()) {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
//         await prefs.setBool(_isLoggedInKey, true);
//       }
//     } catch (e) {
//       print('Error saving current user: $e');
//     }
//   }

//   // Get current user
//   static Future<User?> getCurrentUser() async {
//     try {
//       if (_currentUser != null) return _currentUser;

//       await initialize();
//       return _currentUser;
//     } catch (e) {
//       print('Error getting current user: $e');
//       return null;
//     }
//   }

//   // Check if logged in
//   static Future<bool> isLoggedIn() async {
//     try {
//       await initialize();
//       return _isLoggedIn;
//     } catch (e) {
//       print('Error checking login status: $e');
//       return false;
//     }
//   }

//   // Check if email exists
//   static Future<bool> _emailExists(String email) async {
//     try {
//       await initialize();
//       return _users
//           .any((user) => user.email.toLowerCase() == email.toLowerCase());
//     } catch (e) {
//       print('Error checking email: $e');
//       return false;
//     }
//   }

//   // Check if username exists
//   static Future<bool> _usernameExists(String username) async {
//     try {
//       await initialize();
//       return _users
//           .any((user) => user.username.toLowerCase() == username.toLowerCase());
//     } catch (e) {
//       print('Error checking username: $e');
//       return false;
//     }
//   }

//   // Public method to check if email exists (for UI)
//   static Future<bool> emailExists(String email) async {
//     return await _emailExists(email);
//   }

//   // Public method to check if username exists (for UI)
//   static Future<bool> usernameExists(String username) async {
//     return await _usernameExists(username);
//   }

//   // Logout
//   static Future<void> logout() async {
//     try {
//       _currentUser = null;
//       _isLoggedIn = false;

//       if (await _canUseStorage()) {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.remove(_currentUserKey);
//         await prefs.setBool(_isLoggedInKey, false);
//       }
//     } catch (e) {
//       print('Error during logout: $e');
//     }
//   }

//   // Update user
//   static Future<void> updateUser(User user) async {
//     try {
//       await _saveCurrentUser(user);

//       // Update in memory
//       for (int i = 0; i < _users.length; i++) {
//         if (_users[i].email.toLowerCase() == user.email.toLowerCase()) {
//           _users[i] = user;
//           break;
//         }
//       }

//       // Save to SharedPreferences if available
//       if (await _canUseStorage()) {
//         final prefs = await SharedPreferences.getInstance();
//         List<String> userStrings =
//             _users.map((u) => jsonEncode(u.toJson())).toList();
//         await prefs.setStringList(_usersKey, userStrings);
//       }
//     } catch (e) {
//       print('Error updating user: $e');
//       rethrow;
//     }
//   }

//   // Clear all data
//   static Future<void> clearAllData() async {
//     try {
//       _users.clear();
//       _currentUser = null;
//       _isLoggedIn = false;

//       if (await _canUseStorage()) {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.clear();
//       }

//       print('All data cleared');
//     } catch (e) {
//       print('Error clearing data: $e');
//     }
//   }

//   // Get debug info
//   static Future<Map<String, dynamic>> getDebugInfo() async {
//     try {
//       await initialize();

//       Map<String, dynamic> info = {
//         'memory_users': _users.length,
//         'current_user': _currentUser?.email ?? 'None',
//         'is_logged_in': _isLoggedIn,
//         'storage_available': await _canUseStorage(),
//       };

//       if (await _canUseStorage()) {
//         final prefs = await SharedPreferences.getInstance();
//         info['storage_users'] = (prefs.getStringList(_usersKey) ?? []).length;
//         info['storage_keys'] = prefs.getKeys().toList();
//       }

//       return info;
//     } catch (e) {
//       return {'error': e.toString()};
//     }
//   }
// }



import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class SimpleStorageService {
  // In-memory storage as primary storage
  static List<User> _users = [];
  static User? _currentUser;
  static bool _isLoggedIn = false;
  static bool _isInitialized = false;

  // Keys for SharedPreferences
  static const String _usersKey = 'registered_users';
  static const String _currentUserKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

  // Initialize storage - load existing data (ປັບປຸງໃຫ້ດີກວ່າ)
  static Future<void> initialize() async {
    if (_isInitialized) return; // ບໍ່ໃຫ້ initialize ຊ້ຳ

    try {
      print('Initializing storage...');
      final prefs = await SharedPreferences.getInstance();

      // Load users ຈາກ SharedPreferences
      List<String>? userStrings = prefs.getStringList(_usersKey);
      if (userStrings != null && userStrings.isNotEmpty) {
        _users = [];
        for (String str in userStrings) {
          try {
            Map<String, dynamic> userJson = jsonDecode(str);
            User user = User.fromJson(userJson);
            _users.add(user);
            print('Loaded user: ${user.email} (password: ${user.password})');
          } catch (e) {
            print('Error parsing user data: $e');
            print('Problematic user string: $str');
          }
        }
      }

      // Load current user
      String? currentUserString = prefs.getString(_currentUserKey);
      if (currentUserString != null && currentUserString.isNotEmpty) {
        try {
          Map<String, dynamic> userJson = jsonDecode(currentUserString);
          _currentUser = User.fromJson(userJson);
          print('Loaded current user: ${_currentUser?.email}');
        } catch (e) {
          print('Error parsing current user: $e');
          _currentUser = null;
          await prefs.remove(_currentUserKey);
        }
      }

      // Load login status
      _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

      // ຖ້າມີ current user ແຕ່ບໍ່ໄດ້ login ໃຫ້ລົບ current user ອອກ
      if (_currentUser != null && !_isLoggedIn) {
        _currentUser = null;
        await prefs.remove(_currentUserKey);
      }

      _isInitialized = true;
      print(
          'Storage initialized successfully: ${_users.length} users loaded, logged in: $_isLoggedIn');

      // Debug: ສະແດງຂໍ້ມູນທຸກຜູ້ໃຊ້
      for (int i = 0; i < _users.length; i++) {
        User user = _users[i];
        print(
            'User $i: ${user.email} / ${user.username} (password: ${user.password})');
      }
    } catch (e) {
      print('Error initializing storage: $e');
      // ໃຊ້ default values ຖ້າມີຂໍ້ຜິດພາດ
      _users = [];
      _currentUser = null;
      _isLoggedIn = false;
      _isInitialized = true;
    }
  }

  // ບັນທຶກຜູ້ໃຊ້ລົງ SharedPreferences
  static Future<void> _saveUsersToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> userStrings =
          _users.map((u) => jsonEncode(u.toJson())).toList();
      await prefs.setStringList(_usersKey, userStrings);
      print('Users saved to storage: ${_users.length} users');

      // Debug: ສະແດງຂໍ້ມູນທີ່ບັນທຶກ
      for (int i = 0; i < _users.length; i++) {
        print(
            'Saved user $i: ${_users[i].email} (password: ${_users[i].password})');
      }
    } catch (e) {
      print('Error saving users to storage: $e');
    }
  }

  // Register user (ປັບປຸງແລ້ວ)
  static Future<void> registerUser(User user) async {
    await initialize(); // ໃຫ້ແນ່ໃຈວ່າ initialized ແລ້ວ

    try {
      print('Registering user: ${user.email} with password: ${user.password}');

      // ກວດສອບວ່າ email ມີແລ້ວບໍ
      bool emailExists =
          _users.any((u) => u.email.toLowerCase() == user.email.toLowerCase());
      if (emailExists) {
        throw Exception('ອີເມວນີ້ໄດ້ຖືກລົງທະບຽນແລ້ວ');
      }

      // ກວດສອບວ່າ username ມີແລ້ວບໍ
      bool usernameExists = _users
          .any((u) => u.username.toLowerCase() == user.username.toLowerCase());
      if (usernameExists) {
        throw Exception('ຊື່ຜູ້ໃຊ້ນີ້ໄດ້ຖືກໃຊ້ແລ້ວ');
      }

      // ເພີ່ມຢໍ້ໃຈວ່າ User ມີຂໍ້ມູນຄົບຖ້ວນ
      User completeUser = User(
        username: user.username,
        email: user.email,
        password: user.password,
        name: user.name,
        age: user.age,
        weight: user.weight,
        height: user.height,
      );

      // ເພີ່ມຜູ້ໃຊ້ໃໝ່
      _users.add(completeUser);

      // ບັນທຶກລົງ SharedPreferences
      await _saveUsersToStorage();

      print('User registered successfully: ${completeUser.email}');
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  // Login user (ປັບປຸງດ້ວຍ debug ທີ່ດີກວ່າ)
  static Future<User?> login(String emailOrUsername, String password) async {
    await initialize(); // ໃຫ້ແນ່ໃຈວ່າ initialized ແລ້ວ

    try {
      print('=== LOGIN ATTEMPT ===');
      print('Email/Username: $emailOrUsername');
      print('Password: $password');
      print('Available users: ${_users.length}');

      // ຊອກຫາຜູ້ໃຊ້ດ້ວຍ email ຫຼື username
      User? foundUser;
      for (int i = 0; i < _users.length; i++) {
        User user = _users[i];
        print(
            'Checking user $i: ${user.email} / ${user.username} (stored password: ${user.password})');

        bool isEmailMatch =
            user.email.toLowerCase() == emailOrUsername.toLowerCase();
        bool isUsernameMatch =
            user.username.toLowerCase() == emailOrUsername.toLowerCase();

        print('Email match: $isEmailMatch, Username match: $isUsernameMatch');

        if (isEmailMatch || isUsernameMatch) {
          foundUser = user;
          print('Found matching user: ${user.email}');
          print(
              'Password comparison: input="$password" vs stored="${user.password}"');
          print('Password match: ${user.password == password}');
          break;
        }
      }

      if (foundUser == null) {
        print('User not found: $emailOrUsername');
        throw Exception('ບໍ່ພົບຜູ້ໃຊ້ນີ້ໃນລະບົບ');
      }

      if (foundUser.password != password) {
        print('Wrong password for user: $emailOrUsername');
        print('Expected: "${foundUser.password}", Got: "$password"');
        throw Exception('ລະຫັດຜ່ານບໍ່ຖືກຕ້ອງ');
      }

      // ບັນທຶກຜູ້ໃຊ້ປັດຈຸບັນ
      await _saveCurrentUser(foundUser);

      print('Login successful for: ${foundUser.email}');
      return foundUser;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // ບັນທຶກຜູ້ໃຊ້ປັດຈຸບັນ (ປັບປຸງແລ້ວ)
  static Future<void> _saveCurrentUser(User user) async {
    try {
      _currentUser = user;
      _isLoggedIn = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
      await prefs.setBool(_isLoggedInKey, true);

      print('Current user saved: ${user.email}');
    } catch (e) {
      print('Error saving current user: $e');
      throw e;
    }
  }

  // Reset password (ປັບປຸງແລ້ວ)
  static Future<void> resetPassword(String email, String newPassword) async {
    await initialize();

    try {
      print('Resetting password for: $email');

      // ຊອກຫາຜູ້ໃຊ້ດ້ວຍ email
      int userIndex = -1;
      for (int i = 0; i < _users.length; i++) {
        if (_users[i].email.toLowerCase() == email.toLowerCase()) {
          userIndex = i;
          break;
        }
      }

      if (userIndex == -1) {
        throw Exception('ບໍ່ພົບອີເມວນີ້ໃນລະບົບ');
      }

      // ອັບເດດລະຫັດຜ່ານ
      User oldUser = _users[userIndex];
      User updatedUser = User(
        username: oldUser.username,
        email: oldUser.email,
        password: newPassword,
        name: oldUser.name,
        age: oldUser.age,
        weight: oldUser.weight,
        height: oldUser.height,
      );

      _users[userIndex] = updatedUser;

      // ອັບເດດ current user ຖ້າເປັນຄົນດຽວກັນ
      if (_currentUser?.email.toLowerCase() == email.toLowerCase()) {
        _currentUser = updatedUser;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            _currentUserKey, jsonEncode(updatedUser.toJson()));
      }

      // ບັນທຶກການປ່ຽນແປງລົງ storage
      await _saveUsersToStorage();

      print('Password reset successfully for: $email');
    } catch (e) {
      print('Password reset error: $e');
      rethrow;
    }
  }

  // Find user by email (ສຳລັບ forgot password)
  static Future<User?> findUserByEmail(String email) async {
    await initialize();

    try {
      for (User user in _users) {
        if (user.email.toLowerCase() == email.toLowerCase()) {
          return user;
        }
      }
      return null;
    } catch (e) {
      print('Error finding user by email: $e');
      return null;
    }
  }

  // Get current user
  static Future<User?> getCurrentUser() async {
    await initialize();
    return _currentUser;
  }

  // Check if logged in
  static Future<bool> isLoggedIn() async {
    await initialize();
    return _isLoggedIn && _currentUser != null;
  }

  // Check if email exists (public method)
  static Future<bool> emailExists(String email) async {
    await initialize();
    return _users
        .any((user) => user.email.toLowerCase() == email.toLowerCase());
  }

  // Check if username exists (public method)
  static Future<bool> usernameExists(String username) async {
    await initialize();
    return _users
        .any((user) => user.username.toLowerCase() == username.toLowerCase());
  }

  // Logout (ປັບປຸງແລ້ວ)
  static Future<void> logout() async {
    try {
      _currentUser = null;
      _isLoggedIn = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
      await prefs.setBool(_isLoggedInKey, false);

      print('User logged out successfully');
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Update user
  static Future<void> updateUser(User user) async {
    await initialize();

    try {
      // ອັບເດດໃນ memory
      for (int i = 0; i < _users.length; i++) {
        if (_users[i].email.toLowerCase() == user.email.toLowerCase()) {
          _users[i] = user;
          break;
        }
      }

      // ອັບເດດ current user ຖ້າເປັນຄົນດຽວກັນ
      if (_currentUser?.email.toLowerCase() == user.email.toLowerCase()) {
        await _saveCurrentUser(user);
      }

      // ບັນທຶກລົງ storage
      await _saveUsersToStorage();

      print('User updated successfully');
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  // Clear all data (ສຳລັບ debug)
  static Future<void> clearAllData() async {
    try {
      _users.clear();
      _currentUser = null;
      _isLoggedIn = false;
      _isInitialized = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      print('All data cleared');
    } catch (e) {
      print('Error clearing data: $e');
    }
  }

  // Get debug info (ປັບປຸງໃຫ້ມີລາຍລະອຽດຫຼາຍຂຶ້ນ)
  static Future<Map<String, dynamic>> getDebugInfo() async {
    await initialize();

    try {
      final prefs = await SharedPreferences.getInstance();

      List<Map<String, dynamic>> userDetailsList = _users
          .map((u) => {
                'email': u.email,
                'username': u.username,
                'password': u.password,
                'name': u.name,
                'age': u.age,
                'weight': u.weight,
                'height': u.height,
              })
          .toList();

      return {
        'memory_users': _users.length,
        'memory_users_details': userDetailsList,
        'current_user': _currentUser?.email ?? 'None',
        'current_user_details': _currentUser?.toJson(),
        'is_logged_in': _isLoggedIn,
        'is_initialized': _isInitialized,
        'storage_users': (prefs.getStringList(_usersKey) ?? []).length,
        'storage_keys': prefs.getKeys().toList(),
        'raw_storage_data': prefs.getStringList(_usersKey),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
