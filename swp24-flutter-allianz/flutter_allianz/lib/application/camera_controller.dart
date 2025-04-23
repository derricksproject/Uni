import 'package:ditredi/ditredi.dart';

/// A controller that manages the camera's rotation, zoom, and reset functionalities.
///
/// This class uses the `DiTreDiController` from the `ditredi` package to handle camera 
/// manipulation such as rotation, zooming, and resetting the camera position.
///
/// **Author**: Gagan Lal.
class CameraController {
  late final DiTreDiController _controller;

  CameraController() 
    : _controller = DiTreDiController(
        rotationX: -100,
        rotationY: 0,
        rotationZ: 50,
        lightStrength: 0.75,
      );

  DiTreDiController get controller => _controller;

  /// Rotates the camera by the specified X, Y, and Z angles.
  ///
  /// **Parameters**:
  /// - `dx`: The change in rotation along the X-axis.
  /// - `dy`: The change in rotation along the Y-axis.
  /// - `dz`: The change in rotation along the Z-axis.
  void rotateCamera(double dx, double dy, double dz) {
      _controller.rotationX += dx;
      _controller.rotationY += dy;
      _controller.rotationZ += dz;
  }

  /// Zooms the camera in or out by the specified delta.
  ///
  /// **Parameters**:
  /// - `delta`: The amount to zoom in or out. Positive values zoom in, negative values zoom out.
  void zoomCamera(double delta) {
      _controller.update(userScale: _controller.userScale + delta );
  }

  /// Resets the camera to its default position and scale.
  void resetCamera() {
      _controller.update(
        rotationX: -110,
        rotationY: 0,
        rotationZ: 50,
        lightStrength: 0.75,
        userScale: 1.3,
        );
  }
}