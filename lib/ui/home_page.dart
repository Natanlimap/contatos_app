import 'dart:io';
import 'dart:math';

import 'package:contacts/domain/contact.dart';
import 'package:contacts/helper/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';

import 'contact_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();
  Contact _lastRemoved = Contact();
  List<Contact> contatos = [];

  //carregando a lista de contatos do banco ao iniciar o app
  @override
  void initState() {
    super.initState();
    //then retorna um futuro e coloca em list
    updateList();
  }

  void updateList() {
    helper.getAllContact().then((list) {
      //atualizando a lista de contatos na tela
      setState(() {
        contatos = list.cast<Contact>();
        contatos.sort((a, b) => a.name.compareTo(b.name));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String lastLetter = "";
    return Scaffold(
      appBar: _customAppBar(),
      backgroundColor: Colors.white,
      body: ListView.builder(
          itemCount: contatos.length,
          itemBuilder: (context, index) {
            String firstLetter = contatos[index].name[0].toUpperCase();

            if (firstLetter != lastLetter) {
              lastLetter = firstLetter;
              return Expanded(
                  child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    width: double.infinity,
                    color: const Color(0xffF7F7FC),
                    margin: const EdgeInsets.only(bottom: 32),
                    child: Text(
                      firstLetter.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                  ),
                  _contatoCard(context, index),
                ],
              ));
            } else {
              return _contatoCard(context, index);
            }
          }),
    );
  }

  /// Função para criação de um card de contato para lista.
  Widget _contatoCard(BuildContext context, int index) {
    return Slidable(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      startActionPane: ActionPane(motion: const ScrollMotion(), children: [
        SlidableAction(
          onPressed: (a) {
            launch("tel:${contatos[index].phone}");
          },
          icon: Icons.call,
          backgroundColor: const Color(0xff4680FF),
          label: "Call",
        ),
        SlidableAction(
          onPressed: (a) {
            _showContactPage(contact: contatos[index]);
          },
          icon: Icons.edit,
          backgroundColor: Colors.deepOrange,
          label: "Edit",
        ),
      ]),
      endActionPane: ActionPane(motion: const ScrollMotion(), children: [
        SlidableAction(
          onPressed: (a) {
            _lastRemoved = contatos[index];
            helper.deleteContact(contatos[index].id);
            updateList();
            final snack = SnackBar(
              content: Text("${_lastRemoved.name} foi excluido dos contatos."),
              action: SnackBarAction(
                  label: "Desfazer",
                  onPressed: () {
                    setState(() async {
                      await helper.saveContact(_lastRemoved);
                      updateList();
                    });
                  }),
              duration: const Duration(seconds: 2),
            );
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(snack);
          },
          icon: Icons.delete,
          backgroundColor: Colors.red,
          label: "Delete",
        ),
      ]),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16, top: 16),
        child: ListTile(
          minLeadingWidth: 20,
          leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.transparent,
              child: SizedBox(
                width: 60,
                height: 60,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: contatos[index].img == ""
                      ? Container(
                          alignment: Alignment.center,
                          color: Colors.black,
                          child: Text(
                            contatos[index].name.substring(
                                0, min(2, contatos[index].name.length)),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      : Image.file(
                          File(contatos[index].img),
                          fit: BoxFit.cover,
                        ),
                ),
              )),
          title: Text(
            contatos[index].name,
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            contatos[index].phone,
            style: const TextStyle(fontSize: 15.0),
          ),
          enabled: true,
        ),
      ),
    );
  }

  _customAppBar() {
    return AppBar(
      title: const Text(
        "Contacts",
        style: TextStyle(color: Colors.black, fontSize: 16),
      ),
      backgroundColor: Colors.white,
      centerTitle: true,
      actions: [
        GestureDetector(
          onTap: () => {
            _showContactPage(),
          },
          child: const Icon(
            Icons.add,
            size: 30,
            color: Colors.grey,
          ),
        )
      ],
    );
  }

  //mostra o contato. Parâmetro opcional
  _showContactPage({Contact? contact}) async {
    Contact contatoRet = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact)));

    if (contatoRet.id == 0) {
      await helper.saveContact(contatoRet);
    } else {
      await helper.updateContact(contatoRet);
    }

    updateList();
  }
}
