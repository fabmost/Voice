import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryScreen extends StatefulWidget {
  static const routeName = '/gallery';

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<GalleryScreen> {
  List<AssetPathEntity> _albums = [];
  List<Widget> _mediaList = [];
  int currentPage = 0;
  int lastPage;
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    _fetchNewMedia();
  }

  Widget _albumDropDown() {
    int pos = -1;
    return DropdownButtonHideUnderline(
      child: DropdownButton(
        value: _selected,
        icon: Icon(Icons.arrow_drop_down),
        iconSize: 32,
        iconEnabledColor: Colors.white,
        items: _albums.map((value) {
          pos++;
          return DropdownMenuItem(
            value: pos,
            child: Text(value.name),
          );
        }).toList(),
        selectedItemBuilder: (BuildContext context) {
          return _albums.map((value) {
            return Container(
              alignment: Alignment.center,
              child: Text(
                value.name,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            );
          }).toList();
        },
        onChanged: (value) {
          setState(() {
            currentPage = 0;
            _mediaList.clear();
            _selected = value;
            _fetchNewMedia();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _albums.isEmpty ? Text('Galería') : _albumDropDown(),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scroll) {
          _handleScrollEvent(scroll);
          return;
        },
        child: GridView.builder(
            itemCount: _mediaList.length,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            itemBuilder: (BuildContext context, int index) {
              return _mediaList[index];
            }),
      ),
    );
  }

  _handleScrollEvent(ScrollNotification scroll) {
    if (scroll.metrics.pixels / scroll.metrics.maxScrollExtent > 0.33) {
      if (currentPage != lastPage) {
        _fetchNewMedia();
      }
    }
  }

  _fetchNewMedia() async {
    lastPage = currentPage;
    var result = await PhotoManager.requestPermission();
    if (result) {
      // success
      //load the album list
      if (_albums.isEmpty)
        _albums = await PhotoManager.getAssetPathList(onlyAll: false);
      List<AssetEntity> media =
          await _albums[_selected].getAssetListPaged(currentPage, 60);
      print(media);
      List<Widget> temp = [];
      for (var asset in media) {
        temp.add(
          FutureBuilder(
            future: asset.thumbDataWithSize(200, 200),
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done)
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(asset);
                  },
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: Image.memory(
                          snapshot.data,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (asset.type == AssetType.video)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 5, bottom: 5),
                            child: Icon(
                              Icons.videocam,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              return Container();
            },
          ),
        );
      }
      setState(() {
        _mediaList.addAll(temp);
        currentPage++;
      });
    } else {
      // fail
      /// if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
    }
  }
}
