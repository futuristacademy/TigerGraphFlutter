import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'config.dart';

import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TigerGraph POST Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UserScreen(title: 'User Profile (Demo with TigerGraph)'),
    );
  }
}

//Create a basic userScreen
class UserScreen extends StatefulWidget {
  UserScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  Vertex userVertex;
  final String host = hostRaghava; //CHANGE THIS TO YOUR TIGERGRAPH HOST NAME
  final String authKey = authKeyRaghava; //CHANGE THIS TO YOUR TIGERGRAPH AUTH KEY

  Future<Map> fetchPost(String vertexType, int vertexID) async { //Returns JSON from HTTP GET call for vertexType and vertexID specified in parameters
    final response = await http.get(returnHttpUrl(host,vertexType, vertexID),
      headers: {
        HttpHeaders.authorizationHeader: authKey},
    );
    if (response.statusCode == 200) { // connection is made with server
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load post'); //connection failed
    }
  }

  ListView _buildAttributeList() {
    double sW = MediaQuery.of(context).size.width;
    double sH = MediaQuery.of(context).size.height;
    Map userAttributes = userVertex.attributes;
    List attributeKeyList = userAttributes.keys.toList();

    return ListView.builder(
      // Must have an item count equal to the number of items!
      itemCount: attributeKeyList.length,
      // A callback that will return a widget.
      itemBuilder: (context, i) {
        String attributeKey = attributeKeyList[i];
        return Card(
            child: ListTile(
              title: Text(attributeKey + ':',
                  textAlign: TextAlign.left,
                  style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: Sizer.getTextSize(sW, sH, 20))),
              trailing: Text(userAttributes[attributeKey],
                  textAlign: TextAlign.center,
                  style: new TextStyle(
                      fontSize: Sizer.getTextSize(sW, sH, 20),
                      color: Colors.black)
              ),
            )
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double pixelTwoWidth = 411.42857142857144;
    double pixelTwoHeight = 683.4285714285714;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              StreamBuilder(
                stream: Stream.fromFuture(fetchPost('Person',1164982)), //Original values for testing, returns info for Raghava Uppuluri
                builder: (context, snapshot) {
                  if(snapshot.hasData)
                  {
                    userVertex = Vertex.fromJson(snapshot.data); //gets attributes and vertex data from JSON
                    return Center(
                      child: Container(
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          height: screenHeight * 0.7,
                          width: screenWidth * 0.9,

                          child: _buildAttributeList() //builds profile of attributes (information about user in this case)
                      ),
                    );
                  }
                  else{
                    return Container(
                        alignment: Alignment.center,
                        child: Column(
                          children: <Widget>[
                            Text(
                              "Connecting...",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: "Lato",
                                color: Colors.grey,
                                fontSize: 32 * screenWidth / pixelTwoWidth,
                              ),
                            ),
                            CircularProgressIndicator()
                          ],
                        )
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

//TigerGraph vertex object (add edges object in the future)
class Vertex {
  final String vertexId;
  final String vertexType;
  final Map attributes;

  Vertex({this.vertexId, this.vertexType, this.attributes});

  factory Vertex.fromJson(Map<String, dynamic> json) { //creates Vertex object from http GET call to TigerGraph graph
    return Vertex(
      vertexId: json['results'][0]['v_id'],
      vertexType: json['results'][0]['v_type'],
      attributes: json['results'][0]['attributes'],
    );
  }
}

class Sizer {
  //pixel 2 width and height
  static const double pW = 411.42857142857144;
  static const double pH = 683.4285714285714;

  //grabs the text size
  static double getTextSize(double w, double h, double s) {
    return s * w / pW;
  }
}

