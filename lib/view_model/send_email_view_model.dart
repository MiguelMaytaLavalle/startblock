import 'package:startblock/model/email.dart';

class SendEmailViewModel{
  EmailModel emailModel = EmailModel();

  getIsHTML(){
    return emailModel.isHTML;
  }

  setIsHTML(bool value){
    emailModel.isHTML = value;
  }

  getAttachments(){
    return emailModel.attachments;
  }

  addAttachment(String path){
    emailModel.attachments.add(path);
  }

  removeAttachment(int index){
    emailModel.attachments.remove(index);
  }

  getRecipientController(){
    return emailModel.recipientController;
  }

  getSubjectController(){
    return emailModel.subjectController;
  }

  getBodyController(){
    return emailModel.bodyController;
  }

  getPlatformResponse(){
    return emailModel.platformResponse;
  }

  setPlatformResponse(String text){
    emailModel.platformResponse = text;
  }

}
