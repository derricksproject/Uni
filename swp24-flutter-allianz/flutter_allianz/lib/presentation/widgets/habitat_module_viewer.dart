import 'package:ditredi/ditredi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_allianz/application/camera_controller.dart';
import 'package:flutter_allianz/enums/page_index.dart';
import 'package:flutter_allianz/presentation/pages/skeleton.dart';


/// A StatefulWidget that represents the Habitat Module view.
/// This widget displays 3D models of a habitat, PBR (photobioreactor), and sensor boards,
/// and allows navigation between different pages and camera control.
/// 
/// **Author**: Gagan Lal.
class HabitatModuleView extends StatefulWidget {
  const HabitatModuleView({super.key});

  @override
  HabitatModuleViewState createState() => HabitatModuleViewState();
}

class HabitatModuleViewState extends State<HabitatModuleView> {
  late final CameraController _cameraController;

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController();
  }

  /// Loads 3D modules such as habitat, PBR, and sensor boards.
  /// 
  /// This method loads different 3D models from the assets folder,
  /// applies colors to the sensor boards, and returns a list of meshes.
  Future<List<Mesh3D>> _loadModules() async {
    // Load different modules from assets
    final habitatFaces = await ObjParser().loadFromResources('assets/laboratory/module_small.obj');
    final pbrFaces = await ObjParser().loadFromResources('assets/pbr/pbr_small.obj');
    final sensorboardFaces = await ObjParser().loadFromResources('assets/sensorboard/sensorboard_small.obj');

    // Apply colors to different sensor boards
    final sensorboardBlueFaces = sensorboardFaces.map((face) => face.copyWith(color: Colors.blue)).toList();
    final sensorboardGreenFaces = sensorboardFaces.map((face) => face.copyWith(color: const Color.fromARGB(255, 255, 230, 0))).toList();
    final sensorboardPurpleFaces = sensorboardFaces.map((face) => face.copyWith(color: Colors.purple)).toList();
    final sensorboardOrangeFaces = sensorboardFaces.map((face) => face.copyWith(color: const Color.fromARGB(255, 1, 241, 253))).toList();

    // Create Mesh3D objects for each module
    final habitat = Mesh3D(habitatFaces); 
    final pbr = Mesh3D(pbrFaces.map((face) => face.copyWith(color: Colors.red)).toList());
    final sensorboardBlue = Mesh3D(sensorboardBlueFaces);
    final sensorboardGreen = Mesh3D(sensorboardGreenFaces);
    final sensorboardPurple = Mesh3D(sensorboardPurpleFaces);
    final sensorboardOrange = Mesh3D(sensorboardOrangeFaces);

    return [habitat, pbr, sensorboardBlue, sensorboardGreen, sensorboardPurple, sensorboardOrange];
  }

  /// Navigates to a specified page in the application.
  /// 
  /// This method changes the page in the Skeleton widget by calling
  /// the `changePage` method with the specified `PageIndex`.
  void _navigateToPage(PageIndex page) {
    Skeleton.changePage(page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<List<Mesh3D>>(
            future: _loadModules(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) {
                      final dx = details.localPosition.dx;
                      final dy = details.localPosition.dy;

                      if (dx > 100 && dx < 200 && dy > 150 && dy < 250) {
                        _navigateToPage(PageIndex.photobioreactor);
                      } else if (dx > 300 && dx < 400 && dy > 150 && dy < 250) {
                        _navigateToPage(PageIndex.sensorboards);
                      }
                    },
                    child: Stack(
                      children: [
                        DiTreDiDraggable(
                          controller: _cameraController.controller,
                          child: DiTreDi(
                            figures: [
                              snapshot.data![0], // Habitat
                              TransformModifier3D(
                                snapshot.data![1], // PBR
                                Matrix4.identity()
                                  ..translate(10.0, -15.0, 58.0)
                                  ..rotateX(4.7124)
                                  ..rotateY(0.9),
                              ),
                              TransformModifier3D(
                                snapshot.data![2], // Sensorboard blue
                                Matrix4.identity()
                                  ..translate(-0.3, 19.5, 33.0)
                                  ..rotateY(1.5708)
                                  ..rotateX(-0.05)
                                  ..scale(1.8, 1.8, 1.8),
                              ),
                              TransformModifier3D(
                                snapshot.data![3], // Sensorboard yellow
                                Matrix4.identity()
                                  ..translate(-7.5, 18.5, 57.5)
                                  ..rotateY(1.5708)
                                  ..rotateX(-0.63)
                                  ..scale(1.8, 1.8, 1.8),
                              ),
                              TransformModifier3D(
                                snapshot.data![4], // Sensorboard purple
                                Matrix4.identity()
                                  ..translate(-0.5, 19.5, 20.0)
                                  ..rotateY(1.5708)
                                  ..rotateX(-0.05)
                                  ..scale(1.8, 1.8, 1.8),
                              ),
                              TransformModifier3D(
                                snapshot.data![5], // Sensorboard turquoise
                                Matrix4.identity()
                                  ..translate(-7.0, 18.0, 45.0)
                                  ..rotateY(1.5708)
                                  ..rotateX(-0.55)
                                  ..scale(1.8, 1.8, 1.8),
                              ),
                            ],
                            controller: _cameraController.controller,
                            config: const DiTreDiConfig(
                              defaultColorMesh: Colors.white,
                            ),
                          ),
                        ),
                        // Buttons positioned at top left
                        Positioned(
                          top: 30, // Abstand von oben
                          left: 20, // Abstand von links
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextButton(
                                onPressed: () => _navigateToPage(PageIndex.pbrs),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text("PBR"),
                              ),
                              TextButton(
                                onPressed: () => _navigateToPage(PageIndex.boards1),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.yellow,
                                ),
                                child: const Text("Sb1"),
                              ),
                              TextButton(
                                onPressed: () => _navigateToPage(PageIndex.boards2),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.teal,
                                ),
                                child: const Text("Sb2"),
                              ),
                              TextButton(
                                onPressed: () => _navigateToPage(PageIndex.boards3),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                ),
                                child: const Text("Sb3"),
                              ),
                              TextButton(
                                onPressed: () => _navigateToPage(PageIndex.boards4),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.purple,
                                ),
                                child: const Text("Sb4"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
          // Kamera-Steuerungsbuttons bleiben unverändert
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left),
                onPressed: () => _cameraController.rotateCamera(0, 0, -5),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_upward),
                onPressed: () => _cameraController.rotateCamera(5, 0, 0),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_downward),
                onPressed: () => _cameraController.rotateCamera(-5, 0, 0),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: () => _cameraController.rotateCamera(0, 0, 5),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _cameraController.zoomCamera(0.1),
              ),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => _cameraController.zoomCamera(-0.1),
              ),
              IconButton(
                icon: const Icon(Icons.restore),
                onPressed: () => _cameraController.resetCamera(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
