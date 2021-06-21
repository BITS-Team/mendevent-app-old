import 'package:mend_doctor/models/modEvent.dart';
import 'package:mend_doctor/models/modEventExhibition.dart';
import 'package:mend_doctor/models/modEventRoom.dart';
import 'package:mend_doctor/models/modEventFaq.dart';
import 'package:mend_doctor/models/modEventSpeaker.dart';
import 'package:mend_doctor/models/modEventProgramItem.dart';
import 'package:mend_doctor/models/lstEventTimeTable.dart';
import 'package:mend_doctor/models/modDoctor.dart';
import 'package:mend_doctor/models/modEventParticipant.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

/// GENERALLY DEPRECATED
/// zarim field ashiglagdsaar baigaa :)
class EventData {
  static final EventData _appData = new EventData._internal();

  String text;
  Event mEvent;
  EventTimeTable mTimeTable;
  String mMainZohionBaiguulagch;
  List<EventRoom> mRooms;
  List<EventFaq> mFaqs;
  List<EventSpeaker> mSpeakers;
  List<EventSpeaker> mFeaturedSpeakers;
  List<EventProgramItem> mPrograms;

  // Refactored
  Doctor mProfile;
  bool isAllEventsLoaded = false;

  Map<int, Event> lstEvent = Map<int, Event>(); // Niit event list
  Map<int, Event> lstEndedEvent = Map<int, Event>(); // Duussan event list;
  Map<int, Event> lstAttendedEvent = Map<int, Event>(); // Oroltsson event list
  Map<int, EventUserPayment> mRegisteredEventUserIds = Map<int, EventUserPayment>(); /// event.id, eventUserPayment if user register event => generate event_user_id
  Map<int, Map<int, EventSpeaker>> lstSpeakersByEvent = Map<int, Map<int, EventSpeaker>>();
  Map<int, List<EventRoom>> lstRoomsByEvent = Map<int, List<EventRoom>>();
  Map<int, Map<int, EventProgramItem>> lstProgramsByEvent = Map<int, Map<int, EventProgramItem>>();
  Map<int, Map<int, EventParticipant>> lstParticipantsByEvent = Map<int, Map<int, EventParticipant>>();
  Map<int, List<EventTimeTable>> lstTimeTableByEvent = Map<int, List<EventTimeTable>>();
  Map<int, LinkSpeakerProgram> lstSpeakerProgram = Map<int, LinkSpeakerProgram>();

  /// Map< event.id, Map< program.id, Map <exhibition.id, exhibition>>>
  Map<int, Map<int, Map<int, Exhibition>>> lstExhibitions = Map<int, Map<int, Map<int, Exhibition>>>();
  Map<int, bool> hasExhibitionByEvent = Map<int, bool>();
  Map<int, Map<int,String>> lstEventSpeakerCareers = Map<int, Map<int,String>>();

  Map<int, bool> isLoadedDataByEvent = Map<int, bool>(); // tuhain event-iin timetable, speakers load hiigdsen eseh

  /// ProgramDetails deer asking question => speakerId
  int askingSpeakerId = -1;


  /// TODO: deed talaas ashiglaj bgaa esehiig neg burchlen shalgaj ustgah
  /// new : after using SQLite
  int lastEventId = 0;
  FirebaseMessaging firebaseMessaging;
  String firebaseToken = '';


  factory EventData() {
    return _appData;
  }
  EventData._internal();

  resetData() {
    this.text = null;
    this.mMainZohionBaiguulagch = null;
    this.mTimeTable = null;
    this.mFaqs = null;
    this.mSpeakers = null;
    this.mFeaturedSpeakers = null;
    this.mPrograms = null;

    this.mProfile = null;
    this.isAllEventsLoaded = false;

    this.lstEvent.clear();
    this.lstEndedEvent.clear();
    this.lstAttendedEvent.clear();
    this.mRegisteredEventUserIds.clear();
    this.lstSpeakersByEvent.clear();
    this.lstRoomsByEvent.clear();
    this.lstProgramsByEvent.clear();
    this.lstParticipantsByEvent.clear();
    this.lstTimeTableByEvent.clear();
    this.lstSpeakerProgram.clear();
    this.lstExhibitions.clear();
    this.hasExhibitionByEvent.clear();
    this.lstEventSpeakerCareers.clear();
    this.isLoadedDataByEvent.clear();

    /// Refactored
    this.firebaseToken = '';

  }

  String getText() {
    return text != null ? text : "";
  }

  setText(String txt) {
    text = txt;
  }

  Event getEvent() {
    return this.mEvent;
  }

  setEvent(Event evt) {
    resetData();
    this.mEvent = evt;
  }

  EventTimeTable getTimeTable() {
    return this.mTimeTable;
  }

  setTimeTable(EventTimeTable ett) {
    this.mTimeTable = ett;
  }

  String getMainZohionBaiguulagch() {
    return this.mMainZohionBaiguulagch != null ? this.mMainZohionBaiguulagch : "";
  }

  setMainZohionBaiguulagch(String main) {
    this.mMainZohionBaiguulagch = main;
  }

  List<EventRoom> getRooms() {
    return this.mRooms;
  }

  setRooms(List<EventRoom> _rooms) {
    this.mRooms = _rooms;
  }

  List<EventFaq> getFaqs() {
    return this.mFaqs;
  }

  setFaqs(List<EventFaq> _faqs) {
    this.mFaqs = _faqs;
  }

  List<EventSpeaker> getSpeakers() {
    return this.mSpeakers;
  }

  setSpeakers(List<EventSpeaker> _speakers) {
    this.mSpeakers = _speakers;
  }

  List<EventSpeaker> getFeaturedSpeakers() {
    return this.mFeaturedSpeakers;
  }

  setFeaturedSpeakers(List<EventSpeaker> _speakers) {
    this.mFeaturedSpeakers = _speakers;
  }

  List<EventProgramItem> getPrograms() {
    return this.mPrograms;
  }

  setPrograms(List<EventProgramItem> _programs) {
    this.mPrograms = _programs;
  }

  List<String> getEventDays(int eventId) {
    List<String> days = List<String>();
    lstProgramsByEvent[eventId].forEach((k, v) => days.add(v.getOpenDate()));
    List<String> d = days.toSet().toList();
    return d;
  }
}

final eventData = EventData();

class EventUserPayment {
  final int eventUserId;
  final String paymentCode;
  final bool old;  // bolood ongorson eseh
  bool isPaid = false;
  String paymentType;
  int paymentAmount;
  EventUserPayment({this.eventUserId, this.paymentCode, this.old});
}

class LinkSpeakerProgram {
  Map<int, Map<int, String>> speakerPrograms;          // <speakerId, {<program_id, role>}>
  Map<int, Map<int, String>> programSpeakers;           // <programId, {speaker_ids, role}>
}

