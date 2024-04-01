import 'package:chat_app/consts.dart';
import 'package:chat_app/login_screen.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/services/auth_services.dart';
import 'package:chat_app/services/database_services.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GetIt getIt = GetIt.instance;
  late AuthServices _authServices;
  late DatabaseServices _databaseServices;

  @override
  void initState() {
    super.initState();
    _authServices = getIt.get<AuthServices>();
    _databaseServices = getIt.get<DatabaseServices>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            'live Chat App',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 20, right: 10),
            child: IconButton(
              onPressed: () {
                // Handle logout
                _authServices.signOut().then((value) => {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()))
                    });
              },
              icon: Icon(Icons.logout),
            ),
          )
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        SizedBox(height: 30),
        Expanded(
          child: chatsList(),
        )
      ],
    );
  }

  Widget chatsList() {
    return StreamBuilder(
        stream: _databaseServices.getUsers(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                          title: Text(snapshot.data.docs[index]['name']),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                                snapshot.data.docs[index]['pfpURL']),
                            radius: 30,
                          )),
                    ),
                  );
                });
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}
