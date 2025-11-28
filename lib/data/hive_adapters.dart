import 'package:hive/hive.dart';
import '../models/puzzle.dart';
import '../models/user_state.dart';


void registerHiveAdapters() {
  
  Hive.registerAdapter(PuzzleAdapter());
  Hive.registerAdapter(UserStateAdapter());
}
