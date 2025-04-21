import 'package:flutter/foundation.dart';

enum CallerSDKType { generated, manual }

class ConnectorConfig {
  final String region;
  final String connectorId;
  final String projectId;

  ConnectorConfig(this.region, this.connectorId, this.projectId);
}

class FirebaseDataConnect {
  final ConnectorConfig connectorConfig;
  final CallerSDKType sdkType;

  FirebaseDataConnect({
    required this.connectorConfig,
    required this.sdkType,
  });

  static FirebaseDataConnect instanceFor({
    required ConnectorConfig connectorConfig,
    required CallerSDKType sdkType,
  }) {
    return FirebaseDataConnect(
      connectorConfig: connectorConfig,
      sdkType: sdkType,
    );
  }
}
