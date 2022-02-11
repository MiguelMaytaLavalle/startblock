import 'package:flutter/cupertino.dart';

class EmailModel{
  late List<String> attachments = [];
  bool isHTML = false;
  final TextEditingController recipientController = TextEditingController(text: 'example@example.com',);
  final TextEditingController subjectController = TextEditingController(text: 'The subject');
  final TextEditingController bodyController = TextEditingController(text: 'Mail body.',);
  late String platformResponse = '';

}
