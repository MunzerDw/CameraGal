import 'dart:async';
import 'dart:math';
import 'package:App/Components/AddGallery/AddGallery.dart';
import 'package:App/Components/GalleriesCard/GalleriesCard.dart';
import 'package:flutter/material.dart';

import '../../Storage.dart';

class Galleries extends StatefulWidget {
  final List<String> galleries;
  final Function addGalleryFromHome;
  final Function deleteGalleryFromHome;
  Galleries(
      {@required this.galleries,
      @required this.addGalleryFromHome,
      @required this.deleteGalleryFromHome});

  @override
  _GalleriesState createState() => _GalleriesState();
}

class _GalleriesState extends State<Galleries> {
  GlobalKey<AnimatedListState> _listKey = GlobalKey();

  Widget _buildItem(
      BuildContext context, int index, String item, Animation animation) {
    TextEditingController textFieldController = TextEditingController();
    textFieldController.text = item;
    return index != 0
        ? Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: SizeTransition(
              sizeFactor: animation,
              axis: Axis.vertical,
              child: GalleriesCard(
                title: item,
                deleteGallery: this._removeItem,
                editGallery: this._editGallery,
                textFieldController: textFieldController,
              ),
            ),
          )
        : Center(
            child: Container(
            padding: EdgeInsets.fromLTRB(20, 100, 20, 100),
            child: Text(
              "Galleries",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 40.0,
                  color: Colors.black),
            ),
          ));
  }

  Future<bool> _addAnItem(String gallery) async {
    if (widget.galleries.contains(gallery) || gallery == "") {
      return false;
    }
    if (await widget.addGalleryFromHome(gallery)) {
      setState(() {
        _listKey.currentState.insertItem(widget.galleries.length);
      });
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _removeItem(String gallery) async {
    int index = widget.galleries.indexOf(gallery);
    if (await widget.deleteGalleryFromHome(gallery)) {
      setState(() {
        _listKey.currentState.removeItem(
          index + 1,
          (BuildContext context, Animation animation) => _buildItem(
              context, widget.galleries.indexOf(gallery), gallery, animation),
          duration: const Duration(milliseconds: 250),
        );
      });
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _editGallery(String gallery, String newName) async {
    int index = widget.galleries.indexOf(gallery);
    if ((widget.galleries.indexOf(newName) != index &&
            widget.galleries.contains(newName)) ||
        newName == "") {
      return false;
    }

    if (await Storage.editGalleryName(gallery, newName)) {
      setState(() {
        _listKey.currentState.removeItem(
          index,
          (BuildContext context, Animation animation) =>
              _buildItem(context, index, gallery, animation),
          duration: const Duration(milliseconds: 0),
        );
        widget.galleries.remove(gallery);

        widget.galleries.insert(index, newName);
        _listKey.currentState
            .insertItem(index, duration: Duration(milliseconds: 0));
      });
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Container(
          margin: EdgeInsets.fromLTRB(0, 0, 10, 5),
          child: FloatingActionButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (_) => AddGallery(
                        addGallery: this._addAnItem,
                      ));
            },
            backgroundColor: Colors.green[300],
            child: Icon(Icons.add),
            elevation: 2,
          ),
        ),
        body: Container(
            color: Colors.grey[100],
            child: Column(
              children: <Widget>[
                Expanded(
                    child: AnimatedList(
                  padding: EdgeInsets.fromLTRB(0, 20, 0, 80),
                  shrinkWrap: true,
                  key: this._listKey,
                  initialItemCount: widget.galleries.length + 1,
                  itemBuilder: (context, index, animation) => _buildItem(
                      context,
                      index,
                      (index == 0 ? 0 : index - 1) >= widget.galleries.length
                          ? ""
                          : widget.galleries[index == 0 ? 0 : index - 1],
                      animation),
                )),
              ],
            )));
  }
}