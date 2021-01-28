class GitAuthor {
  final String login;
  final String avatarUrl;
  final String htmlUrl;
  final String type;

  GitAuthor({this.login, this.avatarUrl, this.htmlUrl, this.type});

  factory GitAuthor.fromJSON(Map<String, dynamic> json) => GitAuthor(
        login: json['login'],
        avatarUrl: json['avatar_url'],
        htmlUrl: json['html_url'],
        type: json['type'],
      );
}
