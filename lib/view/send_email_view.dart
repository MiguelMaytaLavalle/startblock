import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:startblock/helper/excel.dart';
import 'package:startblock/model/history_card.dart';
import 'package:startblock/view_model/send_email_view_model.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'dart:io';
import 'package:open_file/open_file.dart' as open_file;
import 'package:path_provider/path_provider.dart' as path_provider;

class EmailScreen extends StatefulWidget {
  const EmailScreen({Key? key, required this.hCardModel}) : super(key: key);
  final HistoryCardModel hCardModel;

  @override
  _EmailScreenState createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  SendEmailViewModel sendEmailVM = SendEmailViewModel();
  ExportToExcel exportExcel = ExportToExcel();

  //HistoryWrapper histWrapper = HistoryWrapper(leftData, widget.rightData);

  Future<void> send() async {
    final Email email = Email(
      body: sendEmailVM.getBodyController().text,
      subject: sendEmailVM.getSubjectController().text,
     recipients: [sendEmailVM.getRecipientController().text],
     attachmentPaths: sendEmailVM.getAttachments(),
     isHTML: sendEmailVM.getIsHTML()
    );

    try {
      await FlutterEmailSender.send(email);
      sendEmailVM.setPlatformResponse('success');
    } catch (error) {
      sendEmailVM.setPlatformResponse(error.toString());
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(sendEmailVM.getPlatformResponse()),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Email'),
        actions: <Widget>[
          IconButton(
            onPressed: send,
            icon: Icon(Icons.send),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                //controller: _recipientController,
                controller: sendEmailVM.getRecipientController(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Recipient',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                //controller: _subjectController,
                controller: sendEmailVM.getSubjectController(),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Subject',
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  //controller: _bodyController,
                  controller: sendEmailVM.getBodyController(),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                      labelText: 'Body', border: OutlineInputBorder()),
                ),
              ),
            ),
            CheckboxListTile(
              contentPadding:
              const EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
              title: const Text('HTML'),
              onChanged: (bool? value) {
                if (value != null) {
                  setState(() {
                    //isHTML = value;
                    sendEmailVM.setIsHTML(value);
                  });
                }
              },
              //value: isHTML,
              value: sendEmailVM.getIsHTML(),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  //for (var i = 0; i < attachments.length; i++)
                  for (var i = 0; i < sendEmailVM.getAttachments().length; i++)
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            //attachments[i],
                            sendEmailVM.getAttachments()[i],
                            softWrap: false,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.remove_circle),
                          onPressed: () => {_removeAttachment(i)},
                        )
                      ],
                    ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      //icon: Icon(Icons.attach_file), onPressed: attachExcel,
                      icon: Icon(Icons.attach_file),
                      onPressed: () async {
                        String tmp = await exportExcel.attachExcel(widget.hCardModel);
                        sendEmailVM.addAttachment(tmp);
                      },
                      //onPressed: _openImagePicker,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeAttachment(int index) {
    setState(() {
      //attachments.removeAt(index);
      sendEmailVM.removeAttachment(index);
    });
  }


}

