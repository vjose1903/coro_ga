class SqlResponse {
  SqlResponse({this.messages, this.data, this.hasError = false});

  bool? hasError;
  List? messages;
  dynamic data;

  void addMsg(String arg) {
    messages ??= [];
    messages!.add(arg);
  }

  void addMsgs(List<String> args) {
    messages ??= [];

    for (String arg in args) {
      messages!.add(arg);
    }
  }

  @override
  String toString() {
    return "hasError: $hasError, messages: $messages, data: $data";
  }
}
