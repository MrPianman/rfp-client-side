import 'package:graphql_flutter/graphql_flutter.dart';
import '../config/app_config.dart';
import 'auth_manager.dart';

class _RefreshLink extends Link {
  @override
  Stream<Response> request(Request request, [NextLink? forward]) async* {
    final next = forward;
    if (next == null) throw StateError('No forward link for RefreshLink');

    try {
      yield* next(request);
    } on HttpLinkServerException catch (e) {
      if (e.response.statusCode == 401) {
        final refreshed = await AuthManager.instance.refreshTokens();
        if (refreshed) {
          yield* next(request);
          return;
        }
      }
      rethrow;
    }
  }
}

class GraphQLService {
  GraphQLService._();
  static final GraphQLService instance = GraphQLService._();

  GraphQLClient? _client;
  Uri endpoint = Uri.parse('https://example.com/graphql');

  GraphQLClient get client {
    final current = _client;
    if (current == null) {
      throw StateError('GraphQLService not initialized');
    }
    return current;
  }

  Future<void> init({AppConfig? config, Uri? endpoint}) async {
    final effectiveConfig = config ?? AppConfig.defaultConfig;
    endpoint ??= effectiveConfig.graphqlEndpoint;
    this.endpoint = endpoint;

    final httpLink = HttpLink(this.endpoint.toString());

    final authLink = AuthLink(
      getToken: () async {
        final token = AuthManager.instance.accessToken;
        return token == null || token.isEmpty ? null : 'Bearer $token';
      },
    );

    _client = GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: _RefreshLink().concat(authLink).concat(httpLink),
    );
  }
}
