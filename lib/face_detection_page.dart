import 'package:arkit_plugin/arkit_plugin.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class FaceDetectionPage extends StatefulWidget {
  @override
  _FaceDetectionPageState createState() => _FaceDetectionPageState();
}

class _FaceDetectionPageState extends State<FaceDetectionPage> {
  late ARKitController arkitController;
  ARKitNode? node;

  ARKitNode? leftEye;
  ARKitNode? rightEye;
  ARKitNode? neck;

  @override
  void dispose() {
    arkitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Face Detection Sample')),
        body: Container(
          child: ARKitSceneView(
            configuration: ARKitConfiguration.faceTracking,
            onARKitViewCreated: onARKitViewCreated,
          ),
        ),
      );

  void onARKitViewCreated(ARKitController arkitController) {
    this.arkitController = arkitController;
    this.arkitController.onAddNodeForAnchor = _handleAddAnchor;
    this.arkitController.onUpdateNodeForAnchor = _handleUpdateAnchor;
  }

  void _handleAddAnchor(ARKitAnchor anchor) {
    if (!(anchor is ARKitFaceAnchor)) {
      return;
    }
    final material = ARKitMaterial(
      // fillMode: ARKitFillMode.lines,
      diffuse: ARKitMaterialProperty.image(
          'https://images.unsplash.com/photo-1663208841736-f7da2ec6703c?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=3028&q=80'),
    );
    anchor.geometry.materials.value = [material];

    node = ARKitNode(geometry: anchor.geometry);
    arkitController.add(node!, parentNodeName: anchor.nodeName);

    leftEye = _createEye(anchor.leftEyeTransform);
    arkitController.add(leftEye!, parentNodeName: anchor.nodeName);
    rightEye = _createEye(anchor.rightEyeTransform);
    arkitController.add(rightEye!, parentNodeName: anchor.nodeName);

    neck = _createNeck(anchor.transform);
    arkitController.add(neck!, parentNodeName: anchor.nodeName);
  }

  ARKitNode _createEye(Matrix4 transform) {
    final position = vector.Vector3(
      transform.getColumn(3).x,
      transform.getColumn(3).y,
      transform.getColumn(3).z,
    );
    final material = ARKitMaterial(
      diffuse: ARKitMaterialProperty.color(Colors.yellow),
    );
    final sphere = ARKitBox(
        materials: [material], width: 0.03, height: 0.03, length: 0.03);

    return ARKitNode(geometry: sphere, position: position);
  }

  void _handleUpdateAnchor(ARKitAnchor anchor) {
    if (anchor is ARKitFaceAnchor && mounted) {
      final faceAnchor = anchor;
      arkitController.updateFaceGeometry(node!, anchor.identifier);
      _updateEye(leftEye!, faceAnchor.leftEyeTransform,
          faceAnchor.blendShapes['eyeBlink_L'] ?? 0);
      _updateEye(rightEye!, faceAnchor.rightEyeTransform,
          faceAnchor.blendShapes['eyeBlink_R'] ?? 0);
    }
  }

  /// Create Neck from the face anchor
  ARKitNode _createNeck(Matrix4 transform) {
    final position = vector.Vector3(
      transform.getColumn(3).x,
      transform.getColumn(3).y - 0.35,
      transform.getColumn(3).z + 0.2,
    );
    final material = ARKitMaterial(
      diffuse: ARKitMaterialProperty.color(Colors.red),
    );
    final sphere = ARKitBox(
        materials: [material], width: 0.03, height: 0.03, length: 0.03);

    return ARKitNode(geometry: sphere, position: position);
  }

  void _updateEye(ARKitNode node, Matrix4 transform, double blink) {
    final scale = vector.Vector3(1, 1 - blink, 1);
    node.scale = scale;
  }
}
