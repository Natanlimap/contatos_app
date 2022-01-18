import 'dart:io';
import 'dart:math';

import 'package:contacts/domain/contact.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatefulWidget {
  Contact? contact;

  //construtor que inicia o contato.
  //Entre chaves porque é opcional.
  ContactPage({Key? key, this.contact}) : super(key: key);

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  Contact _editedContact = Contact();
  bool _userEdited = false;
  bool _isEditing = false;
  //para garantir o foco no nome
  final _nomeFocus = FocusNode();

  //controladores
  TextEditingController nomeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  void isEdittingAction() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  void initState() {
    super.initState();

    //acessando o contato definido no widget(ContactPage)
    //mostrar se ela for privada
    if (widget.contact == null) {
      _editedContact = Contact();
      setState(() {
        _isEditing = true;
      });
    } else {
      _editedContact = widget.contact!;

      nomeController.text = _editedContact.name;
      emailController.text = _editedContact.email;
      phoneController.text = _editedContact.phone;
    }
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Abandonar alteração?"),
              content: const Text("Os dados serão perdidos."),
              actions: <Widget>[
                TextButton(
                    child: const Text("cancelar"),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                TextButton(
                  child: const Text("sim"),
                  onPressed: () {
                    //desempilha 2x
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
    } else {
      return Future.value(true);
    }
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    //com popup de confirmação
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
            leading: GestureDetector(
              onTap: () async {
                bool canPop = await _requestPop();
                if (_editedContact.name.isNotEmpty && canPop) {
                  Navigator.pop(context, _editedContact);
                } else if (_userEdited == false) {
                  Navigator.pop(context);
                }
              },
              child: const Icon(Icons.arrow_back),
            ),
            actions: [
              GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_editedContact.name != "") {
                        _userEdited = false;
                        isEdittingAction();
                      } else {
                        FocusScope.of(context).requestFocus(_nomeFocus);
                      }
                    });
                  },
                  child: SizedBox(
                      height: 60,
                      width: 60,
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(10)),
                        child: Icon(
                          _isEditing == true ? Icons.check : Icons.edit,
                          size: 20,
                          color: Colors.white,
                        ),
                      )))
            ],
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.grey,
            centerTitle: true),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.transparent,
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: _editedContact.img == ""
                            ? Container(
                                alignment: Alignment.center,
                                color: Colors.black,
                                child: Text(
                                  _editedContact.name.substring(
                                      0, min(2, _editedContact.name.length)),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : Image.file(
                                File(_editedContact.img),
                                fit: BoxFit.cover,
                              ),
                      ),
                    )),
                onTap: () {
                  ImagePicker()
                      .pickImage(source: ImageSource.camera, imageQuality: 50)
                      .then((file) {
                    if (file == null) {
                      return;
                    } else {
                      setState(() {
                        _editedContact.img = file.path;
                      });
                    }
                  });
                },
              ),
              _editedContact.name != ""
                  ? Text(
                      _editedContact.name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )
                  : Container(),
              _editedContact.phone != ""
                  ? Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        _editedContact.phone,
                        style: const TextStyle(color: Colors.black45),
                      ),
                    )
                  : Container(),
              _editedContact.email != ""
                  ? Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        _editedContact.email,
                        style: const TextStyle(color: Colors.black45),
                      ),
                    )
                  : Container(),
              const SizedBox(
                height: 32,
              ),
              _isEditing
                  ? TextField(
                      controller: nomeController,
                      focusNode: _nomeFocus,
                      decoration: const InputDecoration(labelText: "Nome"),
                      onChanged: (text) {
                        _userEdited = true;
                        setState(() {
                          _editedContact.name = text;
                        });
                      },
                    )
                  : Container(),
              _isEditing
                  ? TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: "E-mail"),
                      onChanged: (text) {
                        _userEdited = true;
                        _editedContact.email = text;
                      },
                    )
                  : Container(),
              _isEditing
                  ? TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: "Telefone"),
                      onChanged: (text) {
                        _userEdited = true;
                        _editedContact.phone = text;
                      },
                    )
                  : Container(),
              _isEditing == false
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            launch("sms:${_editedContact.phone}");
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            child: const Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.white,
                            ),
                            decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            launch("tel:${_editedContact.phone}");
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            child: const Icon(
                              Icons.call,
                              color: Colors.white,
                            ),
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            launch("sms:${_editedContact.phone}");
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            child: const Icon(
                              CupertinoIcons.video_camera,
                              size: 30,
                              color: Colors.white,
                            ),
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            launch("sms:${_editedContact.phone}");
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            child: const Icon(
                              Icons.email,
                              color: Colors.white,
                            ),
                            decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        )
                      ],
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
