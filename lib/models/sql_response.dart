class SqlResponse {
  SqlResponse({this.messages, this.data, this.hasError = false});

  bool? hasError;
  List<String>? messages;
  dynamic data;

  void addMsg(String arg) {
    messages ??= [];
    messages!.add(arg);
  }

  void addMsgs(List<String>? args) {
    if (args == null) return;
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
