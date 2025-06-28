// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/user.dart';

// class SimpleStorageService {
//   // In-memory storage as fallback
//   static List<User> _users = [];
//   static User? _currentUser;
//   static bool _isLoggedIn = false;

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

//   // Register user
//   static Future<void> registerUser(User user) async {
//     try {
//       // Check if email already exists
//       bool emailExists = await _emailExists(user.email);
//       if (emailExists) {
//         throw Exception('ອີເມວນີ້ໄດ້ຖືກລົງທະບຽນແລ້ວ');
//       }

//       if (await _canUseStorage()) {
//         // Use SharedPreferences
//         final prefs = await SharedPreferences.getInstance();
//         List<String> users = prefs.getStringList('users') ?? [];
//         users.add(jsonEncode(user.toJson()));
//         await prefs.setStringList('users', users);
//       } else {
//         // Use memory storage
//         _users.add(user);
//       }

//       print('User registered: ${user.email}');
//     } catch (e) {
//       print('Registration error: $e');
//       rethrow;
//     }
//   }

//   // Login user
//   static Future<User?> login(String email, String password) async {
//     try {
//       List<User> users = [];

//       if (await _canUseStorage()) {
//         // Load from SharedPreferences
//         final prefs = await SharedPreferences.getInstance();
//         List<String> userStrings = prefs.getStringList('users') ?? [];
//         users =
//             userStrings.map((str) => User.fromJson(jsonDecode(str))).toList();
//       } else {
//         // Use memory storage
//         users = _users;
//       }

//       // Find user
//       for (User user in users) {
//         if (user.email.toLowerCase() == email.toLowerCase() &&
//             user.password == password) {
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

//   // Save current user
//   static Future<void> _saveCurrentUser(User user) async {
//     try {
//       _currentUser = user;
//       _isLoggedIn = true;

//       if (await _canUseStorage()) {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('current_user', jsonEncode(user.toJson()));
//         await prefs.setBool('is_logged_in', true);
//       }
//     } catch (e) {
//       print('Error saving current user: $e');
//     }
//   }

//   // Get current user
//   static Future<User?> getCurrentUser() async {
//     try {
//       if (_currentUser != null) return _currentUser;

//       if (await _canUseStorage()) {
//         final prefs = await SharedPreferences.getInstance();
//         String? userString = prefs.getString('current_user');
//         if (userString != null) {
//           _currentUser = User.fromJson(jsonDecode(userString));
//           return _currentUser;
//         }
//       }

//       return null;
//     } catch (e) {
//       print('Error getting current user: $e');
//       return null;
//     }
//   }

//   // Check if logged in
//   static Future<bool> isLoggedIn() async {
//     try {
//       if (_isLoggedIn) return true;

//       if (await _canUseStorage()) {
//         final prefs = await SharedPreferences.getInstance();
//         _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
//       }

//       return _isLoggedIn;
//     } catch (e) {
//       print('Error checking login status: $e');
//       return false;
//     }
//   }

//   // Check if email exists
//   static Future<bool> _emailExists(String email) async {
//     try {
//       List<User> users = [];

//       if (await _canUseStorage()) {
//         final prefs = await SharedPreferences.getInstance();
//         List<String> userStrings = prefs.getStringList('users') ?? [];
//         users =
//             userStrings.map((str) => User.fromJson(jsonDecode(str))).toList();
//       } else {
//         users = _users;
//       }

//       return users
//           .any((user) => user.email.toLowerCase() == email.toLowerCase());
//     } catch (e) {
//       print('Error checking email: $e');
//       return false;
//     }
//   }

//   // Logout
//   static Future<void> logout() async {
//     try {
//       _currentUser = null;
//       _isLoggedIn = false;

//       if (await _canUseStorage()) {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.remove('current_user');
//         await prefs.setBool('is_logged_in', false);
//       }
//     } catch (e) {
//       print('Error during logout: $e');
//     }
//   }

//   // Update user
//   static Future<void> updateUser(User user) async {
//     try {
//       await _saveCurrentUser(user);

//       if (await _canUseStorage()) {
//         final prefs = await SharedPreferences.getInstance();
//         List<String> userStrings = prefs.getStringList('users') ?? [];

