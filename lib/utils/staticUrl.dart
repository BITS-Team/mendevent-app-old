class StaticUrl {
//  static String _domain = "http://192.168.1.10";
//  static String _domain = "http://mend.api";
 static String _domain = "https://api.mendevent.mn";

//   static String _domain = "http://7f71da48e118.ngrok.io";
//  static String _domain = "https://mendapi.chatbot.mn";
//   static String _apiPort = ":1337";
  static String _apiPort = "";

  static String _loginUrl = "/auth/local";
  static String _userList = "/users";
  static String _registerUrl = "/doctors/customCreate";
  static String _profileUrl = "/doctors/";
  static String _upload = "/upload/";
  static String _appointmentUrl = "/appointments/";

  static String _eventUrl = "/events/";
  static String _eventSpeakerUrl = "/eventspeakers";
  static String _eventSpeakerProgramUrl = "/eventprogramspeakers";
  static String _eventSchedulesUrl = "/eventprograms";
  static String _eventParticipantUrl = "/eventparticipants";
  static String _eventExhibitionUrl = "/eventexhibitions";
  static String _eventExhibitionVoteUrl = "/eventexhibitionvotes";
  static String _eventUserUrl = "/eventusers";
  static String _eventUserPaymentUrl = "/eventpayments";
  static String _eventEventRoomsUrl = "/eventrooms";
  static String _eventEventFaqsUrl = "/eventfaqs";
  static String _eventQuestionUrl = "/eventquestions";
  static String _eventQuestionVoteOfUserUrl = "/eventquestionvotes/votesofuser";
  static String _eventQuestionVoteUrl = "/eventquestionvotes/votetoquestion";
  static String _eventFilesUrl = "/eventfiles";
  static String _eventAttendanceUrl = "/eventattendancebuckets";
  static String _attendanceOperatorUrl = "/eventattendences/operator";
  static String _imagePath = "/uploads_compressed";
  static String _codeRequestUrl = "/sms/register";
  static String _codeVerifyUrl = "/sms/confirmation";
  static String _resetPasswordUrl = "/sms/reset";
  static String _resetVerifyUrl = "/sms/resetconfirmation";
  static String _eventPollUrl = "/eventpolls";
  static String _eventPollOptionUrl = "/eventpolloptions";
  static String _eventInvoicesUrl = "/eventinvoices";
  static String _eventPackagesUrl = "/eventpackages";
  static String _firebaseTokenUrl = "/firebase/token";

  static String getDomain(){
    return _domain;
  }
  static String getDomainPort(){
    return _domain + _apiPort;
  }
  static String getLoginUrlwithDomain(){
    return getDomainPort() + _loginUrl;
  }
  static String getLoginUrl(){
    return _loginUrl;
  }

  static String getUsersUrlwithDomain(){
    return getDomainPort() + _userList;
  }
  static String getUsersUrl(){
    return _userList;
  }

  static String getRegisterUrlwithDomain(){
    return getDomainPort() + _registerUrl;
  }
  static String getRegisterUrl(){
    return _registerUrl;
  }

  static String getProfileUrlwithDomain(){
    return getDomainPort() + _profileUrl;
  }
  static String getProfileUrl(){
    return _profileUrl;
  }

  static String getUploadUrlwithDomain(){
    return getDomainPort() + _upload;
  }
  static String getUploadUrl(){
    return _upload;
  }

  static String getAppointmentUrlwithDomain(){
    return getDomainPort() + _appointmentUrl;
  }
  static String getAppointmentUrl(){
    return _appointmentUrl;
  }

  static String getEventUrlwithDomain(){
    return getDomainPort() + _eventUrl;
  }
  static String getEventurl(){
    return _eventUrl;
  }

  static String getEventSpeakerUrlwithDomain(){
    return getDomainPort() + _eventSpeakerUrl;
  }
  static String getEventSpeakerurl(){
    return _eventSpeakerUrl;
  }

  static String getEventSpeakerProgramUrlwithDomain(){
    return getDomainPort() + _eventSpeakerProgramUrl;
  }
  static String getEventSpeakerProgramurl(){
    return _eventSpeakerProgramUrl;
  }

  static String getEventSchedulesUrlwithDomain(){
    return getDomainPort() + _eventSchedulesUrl;
  }
  static String getEventSchedulesurl(){
    return _eventSchedulesUrl;
  }

  static String getEventParticipantsUrlwithDomain(){
    return getDomainPort() + _eventParticipantUrl;
  }
  static String getEventParticipantsurl(){
    return _eventParticipantUrl;
  }

  static String getEventExhibitionsUrlwithDomain(){
    return getDomainPort() + _eventExhibitionUrl;
  }
  static String getEventExhibitionsurl(){
    return _eventExhibitionUrl;
  }

  static String getEventExhibitionVotesUrlwithDomain(){
    return getDomainPort() + _eventExhibitionVoteUrl;
  }
  static String getEventExhibitionVotesurl(){
    return _eventExhibitionVoteUrl;
  }

  static String getEventUsersUrlwithDomain(){
    return getDomainPort() + _eventUserUrl;
  }
  static String getEventUsersurl(){
    return _eventUserUrl;
  }

  static String getEventPaymentUrlwithDomain(){
    return getDomainPort() + _eventUserPaymentUrl;
  }
  static String getEventPaymentsurl(){
    return _eventUserPaymentUrl;
  }


  static String getEventRoomsUrlwithDomain(){
    return getDomainPort() + _eventEventRoomsUrl;
  }
  static String getEventRoomsurl(){
    return _eventEventRoomsUrl;
  }

  static String getEventFaqsUrlwithDomain(){
    return getDomainPort() + _eventEventFaqsUrl;
  }
  static String getEventFaqsurl(){
    return _eventEventFaqsUrl;
  }

  static String getEventQuestionsUrlwithDomain(){
    return getDomainPort() + _eventQuestionUrl;
  }
  static String getEventQuestionsurl(){
    return _eventQuestionUrl;
  }

  static String getEventQuestionVotesUrlwithDomain(){
    return getDomainPort() + _eventQuestionVoteOfUserUrl;
  }
  static String getEventQuestionVotesurl(){
    return _eventQuestionVoteOfUserUrl;
  }

  static String getEventVoteQuestionUrlwithDomain(){
    return getDomainPort() + _eventQuestionVoteUrl;
  }
  static String getEventVoteQuestionurl(){
    return _eventQuestionVoteUrl;
  }

  static String getEventFilesUrlwithDomain(){
    return getDomainPort() + _eventFilesUrl;
  }
  static String getEventFilesurl(){
    return _eventFilesUrl;
  }

  static String getEventAttendancesUrlwithDomain(){
    return getDomainPort() + _eventAttendanceUrl;
  }
  static String getEventAttendancesUrl(){
    return _eventAttendanceUrl;
  }

  static String getAttendanceEventByOperatorUrlwithDomain(){
    return getDomainPort() + _attendanceOperatorUrl;
  }
  static String getAttendanceEventByOperatorUrl(){
    return _attendanceOperatorUrl;
  }

  static String fixImageUrl(String imgUrl){
    var i = imgUrl.replaceFirst('/uploads', _imagePath);
    // return i;
    return imgUrl;
  }

  static String getCodeRequestUrlwithDomain(){
    return getDomainPort() + _codeRequestUrl;
  }
  static String getCodeRequestUrl(){
    return _codeRequestUrl;
  }

  static String getCodeConfirmationUrlwithDomain(){
    return getDomainPort() + _codeVerifyUrl;
  }
  static String getCodeConfirmationUrl(){
    return _codeVerifyUrl;
  }

  static String getResetPasswordUrlwithDomain(){
    return getDomainPort() + _resetPasswordUrl;
  }
  static String getResetPasswordUrl(){
    return _resetPasswordUrl;
  }

  static String getResetVerifyUrlwithDomain(){
    return getDomainPort() + _resetVerifyUrl;
  }
  static String getResetVerifyUrl(){
    return _resetVerifyUrl;
  }

  static String getEventPollUrlwithDomain(){
    return getDomainPort() + _eventPollUrl;
  }
  static String getEventPollUrl(){
    return _eventPollUrl;
  }

  static String getPollOptionUrlwithDomain(){
    return getDomainPort() + _eventPollOptionUrl;
  }
  static String getPollOptionUrl(){
    return _eventPollOptionUrl;
  }
  
  static String getEventInvoicesUrlwithDomain(){
    return getDomainPort() + _eventInvoicesUrl;
  }
  static String getEventInvoicesUrl(){
    return _eventInvoicesUrl;
  }

  static String getEventPackagesUrlwithDomain(){
    return getDomainPort() + _eventPackagesUrl;
  }
  static String getEventPackagesUrl(){
    return _eventPackagesUrl;
  }

  static String getFirebaseTokenUrlwithDomain(){
    return getDomainPort() + _firebaseTokenUrl;
  }
  static String getFirebaseTokenUrl(){
    return _firebaseTokenUrl;
  }
}
