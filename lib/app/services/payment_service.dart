import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/payment.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createPayment(Payment payment) async {
    try {
      // Start a batch write
      final batch = _firestore.batch();
      
      // Add the payment document
      final paymentRef = _firestore.collection('payments').doc();
      batch.set(paymentRef, payment.toMap());
      
      // Update product availability
      final productRef = _firestore.collection('products').doc(payment.productId);
      batch.update(productRef, {
        'isAvailable': false,
        'currentRenter': payment.userId,
        'lastRentDate': payment.rentDate,
      });

      // Commit the batch
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  Future<List<Payment>> getUserPayments() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final snapshot = await _firestore
          .collection('payments')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Payment.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user payments: $e');
    }
  }

  Future<void> cancelPayment(String paymentId, String productId) async {
    try {
      final batch = _firestore.batch();
      
      // Update payment status
      final paymentRef = _firestore.collection('payments').doc(paymentId);
      batch.update(paymentRef, {'status': 'cancelled'});
      
      // Update product availability
      final productRef = _firestore.collection('products').doc(productId);
      batch.update(productRef, {
        'isAvailable': true,
        'currentRenter': null,
        'lastRentDate': null,
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to cancel payment: $e');
    }
  }
}