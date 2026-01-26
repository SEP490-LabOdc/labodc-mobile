import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/vietqr_bank_model.dart';
import '../bank_api_service.dart';
import '../bank_cache_service.dart';

// States
abstract class BankState {}

class BankInitial extends BankState {}

class BankLoading extends BankState {}

class BankLoaded extends BankState {
  final List<VietQRBank> banks;
  final List<VietQRBank> transferSupportedBanks;

  BankLoaded(this.banks)
    : transferSupportedBanks = banks.where((b) => b.supportsTransfer).toList();
}

class BankError extends BankState {
  final String message;
  BankError(this.message);
}

// Cubit
class BankCubit extends Cubit<BankState> {
  final BankApiService apiService;
  final BankCacheService cacheService;

  BankCubit({
    required this.apiService,
    required SharedPreferences sharedPreferences,
  }) : cacheService = BankCacheService(sharedPreferences),
       super(BankInitial());

  /// Load banks (from cache or API)
  Future<void> loadBanks({bool forceRefresh = false}) async {
    emit(BankLoading());

    try {
      // Try to use cache first if valid and not forced refresh
      if (!forceRefresh && cacheService.isCacheValid()) {
        final cachedBanks = cacheService.getCachedBanks();
        if (cachedBanks != null && cachedBanks.isNotEmpty) {
          emit(BankLoaded(cachedBanks));
          return;
        }
      }

      // Fetch from API
      final banks = await apiService.fetchBanks();

      // Save to cache
      await cacheService.saveBanks(banks);

      emit(BankLoaded(banks));
    } catch (e) {
      // Try cache as fallback
      final cachedBanks = cacheService.getCachedBanks();
      if (cachedBanks != null && cachedBanks.isNotEmpty) {
        emit(BankLoaded(cachedBanks));
      } else {
        emit(BankError('Không thể tải danh sách ngân hàng: $e'));
      }
    }
  }

  /// Clear cache and reload
  Future<void> refreshBanks() async {
    await cacheService.clearCache();
    await loadBanks(forceRefresh: true);
  }
}
