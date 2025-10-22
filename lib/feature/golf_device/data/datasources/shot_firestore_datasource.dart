import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/shot_anaylsis_model.dart';

abstract class ShotFirestoreDatasource {
  Future<String> saveShot(ShotAnalysisModel model);
  Future<void> deleteShot(String userId, String shotId);
  Future<void> deleteAllShotsForUser(String userId);
  Future<List<ShotAnalysisModel>> fetchShotsForUser(String userId, {int limit = 100});
}

class ShotFirestoreDatasourceImpl implements ShotFirestoreDatasource {
  final FirebaseFirestore firestore;
  final String collectionName;

  ShotFirestoreDatasourceImpl({FirebaseFirestore? firestore, this.collectionName = 'shots_analysis'})
      : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<String> saveShot(ShotAnalysisModel model) async {
    try {
      final existingShot = await firestore
          .collection(collectionName)
          .where('userUid', isEqualTo: model.userUid)
          .where('shotNumber', isEqualTo: model.shotNumber)
          .limit(1)
          .get();

      if (existingShot.docs.isNotEmpty) {
        // ✅ Agar exist karta hai to UPDATE karen
        final docId = existingShot.docs.first.id;
        await firestore
            .collection(collectionName)
            .doc(docId)
            .update(model.toMap());

        print("🔄 Shot #${model.shotNumber} updated with ID: $docId");
        return docId;
      } else {
        final docRef = await firestore
            .collection(collectionName)
            .add(model.toMap());

        print("✅ New shot #${model.shotNumber} saved with ID: ${docRef.id}");
        return docRef.id;
      }
    } catch (e) {
      print("❌ Error saving shot: $e");
      rethrow;
    }
  }

  @override
  Future<void> deleteShot(String userId, String shotId) async {
    // ✅ Direct collection se delete
    await firestore
        .collection(collectionName)
        .doc(shotId)
        .delete();
  }

  Future<List<ShotAnalysisModel>> fetchShotsForUser(String userUid,
      {int limit = 100}) async {
    // final querySnap = await firestore
    //     .collection(collectionName)
    //     .where('userUid', isEqualTo: userUid)
    //     .orderBy('timestamp', descending: true)
    //     .limit(limit)
    //     .get();

    final querySnap = await firestore
        .collection(collectionName)
        .where('userUid', isEqualTo: userUid)
        .orderBy('shotNumber',)
        .get();
    print("📊 Fetched ${querySnap.docs.length} shots for user: $userUid");

    return querySnap.docs
        .map((d) => ShotAnalysisModel.fromMap(d.data(), d.id))
        .toList();
  }

  @override
  Future<void> deleteAllShotsForUser(String userUid) async {
    final collection = firestore.collection('shots_analysis');
    final snapshots = await collection.where('userUid', isEqualTo: userUid).get();

    for (final doc in snapshots.docs) {
      await doc.reference.delete();
    }
    print("✅ Deleted ${snapshots.docs.length} shots for user $userUid");
  }

}
