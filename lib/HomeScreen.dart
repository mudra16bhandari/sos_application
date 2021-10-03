import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sos_application/EmergencyContactList.dart';
import 'package:shake/shake.dart';
import 'package:telephony/telephony.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Contact> emergencyContacts = [];
  List<Contact> contactsList = [];
  ShakeDetector? detector;
  final Telephony telephony = Telephony.instance;


  @override
  void initState() {
    super.initState();
    detector = ShakeDetector.autoStart(onPhoneShake: () {
      sendMessage();
    });
  }

  Future<PermissionStatus> _getPermission() async {
    bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted) {
      final Map<Permission, PermissionStatus> permissionStatus =
      await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ?? PermissionStatus.limited;
    } else {
      return permission;
    }
  }

  Future<void> _getContacts() async {
    final List<Contact> contacts = await ContactsService.getContacts();
    contactsList = contacts;
  }

  addContact(int length) async {
    if (length < 3) {
      await _getContacts();
      showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(contactsList
                        .elementAt(index)
                        .displayName!),
                    trailing: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          emergencyContacts.add(contactsList.elementAt(index));
                        });
                      },
                      child: emergencyContacts.length<3 ? Text("Add") : Container(),
                    ),
                  );
                },
                itemCount: contactsList.length,
              ),
            );
          });
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: Text('Limit reached'),
            );
          });
    }
  }

  sendMessage() {
    for (int i = 0; i < emergencyContacts.length; i++) {
      print('Here');
        telephony.sendSms(to: emergencyContacts.elementAt(i).phones!.first.value.toString(), message: "I'm in danger, please Help!");
    }
  }

    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('SoS Application'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Emergency Contacts'),
                  IconButton(
                      onPressed: () async {
                        await addContact(emergencyContacts.length);
                      },
                      icon: Icon(Icons.add)),
                ],
              ),
            ),
            FutureBuilder(
                future: _getPermission(),
                builder: (context, snapshot) {
                  if (snapshot.data.toString().contains('granted')) {
                    return EmergencyContactList(emergencyContacts);
                  } else {
                    return Text("Please Enable Contact Permissions");
                  }
                })
          ],
        ),
      );
    }
  }
