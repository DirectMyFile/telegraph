import "dart:io";
import "dart:convert";

class TelegraphBot {
  final String endpoint;
  final String accessToken;
  final String verifyToken;

  TelegraphBot(this.endpoint, this.accessToken, this.verifyToken);
}

main(List<String> args) async {
  String telegraphString = await (new File(Directory.current.path + "/telegraph.json").readAsString());
  Map telegraphConfig = JSON.decode(telegraphString);

  // list of bots, organized by endpoint name for easy access
  Map<String, TelegraphBot> bots = {};
  telegraphConfig["bots"].forEach((Map map) {
    bots[map["endpoint"]] = new TelegraphBot(map["endpoint"], map["access_token"], map["verify_token"]);
  });

  // setup HTTP server
  int port = telegraphConfig["port"];
  HttpServer server = await HttpServer.bind("127.0.0.1", port);

  server.listen((HttpRequest request) async {
    if (request.uri.path == "/ws") {
      // TODO: Bot API
      return;
    }

    if (request.uri.pathSegments[0] == "bots" && request.uri.pathSegments.length == 2) {
      String botName = request.uri.pathSegments[1];

      if (!bots.containsKey(botName))
        return;
      TelegraphBot bot = bots[botName];

      if (request.method == "GET") {
        print("Facebook trying to authenticate with bot $botName");
        if (bot.verifyToken == request.uri.queryParameters["hub.verify_token"]) {
          request.response.write(request.uri.queryParameters["hub.challenge"]);
        } else {
          request.response.write("trololol nope");
        }

        request.response.close();
      }

      if (request.method == "POST") {
        print("Facebook sent a message to bot $botName");
        String content = await UTF8.decodeStream(request);
        print("raw (everything else unsupported right now): $content");
      }

      return;
    }

    print("Invalid HTTP request to ${request.uri.toString()}");

  });

  print("HTTP server started on port ${port}");
}
