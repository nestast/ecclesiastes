import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'event_provider.dart';
import 'services/report_provider.dart';

final eventProvider = ChangeNotifierProvider((ref) => EventProvider());

final interactiveReportProvider = ChangeNotifierProvider((ref) => InteractiveReportProvider());
