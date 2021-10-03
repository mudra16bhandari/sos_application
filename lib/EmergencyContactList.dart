import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';

class EmergencyContactList extends StatefulWidget {
  final List<Contact> emergencyContacts;
  EmergencyContactList(this.emergencyContacts);

  @override
  State<EmergencyContactList> createState() => _EmergencyContactListState();
}

class _EmergencyContactListState extends State<EmergencyContactList> {
  @override
  Widget build(BuildContext context) {
    if(widget.emergencyContacts.isEmpty){
      return Container(child: Text("Here"),);
    }
    else{
      return Container(
        height: 500,
        child: ListView.builder(itemBuilder: (context,index){
          return ListTile(title: Text(widget.emergencyContacts.elementAt(index).displayName!),
          subtitle: Text(widget.emergencyContacts.elementAt(index).phones!.first.value.toString()),
            trailing: ElevatedButton(child: Text('Delete'),onPressed: (){
              setState(() {
                widget.emergencyContacts.removeAt(index);
              });
            },),
          );
        },
          itemCount: widget.emergencyContacts.length,
        ),
      );
    }
  }
}
