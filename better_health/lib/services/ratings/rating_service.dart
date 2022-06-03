import 'package:better_health/utils/custom_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RatingService {
  static Future addRating(double rating, String doctorID, String date, String month) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final snapshots = await FirebaseFirestore.instance.collection('schedules')
      .where('doctorID', isEqualTo: doctorID)
      .where('patientID', isEqualTo: user!.uid)
      .where('date', isEqualTo: date)
      .where('month', isEqualTo: month).get();

      final userData = await FirebaseFirestore.instance.collection('users').doc(doctorID).get();
      final processedUserData = userData.data() as Map<String, dynamic>;

      double finalRating = (processedUserData['rating'] + rating) / 2;

      for(var s in snapshots.docs) {
        String documentID = s.reference.id;
        await FirebaseFirestore.instance.collection('schedules').doc(documentID).update({
          'rating': rating
        });

        await FirebaseFirestore.instance.collection('users').doc(doctorID).update({
          'rating': finalRating
        });
      }
    } on FirebaseAuthException catch (e) {
      throw CustomException(e.message);
    }
  }
}