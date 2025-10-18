import 'dart:io';

import 'package:eduevent_hub/components/dropdown_field.dart';
import 'package:eduevent_hub/components/text_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/Events/events.dart';
import '../../models/Events/symposium_events.dart';

class EventStepperPage extends StatefulWidget {
  final String collegeId;

  EventStepperPage({required this.collegeId});

  @override
  _EventStepperPageState createState() => _EventStepperPageState();
}

class _EventStepperPageState extends State<EventStepperPage> {
  final _supabase = Supabase.instance.client;

  int currentStep = 0;

  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController registrationUrlController =
      TextEditingController();
  final TextEditingController totalSeatsController = TextEditingController();

  // DateTime? startTime;
  // DateTime? endTime;

  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  String eventType = 'workshop'; // 'workshop' or 'symposium'

  final ImagePicker _picker = ImagePicker();
  XFile? pickedImage;
  Uint8List? imageBytes;

  List<SymposiumEvent> symposiumWorkshops = [];

  @override
  void initState() {
    super.initState();
    if (eventType == 'symposium') {
      addSymposiumWorkshop();
    }
  }

  Future<void> showDateTimePickerSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets, // keyboard safe
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 5,
                      width: 50,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    /// Date Field
                    TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Select Date",
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: const OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text: selectedDate == null
                            ? ""
                            : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    /// Start Time Field
                    TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "Start Time",
                        prefixIcon: const Icon(Icons.access_time),
                        border: const OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text: startTime == null
                            ? ""
                            : startTime!.format(context),
                      ),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: ctx,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            startTime = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    /// End Time Field
                    TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: "End Time",
                        prefixIcon: const Icon(Icons.access_time_outlined),
                        border: const OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                        text: endTime == null ? "" : endTime!.format(context),
                      ),
                      onTap: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: ctx,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            endTime = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx, {
                          "date": selectedDate,
                          "startTime": startTime,
                          "endTime": endTime,
                        });
                      },
                      child: const Text("Save"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (kIsWeb) {
        imageBytes = await image.readAsBytes();
      }
      setState(() {
        pickedImage = image;
      });
    }
  }

  Widget imagePreview() {
    if (pickedImage != null) {
      if (kIsWeb && imageBytes != null) {
        return Image.memory(imageBytes!, width: 200, height: 200);
      } else {
        return Image.file(File(pickedImage!.path), width: 200, height: 200);
      }
    }
    return Text('No image selected');
  }

  // Future<void> pickStartDate() async {
  //   final picked = await showDatePicker(
  //     context: context,
  //     initialDate: startTime ?? DateTime.now(),
  //     firstDate: DateTime.now(),
  //     lastDate: DateTime(2100),
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       startTime = picked;
  //     });
  //   }
  // }

  // Future<void> pickEndDate() async {
  //   final picked = await showDatePicker(
  //     context: context,
  //     initialDate: endTime ?? DateTime.now(),
  //     firstDate: DateTime.now(),
  //     lastDate: DateTime(2100),
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       endTime = picked;
  //     });
  //   }
  // }

  // Future<void> pickSymposiumStartDate(int index) async {
  //   final picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime.now(),
  //     lastDate: DateTime(2100),
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       symposiumWorkshops[index].startTime = picked.toIso8601String();
  //     });
  //   }
  // }

  // Future<void> pickSymposiumEndDate(int index) async {
  //   final picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime.now(),
  //     lastDate: DateTime(2100),
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       symposiumWorkshops[index].endTime = picked.toIso8601String();
  //     });
  //   }
  // }

  void addSymposiumWorkshop() {
    setState(() {
      symposiumWorkshops.add(
        SymposiumEvent(
          symposiumEventId: '',
          eventId: '',
          name: '',
          description: '',
          startTime: '',
          endTime: '',
          totalSeats: 0,
        ),
      );
    });
  }

  void removeSymposiumWorkshop(int index) {
    setState(() {
      symposiumWorkshops.removeAt(index);
    });
  }

  Future<void> saveEvent() async {
    String getDayOfWeek(DateTime? date) {
      if (date == null) return "";
      return DateFormat('EEEE').format(date);
    }

    String formatTimeOfDay(TimeOfDay tod) {
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
      return DateFormat("HH:mm:ss").format(dt); // 24-hour format for Postgres
    }

    try {
      final totalSeats = int.tryParse(this.totalSeatsController.text) ?? 0;

      final event = Event(
        eventId: '',
        collegeId: widget.collegeId,
        eventName: eventNameController.text,
        eventType: eventType,
        workshopName: eventType == 'workshop' ? eventNameController.text : '',
        description: descriptionController.text,
        startTime: startTime != null ? formatTimeOfDay(startTime!) : "",
        endTime: endTime != null ? formatTimeOfDay(endTime!) : "",
        totalSeats: totalSeats,
        startDate: selectedDate != null
            ? DateFormat("yyyy-MM-dd").format(selectedDate!)
            : "",
        startDay: getDayOfWeek(selectedDate),
        location: locationController.text,
        registrationUrl: registrationUrlController.text,
      );

      final res = await _supabase
          .from('events')
          .insert(event.toJson())
          .select()
          .single();
      final eventId = res['event_id'].toString();

      print('Event created with ID: $eventId');

      if (eventType == 'workshop') {
        if (pickedImage != null) {
          await uploadEventImage(eventId);
        }
      } else if (eventType == 'symposium') {
        for (var symEvent in symposiumWorkshops) {
          symEvent.eventId = eventId;
          await _supabase
              .from('symposium_events')
              .insert(symEvent.toJson())
              .select();
        }
        if (pickedImage != null) {
          await uploadEventImage(eventId);
        }
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Event saved successfully')));
      Navigator.of(context).pop();
    } catch (e) {
      print('Error saving event: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save event')));
    }
  }

  Future<void> uploadEventImage(String eventId) async {
    final filePath = 'Events/EventImages/$eventId/event.png';

    final storage = _supabase.storage.from('event_assets');

    if (kIsWeb) {
      // Upload using bytes for web
      final res = await storage.uploadBinary(
        filePath,
        imageBytes!,
        fileOptions: const FileOptions(upsert: true),
      );
      print('Image upload response (web): $res');
    } else {
      // Upload using File for mobile
      final file = File(pickedImage!.path);
      final res = await storage.upload(
        filePath,
        file,
        fileOptions: const FileOptions(upsert: true),
      );
      print('Image upload response (mobile): $res');
    }

    final publicUrl = storage.getPublicUrl(filePath);
    print('Public URL: $publicUrl');

    await _supabase.from('event_images').insert({
      'event_id': eventId,
      'image_url': publicUrl,
    });

    print('Image metadata added');
  }

  List<Step> getSteps() {
    return [
      Step(
        title: Text('Event Info'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              label: 'Event Name',
              // icon: Icons.event,
              controller: eventNameController,
            ),
            // TextField(
            //   controller: eventNameController,
            //   decoration: InputDecoration(labelText: 'Event Name'),
            // ),
            SizedBox(height: 15),
            CustomDropdownField(
              label: 'select type of event',
              items: ['workshop', 'symposium'],
              value: eventType,
              onChanged: (val) {
                setState(() {
                  eventType = val!;
                  if (eventType == 'symposium') {
                    symposiumWorkshops = [];
                    addSymposiumWorkshop();
                  }
                });
              },
            ),
            SizedBox(height: 15),
            CustomTextField(
              controller: descriptionController,
              label: 'Description',
            ),
            SizedBox(height: 15),
            CustomTextField(controller: locationController, label: 'Location'),
            SizedBox(height: 15),
            CustomTextField(
              controller: registrationUrlController,

              label: 'Registration URL (Optional)',
            ),
          ],
        ),
        isActive: currentStep == 0,
      ),
      Step(
        title: Text('Schedule'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (eventType == 'workshop') ...[
              ElevatedButton(
                onPressed: () async {
                  await showDateTimePickerSheet(context);

                  // 👉 {date: 2025-09-20 00:00:00.000, startTime: TimeOfDay(10:30), endTime: TimeOfDay(12:00)}
                },
                child: Text('Pick Start Date'),
              ),

              // Text(
              //   startTime != null
              //       ? startTime!.toLocal().toString().split(' ')[0]
              //       : 'Select start date',
              // ),
              // ElevatedButton(
              //   onPressed: pickEndDate,
              //   child: Text('Pick End Date'),
              // ),
              // Text(
              //   endTime != null
              //       ? endTime!.toLocal().toString().split(' ')[0]
              //       : 'Select end date',
              // ),
              SizedBox(height: 15),
              TextField(
                controller: totalSeatsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Total Seats'),
              ),
            ],
            if (eventType == 'symposium') ...[
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: symposiumWorkshops.length,
                itemBuilder: (context, index) {
                  final workshop = symposiumWorkshops[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          TextField(
                            onChanged: (val) => workshop.name = val,
                            decoration: InputDecoration(
                              labelText: 'Workshop Name',
                            ),
                          ),
                          TextField(
                            onChanged: (val) => workshop.description = val,
                            decoration: InputDecoration(
                              labelText: 'Workshop Description',
                            ),
                          ),
                          // ElevatedButton(
                          //   onPressed: () => pickSymposiumStartDate(index),
                          //   child: Text('Pick Start Date'),
                          // ),
                          Text(
                            workshop.startTime.isNotEmpty
                                ? workshop.startTime.split('T')[0]
                                : 'Select start date',
                          ),
                          // ElevatedButton(
                          //   onPressed: () => pickSymposiumEndDate(index),
                          //   child: Text('Pick End Date'),
                          // ),
                          Text(
                            workshop.endTime.isNotEmpty
                                ? workshop.endTime.split('T')[0]
                                : 'Select end date',
                          ),
                          TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (val) =>
                                workshop.totalSeats = int.tryParse(val) ?? 0,
                            decoration: InputDecoration(
                              labelText: 'Total Seats',
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => removeSymposiumWorkshop(index),
                            child: Text('Remove Workshop'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              ElevatedButton(
                onPressed: addSymposiumWorkshop,
                child: Text('Add Workshop'),
              ),
            ],
          ],
        ),
        isActive: currentStep == 1,
      ),
      Step(
        title: Text('Image'),
        content: Column(
          children: [
            ElevatedButton(
              onPressed: pickImage,
              child: Text('Pick Event Image'),
            ),
            SizedBox(height: 10),
            imagePreview(),
          ],
        ),
        isActive: currentStep == 2,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Event')),
      body: Stepper(
        currentStep: currentStep,
        steps: getSteps(),
        onStepContinue: () {
          if (currentStep < 2) {
            setState(() {
              currentStep += 1;
            });
          } else {
            saveEvent();
          }
        },
        onStepCancel: () {
          if (currentStep > 0) {
            setState(() {
              currentStep -= 1;
            });
          }
        },
      ),
    );
  }
}
