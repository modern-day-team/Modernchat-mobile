class RegisterBody {
  const RegisterBody({
    required this.username,
    required this.password,
    required this.nickname,
    this.inviteCode,
    this.email,
    this.emailCode,
  });

  final String username;
  final String password;
  final String nickname;
  final String? inviteCode;
  final String? email;
  final String? emailCode;

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'nickname': nickname,
        if (inviteCode != null && inviteCode!.isNotEmpty) 'inviteCode': inviteCode,
        if (email != null && email!.isNotEmpty) 'email': email,
        if (emailCode != null && emailCode!.isNotEmpty) 'emailCode': emailCode,
      };
}
