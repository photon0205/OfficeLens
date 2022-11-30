import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<File> imgList = [];
  ImagePicker image = ImagePicker();
  final pdf = pw.Document();
  getImagecam() async {
    var img = await image.pickImage(source: ImageSource.camera);
    if (img == null) {
      return;
    }
    setState(() {
      imgList.add(File(img!.path));
    });
  }

  getImage() async {
    var img = await image.pickImage(source: ImageSource.gallery);
    if (img == null) {
      return;
    }
    setState(() {
      imgList.add(File(img!.path));
    });
  }

  createPDF() async {
    for (var img in imgList) {
      final image = pw.MemoryImage(img.readAsBytesSync());

      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context contex) {
            return pw.Center(child: pw.Image(image));
          }));
      final dir = await getExternalStorageDirectory();
      final file = File('${dir!.path}/filename.pdf');
      final _result = await OpenFile.open(file.path);
    }
  }

  savePDF() async {
    try {
      final dir = await getExternalStorageDirectory();
      final file = File('${dir!.path}/filename.pdf');
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('success' + 'saved to documents'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'error : $e',
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OfficeLens"),
      ),
      body: Container(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...List.generate(
                    imgList.length,
                    (index) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 80,
                            width: 80,
                            child: Image.file(imgList[index]),
                          ),
                        )),
                InkWell(
                  onTap: (() => showDialog(
                      context: context,
                      builder: (context1) {
                        return Dialog(
                          child: SizedBox(
                              height: 100,
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      getImagecam();
                                      Navigator.of(context1).pop();
                                    },
                                    child: SizedBox(
                                      height: 50,
                                      child: Row(
                                        children: const [
                                          Icon(Icons.camera),
                                          Text("Camera"),
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      getImage();
                                      Navigator.of(context1).pop();
                                    },
                                    child: SizedBox(
                                      height: 50,
                                      child: Row(
                                        children: const [
                                          Icon(Icons.image),
                                          Text("Gallery"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                        );
                      })),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      alignment: Alignment.center,
                      height: 80,
                      width: 80,
                      color: Colors.black.withOpacity(0.3),
                      child: const Text(
                        "+",
                        style: TextStyle(color: Colors.white, fontSize: 80),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              createPDF();
            },
            child: const Text("Create"),
          ),
        ]),
      ),
    );
  }
}