import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection names
  static const String _documentsCollection = 'documents';
  static const String _transactionsCollection = 'transactions';
  static const String _evidenceCollection = 'evidence';
  static const String _usersCollection = 'users';

  // Document operations
  Future<void> saveDocument({
    required String fileName,
    required String downloadURL,
    required String uploadedBy,
    Map<String, dynamic>? metadata,
  }) async {
    await _firestore.collection(_documentsCollection).add({
      'fileName': fileName,
      'downloadURL': downloadURL,
      'uploadedBy': uploadedBy,
      'uploadedAt': FieldValue.serverTimestamp(),
      'metadata': metadata ?? {},
    });
  }

  Stream<QuerySnapshot> getDocuments() {
    return _firestore
        .collection(_documentsCollection)
        .orderBy('uploadedAt', descending: true)
        .snapshots();
  }

  Future<List<Map<String, dynamic>>> getDocumentsList() async {
    final snapshot = await _firestore
        .collection(_documentsCollection)
        .orderBy('uploadedAt', descending: true)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // Transaction operations
  Future<void> saveTransaction({
    required String type,
    required double amount,
    required String userId,
    Map<String, dynamic>? additionalData,
  }) async {
    await _firestore.collection(_transactionsCollection).add({
      'type': type,
      'amount': amount,
      'userId': userId,
      'timestamp': FieldValue.serverTimestamp(),
      'additionalData': additionalData ?? {},
    });
  }

  Stream<QuerySnapshot> getTransactions() {
    return _firestore
        .collection(_transactionsCollection)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Evidence operations
  Future<void> saveEvidence({
    required String title,
    required String description,
    required List<String> fileURLs,
    required String userId,
    Map<String, dynamic>? location,
  }) async {
    await _firestore.collection(_evidenceCollection).add({
      'title': title,
      'description': description,
      'fileURLs': fileURLs,
      'userId': userId,
      'location': location,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getEvidence() {
    return _firestore
        .collection(_evidenceCollection)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // User operations
  Future<void> saveUser({
    required String userId,
    required String name,
    required String email,
    Map<String, dynamic>? additionalData,
  }) async {
    await _firestore.collection(_usersCollection).doc(userId).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
      'additionalData': additionalData ?? {},
    }, SetOptions(merge: true));
  }

  Future<DocumentSnapshot> getUser(String userId) {
    return _firestore.collection(_usersCollection).doc(userId).get();
  }

  // File upload helpers
  Future<String> uploadFile({
    required String path,
    required List<int> bytes,
    required String fileName,
  }) async {
    final ref = _storage.ref().child(path).child(fileName);
    await ref.putData(bytes as Uint8List);
    return await ref.getDownloadURL();
  }

  // Real-time listeners helpers
  void listenToDocuments(Function(List<Map<String, dynamic>>) onUpdate) {
    getDocuments().listen((snapshot) {
      final docs = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
      onUpdate(docs);
    });
  }

  void listenToTransactions(Function(List<Map<String, dynamic>>) onUpdate) {
    getTransactions().listen((snapshot) {
      final transactions = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
      onUpdate(transactions);
    });
  }

  void listenToEvidence(Function(List<Map<String, dynamic>>) onUpdate) {
    getEvidence().listen((snapshot) {
      final evidence = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
      onUpdate(evidence);
    });
  }
}