//         for (int i = 0; i < userStrings.length; i++) {
//           User existingUser = User.fromJson(jsonDecode(userStrings[i]));
//           if (existingUser.email.toLowerCase() == user.email.toLowerCase()) {
//             userStrings[i] = jsonEncode(user.toJson());
//             break;
//           }
//         }

//         await prefs.setStringList('users', userStrings);
//       } else {
//         // Update in memory
//         for (int i = 0; i < _users.length; i++) {
//           if (_users[i].email.toLowerCase() == user.email.toLowerCase()) {
//             _users[i] = user;
//             break;
//           }
//         }
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
//       Map<String, dynamic> info = {
//         'memory_users': _users.length,
//         'current_user': _currentUser?.email ?? 'None',
//         'is_logged_in': _isLoggedIn,
//         'storage_available': await _canUseStorage(),
//       };

//       if (await _canUseStorage()) {
//         final prefs = await SharedPreferences.getInstance();
//         info['storage_users'] = (prefs.getStringList('users') ?? []).length;
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
  // In-memory storage as fallback
  static List<User> _users = [];
  static User? _currentUser;
  static bool _isLoggedIn = false;

  // Keys for SharedPreferences
  static const String _usersKey = 'registered_users';
  static const String _currentUserKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

  // Try to use SharedPreferences, fallback to memory
  static Future<bool> _canUseStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('test', 'test');
      await prefs.remove('test');
      return true;
    } catch (e) {
      print('SharedPreferences not available, using memory storage');
      return false;
    }
  }

  // Initialize storage - load existing data
  static Future<void> initialize() async {
    try {
      if (await _canUseStorage()) {
        final prefs = await SharedPreferences.getInstance();

        // Load users
        List<String> userStrings = prefs.getStringList(_usersKey) ?? [];
        _users =
            userStrings.map((str) => User.fromJson(jsonDecode(str))).toList();

        // Load current user
        String? currentUserString = prefs.getString(_currentUserKey);
        if (currentUserString != null) {
          _currentUser = User.fromJson(jsonDecode(currentUserString));
        }

        // Load login status
        _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

        print('Storage initialized: ${_users.length} users loaded');
      }
    } catch (e) {
      print('Error initializing storage: $e');
    }
  }

  // Register user
  static Future<void> registerUser(User user) async {
    try {
      // Check if email already exists
      bool emailExists = await _emailExists(user.email);
      if (emailExists) {
        throw Exception('ອີເມວນີ້ໄດ້ຖືກລົງທະບຽນແລ້ວ');
      }

      // Check if username already exists
      bool usernameExists = await _usernameExists(user.username);
      if (usernameExists) {
        throw Exception('ຊື່ຜູ້ໃຊ້ນີ້ໄດ້ຖືກໃຊ້ແລ້ວ');
      }

      // Add to memory
      _users.add(user);

      // Save to SharedPreferences if available
      if (await _canUseStorage()) {
        final prefs = await SharedPreferences.getInstance();
        List<String> userStrings =
            _users.map((u) => jsonEncode(u.toJson())).toList();
        await prefs.setStringList(_usersKey, userStrings);
      }

      print('User registered: ${user.email}');
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  // Login user (supports email or username)
  static Future<User?> login(String emailOrUsername, String password) async {
    try {
      // Ensure data is loaded
      await initialize();

      // Find user by email or username
      for (User user in _users) {
        bool isEmailMatch =
            user.email.toLowerCase() == emailOrUsername.toLowerCase();
        bool isUsernameMatch =
            user.username.toLowerCase() == emailOrUsername.toLowerCase();

        if ((isEmailMatch || isUsernameMatch) && user.password == password) {
          await _saveCurrentUser(user);
          return user;
        }
      }

      throw Exception('ອີເມວ ຫຼື ລະຫັດຜ່ານບໍ່ຖືກຕ້ອງ');
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // Reset password
  static Future<void> resetPassword(String email, String newPassword) async {
    try {
      await initialize();

      // Find user by email
      User? targetUser;
      int userIndex = -1;

      for (int i = 0; i < _users.length; i++) {
        if (_users[i].email.toLowerCase() == email.toLowerCase()) {
          targetUser = _users[i];
          userIndex = i;
          break;
        }
      }

      if (targetUser == null) {
        throw Exception('ບໍ່ພົບອີເມວນີ້ໃນລະບົບ');
      }

      // Update password
      User updatedUser = User(
        username: targetUser.username,
        email: targetUser.email,
        password: newPassword,
      );

      _users[userIndex] = updatedUser;

      // Update current user if it's the same user
      if (_currentUser?.email.toLowerCase() == email.toLowerCase()) {
        _currentUser = updatedUser;
      }

      // Save to SharedPreferences if available
      if (await _canUseStorage()) {
        final prefs = await SharedPreferences.getInstance();
        List<String> userStrings =
            _users.map((u) => jsonEncode(u.toJson())).toList();
        await prefs.setStringList(_usersKey, userStrings);

        // Update current user in storage if needed
        if (_currentUser?.email.toLowerCase() == email.toLowerCase()) {
          await prefs.setString(
              _currentUserKey, jsonEncode(_currentUser!.toJson()));
        }
      }

      print('Password reset for: $email');
    } catch (e) {
      print('Password reset error: $e');
      rethrow;
    }
  }

  // Find user by email (for forgot password)
  static Future<User?> findUserByEmail(String email) async {
    try {
      await initialize();

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

  // Save current user
  static Future<void> _saveCurrentUser(User user) async {
    try {
      _currentUser = user;
      _isLoggedIn = true;

      if (await _canUseStorage()) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
        await prefs.setBool(_isLoggedInKey, true);
      }
    } catch (e) {
      print('Error saving current user: $e');
    }
  }

  // Get current user
  static Future<User?> getCurrentUser() async {
    try {
      if (_currentUser != null) return _currentUser;

      await initialize();
      return _currentUser;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Check if logged in
  static Future<bool> isLoggedIn() async {
    try {
      await initialize();
      return _isLoggedIn;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Check if email exists
  static Future<bool> _emailExists(String email) async {
    try {
      await initialize();
      return _users
          .any((user) => user.email.toLowerCase() == email.toLowerCase());
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }

  // Check if username exists
  static Future<bool> _usernameExists(String username) async {
    try {
      await initialize();
      return _users
          .any((user) => user.username.toLowerCase() == username.toLowerCase());
    } catch (e) {
      print('Error checking username: $e');
      return false;
    }
  }

  // Public method to check if email exists (for UI)
  static Future<bool> emailExists(String email) async {
    return await _emailExists(email);
  }

  // Public method to check if username exists (for UI)
  static Future<bool> usernameExists(String username) async {
    return await _usernameExists(username);
  }

  // Logout
  static Future<void> logout() async {
    try {
      _currentUser = null;
      _isLoggedIn = false;

      if (await _canUseStorage()) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_currentUserKey);
        await prefs.setBool(_isLoggedInKey, false);
      }
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Update user
  static Future<void> updateUser(User user) async {
    try {
      await _saveCurrentUser(user);

      // Update in memory
      for (int i = 0; i < _users.length; i++) {
        if (_users[i].email.toLowerCase() == user.email.toLowerCase()) {
          _users[i] = user;
          break;
        }
      }

      // Save to SharedPreferences if available
      if (await _canUseStorage()) {
        final prefs = await SharedPreferences.getInstance();
        List<String> userStrings =
            _users.map((u) => jsonEncode(u.toJson())).toList();
        await prefs.setStringList(_usersKey, userStrings);
      }
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  // Clear all data
  static Future<void> clearAllData() async {
    try {
      _users.clear();
      _currentUser = null;
      _isLoggedIn = false;

      if (await _canUseStorage()) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      }

      print('All data cleared');
    } catch (e) {
      print('Error clearing data: $e');
    }
  }

  // Get debug info
  static Future<Map<String, dynamic>> getDebugInfo() async {
    try {
      await initialize();

      Map<String, dynamic> info = {
        'memory_users': _users.length,
        'current_user': _currentUser?.email ?? 'None',
        'is_logged_in': _isLoggedIn,
        'storage_available': await _canUseStorage(),
      };

      if (await _canUseStorage()) {
        final prefs = await SharedPreferences.getInstance();
        info['storage_users'] = (prefs.getStringList(_usersKey) ?? []).length;
        info['storage_keys'] = prefs.getKeys().toList();
      }

      return info;
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
