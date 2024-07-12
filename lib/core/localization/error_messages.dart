import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../error/app_error.dart';

class ErrorMessages {
  static String getLocalizedErrorMessage(BuildContext context, AppError error) {
    final l10n = AppLocalizations.of(context)!;

    switch (error.type) {
      case ErrorType.network:
        return l10n.networkErrorMessage;
      case ErrorType.database:
        return l10n.databaseErrorMessage;
      default:
        return l10n.generalErrorMessage;
    }
  }
}
