import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/shot_anaylsis_model.dart';

abstract class ShotFirestoreDatasource {
  Future<String> saveShot(ShotAnalysisModel model);

  Future<void> deleteShot(String userId, String shotId);

  Future<int> getTodayNextSessionNumber(String userId, String todayDate);

  Future<void> deleteSession(String userId, String todayDate, int sessionNumber);
  Future<void> deleteAllSessionsForDate(String userId, String todayDate);

  Future<List<ShotAnalysisModel>> fetchShotsForUser(String userId,String todayDate);
  Future<List<ShotAnalysisModel>> fetchAllShotsForUser(String userId);

  Future<void> updateSessionFavorite({
    required String userUid,
    required String date,
    required int sessionNumber,
    required bool isFavorite,
  });
}

class ShotFirestoreDatasourceImpl implements ShotFirestoreDatasource {
  final FirebaseFirestore firestore;
  final String collectionName;

  ShotFirestoreDatasourceImpl(
      {FirebaseFirestore? firestore, this.collectionName = 'shots_analysis'})
      : firestore = firestore ?? FirebaseFirestore.instance;

  // @override
  // Future<String> saveShot(ShotAnalysisModel model) async {
  //   try {
  //     final existingShot = await firestore
  //         .collection(collectionName)
  //         .where('userUid', isEqualTo: model.userUid)
  //         .where('shotNumber', isEqualTo: model.shotNumber)
  //         .limit(1)
  //         .get();
  //
  //     if (existingShot.docs.isNotEmpty) {
  //       // ✅ Agar exist karta hai to UPDATE karen
  //       final docId = existingShot.docs.first.id;
  //       await firestore
  //           .collection(collectionName)
  //           .doc(docId)
  //           .update(model.toMap());
  //
  //       print("🔄 Shot #${model.shotNumber} updated with ID: $docId");
  //       return docId;
  //     } else {
  //       final docRef = await firestore
  //           .collection(collectionName)
  //           .add(model.toMap());
  //
  //       print("✅ New shot #${model.shotNumber} saved with ID: ${docRef.id}");
  //       return docRef.id;
  //     }
  //   } catch (e) {
  //     print("❌ Error saving shot: $e");
  //     rethrow;
  //   }
  // }

  @override
  Future<String> saveShot(ShotAnalysisModel model) async {
    try {
      final sessionDocRef = firestore
          .collection('users')
          .doc(model.userUid)
          .collection('sessions')
          .doc(model.date);

      await sessionDocRef.set({'exists': true}, SetOptions(merge: true));

      final shotsRef = sessionDocRef.collection('shots');

      final existingShot = await shotsRef
          .where('shotNumber', isEqualTo: model.shotNumber)
          .where('sessionNumber', isEqualTo: model.sessionNumber)
          .limit(1)
          .get();

      if (existingShot.docs.isNotEmpty) {
        final docId = existingShot.docs.first.id;
        await shotsRef.doc(docId).update(model.toMap());
        print("🔄 Shot updated with ID: $docId");
        return docId;
      } else {
        final docRef = await shotsRef.add(model.toMap());
        print("✅ New shot saved with ID: ${docRef.id}");
        return docRef.id;
      }
    } catch (e) {
      print("❌ Error saving shot: $e");
      rethrow;
    }
  }

  @override
  Future<int> getTodayNextSessionNumber(String userUid, String todayDate) async {
    final shotsRef = firestore
        .collection('users')
        .doc(userUid)
        .collection('sessions')
        .doc(todayDate)
        .collection('shots');

    final querySnap = await shotsRef.get();
    if (querySnap.docs.isEmpty) return 1;

    final sessionNumbers =
    querySnap.docs.map((d) => d['sessionNumber'] as int).toList();

    final maxSession = sessionNumbers.isEmpty ? 0 : sessionNumbers.reduce((a, b) => a > b ? a : b);
    return maxSession + 1;
  }

  @override
  Future<void> deleteShot(String userId, String shotId) async {
    // ✅ Direct collection se delete
    await firestore.collection(collectionName).doc(shotId).delete();
  }

  @override
  Future<List<ShotAnalysisModel>> fetchShotsForUser(
      String userUid,
      String todayDate,
      ) async {
    final shotsRef = firestore
        .collection('users')
        .doc(userUid)
        .collection('sessions')
        .doc(todayDate)
        .collection('shots');

    final querySnap = await shotsRef.orderBy('shotNumber').get();

    return querySnap.docs
        .map((d) => ShotAnalysisModel.fromMap(d.data(), d.id))
        .toList();
  }

  @override
  Future<void> deleteSession(
      String userUid,
      String date,
      int sessionNumber,
      ) async {

    final shotsRef = firestore
        .collection('users')
        .doc(userUid)
        .collection('sessions')
        .doc(date)
        .collection('shots');
    final querySnap = await shotsRef.where('sessionNumber', isEqualTo: sessionNumber).get();
    for (final doc in querySnap.docs) {
      await doc.reference.delete();
    }
  }
  @override
  Future<void> deleteAllSessionsForDate(String userUid, String date) async {
    final shotsCollection = firestore
        .collection('users')
        .doc(userUid)
        .collection('sessions')
        .doc(date)
        .collection('shots');

    final querySnap = await shotsCollection.get();

    int totalDeleted = 0;
    for (final shot in querySnap.docs) {
      await shot.reference.delete();
      totalDeleted++;
    }

    print("✅ Deleted total $totalDeleted shots for date $date ($userUid)");
  }
  @override
  Future<List<ShotAnalysisModel>> fetchAllShotsForUser(String userUid) async {

    final sessionCol = firestore
        .collection('users')
        .doc(userUid)
        .collection('sessions');

    final sessionDocs = await sessionCol.get();
    List<ShotAnalysisModel> allShots = [];

    for (var sessionDoc in sessionDocs.docs) {
      final date = sessionDoc.id;

      final shotsCol = sessionCol.doc(date).collection('shots');
      final shotsSnap = await shotsCol.get();

      allShots.addAll(
        shotsSnap.docs.map((d) {
          try {
            return ShotAnalysisModel.fromMap(d.data(), d.id);
          } catch (e) {
            print('Error parsing shot ${d.id}: $e');
            return null;
          }
        }).whereType<ShotAnalysisModel>().toList(),
      );
    }
    return allShots;
  }

  @override
  Future<void> updateSessionFavorite({
    required String userUid,
    required String date,
    required int sessionNumber,
    required bool isFavorite,
  }) async {
    final shotsRef = firestore
        .collection('users')
        .doc(userUid)
        .collection('sessions')
        .doc(date)
        .collection('shots');

    final query = await shotsRef
        .where('sessionNumber', isEqualTo: sessionNumber)
        .get();

    final batch = firestore.batch();

    for (final doc in query.docs) {
      batch.update(doc.reference, {
        'isFavorite': isFavorite,
      });
    }

    await batch.commit();

    print(
      '⭐ Session favorite updated → date=$date, session=$sessionNumber, fav=$isFavorite',
    );
  }
}
