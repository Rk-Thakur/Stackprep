import 'package:flutter/widgets.dart';

/// Global [RouteObserver] used by pages that need to refresh their data when
/// they become visible again after a pushed route pops back (e.g. the
/// dashboard / progress screens reload on return).
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
