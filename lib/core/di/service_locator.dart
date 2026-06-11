import 'package:commute_calendar/core/services/supabase_service.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // supabase
  getIt.registerSingleton<SupabaseClient>(supabaseService);
}
