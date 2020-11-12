import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_video_compress/flutter_video_compress.dart';
//import 'package:video_compress/video_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:video_trimmer/video_trimmer.dart';

import '../models/resource_model.dart';
import '../screens/trim_video_screen.dart';
import '../screens/gallery_screen.dart';
import '../providers/content_provider.dart';
import '../providers/user_provider.dart';

class UserProfileCover extends StatefulWidget {
  final List<ResourceModel> stories;

  UserProfileCover(this.stories);

  @override
  _UserProfileCoverState createState() => _UserProfileCoverState();
}

class _UserProfileCoverState extends State<UserProfileCover> {
  final Trimmer _trimmer = Trimmer();
  List<ResourceModel> _histories = [];

  void _imageOptions(pos) {
    bool showDelete = false;
    switch (pos) {
      case 0:
        if (_histories.length > 0) showDelete = true;
        break;
      case 1:
        if (_histories.length > 1) showDelete = true;
        break;
      case 2:
        if (_histories.length > 2) showDelete = true;
        break;
    }
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          color: Colors.transparent,
          child: Wrap(
            children: <Widget>[
              ListTile(
                onTap: () => _openCamera(pos),
                leading: Icon(
                  Icons.camera_alt,
                ),
                title: Text("Foto"),
              ),
              ListTile(
                onTap: () => _takeVideo(pos),
                leading: Icon(
                  Icons.videocam,
                ),
                title: Text("Video"),
              ),
              ListTile(
                onTap: () => _openGallery(pos),
                leading: Icon(
                  Icons.image,
                ),
                title: Text("Galería"),
              ),
              if (showDelete)
                ListTile(
                  onTap: () => _deleteFile(pos),
                  leading: Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  title: Text(
                    "Eliminar",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _deleteFile(pos) async {
    Navigator.of(context).pop();
    List stories = [];
    _histories.forEach((e) {
      stories.add({'resource': e.id});
    });
    stories.removeAt(pos);

    Map result = await Provider.of<UserProvider>(context, listen: false)
        .editProfile(stories: stories);

    if (result['result']) {
      setState(() {
        _histories.removeAt(pos);
      });
    }
  }

  void _openCamera(pos) async {
    Navigator.of(context).pop();
    final imageFile = await ImagePicker().getImage(
      source: ImageSource.camera,
    );
    if (imageFile != null) {
      _cropImage(pos, imageFile.path);
    }
  }

  void _openGallery(pos) {
    Navigator.of(context).pop();

    Navigator.of(context)
        .pushNamed(GalleryScreen.routeName)
        .then((value) async {
      if (value != null) {
        AssetEntity asset = value as AssetEntity;
        if (asset.type == AssetType.video) {
          File videoFile = await asset.file;
          _trimVideo(pos, videoFile);
        } else {
          File imgFile = await asset.file;
          _cropImage(pos, imgFile.path);
        }
      }
    });
  }

  Future<void> _takeVideo(pos) async {
    Navigator.of(context).pop();
    final videoFile = await ImagePicker().getVideo(
      source: ImageSource.camera,
      maxDuration: Duration(seconds: 60),
    );
    if (videoFile != null) {
      _trimVideo(pos, File(videoFile.path));
    }
  }

  void _cropImage(pos, pathFile) async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: pathFile,
      aspectRatio: CropAspectRatio(ratioX: 9, ratioY: 16),
    );
    if (cropped != null) {
      _newHistory(pos, cropped, false);
    }
  }

  void _trimVideo(pos, videoFile) async {
    await _trimmer.loadVideo(videoFile: File(videoFile.path));
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return TrimmerView(_trimmer);
      }),
    ).then((value) async {
      if (value != null) {
        _newHistory(pos, File(value), true);
      }
    });
  }

  void _newHistory(int position, File file, bool isVideo) async {
    Map resourceMap;
    String thumbnail;
    if (isVideo) {
      final mFile = await FlutterVideoCompress().getThumbnailWithFile(
      //final mFile = await VideoCompress.getFileThumbnail(
        file.path,
        //imageFormat: ImageFormat.JPEG,
        quality: 50,
      );
      Map thumbnailMap =
          await Provider.of<ContentProvider>(context, listen: false)
              .uploadResourceGetUrl(
        mFile.path,
        'I',
        'U',
      );
      thumbnail = thumbnailMap['url'];

      resourceMap = await Provider.of<ContentProvider>(context, listen: false)
          .uploadVideo(
        filePath: file.path,
        type: 'V',
        content: 'U',
        thumbId: thumbnailMap['id'],
        duration: 0,
        ratio: 0,
      );
    } else {
      resourceMap = await Provider.of<ContentProvider>(context, listen: false)
          .uploadResourceGetUrl(
        file.path,
        'I',
        'U',
      );
    }

    List stories = [];
    _histories.forEach((e) {
      stories.add({'resource': e.id});
    });
    if (stories.length > position) {
      stories[position] = {'resource': resourceMap['id']};
    } else {
      stories.add({'resource': resourceMap['id']});
    }

    Map result = await Provider.of<UserProvider>(context, listen: false)
        .editProfile(stories: stories);

    if (result['result']) {
      setState(() {
        ResourceModel newStory = ResourceModel(
          id: resourceMap['id'],
          type: isVideo ? 'V' : 'I',
          thumbnail: thumbnail,
          url: resourceMap['url'],
        );
        if (_histories.length > position) {
          _histories[position] = newStory;
        } else {
          _histories.add(newStory);
        }
      });
    }
  }

  Widget _story(pos) {
    final ResourceModel res = _histories[pos];
    return CachedNetworkImage(
        imageUrl: res.type == 'V' ? res.thumbnail : res.url);
  }

  Widget _placeholder() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          alignment: Alignment.topRight,
          padding: const EdgeInsets.only(right: 8),
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        Spacer(flex: 1),
        const Text(
          'Tu historia',
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 8),
        const Icon(
          Icons.movie,
          color: Colors.white,
        ),
        Spacer(flex: 1),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _histories = widget.stories;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width / 3;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_histories.length >= 0)
          Container(
            width: width,
            color: Colors.grey,
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: GestureDetector(
                onTap: () => _imageOptions(0),
                child: _histories.length > 0 ? _story(0) : _placeholder(),
              ),
            ),
          ),
        if (_histories.length >= 1)
          Container(
            width: width,
            color: Colors.grey,
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: GestureDetector(
                onTap: () => _imageOptions(1),
                child: _histories.length > 1 ? _story(1) : _placeholder(),
              ),
            ),
          ),
        if (_histories.length >= 2)
          Container(
            width: width,
            color: Colors.grey,
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: GestureDetector(
                onTap: () => _imageOptions(2),
                child: _histories.length > 2 ? _story(2) : _placeholder(),
              ),
            ),
          ),
      ],
    );
  }
}